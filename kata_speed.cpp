#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <sstream>
#include <string>

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

    // Add methods for checking liberties, capturing stones, etc.
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
        // Simplified check for empty position
        return (board.getStone(x, y) == Stone::EMPTY);
    }

    bool isGameOver() const {
        // Simplified: Game is over if board is full
        for (int i = 0; i < BOARD_SIZE; ++i) {
            for (int j = 0; j < BOARD_SIZE; ++j) {
                if (board.getStone(i, j) == Stone::EMPTY) {
                    return false;
                }
            }
        }
        return true;
    }

    Board getBoard() const {
        return board;
    }

    Stone getCurrentPlayer() const {
        return currentPlayer;
    }
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
            std::cout << "= 2" << std::endl;
        } else if (cmd == "name") {
            std::cout << "= SimpleGoBot" << std::endl;
        } else if (cmd == "version") {
            std::cout << "= 1.0" << std::endl;
        } else if (cmd == "list_commands") {
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
                         "quit\n"
                         "board_status\n"
                         "time_settings\n"
                         "time_left\n"
                         "final_score\n"
                         "undo\n" << std::endl;
        } else if (cmd == "boardsize") {
            handleBoardSizeCommand(iss);
        } else if (cmd == "clear_board") {
            handleClearBoardCommand();
        } else if (cmd == "play") {
            handlePlayCommand(iss);
        } else if (cmd == "genmove") {
            handleGenmoveCommand(iss);
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
        Stone stone = (color == "black") ? Stone::BLACK : Stone::WHITE;
        int x = move[0] - 'a';
        int y = BOARD_SIZE - (move[1] - '0');
        if (game.isLegalMove(x, y, stone)) {
            game.placeStone(x, y, stone);
            std::cout << "=" << std::endl;
        } else {
            std::cerr << "? illegal move" << std::endl;
        }
    }

    void handleGenmoveCommand(std::istringstream& iss) {
        std::string color;
        iss >> color;
        Stone stone = (color == "black") ? Stone::BLACK : Stone::WHITE;

        // Simple bot's move (random for now)
        int x, y;
        do {
            x = rand() % BOARD_SIZE;
            y = rand() % BOARD_SIZE;
        } while (!game.isLegalMove(x, y, stone));

        game.placeStone(x, y, stone);
        std::cout << "= " << static_cast<char>('a' + x) << BOARD_SIZE - y << std::endl;
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
        // Could include board position, current player, etc.
        std::cout << "= " << std::endl;
    }

    void handleTimeSettingsCommand(std::istringstream& iss) {
        // Implement time settings handling (optional for simplicity)
        // Could include time control details
        std::cout << "=" << std::endl;
    }

    void handleTimeLeftCommand(std::istringstream& iss) {
        // Implement time left reporting (optional for simplicity)
        // Could include time remaining for each player
        std::cout << "= " << std::endl;
    }

    void handleFinalScoreCommand() {
        // Implement final score reporting (optional for simplicity)
        // Could include final game result (win/loss/draw) and scores
        std::cout << "= " << std::endl;
    }

    void handleUndoCommand() {
        // Implement undo command handling (optional for simplicity)
        // Could support undoing the last move
        std::cout << "= " << std::endl;
    }
};

int main() {
    srand(static_cast<unsigned int>(time(nullptr))); // Seed for random number generation

    Game game;
    GTPHandler gtp(game);

    std::string command;
    while (std::getline(std::cin, command)) {
        gtp.handleCommand(command);
    }

    return 0;
}
