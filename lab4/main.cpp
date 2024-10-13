#include <iostream>
#include <array>

const __int8 SIDE_SIZE = 8;
const _int8 BOARD_SIZE = SIDE_SIZE * SIDE_SIZE;

enum regions {a1=99, b1=-8, c1=8, d1=6, b2=-24, c2=-4, d2=-3, c3=7, d3=4, d4=0};
enum directions {up, upright, right, downright, down, downleft, left, upleft};

class game
{
	std::array<__int8, BOARD_SIZE> board;
	std::array<__int8, BOARD_SIZE> weights = {
		regions::a1, regions::b1, regions::c1, regions::d1, regions::d1, regions::c1, regions::b1, regions::a1,
		regions::b1, regions::b2, regions::c2, regions::d2, regions::d2, regions::c2, regions::b2, regions::b1,
		regions::c1, regions::c2, regions::c3, regions::d3, regions::d3, regions::c3, regions::c2, regions::c1,
		regions::d1, regions::d2, regions::d3, regions::d4, regions::d4, regions::d3, regions::d2, regions::d1,
		regions::d1, regions::d2, regions::d3, regions::d4, regions::d4, regions::d3, regions::d2, regions::d1,
		regions::c1, regions::c2, regions::c3, regions::d3, regions::d3, regions::c3, regions::c2, regions::c1,
		regions::b1, regions::b2, regions::c2, regions::d2, regions::d2, regions::c2, regions::b2, regions::b1,
		regions::a1, regions::b1, regions::c1, regions::d1, regions::d1, regions::c1, regions::b1, regions::a1
	};
	bool bot_turn = false;
	__int8 bot_color = -1;
	__int8 opponent_color = 1;
	bool bot_has_moves = true;
	bool opponent_has_moves = true;

	__int8 next_cell(__int8 i, directions dir)
	{
		switch (dir)
		{
		case up:
			i -= SIDE_SIZE;
			break;
		case upright:
			i -= SIDE_SIZE - 1;
			break;
		case right:
			i += 1;
			break;
		case downright:
			i += SIDE_SIZE + 1;
			break;
		case down:
			i += SIDE_SIZE;
			break;
		case downleft:
			i += SIDE_SIZE - 1;
			break;
		case left:
			i -= 1;
			break;
		case upleft:
			i -= SIDE_SIZE + 1;
			break;
		default:
			break;
		}
		return i;
	}

	bool check_bounds_ok(__int8 pos, directions dir)
	{
		return ((dir == directions::upleft || dir == directions::up || dir == directions::upright) && (pos / SIDE_SIZE != 0)) ||
			((dir == directions::upright || dir == directions::right || dir == directions::downright) && ((pos + 1) % SIDE_SIZE != 0)) ||
			((dir == directions::upleft || dir == directions::left || dir == directions::upright) && (pos % SIDE_SIZE != 0)) ||
			((dir == directions::downleft || dir == directions::down || dir == directions::downright) && (pos / SIDE_SIZE < SIDE_SIZE - 1));
	}

	bool can_make_move(__int8 pos, __int8 current_color)
	{
		for (directions dir = directions::up; dir < 8; dir = (directions)(dir + 1))
		{
			if (!check_bounds_ok(pos, (directions)dir))
				continue;

			__int8 pos1 = next_cell(pos, (directions)dir);

			if (board[pos1] != -current_color)
				continue;

			while (board[pos1] == -current_color)
			{
				if (check_bounds_ok(pos1, (directions)dir))
					pos1 = next_cell(pos1, (directions)dir);
				else
					break;
			}

			if (board[pos1] == current_color)
				return true;
		}

		return false;
	}

	void repaint_cells(__int8 pos, __int8 current_color)
	{
		for (directions dir = directions::up; dir < 8; dir = (directions)(dir + 1))
		{
			if (!check_bounds_ok(pos, (directions)dir))
				continue;

			__int8 pos1 = next_cell(pos, (directions)dir);

			if (board[pos1] != -current_color)
				continue;

			__int8 points = 0;
			while (board[pos1] == -current_color)
			{
				++points;
				if (check_bounds_ok(pos1, (directions)dir))
					pos1 = next_cell(pos1, (directions)dir);
				else
					break;
			}
			
			if (board[pos1] == current_color)
			{
				pos1 = pos;
				//std::cout << +points << " cells to repaint\n";
				while (points--)
				{
					pos1 = next_cell(pos1, (directions)dir);
					board[pos1] = current_color;
					//std::cout << +pos1 << "\n";
				}
			}
		}
	}

	void make_move()
	{
		bot_has_moves = true;
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
			if (!board[i] && can_make_move(i, bot_color))
			{
				board[i] = bot_color;
				std::cerr << (char)('a' + i % SIDE_SIZE) << i / SIDE_SIZE + 1 << "\n";
				std::cout << "bot's move: " << (char)('a' + i % SIDE_SIZE) << i / SIDE_SIZE + 1 << "\n";
				repaint_cells(i, bot_color);
				return;
			}
		std::cout << "bot doesn't have any moves\n";
		bot_has_moves = false;
	}

	void parse_move()
	{
		opponent_has_moves = false;
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
			if (!board[i] && can_make_move(i, opponent_color))
			{
				opponent_has_moves = true;
				break;
			}
		if (opponent_has_moves)
		{
			char column, row;
			std::cin >> column >> row;
			board[SIDE_SIZE * (row - '1') + (column - 'a')] = opponent_color;
			repaint_cells(SIDE_SIZE * (row - '1') + (column - 'a'), opponent_color);
			std::cout << "opponent's move: " << column << row << "\n";
		}
		else
		{
			std::cout << "opponent doesn't have any moves\n";
		}
	}

	void switch_turn()
	{
		bot_turn = !bot_turn;
	}

	inline bool game_over()
	{
		/*for (__int8 i = 0; i < BOARD_SIZE; ++i)
			if (!board[i])
				return false;*/
		return !(bot_has_moves || opponent_has_moves);
	}

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

		std::cout << "bot's points: " << bot_points << "\n" <<
			"opponent's points: " << opponent_points << "\n";
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