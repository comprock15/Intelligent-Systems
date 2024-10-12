#include <iostream>
#include <array>

const __int8 SIDE_SIZE = 8;
const _int8 BOARD_SIZE = SIDE_SIZE * SIDE_SIZE;

class game
{
	std::array<__int8, SIDE_SIZE* SIDE_SIZE> board;

public:
	game()
	{
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
			board[i] = 0;

		board[27] = -1;
		board[28] = 1;
		board[35] = 1;
		board[36] = -1;
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
};

int main(int argc, char* argv[])
{
	game g;

	g.print_board();
}