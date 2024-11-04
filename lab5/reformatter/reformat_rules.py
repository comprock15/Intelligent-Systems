import sys

input_file = 'Правила.txt'
output_file = 'rules.txt'

# нумерация с нулями в начале
zero_beginning = True
# сортировка фактов в посылке
fact_sorting = True

def read_rules(filename, zero_beginning=True):
    rules = []
    max_fact_number = 1
    with open(filename, mode='r', encoding='utf-8') as f:
        for line in f:
            if line[0].isdigit(): # пронумерованные правила
                line = line.rstrip().split(';')
                line[0] = '' # r
                if line[1] != ' ': # есть посылки
                    line[1] = [fact.lstrip()[1:] for fact in line[1].split(',')] # посылки
                    if fact_sorting:
                        line[1] = sorted(line[1], key=lambda fact: int(fact))
                    line[2] = line[2].lstrip()[1:] # следствие
                    max_fact_number = max(max_fact_number, *[int(fact) for fact in line[1]], int(line[2]))
                    line[3] = line[3].lstrip().split('//')[0] # пропуск комментов
                    rules.append([line[0], line[1], line[2], '1,0', line[3] + '\n'])
    # нумерация правил
    n = len(rules)
    m = len(str(max_fact_number))
    for i in range(n):
        if zero_beginning:
            rules[i][0] = 'r' + '0' * (len(str(n)) - len(str(i+1))) + str(i+1)
            rules[i][1] = ','.join(['f' + '0' * (m - len(fact)) + fact for fact in rules[i][1]])
            rules[i][2] = 'f' + '0' * (m - len(rules[i][2])) + rules[i][2]
            rules[i] = ';'.join(rules[i])
        else:
            rules[i][0] = 'r' + str(i+1)
            rules[i][1] = ','.join(['f' + fact for fact in rules[i][1]])
            rules[i][2] = 'f' + rules[i][2]
            rules[i] = ';'.join(rules[i])
    return rules

def write_rules(filename, rules):
    with open(filename, mode='w', encoding='utf-8') as f:
        f.writelines(rules)

if __name__ == '__main__':
    if (len(sys.argv) == 3):
        input_file = sys.argv[1]
        output_file = sys.argv[2]
    rules = read_rules(input_file, zero_beginning)
    write_rules(output_file, rules)