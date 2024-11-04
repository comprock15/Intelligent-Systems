import sys

input_file = 'Факты.txt'
output_file = 'facts.txt'

# нумерация с нулями в начале
zero_beginning = True

def read_facts(filename, zero_beginning=True):
    facts = []
    with open(filename, mode='r', encoding='utf-8') as f:
        for line in f:
            if line[0].isdigit(): # пронумерованные факты
                line = line.rstrip().split(';')
                line[0] = ''
                line[1] = line[1].lstrip()
                # пропуск английского названия
                ind_rus = 0
                for i in range (len(line[2])):
                    if 'а' <= line[2][i].lower() <= 'я':
                        ind_rus = i
                        break
                line[2] = line[2][ind_rus:].split('//')[0] # пропуск комментов
                facts.append(';'.join(line) + '\n')
    # нумерация фактов
    n = len(facts)
    for i in range(n):
        if zero_beginning:
            facts[i] = 'f' + '0' * (len(str(n)) - len(str(i+1))) + str(i+1) + facts[i]
        else:
            facts[i] = 'f' + str(i + 1) + facts[i]
    return facts

def write_facts(filename, facts):
    with open(filename, mode='w', encoding='utf-8') as f:
        f.writelines(facts)

if __name__ == '__main__':
    if (len(sys.argv) == 3):
        input_file = sys.argv[1]
        output_file = sys.argv[2]
    facts = read_facts(input_file, zero_beginning)
    write_facts(output_file, facts)