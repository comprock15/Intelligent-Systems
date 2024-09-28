#include <iostream>
#include <queue>
#include <unordered_set>
#include <vector>
#include <chrono>

struct state {
	short depth;
	// 0 - left coast, 1 - right coast
	bool wolf, goat, cabbage, boat;
	state* parent;

	state() :
		wolf(0),
		goat(0),
		cabbage(0),
		boat(0),
		depth(0),
		parent(nullptr) {};

	state(bool w, bool g, bool c, bool b, short depth, state* parent) :
		wolf(w),
		goat(g),
		cabbage(c),
		boat(b),
		depth(depth),
		parent(parent) {};

	// true if wolf can't eat goat and goat can't eat cabbage
	bool is_safe()
	{
		return !(( wolf &&  goat    && !boat) || 
				 ( goat &&  cabbage && !boat) || 
				 (!wolf && !goat    &&  boat) || 
				 (!goat && !cabbage &&  boat));
	}

	/*
	w|      |
	g|b     |
	c|      |
	*/
	friend std::ostream& operator<<(std::ostream& os, const state& st)
	{
		// row 1
		if (st.wolf)
			os << " |      |w\n";
		else
			os << "w|      | \n";

		// row 2
		if (st.goat)
			os << " ";
		else
			os << "g";

		if (st.boat)
			os << "|     b|";
		else
			os << "|b     |";

		if (st.goat)
			os << "g\n";
		else
			os << " \n";

		// row 3
		if (st.cabbage)
			os << " |      |c\n";
		else
			os << "c|      | \n";

		return os;
	}
};

struct state_hash
{
	short operator()(const state& st) const
	{
		return st.wolf << 3 ^ st.goat << 2 ^ st.cabbage << 1 ^ st.boat;
	}
};

struct state_eq
{
	bool operator()(const state& st1, const state& st2) const
	{
		return  st1.wolf == st2.wolf &&
				st1.goat == st2.goat &&
				st1.cabbage == st2.cabbage &&
				st1.boat == st2.boat;
	}
};

class solver {
private:
	int nodes_checked = 0;
	std::queue<state> created_states;

	// Start state of solution
	state root;
	// Final state of solution
	state* ans = nullptr;

	void print_answer(state* node)
	{
		if (node != &root)
		{
			print_answer(node->parent);
			std::cout << node->depth << ".\n"
					  << *node << "\n";
		}
	}

	inline void add_states(state* node, std::queue<state*>& q)
	{
		// move boat alone to the opposite coast
		created_states.push(state(node->wolf, node->goat, node->cabbage, !node->boat, node->depth + 1, node));
		q.push(&created_states.back());

		// move wolf to the opposite coast
		if (node->boat == node->wolf)
		{
			created_states.push(state(!node->wolf, node->goat, node->cabbage, !node->boat, node->depth + 1, node));
			q.push(&created_states.back());
		}

		// move goat to the opposite coast
		if (node->boat == node->goat)
		{
			created_states.push(state(node->wolf, !node->goat, node->cabbage, !node->boat, node->depth + 1, node));
			q.push(&created_states.back());
		}

		// move cabbage to the opposite coast
		if (node->boat == node->cabbage)
		{
			created_states.push(state(node->wolf, node->goat, !node->cabbage, !node->boat, node->depth + 1, node));
			q.push(&created_states.back());
		}
	}

	inline bool is_answer(const state* node) const
	{
		return node->wolf && node->goat && node->cabbage && node->boat;
	}

public:
	// solve task using BFS
	bool BFS()
	{
		++nodes_checked;

		if (is_answer(&root))
		{
			ans = &root;
			return true;
		}

		if (!root.is_safe())
			return false;

		std::unordered_set<state, state_hash, state_eq> closed;
		std::queue<state*> opened;

		add_states(&root, opened);

		while (!opened.empty())
		{
			state* st = opened.front();
			opened.pop();
			
			++nodes_checked;

			// if state already appeared
			if (closed.find(*st) != closed.end())
				continue;

			if (!st->is_safe())
				continue;

			// if found answer
			if (is_answer(st))
			{
				ans = st;
				return true;
			}

			closed.insert(*st);

			add_states(st, opened);
		}

		return false;
	}

	void print_answer(bool print_all_steps = false)
	{
		std::cout << root;

		if (ans == nullptr)
		{
			std::cout << "no solution\n";
			return;
		}

		std::cout << "nodes checked:  " << nodes_checked << "\n";
		std::cout << "solution depth: " << ans->depth << "\n";
		if (print_all_steps)
			print_answer(ans);
	}

	void set_root(bool w, bool g, bool c, bool b)
	{
		root.wolf = w;
		root.goat = g;
		root.cabbage = c;
		root.boat = b;
	}

	short get_solution_length()
	{
		if (ans == nullptr)
			return -1;
		else
			return ans->depth;
	}
};

struct testcase {
	bool wolf, goat, cabbage, boat;
	short solution_length;

	testcase(bool w, bool g, bool c, bool b, short len) :
		wolf(w),
		goat(g),
		cabbage(c),
		boat(b),
		solution_length(len) {};
};

void compare_ans(size_t x, size_t y)
{
	if (x != y)
		throw std::exception("Wrong answer");
}

void run_tests(const std::vector<testcase>& task, int task_n, bool print_ans = 0)
{
	std::chrono::steady_clock::time_point t1, t2;

	for (int i = 0; i < task.size(); i++)
	{
		solver sol;
		sol.set_root(task[i].wolf, task[i].goat, task[i].cabbage, task[i].boat);
		
		switch (task_n)
		{
		case 1:
			t1 = std::chrono::steady_clock::now();
			sol.BFS();
			t2 = std::chrono::steady_clock::now();
			break;
		default:
			break;
		}

		sol.print_answer(false);

		std::cout << "    Time: " << std::chrono::duration_cast<std::chrono::milliseconds> (t2 - t1).count() << " ms\n";

		try
		{
			compare_ans(sol.get_solution_length(), task[i].solution_length);
		}
		catch (std::exception e)
		{
			std::cout << "        " << sol.get_solution_length() << " != " << task[i].solution_length << " WRONG ANSWER\n";
		}

		std::cout << "\n";
	}
}

void solve()
{
	std::vector<testcase> task = {
		testcase(0, 0, 0, 0, 7),
		testcase(0, 0, 0, 1, -1),
		testcase(0, 0, 1, 0, 3),
		testcase(0, 0, 1, 1, -1),
		testcase(0, 1, 0, 0, 5),
		testcase(0, 1, 0, 1, 6),
		testcase(0, 1, 1, 0, -1),
		testcase(0, 1, 1, 1, 4),
		testcase(1, 0, 0, 0, 3),
		testcase(1, 0, 0, 1, -1),
		testcase(1, 0, 1, 0, 1),
		testcase(1, 0, 1, 1, 2),
		testcase(1, 1, 0, 0, -1),
		testcase(1, 1, 0, 1, 4),
		testcase(1, 1, 1, 0, -1),
		testcase(1, 1, 1, 1, 0)
	};

	std::cout << "------------BFS------------\n";
	run_tests(task, 1);
}

int main()
{
	solve();
}