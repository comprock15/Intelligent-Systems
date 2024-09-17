#include <iostream>
#include <vector>
#include <sstream>
#include <unordered_set>
#include <queue>
#include <chrono>
#include <stack>

using namespace std;

// Directions where we can move 0-cell
enum class directions { RIGHT, DOWN, LEFT, UP };

struct state
{
    short depth;
    directions previous_direction;
    string positions;
    state& previous_state;
    short zero_index;

    state(const string& pos, directions dir, short depth, short zero_ind, state& prev_state) :
        positions(pos),
        previous_direction(dir),
        depth(depth),
        zero_index(zero_ind),
        previous_state(prev_state) {};

    friend ostream& operator<<(ostream& os, const state& st)
    {
        // Print number of action
        os << st.depth << ". ";

        // Print direction
        switch (st.previous_direction)
        {
        case directions::DOWN:
            os <<"DOWN\n";
            break;
        case directions::UP:
            os << "UP\n";
            break;
        case directions::RIGHT:
            os << "RIGHT\n";
            break;
        case directions::LEFT:
            os << "LEFT\n";
            break;
        default:
            os << "Error with direction\n";
        }

        // Print positions
        for (size_t i = 0; i < st.positions.length(); i++)
        {
            short num = stoi(string(1, st.positions[i]), 0, 16);
            if (num < 10)
                os << " ";

            if (num == 0)
                os << "  ";
            else
                os << num << " ";

            if ((i + 1) % 4 == 0)
                os << "\n";
        }

        return os;
    }
};

class puzzle15
{
private:
    // Size of side
    short side_size;
    // Count of elements
    short size;
    // Positions of numbers
    string start_positions;
    // Number of checked nodes
    int nodes_checked = 0;
    // All created states
    queue<state> created_states;

    // "Null"-reference
    state dummy = state(start_positions, directions::UP, (short)-1, (short)0, dummy);
    // Start state of solution
    state root = state(start_positions, directions::UP, (short)0, (short)0, dummy);
    // Final state of solution
    state* ans = &dummy;

    // Solved string
    const string solved = "123456789ABCDEF0";

    // Get numbers positions from string
    friend istream& operator>>(istream& is, puzzle15& p15)
    {
        for (size_t i = 0; i < p15.size; i++)
        {
            is >> p15.start_positions[i];
            if (p15.start_positions[i] == '0')
            {
                p15.root.zero_index = i;
            }
        }
        p15.root.positions = p15.start_positions;
        return is;
    }

    // Print puzzle15 start state
    friend ostream& operator<<(ostream& os, const puzzle15& p15)
    {
        for (size_t i = 0; i < p15.size; i++)
        {
            short num = stoi(string(1, p15.start_positions[i]), 0, 16);
            if (num < 10)
                os << " ";

            if (num == 0)
                os << "  ";
            else
                os << num << " ";

            if ((i + 1) % p15.side_size == 0)
                os << "\n";
        }
        return os;
    }

    // Check if the position is solvable
    inline bool is_solvable(const string& pos)
    {
        // inversion: i < j, a[i] > a[j]
        int inversions = 0;
        // Index of the row with zero
        int zero_row = 0;

        // Count inversions (we don't count 0)
        for (size_t i = 0; i < size; ++i)
        {
            if (pos[i] != '0')
            {
                for (size_t j = i + 1; j < size; ++j)
                {
                    if ((pos[j] != '0') && (pos[i] > pos[j]))
                        ++inversions;
                }
            }
            else // zero found
            {
                zero_row = i / 4;
            }
        }

        if (side_size % 2)
            return inversions % 2 == 0;

        return (inversions + zero_row) % 2 != 0;
    }

    void print_answer(state* node)
    {
        if (node != &root)
        {
            print_answer(&node->previous_state);
            cout << *node << "\n";
        }
    }

public:
    puzzle15(short side_size)
    {
        this->side_size = side_size;
        this->size = side_size * side_size;
        start_positions = string(size, '0');
    }

    void set_positions(const string& pos)
    {
        nodes_checked = 0;
        for (size_t i = 0; i < size; i++)
        {
            start_positions[i] = pos[i];
            if (start_positions[i] == '0')
            {
                root.zero_index = i;
            }
        }
        root.positions = start_positions;
    }

    // Find solution using BFS
    bool BFS()
    {
        // Check if the position is solvable
        if (!is_solvable(start_positions))
        {
            ans = &dummy;
            return false;
        }

        ++nodes_checked;
        // Check if puzzle is already solved
        if (start_positions == solved)
        {
            ans = &root;
            return true;
        }

        unordered_set<string> checked_states;
        checked_states.insert(start_positions);

        queue<state*> q;

        add_states(&root, q);

        while (!q.empty())
        {
            state* st = q.front();
            q.pop();

            if (st->depth > 80)
                continue;

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

            ++nodes_checked;

            // if found answer
            if (st->positions == solved)
            {
                ans = st;
                return true;
            }

            checked_states.insert(st->positions);
            add_states(st, q);
        }

        return false;
    }

    // Find solution using DFS;
    bool DFS()
    {
        // Check if the position is solvable
        if (!is_solvable(start_positions))
        {
            ans = &dummy;
            return false;
        }

        ++nodes_checked;
        // Check if puzzle is already solved
        if (start_positions == solved)
        {
            ans = &root;
            return true;
        }

        unordered_set<string> checked_states;
        checked_states.insert(start_positions);

        stack<state*> q;

        add_states(&root, q);

        while (!q.empty())
        {
            state* st = q.top();
            q.pop();

            if (st->depth > 80)
                continue;

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

            ++nodes_checked;

            // if found answer
            if (st->positions == solved)
            {
                ans = st;
                return true;
            }

            checked_states.insert(st->positions);
            add_states(st, q);
        }

        return false;
    }

    // Add new states with moved zero
    inline void add_states(state* st, queue<state*>& q)
    {
        // Move zero up
        if (st->previous_direction != directions::DOWN && st->zero_index - 4 >= 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 4]);
            created_states.push(state(pos1, directions::UP, st->depth + 1, st->zero_index - 4, *st));
            q.push(&created_states.back());
        }

        // Move zero down
        if (st->previous_direction != directions::UP && st->zero_index + 4 < size)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 4]);
            created_states.push(state(pos1, directions::DOWN, st->depth + 1, st->zero_index + 4, *st));
            q.push(&created_states.back());
        }

        // Move zero left
        if (st->previous_direction != directions::RIGHT && st->zero_index % 4 != 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 1]);
            created_states.push(state(pos1, directions::LEFT, st->depth + 1, st->zero_index - 1, *st));
            q.push(&created_states.back());
        }

        // Move zero right
        if (st->previous_direction != directions::LEFT && st->zero_index % 4 != 3)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 1]);
            created_states.push(state(pos1, directions::RIGHT, st->depth + 1, st->zero_index + 1, *st));
            q.push(&created_states.back());
        }
    }
    inline void add_states(state* st, stack<state*>& q)
    {
        // Move zero up
        if (st->previous_direction != directions::DOWN && st->zero_index - 4 >= 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 4]);
            created_states.push(state(pos1, directions::UP, st->depth + 1, st->zero_index - 4, *st));
            q.push(&created_states.back());
        }

        // Move zero down
        if (st->previous_direction != directions::UP && st->zero_index + 4 < size)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 4]);
            created_states.push(state(pos1, directions::DOWN, st->depth + 1, st->zero_index + 4, *st));
            q.push(&created_states.back());
        }

        // Move zero left
        if (st->previous_direction != directions::RIGHT && st->zero_index % 4 != 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 1]);
            created_states.push(state(pos1, directions::LEFT, st->depth + 1, st->zero_index - 1, *st));
            q.push(&created_states.back());
        }

        // Move zero right
        if (st->previous_direction != directions::LEFT && st->zero_index % 4 != 3)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 1]);
            created_states.push(state(pos1, directions::RIGHT, st->depth + 1, st->zero_index + 1, *st));
            q.push(&created_states.back());
        }
    }

    void print_answer(bool print_all_steps = false)
    {
        cout << *this;
        if (ans == &dummy)
        {
            cout << "Position can't be solved\n";
            return;
        }
        cout << "solution depth: " << ans->depth << "\n";
        if (print_all_steps)
            print_answer(ans);
    }

    short get_solution_length()
    {
        return ans->depth;
    }
};

struct testcase {
    string positions;
    short solution_length;

    testcase(const string& pos, short len) :
        positions(pos), solution_length(len) {}
};

void compare_ans(size_t x, size_t y)
{
    if (x != y)
        throw exception("Wrong answer");
}

void run_tests(const vector<testcase>& task, int task_n)
{
    puzzle15 p15(4);
    chrono::steady_clock::time_point t1, t2;

    for (int i = 0; i < task.size(); i++)
    {
        p15.set_positions(task[i].positions);
        switch (task_n)
        {
        case 1:
            t1 = chrono::steady_clock::now();
            p15.BFS();
            t2 = chrono::steady_clock::now();
            break;
        case 2:
            t1 = chrono::steady_clock::now();
            p15.DFS();
            t2 = chrono::steady_clock::now();
            break;
        default:
            break;
        }

        p15.print_answer();

        cout << "    Time: " << chrono::duration_cast<chrono::milliseconds> (t2 - t1).count() << " ms\n";

        try
        {
            compare_ans(p15.get_solution_length(), task[i].solution_length);
        }
        catch (exception e)
        {
            cout << "        " << p15.get_solution_length() << " != " << task[i].solution_length << " WRONG ANSWER\n";
        }

        cout << "\n";
    }
}

void solve()
{
    vector<testcase> task = {
        testcase("123456789AFB0EDC", -1),
        testcase("F2345678A0BE91CD", -1),
        testcase("123456789ABCDEF0", 0),
        testcase("1234067859ACDEBF", 5),
        testcase("5134207896ACDEBF", 8),
        testcase("16245A3709C8DEBF", 10),
        testcase("1723068459ACDEBF", 13),
        testcase("12345678A0BE9FCD", 19)
    };

    cout << "------------BFS------------\n";
    run_tests(task, 1);

    cout << "------------DFS------------\n";
    run_tests(task, 2);
}

int main()
{
    //string s;
    //s = "16245A3709C8DEBF";

    //puzzle15 p15 = puzzle15(4);
    //istringstream iss(s);

    //iss >> p15;
    ////cin >> p15;
    //cout << p15;

    //p15.BFS();
    //p15.print_answer();

    solve();
}


