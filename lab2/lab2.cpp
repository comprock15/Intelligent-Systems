#include <iostream>
#include <vector>
#include <sstream>
#include <unordered_set>
#include <queue>

using namespace std;

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
        os << st.depth << ". ";

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
    
    int nodes_checked = 0;

    queue<state> created_states;

    state dummy = state(start_positions, directions::UP, (short)-1, (short)0, dummy);
    state root = state(start_positions, directions::UP, (short)0, (short)0, dummy);
    state* ans = &root;

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

    // Print puzzle15 current state
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

    inline bool is_solvable(const string& pos)
    {
        int inversions = 0;
        int zero_row = 0;
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
            else
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
    
    // Flat print of current state of grid
    void print()
    {
        cout << start_positions << "\n";
    }

    bool BFS()
    {
        if (!is_solvable(start_positions))
            return false;

        ++nodes_checked;
        if (start_positions == solved)
            return true;

        unordered_set<string> checked_states;
        checked_states.insert(start_positions);

        queue<state*> q;

        add_states(&root, q);

        while (!q.empty())
        {
            state* st = q.front();
            q.pop();

            //cout << "prev " << st->previous_state << "\n";
            //cout << st << "\n";

            if (checked_states.find(st->positions) != checked_states.end())
                continue;

            ++nodes_checked;
            if (st->positions == solved)
            {
                //cout << "depth: " << st->depth << " nodes checked: " << nodes_checked << "\n";
                /*while (&st->previous_state != &dummy)
                {
                    cout << *st << "\n";
                    st = &st->previous_state;
                }*/
                ans = st;
                return true;
            }

            checked_states.insert(st->positions);
            add_states(st, q);
        }

        return false;
    }

    inline void add_states(state* st, queue<state*>& q)
    {
        if (st->zero_index - 4 >= 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 4]);
            created_states.push(state(pos1, directions::UP, st->depth + 1, st->zero_index - 4, *st));
            q.push(&created_states.back());
        }

        if (st->zero_index + 4 < size)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 4]);
            created_states.push(state(pos1, directions::DOWN, st->depth + 1, st->zero_index + 4, *st));
            q.push(&created_states.back());
        }

        if (st->zero_index % 4 != 0)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index - 1]);
            created_states.push(state(pos1, directions::LEFT, st->depth + 1, st->zero_index - 1, *st));
            q.push(&created_states.back());
        }

        if (st->zero_index % 4 != 3)
        {
            string pos1 = st->positions;
            swap(pos1[st->zero_index], pos1[st->zero_index + 1]);
            created_states.push(state(pos1, directions::RIGHT, st->depth + 1, st->zero_index + 1, *st));
            q.push(&created_states.back());
        }
    }

    void print_answer()
    {
        cout << "    depth: " << ans->depth << "\n";
        print_answer(ans);
    }
};

void solve()
{
    string s;
    s = "16245A3709C8DEBF";

    puzzle15 p15 = puzzle15(4);
    istringstream iss(s);

    iss >> p15;
    //cin >> p15;
    cout << p15;

    p15.BFS();
    p15.print_answer();
}

int main()
{
    solve();
}

