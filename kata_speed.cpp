#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <sstream>
#include <string>
#include <stdexcept>
#include <chrono>
#include <thread>
#include <fstream>
#include <cstdio>    // For std::FILE
#include <algorithm> // For std::remove
#include <unistd.h>  // For POSIX compatibility
#include <sys/types.h>

const int BOARD_SIZE = 9;

enum class Stone { EMPTY, BLACK, WHITE };

class Board {
private:
    Stone board[BOARD_SIZE][BOARD_SIZE];

public:
    Board() {
        // Initialize the board with empty stones
        for (int i = 0; i < BOARD_SIZE; ++i) {
            for (int j = 0; j < BOARD_SIZE; ++j) {
                board[i][j] = Stone::EMPTY;
            }
        }
    }

    Stone getStone(int x, int y) const {
        return board[x][y];
    }

    void setStone(int x, int y, Stone stone) {
        board[x][y] = stone;
    }

    bool isOnBoard(int x, int y) const {
        return x >= 0 && x < BOARD_SIZE && y >= 0 && y < BOARD_SIZE;
    }

    bool isEmpty(int x, int y) const {
        return board[x][y] == Stone::EMPTY;
    }

    bool isSameColor(int x, int y, Stone stone) const {
        return board[x][y] == stone;
    }

    // Methods for checking liberties, capturing stones, etc. can be added here
};

class Game {
private:
    Board board;
    Stone currentPlayer;

public:
    Game() : currentPlayer(Stone::BLACK) {}

    void placeStone(int x, int y, Stone stone) {
        board.setStone(x, y, stone);
        currentPlayer = (currentPlayer == Stone::BLACK) ? Stone::WHITE : Stone::BLACK;
    }

    bool isLegalMove(int x, int y, Stone stone) const {
        // Check if the position is within bounds and empty
        return board.isOnBoard(x, y) && board.isEmpty(x, y);
    }

    bool isGameOver() const {
        // Game over if the board is full or other end-game conditions are met
        return boardIsFull();
    }

    Board getBoard() const {
        return board;
    }

    Stone getCurrentPlayer() const {
        return currentPlayer;
    }

private:
    bool boardIsFull() const {
        for (int i = 0; i < BOARD_SIZE; ++i) {
            for (int j = 0; j < BOARD_SIZE; ++j) {
                if (board.getStone(i, j) == Stone::EMPTY) {
                    return false;
                }
            }
        }
        return true;
    }

    // Additional game logic methods can be added here
};

class GTPHandler {
private:
    Game& game;

public:
    GTPHandler(Game& g) : game(g) {}

    void handleCommand(const std::string& command) {
        std::istringstream iss(command);
        std::string cmd;
        iss >> cmd;

        if (cmd == "protocol_version") {
            handleProtocolVersion();
        } else if (cmd == "name") {
            handleName();
        } else if (cmd == "version") {
            handleVersion();
        } else if (cmd == "list_commands") {
            handleListCommands();
        } else if (cmd == "boardsize") {
            handleBoardSizeCommand(iss);
        } else if (cmd == "clear_board") {
            handleClearBoardCommand();
        } else if (cmd == "play") {
            handlePlayCommand(iss);
        } else if (cmd == "genmove") {
            handleGenmoveCommand();
        } else if (cmd == "quit") {
            handleQuitCommand();
        } else if (cmd == "known_command") {
            handleKnownCommand(iss);
        } else if (cmd == "board_status") {
            handleBoardStatusCommand();
        } else if (cmd == "time_settings") {
            handleTimeSettingsCommand(iss);
        } else if (cmd == "time_left") {
            handleTimeLeftCommand(iss);
        } else if (cmd == "final_score") {
            handleFinalScoreCommand();
        } else if (cmd == "undo") {
            handleUndoCommand();
        } else {
            std::cerr << "? unknown command" << std::endl;
        }
    }

private:
    // Command handlers
    void handleProtocolVersion() {
        std::cout << "= 2" << std::endl;
    }

    void handleName() {
        std::cout << "= SimpleGoBot" << std::endl;
    }

    void handleVersion() {
        std::cout << "= 1.0" << std::endl;
    }

    void handleListCommands() {
        std::cout << "= protocol_version\n"
                     "name\n"
                     "version\n"
                     "list_commands\n"
                     "boardsize\n"
                     "clear_board\n"
                     "play\n"
                     "genmove\n"
                     "quit\n"
                     "known_command\n"
                     "board_status\n"
                     "time_settings\n"
                     "time_left\n"
                     "final_score\n"
                     "undo\n" << std::endl;
    }

    void handleBoardSizeCommand(std::istringstream& iss) {
        int size;
        iss >> size;
        if (size != BOARD_SIZE) {
            std::cerr << "? unacceptable size" << std::endl;
        } else {
            std::cout << "= " << size << std::endl;
        }
    }

    void handleClearBoardCommand() {
        game = Game();
        std::cout << "=" << std::endl;
    }

    void handlePlayCommand(std::istringstream& iss) {
        std::string color, move;
        iss >> color >> move;
        Stone stone;
        try {
            stone = parseStone(color);
        } catch (const std::invalid_argument& e) {
            std::cerr << "? invalid color" << std::endl;
            return;
        }

        int x = move[0] - 'a';
        int y = BOARD_SIZE - (move[1] - '0');

        if (!boardCoordinatesValid(x, y)) {
            std::cerr << "? out of board bounds" << std::endl;
            return;
        }

        if (!game.isLegalMove(x, y, stone)) {
            std::cerr << "? illegal move" << std::endl;
            return;
        }

        game.placeStone(x, y, stone);
        std::cout << "=" << std::endl;
    }

    void handleGenmoveCommand() {
        // Command KataGo for a move
        std::string command = "kataspeed gtp -config C:\\Users\\chang\\Downloads\\katago-v1.14.1-opencl-windows-x64\\golaxy_9d.cfg -model C:\\Users\\chang\\Downloads\\kata1-b28c512nbt-s7168446720-d4316919285.bin.gz genmove ";
        command += (game.getCurrentPlayer() == Stone::BLACK) ? "black" : "white";

        // Execute KataGo command
        std::string kataGoMove = executeKataGoCommand(command);

        // Parse KataGo's response and make the move
        int x = kataGoMove[0] - 'a';
        int y = BOARD_SIZE - (kataGoMove[1] - '0');

        if (!boardCoordinatesValid(x, y)) {
            std::cerr << "? KataGo returned an invalid move" << std::endl;
            return;
        }

        if (!game.isLegalMove(x, y, game.getCurrentPlayer())) {
            std::cerr << "? KataGo returned an illegal move" << std::endl;
            return;
        }

        game.placeStone(x, y, game.getCurrentPlayer());
        std::cout << "= " << kataGoMove << std::endl;
    }

    void handleQuitCommand() {
        std::cout << "=" << std::endl;
        exit(0); // Exit the program
    }

    void handleKnownCommand(std::istringstream& iss) {
        std::string cmd;
        iss >> cmd;
        if (cmd == "protocol_version" || cmd == "name" || cmd == "version" ||
            cmd == "list_commands" || cmd == "boardsize" || cmd == "clear_board" ||
            cmd == "play" || cmd == "genmove" || cmd == "quit" || cmd == "known_command" ||
            cmd == "board_status" || cmd == "time_settings" || cmd == "time_left" ||
            cmd == "final_score" || cmd == "undo") {
            std::cout << "= true" << std::endl;
        } else {
            std::cout << "= false" << std::endl;
        }
    }

    void handleBoardStatusCommand() {
        // Implement board status reporting (optional for simplicity)
        std::cout << "= " << std::endl;
    }

    void handleTimeSettingsCommand(std::istringstream& iss) {
        // Implement time settings handling (optional for simplicity)
        std::
