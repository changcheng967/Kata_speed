#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <sstream>
#include <string>
#include <stdexcept> // For std::invalid_argument
#include <unordered_map>
#include <functional>

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
        if (!isLegalMove(x, y, stone)) {
            throw std::runtime_error("Illegal move");
        }

        board.setStone(x, y, stone);
        currentPlayer = (currentPlayer == Stone::BLACK) ? Stone::WHITE : Stone::BLACK;
    }

    bool isLegalMove(int x, int y, Stone stone) const {
        return board.isOnBoard(x, y) && board.isEmpty(x, y);
    }

    bool isGameOver() const {
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
    std::unordered_map<std::string, std::function<void(std::istringstream&)>> commandHandlers;

public:
    GTPHandler(Game& g) : game(g) {
        commandHandlers = {
            {"protocol_version", [this](std::istringstream& iss){ handleProtocolVersion(); }},
            {"name", [this](std::istringstream& iss){ handleName(); }},
            {"version", [this](std::istringstream& iss){ handleVersion(); }},
            {"list_commands", [this](std::istringstream& iss){ handleListCommands(); }},
            {"boardsize", [this](std::istringstream& iss){ handleBoardSizeCommand(iss); }},
            {"clear_board", [this](std::istringstream& iss){ handleClearBoardCommand(); }},
            {"play", [this](std::istringstream& iss){ handlePlayCommand(iss); }},
            {"genmove", [this](std::istringstream& iss){ handleGenmoveCommand(iss); }},
            {"quit", [this](std::istringstream& iss){ handleQuitCommand(); }},
            {"known_command", [this](std::istringstream& iss){ handleKnownCommand(iss); }},
            {"board_status", [this](std::istringstream& iss){ handleBoardStatusCommand(); }},
            {"time_settings", [this](std::istringstream& iss){ handleTimeSettingsCommand(iss); }},
            {"time_left", [this](std::istringstream& iss){ handleTimeLeftCommand(iss); }},
            {"final_score", [this](std::istringstream& iss){ handleFinalScoreCommand(); }},
            {"undo", [this](std::istringstream& iss){ handleUndoCommand(); }}
        };
    }

    void handleCommand(const std::string& command) {
        std::istringstream iss(command);
        std::string cmd;
        iss >> cmd;

        auto it = commandHandlers.find(cmd);
        if (it != commandHandlers.end()) {
            it->second(iss);
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
        if (!(iss >> color >> move)) {
            std::cerr << "? syntax error" << std::endl;
            return;
        }

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

    void handleGenmoveCommand(std::istringstream& iss) {
        std::string color;
        iss >> color;
        Stone stone;
        try {
            stone = parseStone(color);
        } catch (const std::invalid_argument& e) {
            std::cerr << "? invalid color" << std::endl;
            return;
        }

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
        std::cout << "= " << std::endl;
    }

    void handleTimeSettingsCommand(std::istringstream& iss) {
        // Implement time settings handling (optional for simplicity)
        std::cout << "=" << std::endl;
    }

    void handleTimeLeftCommand(std::istringstream& iss) {
        // Implement time left reporting (optional for simplicity)
        std::cout << "= " << std::endl;
    }

    void handleFinalScoreCommand() {
        // Implement final score reporting (optional for simplicity)
        std::cout << "= " << std::endl;
    }

    void handleUndoCommand() {
        // Implement undo command handling (optional for simplicity)
        std::cout << "= " << std::endl;
    }

    Stone parseStone(const std::string& color) const {
        if (color == "b") {
            return Stone::BLACK;
        } else if (color == "w") {
            return Stone::WHITE;
        } else {
            throw std::invalid_argument("Invalid color");
        }
    }

    bool boardCoordinatesValid(int x, int y) const {
        return x >= 0 && x < BOARD_SIZE && y >= 0 && y < BOARD_SIZE;
    }
};

int main() {
    srand(static_cast<unsigned>(time(nullptr))); // Seed for random number generation

    Game game;
    GTPHandler handler(game);

    std::string input;
    while (std::getline(std::cin, input)) {
        handler.handleCommand(input);
    }

    return 0;
}
