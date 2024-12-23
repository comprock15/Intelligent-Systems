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
    coef = coef.replace(',', '.')
    stored_facts[index] = description
    return f'    (food (name \"{description}\") (certainty-factor {coef}))\n'


# Преобразование строки с нашим правилом в формат для клипса
def rule_to_clips_format(rule):
    (index, lhand, rhand, coef, description) = rule.split(';')

    coef = coef.replace(',', '.')
    string = f'(defrule {index}-fact-doesnt-exist\n'

    cf_string = []
    for i, fact in enumerate(lhand.split(',')):
        string += f'    (available-food (name "{stored_facts[fact]}") (certainty-factor ?cf{i}))\n'
        cf_string.append(f'?cf{i}')

    combine_string = f"(serial-combination-function {coef} (min {' '.join(cf_string)}))" 
    string += f'    (not (exists (available-food (name "{stored_facts[rhand]}"))))\n'
    string += '    =>\n'
    string += f'    (bind ?newcf {combine_string})\n'
    string += f'    (assert (available-food (name "{stored_facts[rhand]}") (certainty-factor ?newcf)))\n'
    string += f'    (assert (sendmessage (str-cat "{description} (" ?newcf ")")))\n)\n'
    return string

def rule_to_clips_format_exists(rule):
    (index, lhand, rhand, coef, description) = rule.split(';')

    coef = coef.replace(',', '.')
    string = f'(defrule {index}-fact-exists\n'

    cf_string = []
    for i, fact in enumerate(lhand.split(',')):
        string += f'    (available-food (name "{stored_facts[fact]}") (certainty-factor ?cf{i}))\n'
        cf_string.append(f'?cf{i}')

    combine_string = f"(serial-combination-function {coef} (min {' '.join(cf_string)}))" 
    string += f'    ?f <- (available-food (name "{stored_facts[rhand]}") (certainty-factor ?cf))\n'
    string += '    =>\n'
    string += f'    (bind ?newcf (parallel-combination-function {combine_string} ?cf))\n'
    string += f'    (modify ?f (certainty-factor ?newcf))\n'
    string += f'    (assert (sendmessage (str-cat "{description} (" ?newcf ")")))\n)\n'
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
                fout.write(rule_to_clips_format_exists(line) + '\n')

    with open("facts-list.txt", 'w', encoding='utf-8') as fout:
        fout.write('\n'.join(stored_facts.values()))