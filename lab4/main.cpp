#include <iostream>
#include <array>
#include <string>
#include <queue>

const __int8 SIDE_SIZE = 8;
const __int8 BOARD_SIZE = SIDE_SIZE * SIDE_SIZE;
__int8 MAX_DEPTH = 7;

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
	__int8 stones_count = 4;

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
		switch (dir)
		{
		case up:
			return pos / SIDE_SIZE != 0;
			break;
		case upright:
			return pos / SIDE_SIZE != 0 && (pos + 1) % SIDE_SIZE != 0;
			break;
		case right:
			return (pos + 1) % SIDE_SIZE != 0;
			break;
		case downright:
			return pos / SIDE_SIZE < SIDE_SIZE - 1 && (pos + 1) % SIDE_SIZE != 0;
			break;
		case down:
			return pos / SIDE_SIZE < SIDE_SIZE - 1;
			break;
		case downleft:
			return pos / SIDE_SIZE < SIDE_SIZE - 1 && pos % SIDE_SIZE != 0;
			break;
		case left:
			return pos % SIDE_SIZE != 0;
			break;
		case upleft:
			return pos / SIDE_SIZE != 0 && pos % SIDE_SIZE != 0;
			break;
		default:
			break;
		}

		return false;
	}

	bool can_make_move(std::array<__int8, BOARD_SIZE> _board, __int8 pos, __int8 current_color)
	{
		for (directions dir = directions::up; dir < 8; dir = (directions)(dir + 1))
		{
			if (!check_bounds_ok(pos, (directions)dir))
				continue;

			__int8 pos1 = next_cell(pos, (directions)dir);

			if (_board[pos1] != -current_color)
				continue;

			while (_board[pos1] == -current_color)
			{
				if (check_bounds_ok(pos1, (directions)dir))
					pos1 = next_cell(pos1, (directions)dir);
				else
					break;
			}

			if (_board[pos1] == current_color)
				return true;
		}

		return false;
	}

	void repaint_cells(std::array<__int8, BOARD_SIZE>& _board, __int8 pos, __int8 current_color)
	{
		for (directions dir = directions::up; dir < 8; dir = (directions)(dir + 1))
		{
			if (!check_bounds_ok(pos, (directions)dir))
				continue;

			__int8 pos1 = next_cell(pos, (directions)dir);

			if (_board[pos1] != -current_color)
				continue;

			__int8 points = 0;
			while (_board[pos1] == -current_color)
			{
				++points;
				if (check_bounds_ok(pos1, (directions)dir))
					pos1 = next_cell(pos1, (directions)dir);
				else
					break;
			}
			
			if (_board[pos1] == current_color)
			{
				pos1 = pos;
				//std::cout << +points << " cells to repaint\n";
				while (points--)
				{
					pos1 = next_cell(pos1, (directions)dir);
					_board[pos1] = current_color;
					//std::cout << +pos1 << "\n";
				}
			}
		}
	}

	void make_move()
	{
		bot_has_moves = false;
		__int8 pos = 0;
		/*for (__int8 i = 0; i < BOARD_SIZE; ++i)
			if (!board[i] && can_make_move(i, bot_color))
			{
				if (bot_has_moves)
				{
					if (weights[i] > weights[pos])
						pos = i;
				}
				else
				{
					pos = i;
				}
				bot_has_moves = true;
			}*/
		minimax(board, 0, bot_color, pos);
		if (pos != -1)
		{
			bot_has_moves = true;
		}
		if (bot_has_moves)
		{
			board[pos] = bot_color;
			std::cerr << (char)('a' + pos % SIDE_SIZE) << pos / SIDE_SIZE + 1 << std::endl;
			std::cout << "bot's move: " << (char)('a' + pos % SIDE_SIZE) << pos / SIDE_SIZE + 1 << "\n";
			repaint_cells(board, pos, bot_color);
			bot_has_moves = true;
		}
		else {
			std::cout << "bot doesn't have any moves\n";
		}
	}

	void parse_move()
	{
		opponent_has_moves = false;
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
			if (!board[i] && can_make_move(board, i, opponent_color))
			{
				opponent_has_moves = true;
				break;
			}
		if (opponent_has_moves)
		{
			std::string move;
			__int8 ind;
			char column, row;
			while (true)
			{
				std::cin >> move;
				column = move[0];
				row = move[1];
				ind = SIDE_SIZE * (row - '1') + (column - 'a');
				if (ind < 0 || ind >= BOARD_SIZE || board[ind] || !can_make_move(board, ind, opponent_color))
				{
					std::cout << "illegal move! try again\n";
				}
				else
					break;
			}
			board[ind] = opponent_color;
			repaint_cells(board, ind, opponent_color);
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

	inline bool game_over(const std::array<__int8, BOARD_SIZE>& _board)
	{
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
		{
			if (!board[i] && (can_make_move(_board, i, bot_color) || can_make_move(_board, i, opponent_color)))
				return false;
		}
		return true;
	}

	__int8 game_result(const std::array<__int8, BOARD_SIZE>& _board, bool print_points = false)
	{
		short bot_points = 0;
		short opponent_points = 0;
		for (__int8 i = 0; i < BOARD_SIZE; ++i)
		{
			if (_board[i] == bot_color)
				++bot_points;
			else if (_board[i] == opponent_color)
				++opponent_points;
		}

		if (print_points)
		{
			std::cout << "bot's points: " << bot_points << "\n" <<
				"opponent's points: " << opponent_points << "\n";
		}
		if (bot_points > opponent_points)
			return 0;
		else if (bot_points < opponent_points)
			return 3;
		return 4;
	}

	short minimax(std::array<__int8, BOARD_SIZE> _board, __int8 depth, __int8 current_color, __int8& best_move)
	{
		best_move = -1;
		//std::cout << "minimax depth " << +depth << "\n";
		if (game_over(_board))
		{
			__int8 res = game_result(_board);
			if (res == 0)
				return 10000;
			if (res == 3)
				return -10000;
			return 5000;
		}

		++depth;

		std::queue<__int8> possible_moves;
		std::queue<__int8> possible_scores;


		for (__int8 i = 0; i < BOARD_SIZE; ++i)
		{
			//std::cout << +i << " " << +_board[i] << "\n";
			if (!_board[i] && can_make_move(_board, i, current_color))
			{
				//std::cout << +i << " " << +_board[i] << "\n";
				possible_moves.push(i);
				short score = weights[i] * current_color;
				if (depth < MAX_DEPTH)
				{
					std::array<__int8, BOARD_SIZE> possible_board(_board);
					possible_board[i] = current_color;
					repaint_cells(possible_board, i, current_color);
					score = minimax(possible_board, depth, -current_color, best_move);
				}
				possible_scores.push(score);
				//if ((score == 10000 && current_color == 1) || (score == -10000 && current_color == -1))
				//	break;
			}
		}

		if (possible_moves.empty())
		{
			best_move = -1;
			return 0;
		}

		best_move = possible_moves.front();
		possible_moves.pop();
		short best_score = possible_scores.front();
		possible_scores.pop();

		if (current_color == 1)
		{
			while (!possible_moves.empty())
			{
				__int8 move = possible_moves.front();
				possible_moves.pop();
				if (possible_scores.front() > best_score)
				{
					best_score = possible_scores.front();
					best_move = move;
				}
				possible_scores.pop();
			}
		}
		else
		{
			while (!possible_moves.empty())
			{
				__int8 move = possible_moves.front();
				possible_moves.pop();
				if (possible_scores.front() < best_score)
				{
					best_score = possible_scores.front();
					best_move = move;
				}
				possible_scores.pop();
			}
		}
		//std::cout << "best move: " << +best_move << "\n";
		return best_score;
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
			if (stones_count == 12)
			{
				MAX_DEPTH = 6;
			}
			else if (stones_count == 40)
			{
				MAX_DEPTH = 8;
			}
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
			++stones_count;
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
				__int8 ind = i * SIDE_SIZE + j;
				switch (board[ind])
				{
				case 1:
					std::cout << "X  |  ";
					break;
				case -1:
					std::cout << "O  |  ";
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
		return game_result(board, true);
	}
};

int main(int argc, char* argv[])
{
	// check if bot plays first or second
	game g(*argv[argc - 1] == '0');

	g.start_game();

	return g.game_result();
}