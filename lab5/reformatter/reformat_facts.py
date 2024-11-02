import sys

input_file = 'Факты.txt'
output_file = 'facts.txt'

def read_facts(filename):
    facts = []
    with open(filename, mode='r', encoding='utf-8') as f:
        for line in f:
            if line[0].isdigit(): # пронумерованные факты
                line = line.rstrip().split(';')
                if (line[2] != ''): # есть описание
                    #line[0] = 'f' + str(len(facts) + 1) # нумерация без нулей в начале
                    line[0] = ''
                    line[1] = line[1].lstrip()
                    line[2] = line[2].lstrip()
                    facts.append(';'.join(line) + '\n')
    # нумерация с нулями в начале
    n = len(facts)
    for i in range(n):
        facts[i] = 'f' + '0' * (len(str(n)) - len(str(i+1))) + str(i+1) + facts[i]
    return facts

def write_facts(filename, facts):
    with open(filename, mode='w', encoding='utf-8') as f:
        f.writelines(facts)

if __name__ == '__main__':
    if (len(sys.argv) == 3):
        input_file = sys.argv[1]
        output_file = sys.argv[2]
    facts = read_facts(input_file)
    write_facts(output_file, facts)