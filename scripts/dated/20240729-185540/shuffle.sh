#!/bin/bash -eu
set -o pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 BASEDIR TMPDIR NTHREADS BATCHSIZE"
    echo "Currently expects to be run from within the 'python' directory of the KataGo repo, or otherwise in the same dir as shuffle.py."
    echo "BASEDIR containing selfplay data and models and related directories"
    echo "TMPDIR scratch space, ideally on fast local disk, unique to this loop"
    echo "NTHREADS number of parallel threads/processes to use in shuffle"
    echo "BATCHSIZE number of samples to concat together per batch for training"
    exit 1
fi

BASEDIR="$1"
shift
TMPDIR="$1"
shift
NTHREADS="$1"
shift
BATCHSIZE="$1"
shift

OUTDIR=$(date "+%Y%m%d-%H%M%S")
OUTDIRTRAIN=$OUTDIR/train
OUTDIRVAL=$OUTDIR/val

mkdir -p "$BASEDIR"/shuffleddata/$OUTDIR
mkdir -p "$TMPDIR"/train
mkdir -p "$TMPDIR"/val

echo "Beginning shuffle at" $(date "+%Y-%m-%d %H:%M:%S")

if [[ -n "${SKIP_VALIDATE:-}" ]]; then
    (
        time python3 C:/Users/chang/OneDrive/Documents/GitHub/Kata_speed/python/shuffle.py \
            "$BASEDIR"/selfplay/ \
            -expand-window-per-row 0.4 \
            -taper-window-exponent 0.65 \
            -out-dir "$BASEDIR"/shuffleddata/$OUTDIRTRAIN \
            -out-tmp-dir "$TMPDIR"/train \
            -approx-rows-per-out-file 70000 \
            -num-processes "$NTHREADS" \
            -batch-size "$BATCHSIZE" \
            -only-include-md5-path-prop-lbound 0.00 \
            -only-include-md5-path-prop-ubound 1.00 \
            -output-npz \
            "$@" \
            2>&1 | tee "$BASEDIR"/shuffleddata/$OUTDIR/outtrain.txt &
        wait
    )
else
    (
        time python3 C:/Users/chang/OneDrive/Documents/GitHub/Kata_speed/python/shuffle.py \
            "$BASEDIR"/selfplay/ \
            -expand-window-per-row 0.4 \
            -taper-window-exponent 0.65 \
            -out-dir "$BASEDIR"/shuffleddata/$OUTDIRVAL \
            -out-tmp-dir "$TMPDIR"/val \
            -approx-rows-per-out-file 70000 \
            -num-processes "$NTHREADS" \
            -batch-size "$BATCHSIZE" \
            -only-include-md5-path-prop-lbound 0.95 \
            -only-include-md5-path-prop-ubound 1.00 \
            -output-npz \
            "$@" \
            2>&1 | tee "$BASEDIR"/shuffleddata/$OUTDIR/outval.txt &
        wait
    )
    (
        time python3 C:/Users/chang/OneDrive/Documents/GitHub/Kata_speed/python/shuffle.py \
            "$BASEDIR"/selfplay/ \
            -expand-window-per-row 0.4 \
            -taper-window-exponent 0.65 \
            -out-dir "$BASEDIR"/shuffleddata/$OUTDIRTRAIN \
            -out-tmp-dir "$TMPDIR"/train \
            -approx-rows-per-out-file 70000 \
            -num-processes "$NTHREADS" \
            -batch-size "$BATCHSIZE" \
            -only-include-md5-path-prop-lbound 0.00 \
            -only-include-md5-path-prop-ubound 0.95 \
            -output-npz \
            "$@" \
            2>&1 | tee "$BASEDIR"/shuffleddata/$OUTDIR/outtrain.txt &
        wait
    )
fi

# Just in case, give a little time for nfs
sleep 10

# Cleanup
echo "Cleaning up any old dirs"
find "$BASEDIR"/shuffleddata/ -mindepth 1 -maxdepth 1 -type d -exec sh -c '
    for d; do
        if [ "$(ls -A "$d")" ]; then
            # Count subdirectories
            count=$(find "$d" -mindepth 1 -maxdepth 1 -type d | wc -l)
            if [ "$count" -gt 5 ]; then
                echo "Removing $d"
                rm -rf "$d"
            fi
        fi
    done
' sh {} +

echo "Finished shuffle at" $(date "+%Y-%m-%d %H:%M:%S")
