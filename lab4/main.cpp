#include <iostream>
#include <array>

const __int8 SIDE_SIZE = 8;
const _int8 BOARD_SIZE = SIDE_SIZE * SIDE_SIZE;

class game
{
	std::array<__int8, BOARD_SIZE> board;
	bool bot_turn = false;
	__int8 bot_color = -1;
	__int8 opponent_color = 1;

public:
	game(bool turn) : bot_turn(turn)
	{
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
			board[i] = 0;

		board[27] = -1;
		board[28] = 1;
		board[35] = 1;
		board[36] = -1;

		if (bot_turn)
		{
			bot_color = 1;
			opponent_color = -1;
		}
	}

	void start_game()
	{
		print_board();
		while (!game_over())
		{
			if (bot_turn)
			{
				make_move();
			}
			else
			{
				parse_move();
			}
			print_board();
			switch_turn();
		}
	}

	void print_board()
	{
		std::cout << "      a     b     c     d     e     f     g     h\n"
			      << "   -------------------------------------------------\n";
		for (__int8 i = 0; i < SIDE_SIZE; ++i)
		{
			std::cout << i + 1 << "  |  ";
			for (__int8 j = 0; j < SIDE_SIZE; ++j)
			{
				_int8 ind = i * SIDE_SIZE + j;
				switch (board[ind])
				{
				case 1:
					std::cout << "b  |  ";
					break;
				case -1:
					std::cout << "w  |  ";
					break;
				default:
					std::cout << "   |  ";
					break;
				}
			}
			std::cout << "\n   -------------------------------------------------\n";
		}
	}

	inline void parse_move()
	{
		char column, row;
		std::cin >> column >> row;
		board[SIDE_SIZE * (row - '1') + (column - 'a')] = opponent_color;
	}

	void make_move()
	{
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
			if (!board[i])
			{
				board[i] = bot_color;
				std::cerr << (char)('a' + i % SIDE_SIZE) << i / SIDE_SIZE + 1 << "\n";
				return;
			}
	}

	inline void switch_turn()
	{
		bot_turn = !bot_turn;
	}

	inline bool game_over()
	{
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
			if (!board[i])
				return false;
		return true;
	}

	__int8 game_result()
	{
		short bot_points = 0;
		short opponent_points = 0;
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
		{
			if (board[i] == bot_color)
				++bot_points;
			else if (board[i] == opponent_color)
				++opponent_points;
		}

		std::cout << "bot points: " << bot_points << "\n" <<
			"opponent points: " << opponent_points << "\n";
		if (bot_points > opponent_points)
			return 0;
		else if (bot_points < opponent_points)
			return 3;
		return 4;
	}
};

int main(int argc, char* argv[])
{
	// check if bot plays first or second
	game g(*argv[argc - 1] == '0');

	g.start_game();

	return g.game_result();
}