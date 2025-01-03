# -*- coding: utf-8 -*-

# Путь к файлу с фактами
facts_path = 'facts.txt'

# Путь к файлу с правилами
rules_path = 'rules.txt'

# Имя выходного файла
output_file = 'facts-rules.clp'

###################################

# Словарь с фактами (чтоб парсить правила)
stored_facts = {}

# Преобразование строки с нашим фактом в формат для клипса
def fact_to_clips_format(fact):
    (index, coef, description) = fact.split(';')
    stored_facts[index] = description
    return f'    (food {description})\n'


# Преобразование строки с нашим правилом в формат для клипса
def rule_to_clips_format(rule):
    (index, lhand, rhand, coef, description) = rule.split(';')
    
    string = f'(defrule {index}\n'

    for fact in lhand.split(','):
        string += f'    (available-food {stored_facts[fact]})\n'

    string += f'    (not (exists (available-food {stored_facts[rhand]})))\n'
    string += '    =>\n'
    string += f'    (assert (available-food {stored_facts[rhand]}))\n'
    string += f'    (assert (sendmessage "{description}"))\n)\n'
    return string


# Функция main просто для красоты
if __name__ == '__main__':
    with open(output_file, 'w', encoding='utf-8') as fout:
        # Парсим факты
        fout.write('(deffacts food-facts\n')
        with open(facts_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.rstrip() # убрали \n
                clips_line = fact_to_clips_format(line)
                fout.write(clips_line)
        fout.write(')\n\n')

        # Парсим правила
        with open(rules_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.rstrip()
                fout.write(rule_to_clips_format(line) + '\n')

    with open("facts-list.txt", 'w', encoding='utf-8') as fout:
        fout.write('\n'.join(stored_facts.values()))