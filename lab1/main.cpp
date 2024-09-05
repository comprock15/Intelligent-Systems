#include <iostream>
#include <string>
#include <queue>
#include <chrono>
#include <vector>
#include <cassert>

using namespace std;

// Information about the current state being checked
struct state
{
	// Previous state
	state* parent;
	// Current value
	size_t value;
	// Current depth
	size_t depth;
	// Operation with which this state was reached from
	string lastOp;

	state(size_t val, size_t depth, string op, state* p = nullptr) :
		value(val), depth(depth), lastOp(op), parent(p) {}
};

// Class controlling the searching
class BFS
{
private:
	// Numbers that have already been checked
	vector<size_t> checked_nums;

	// Number of checked states
	size_t n_states_checked;
	// Root state
	state* root;
	// State with desired number
	state* ans;

	// Print the sequence of operations used to obtain the desired number
	void print_operations(state* st)
	{
		if (st->parent != nullptr)
			print_operations(st->parent);
		else
			return; // Root reached

		cout << "    " << st->depth << ". ";
		cout << st->parent->value << st->lastOp << " = " << st->value << "\n";
	}

public:
	// Search for a sequence of operations to get y from x (+3, *2)
	bool search(size_t x, size_t y)
	{
		// Check if start number is already equals a desired number
		if (x == y)
		{
			ans = root;
			return true;
		}
		++n_states_checked;

		checked_nums = vector<size_t>(y + 1);

		// Queue of states to check
		queue<state*> q;

		// Set the start number
		root = new state(x, 0, "$");

		// Queue next states
		q.push(new state(x * 2, 1, "*2", root));
		q.push(new state(x + 3, 1, "+3", root));

		// Check all states in queue
		while (!q.empty())
		{
			// Get current state
			state* st = q.front();
			q.pop();

			++n_states_checked;

			// Check if state is correct and hasn't been checked before
			if (st->value > y || checked_nums[st->value] == 1)
			{
				continue;
			}

			// Set the current number to be checked
			checked_nums[st->value] = 1;

			// If found answer
			if (st->value == y)
			{
				ans = st;
				return true;
			}

			// Queue next states
			q.push(new state(st->value * 2, st->depth + 1, "*2", st));
			q.push(new state(st->value + 3, st->depth + 1, "+3", st));
		}

		return false;
	}

	// Task 2 (3 operations: +3, *2, -2)
	bool search2(size_t x, size_t y)
	{
		// Check if start number is already equals a desired number
		if (x == y)
		{
			ans = root;
			return true;
		}
		++n_states_checked;

		checked_nums = vector<size_t>(y + 1000);

		// Queue of states to check
		queue<state*> q;

		// Set the start number
		root = new state(x, 0, "$");

		// Queue next states
		q.push(new state(x * 2, 1, "*2", root));
		q.push(new state(x + 3, 1, "+3", root));
		q.push(new state(x - 2, 1, "-2", root));

		// Check all states in queue
		while (!q.empty())
		{
			// Get current state
			state* st = q.front();
			q.pop();

			++n_states_checked;

			// Check if state is correct and hasn't been checked before
			if (st->value > checked_nums.size() - 1 || checked_nums[st->value] == 1)
			{
				continue;
			}

			// Set the current number to be checked
			checked_nums[st->value] = 1;

			// If found answer
			if (st->value == y)
			{
				ans = st;
				return true;
			}

			// Queue next states
			q.push(new state(st->value * 2, st->depth + 1, "*2", st));
			q.push(new state(st->value + 3, st->depth + 1, "+3", st));
			q.push(new state(st->value - 2, st->depth + 1, "-2", st));
		}

		return false;
	}

	// Get number of states checked
	int get_n_states_checked()
	{
		return n_states_checked;
	}

	// Print the sequence of operations used to obtain the desired number
	void print_operations()
	{
		print_operations(ans);
	}

	// Get the number of operations used
	int get_solution_length()
	{
		return ans->depth;
	}

	// Print the information about the solution
	void print_result(bool print_ops)
	{
		cout << root->value << " -> " << ans->value << "\n    ";
		cout << "Solution length: " << get_solution_length() << "\n    ";
		cout << "Nodes checked: " << get_n_states_checked() << "\n";
		if (print_ops)
		{
			cout << "Operations:\n";
			print_operations();
			cout << "\n";
		}
	}
};

struct testcase {
	size_t x, y, solution_length;

	testcase(size_t x, size_t y, size_t len) :
		x(x), y(y), solution_length(len) {}
};

void compare_ans(size_t x, size_t y)
{
	if (x != y)
		throw exception("Wrong answer");
}

void run_tests(const vector<testcase>& task, int task_n)
{
	BFS bfs;
	chrono::steady_clock::time_point t1, t2;

	for (int i = 0; i < task.size(); i++)
	{
		t1 = chrono::steady_clock::now();
		if (task_n == 1)
		{
			bfs.search(task[i].x, task[i].y);
		}
		else
		{
			bfs.search2(task[i].x, task[i].y);
		}
		t2 = chrono::steady_clock::now();
		//cout << task[i].x << " -> " << task[i].y << "\n    ";
		bfs.print_result(0);

		cout << "    Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";

		try
		{
			compare_ans(bfs.get_solution_length(), task[i].solution_length);
		}
		catch (exception e)
		{
			cout << "        " << bfs.get_solution_length() << " != " << task[i].solution_length << " WRONG ANSWER\n";
		}
	}
}

void solve()
{
	vector<testcase> task1 = {
		testcase(1, 100, 8),
		testcase(2, 55, 6),
		testcase(2, 100, 7),
		testcase(1, 97, 8),
		testcase(2, 1000, 12),
		testcase(2, 800000, 24),
		testcase(2, 10000001, 30)
	};
	
	run_tests(task1, 1);

	vector<testcase> task2 = {
		testcase(1, 100, 7),
		testcase(2, 55, 6),
		testcase(2, 100, 7),
		testcase(1, 97, 8),
		testcase(2, 1000, 11),
		testcase(2, 3001, 14),
		testcase(2, 800000, 23),
		testcase(2, 10000001, 30)
	};

	run_tests(task2, 2);
}

int main()
{
	solve();
}