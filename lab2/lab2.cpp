#include <iostream>
#include <vector>
#include <sstream>
#include <unordered_set>
#include <queue>
#include <chrono>
#include <stack>

using namespace std;

// Directions where we can move 0-cell
enum class directions { RIGHT, DOWN, LEFT, UP, DUMMY };

struct state
{
    short depth;
    directions previous_direction;
    string positions;
    state& previous_state;
    short zero_index;
    short heuristics;

    state(const string& pos, directions dir, short depth, short zero_ind, state& prev_state) :
        positions(pos),
        previous_direction(dir),
        depth(depth),
        zero_index(zero_ind),
        previous_state(prev_state) {
        heuristics = -1;
    };

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

class state_gte
{
public:
    bool operator() (state* a, state* b)
    {
        return a->depth + a->heuristics >= b->depth + b->heuristics;
    }
};

short manhattan_distance(state* st)
{
    short dist = 0;
    
    // the state is the root
    if (st->depth == 0)
    {
        for (int i = 0; i < st->positions.size(); ++i)
        {
            if (st->positions[i] != '0')
            {
                short n = stoi(string(1, st->positions[i]), 0, 16);
                --n;
                dist += abs(n - i) % 4; // dx
                dist += abs(n - i) / 4; // dy
            }
        }
    }
    else // any other state
    {
        dist = st->previous_state.heuristics;
        short n = stoi(string(1, st->previous_state.positions[st->zero_index]), 0, 16);
        --n;
        // old manhattan distance
        dist -= abs(n - st->zero_index) % 4 + abs(n - st->zero_index) / 4;
        // new manhattan distance
        dist += abs(n - st->previous_state.zero_index) % 4 + abs(n - st->previous_state.zero_index) / 4; 
    }
 
    return dist;
}

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
    state dummy = state(start_positions, directions::DUMMY, (short)-1, (short)0, dummy);
    // Start state of solution
    state root = state(start_positions, directions::DUMMY, (short)0, (short)0, dummy);
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
        ++nodes_checked;

        // Check if the position is solvable
        if (!is_solvable(start_positions))
        {
            ans = &dummy;
            return false;
        }

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

            ++nodes_checked;

            if (st->depth > 80)
                continue;

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

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
        ++nodes_checked;

        // Check if the position is solvable
        if (!is_solvable(start_positions))
        {
            ans = &dummy;
            return false;
        }

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

            ++nodes_checked;

            if (st->depth > 80)
                continue;

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

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

    // Find solution using Iterative Deepening Search
    bool IDS()
    {
        ++nodes_checked;

        // Check if the position is solvable
        if (!is_solvable(start_positions))
        {
            ans = &dummy;
            return false;
        }

        // Check if puzzle is already solved
        if (start_positions == solved)
        {
            ans = &root;
            return true;
        }

        for (short boundary = 1; boundary <= 80; boundary++)
        {
            if (DLS(boundary))
            //if (DLS_recur(&root, boundary))
                return true;
        }
        return false;
    }

    // Depth Limited Search
    bool DLS(short boundary)
    {
        unordered_set<string> checked_states;
        checked_states.insert(start_positions);

        stack<state*> q;

        add_states(&root, q);

        while (!q.empty())
        {
            state* st = q.top();
            q.pop();

            ++nodes_checked;

            if (st->depth > boundary)
                continue;

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

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

    // Slower than non-recursive version
    bool DLS_recur(state* st, short boundary)
    {
        unordered_set<string> checked_states;
        checked_states.insert(start_positions);

        stack<state*> q;

        add_states(st, q);

        while (!q.empty())
        {
            state* st = q.top();
            q.pop();

            ++nodes_checked;

            if (st->depth > boundary)
                continue;

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

            // if found answer
            if (st->depth == boundary && st->positions == solved)
            {
                ans = st;
                return true;
            }

            checked_states.insert(st->positions);

            if (DLS_recur(st, boundary))
                return true;
        }

        return false;
    }

    bool A_star(short (*heuristics)(state*))
    {
        ++nodes_checked;

        // Check if the position is solvable
        if (!is_solvable(start_positions))
        {
            ans = &dummy;
            return false;
        }

        // Check if puzzle is already solved
        if (start_positions == solved)
        {
            ans = &root;
            return true;
        }

        unordered_set<string> checked_states;
        checked_states.insert(start_positions);

        priority_queue<state*, vector<state*>, state_gte> q;

        root.heuristics = (*heuristics)(&root);

        add_states(&root, q, heuristics);

        while (!q.empty())
        {
            state* st = q.top();
            q.pop();
            
            ++nodes_checked;

            if (st->depth > 80)
                continue;

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

            // if found answer
            if (st->positions == solved)
            {
                ans = st;
                return true;
            }

            checked_states.insert(st->positions);
            add_states(st, q, heuristics);
        }

        return false;
    }

    bool IDA_star(short (*heuristics)(state*))
    {
        ++nodes_checked;

        // Check if the position is solvable
        if (!is_solvable(start_positions))
        {
            ans = &dummy;
            return false;
        }

        // Check if puzzle is already solved
        if (start_positions == solved)
        {
            ans = &root;
            return true;
        }

        root.heuristics = (*heuristics)(&root);

        short boundary = root.heuristics;

        for(int i = 0; i < 1000; ++i)
        {
            boundary = IDA_star_search(&root, boundary, heuristics);
            if (boundary == 0)
                return true;
        }

        return false;
    }

    short IDA_star_search(state* st, short boundary, short (*heuristics)(state*))
    {            
        unordered_set<string> checked_states;
        checked_states.insert(start_positions);

        priority_queue<state*, vector<state*>, state_gte> q;

        short new_boundary = 666666;
        add_states(st, q, heuristics);

        while (!q.empty())
        {
            state* st = q.top();
            q.pop();

            ++nodes_checked;

            if (st->depth + st->heuristics > boundary)
            {
                new_boundary = min(new_boundary, (short)(st->depth + st->heuristics));
                continue;
            }

            // if state already checked
            if (checked_states.find(st->positions) != checked_states.end())
                continue;

            // if found answer
            if (st->positions == solved)
            {
                ans = st;
                return 0;
            }

            checked_states.insert(st->positions);
            add_states(st, q, heuristics);
        }

        return new_boundary;
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

    inline void add_states(state* st, priority_queue<state*, vector<state*>, state_gte>& q, short (*heuristics)(state*))
    {
        // Move zero up
        if (st->previous_direction != directions::DOWN && st->zero_index - 4 >= 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 4]);
            created_states.push(state(pos1, directions::UP, st->depth + 1, st->zero_index - 4, *st));
            created_states.back().heuristics = (*heuristics)(&created_states.back());
            q.push(&created_states.back());
        }

        // Move zero down
        if (st->previous_direction != directions::UP && st->zero_index + 4 < size)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 4]);
            created_states.push(state(pos1, directions::DOWN, st->depth + 1, st->zero_index + 4, *st));
            created_states.back().heuristics = (*heuristics)(&created_states.back());
            q.push(&created_states.back());
        }

        // Move zero left
        if (st->previous_direction != directions::RIGHT && st->zero_index % 4 != 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 1]);
            created_states.push(state(pos1, directions::LEFT, st->depth + 1, st->zero_index - 1, *st));
            created_states.back().heuristics = (*heuristics)(&created_states.back());
            q.push(&created_states.back());
        }

        // Move zero right
        if (st->previous_direction != directions::LEFT && st->zero_index % 4 != 3)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 1]);
            created_states.push(state(pos1, directions::RIGHT, st->depth + 1, st->zero_index + 1, *st));
            created_states.back().heuristics = (*heuristics)(&created_states.back());
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
        cout << "nodes checked:  " << nodes_checked << "\n";
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

void run_tests(const vector<testcase>& task, int task_n, bool print_ans=0)
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
        case 3:
            t1 = chrono::steady_clock::now();
            p15.IDS();
            t2 = chrono::steady_clock::now();
            break;
        case 4:
            t1 = chrono::steady_clock::now();
            p15.A_star(manhattan_distance);
            t2 = chrono::steady_clock::now();
            break;
        case 5:
            t1 = chrono::steady_clock::now();
            p15.IDA_star(manhattan_distance);
            t2 = chrono::steady_clock::now();
            break;
        default:
            break;
        }

        p15.print_answer(print_ans);

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
        testcase("0723168459ACDEBF", 14),
        testcase("7023168459ACDEBF", 15),
        testcase("7203168459ACDEBF", 16),
        testcase("7283160459ACDEBF", 17),
        testcase("12345678A0BE9FCD", 19),
    };

    vector<testcase> task_hard = {
        testcase("12345078A6BE9FCD", 20),
        testcase("51247308A6BE9FCD", 27),
        testcase("F2345678A0BE91DC", 33),
        testcase("75123804A6BE9FCD", 35),
        testcase("75AB2C416D389F0E", 45),
        testcase("75AB2C416D089F3E", 46),
    };

    vector<testcase> task_hardest = {
        testcase("75AB2C016D489F3E", 47),
        testcase("04582E1DF79BCA36", 48),
        testcase("FE169B4C0A73D852", 52),
    };

    cout << "------------BFS------------\n";
    //run_tests(task, 1);

    cout << "------------DFS------------\n";
    //run_tests(task, 2);

    cout << "------------IDS------------\n";
    //run_tests(task, 3);

    cout << "------------A*------------\n";
    //run_tests(task, 4);
    //run_tests(task_hard, 4);

    cout << "------------IDA*------------\n";
    //run_tests(task, 5);
    run_tests(task_hard, 5);
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


