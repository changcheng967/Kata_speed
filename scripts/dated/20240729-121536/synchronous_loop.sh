#!/bin/bash -eu
set -o pipefail
{

# Runs the entire self-play process synchronously in a loop, training a single size of neural net appropriately.
# Assumes you have the katago executable in the specified directory.

if [[ $# -lt 5 ]]
then
    echo "Usage: $0 NAMEPREFIX BASEDIR TRAININGNAME MODELKIND USEGATING"
    exit 0
fi
NAMEPREFIX="$1"
shift
BASEDIRRAW="$1"
shift
TRAININGNAME="$1"
shift
MODELKIND="$1"
shift
USEGATING="$1"
shift

BASEDIR="$(realpath "$BASEDIRRAW")"
GITROOTDIR="$(git rev-parse --show-toplevel)"
LOGSDIR="$BASEDIR"/logs
SCRATCHDIR="$BASEDIR"/shufflescratch

# Create all the directories we need
mkdir -p "$BASEDIR"
mkdir -p "$LOGSDIR"
mkdir -p "$SCRATCHDIR"
mkdir -p "$BASEDIR"/selfplay
mkdir -p "$BASEDIR"/gatekeepersgf

# Parameters for the training run
NUM_GAMES_PER_CYCLE=50
NUM_THREADS_FOR_SHUFFLING=8
NUM_TRAIN_SAMPLES_PER_EPOCH=100000
MAX_TRAIN_PER_DATA=8
NUM_TRAIN_SAMPLES_PER_SWA=80000
BATCHSIZE=128
SHUFFLE_MINROWS=100000
MAX_TRAIN_SAMPLES_PER_CYCLE=500000
TAPER_WINDOW_SCALE=50000
SHUFFLE_KEEPROWS=600000

SELFPLAY_CONFIG="$GITROOTDIR"/cpp/configs/training/selfplay1.cfg
GATING_CONFIG="$GITROOTDIR"/cpp/configs/training/gatekeeper1.cfg

# Copy all the relevant scripts and configs and the katago executable to a dated directory.
DATE_FOR_FILENAME=$(date "+%Y%m%d-%H%M%S")
DATED_ARCHIVE="$BASEDIR"/scripts/dated/"$DATE_FOR_FILENAME"
mkdir -p "$DATED_ARCHIVE"
cp "$GITROOTDIR"/python/*.py "$GITROOTDIR"/python/selfplay/*.sh "$DATED_ARCHIVE"
cp "$GITROOTDIR"/cpp/katago "$DATED_ARCHIVE"/katago.exe
cp "$SELFPLAY_CONFIG" "$DATED_ARCHIVE"/selfplay.cfg
cp "$GATING_CONFIG" "$DATED_ARCHIVE"/gatekeeper.cfg
git show --no-patch --no-color > "$DATED_ARCHIVE"/version.txt
git diff --no-color > "$DATED_ARCHIVE"/diff.txt
git diff --staged --no-color > "$DATED_ARCHIVE"/diffstaged.txt

# Also run the code out of the archive, so that we don't unexpectedly crash or change behavior if the local repo changes.
cd "$DATED_ARCHIVE"

# Begin cycling forever, running each step in order.
set -x
while true
do
    echo "Gatekeeper"
    time ./katago.exe gatekeeper -rejected-models-dir "$BASEDIR"/rejectedmodels -accepted-models-dir "$BASEDIR"/models/ -sgf-output-dir "$BASEDIR"/gatekeepersgf/ -test-models-dir "$BASEDIR"/modelstobetested/ -config "$DATED_ARCHIVE"/gatekeeper.cfg -quit-if-no-nets-to-test | tee -a "$BASEDIR"/gatekeepersgf/stdout.txt

    echo "Selfplay"
    time ./katago.exe selfplay -max-games-total "$NUM_GAMES_PER_CYCLE" -output-dir "$BASEDIR"/selfplay -models-dir "$BASEDIR"/models -config "$DATED_ARCHIVE"/selfplay.cfg | tee -a "$BASEDIR"/selfplay/stdout.txt

    echo "Shuffle"
    (
        time SKIP_VALIDATE=1 ./shuffle.sh "$BASEDIR" "$SCRATCHDIR" "$NUM_THREADS_FOR_SHUFFLING" "$BATCHSIZE" -min-rows "$SHUFFLE_MINROWS" -keep-target-rows "$SHUFFLE_KEEPROWS" -taper-window-scale "$TAPER_WINDOW_SCALE" | tee -a "$BASEDIR"/logs/outshuffle.txt
    )

    echo "Train"
    time ./train.sh "$BASEDIR" "$TRAININGNAME" "$MODELKIND" "$BATCHSIZE" main -samples-per-epoch "$NUM_TRAIN_SAMPLES_PER_EPOCH" -swa-period-samples "$NUM_TRAIN_SAMPLES_PER_SWA" -quit-if-no-data -stop-when-train-bucket-limited -no-repeat-files -max-train-bucket-per-new-data "$MAX_TRAIN_PER_DATA" -max-train-bucket-size "$MAX_TRAIN_SAMPLES_PER_CYCLE"

    echo "Export"
    (
        time ./export_model_for_selfplay.sh "$NAMEPREFIX" "$BASEDIR" "$USEGATING" | tee -a "$BASEDIR"/logs/outexport.txt
    )

done

exit 0
}
