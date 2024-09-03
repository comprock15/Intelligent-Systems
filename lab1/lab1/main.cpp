#include <iostream>
#include <string>
#include <queue>
#include <set>
#include <chrono>
#include <vector>

using namespace std;

struct state
{
	state* parent;
	size_t x, depth;
	string lastOp;

	state(size_t x, size_t depth, string op, state* p = nullptr) :
		x(x), depth(depth), lastOp(op), parent(p) {};
};

class BFS
{
private:
	set<size_t> checkedNums;
	vector<size_t> chN;

	size_t nodesChecked;
	state* root;
	state* ans;

	priority_queue<pair<size_t, state*>> pq;

	void printOperations(state* st)
	{
		if (st->parent != nullptr)
			printOperations(st->parent);
		else
		{
			return;
		}

		cout << st->depth << ". ";
		cout << st->parent->x << st->lastOp << " = " << st->x << "\n";
	}

public:
	bool search(size_t x, size_t y)
	{
		if (x == y)
		{
			return 0;
		}
		++nodesChecked;

		chN = vector<size_t>(y + 1);

		queue<state*> q;
		root = new state(x, 0, "$");
		q.push(new state(x * 2, 1, "*2", root));
		q.push(new state(x + 3, 1, "+3", root));

		while (!q.empty())
		{
			state* st = q.front();
			q.pop();
			++nodesChecked;

			/*if (checkedNums.find(st->x) != checkedNums.end())
			{
				continue;
			}
			checkedNums.insert(st->x);*/

			//cout << st->x << " " << y << "\n";
			if (st->x > y || chN[st->x] == 1)
			{
				continue;
			}
			chN[st->x] = 1;

			// found answer
			if (st->x == y)
			{
				//ops = st.ops;
				//return ops.length();
				ans = st;
				return true;
			}

			//if (st->x < y)
			{
				q.push(new state(st->x * 2, st->depth + 1, "*2", st));
				q.push(new state(st->x + 3, st->depth + 1, "+3", st));
			}
		}

		return false;
	}

	int searchPQ(int x, int y)
	{
		if (x == y)
		{
			return 0;
		}

		root = new state(x, 0, "$");
		pq.push(make_pair<size_t, state*>(0, new state(x * 2, 1, "*2", root)));
		pq.push(make_pair<size_t, state*>(1, new state(x + 3, 1, "+3", root)));

		while (!pq.empty())
		{
			++nodesChecked;

			state* st = pq.top().second;
			pq.pop();

			//cout << st.x << "\n";

			// found answer
			if (st->x == y)
			{
				//ops = st.ops;
				//return ops.length();
				ans = st;
				return st->depth;
			}

			if (st->x < y)
			{
				pq.push(make_pair<size_t, state*>(0, new state(st->x + 3, st->depth + 1, "+2", st)));
				pq.push(make_pair<size_t, state*>(1, new state(st->x * 2, st->depth + 1, "*2", st)));
			}
		}

		return -1;
	}

	bool search2(size_t x, size_t y)
	{
		if (x == y)
		{
			return 0;
		}
		++nodesChecked;

		chN = vector<size_t>(y + 1000);

		queue<state*> q;
		root = new state(x, 0, "$");
		q.push(new state(x * 2, 1, "*2", root));
		q.push(new state(x + 3, 1, "+3", root));
		q.push(new state(x - 2, 1, "-2", root));

		while (!q.empty())
		{
			state* st = q.front();
			q.pop();
			++nodesChecked;

			/*if (checkedNums.find(st->x) != checkedNums.end())
			{
				continue;
			}
			checkedNums.insert(st->x);*/

			//cout << st->x << " " << y << "\n";
			if (st->x > chN.size() || chN[st->x] == 1)
			{
				continue;
			}
			chN[st->x] = 1;

			// found answer
			if (st->x == y)
			{
				//ops = st.ops;
				//return ops.length();
				ans = st;
				return true;
			}

			//if (st->x < y)
			{
				q.push(new state(st->x * 2, st->depth + 1, "*2", st));
				q.push(new state(st->x + 3, st->depth + 1, "+3", st));
				q.push(new state(st->x - 2, st->depth + 1, "-2", st));
			}
		}

		return false;
	}

	int getNodes()
	{
		return nodesChecked;
	}

	void printOperations()
	{
		printOperations(ans);
	}

	int getSolutionLength()
	{
		return ans->depth;
	}

	void printResult()
	{
		cout << root->x << " -> " << ans->x << "\n";
		cout << "Solution length: " << getSolutionLength() << "\n";
		cout << "Nodes checked: " << getNodes() << "\n";
		cout << "Operations:\n";
		printOperations();
		cout << "\n";
	}
};

int main()
{
	//size_t x, y;

	/*cout << "first number>> ";
	cin >> x;

	cout << "second number>> ";
	cin >> y;*/

	BFS bfs;
	chrono::steady_clock::time_point t1, t2;

	t1 = chrono::steady_clock::now();
	bfs.search(1, 100);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search(2, 55);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search(2, 100);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search(1, 97);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search(2, 1000);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search(2, 800000);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search(2, 10000001);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();


	cout << "\n\n";


	t1 = chrono::steady_clock::now();
	bfs.search2(1, 100);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(2, 3);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(2, 55);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(2, 100);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(1, 97);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(2, 1000);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(3, 1001);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(3, 3001);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(2, 800000);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();

	t1 = chrono::steady_clock::now();
	bfs.search2(2, 10000001);
	t2 = chrono::steady_clock::now();
	cout << "Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";
	bfs.printResult();
}