#include <iostream>
#include <queue>

using namespace std;

struct state {
	short depth;
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
	friend ostream& operator<<(ostream& os, const state& st)
	{
		// Print number of action
		os << st.depth << ".\n";

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

class solver {
private:
	int nodes_checked = 0;
	queue<state> created_states;

	// Start state of solution
	state root;
	// Final state of solution
	state* ans = &root;

	void print_answer(state* node)
	{
		if (node != &root)
			print_answer(node->parent);
		cout << *node << "\n";
	}

	void add_states(state* node, queue<state*>& q)
	{
		created_states.push(state(node->wolf, node->goat, node->cabbage, !node->boat, node->depth + 1, node));
		q.push(&created_states.back());

		if (node->boat == node->wolf)
		{
			created_states.push(state(!node->wolf, node->goat, node->cabbage, !node->boat, node->depth + 1, node));
			q.push(&created_states.back());
		}

		if (node->boat == node->goat)
		{
			created_states.push(state(node->wolf, !node->goat, node->cabbage, !node->boat, node->depth + 1, node));
			q.push(&created_states.back());
		}

		if (node->boat == node->cabbage)
		{
			created_states.push(state(node->wolf, node->goat, !node->cabbage, !node->boat, node->depth + 1, node));
			q.push(&created_states.back());
		}
	}

public:
	bool BFS()
	{
		queue<state*> q;

		add_states(&root, q);

		while (!q.empty())
		{
			state* st = q.front();
			q.pop();

			++nodes_checked;

			if (!st->is_safe())
				continue;

			// if found answer
			if (st->wolf && st->goat && st->cabbage)
			{
				ans = st;
				return true;
			}

			//checked_states.insert(st->positions);
			add_states(st, q);
		}

		return false;
	}

	void print_answer()
	{
		cout << "nodes checked:  " << nodes_checked << "\n";
		cout << "solution depth: " << ans->depth << "\n";
		print_answer(ans);
	}
};

int main()
{
	solver s;
	s.BFS();
	s.print_answer();
}