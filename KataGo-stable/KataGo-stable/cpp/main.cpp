#include "main.h"

#include "core/os.h"
#include "core/mainargs.h"

#ifdef NO_GIT_REVISION
#define GIT_REVISION "<omitted>"
#else
#include "program/gitinfo.h"
#endif

#include <sstream>
#include <iostream>

// Include necessary headers
#include "core/using.h"

// Print help information
static void printHelp(const std::vector<std::string>& args) {
    std::cout << std::endl;
    if (args.size() >= 1)
        std::cout << "Usage: " << args[0] << " SUBCOMMAND ";
    else
        std::cout << "Usage: ./kata_speed SUBCOMMAND ";
    std::cout << std::endl;

    std::cout << R"%%(
---Common subcommands------------------

gtp : Runs GTP engine that can be plugged into any standard Go GUI for play/analysis.
benchmark : Test speed with different numbers of search threads.
genconfig : User-friendly interface to generate a config with rules and automatic performance tuning.

version : Print version and exit.

)%%" << std::endl;
}

// Handle subcommands
static int handleSubcommand(const std::string& subcommand, const std::vector<std::string>& args) {
    std::vector<std::string> subArgs(args.begin() + 1, args.end());
    if (subcommand == "gtp")
        return MainCmds::gtp(subArgs);
    if (subcommand == "benchmark")
        return MainCmds::benchmark(subArgs);
    if (subcommand == "genconfig")
        return MainCmds::genconfig(subArgs, args[0]);
    if (subcommand == "version") {
        std::cout << Version::getKataGoVersionFullInfo() << std::flush;
        return 0;
    }
    std::cout << "Unknown subcommand: " << subcommand << std::endl;
    printHelp(args);
    return 1;
}

int main(int argc, const char* const* argv) {
    std::vector<std::string> args = MainArgs::getCommandLineArgsUTF8(argc, argv);
    MainArgs::makeCoutAndCerrAcceptUTF8();

    if (args.size() < 2) {
        printHelp(args);
        return 0;
    }

    std::string cmdArg = std::string(args[1]);
    if (cmdArg == "-h" || cmdArg == "--h" || cmdArg == "-help" || cmdArg == "--help" || cmdArg == "help") {
        printHelp(args);
        return 0;
    }

    // Handle exceptions on Windows
#if defined(OS_IS_WINDOWS)
    int result;
    try {
        result = handleSubcommand(cmdArg, args);
    }
    catch (std::exception& e) {
        std::cerr << "Uncaught exception: " << e.what() << std::endl;
        return 1;
    }
    catch (...) {
        std::cerr << "Uncaught exception that is not a std::exception... exiting due to unknown error" << std::endl;
        return 1;
    }
    return result;
#else
    return handleSubcommand(cmdArg, args);
#endif
}

// Version information
string Version::getKataGoVersion() {
    return string("Kata_speed v1.0.0");
}

string Version::getKataGoVersionForHelp() {
    return string("Kata_speed v1.0.0");
}

string Version::getKataGoVersionFullInfo() {
    std::ostringstream out;
    out << Version::getKataGoVersionForHelp() << std::endl;
    out << "Git revision: " << Version::getGitRevision() << std::endl;
    out << "Compile Time: " << __DATE__ << " " << __TIME__ << std::endl;
    return out.str();
}

string Version::getGitRevision() {
    return string(GIT_REVISION);
}
