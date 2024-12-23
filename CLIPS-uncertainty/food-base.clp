;========================================================================
; Этот блок реализует логику обмена информацией с графической оболочкой,
; а также механизм остановки и повторного пуска машины вывода
; Русский текст в комментариях разрешён!

(deftemplate ioproxy  ; шаблон факта-посредника для обмена информацией с GUI
	(slot fact-id)        ; теоретически тут id факта для изменения
	(multislot answers)   ; возможные ответы
	(multislot messages)  ; исходящие сообщения
	(slot reaction)       ; возможные ответы пользователя
	(slot value)          ; выбор пользователя
	(slot restore)        ; забыл зачем это поле
)

; Собственно экземпляр факта ioproxy
(deffacts proxy-fact
	(ioproxy
		(fact-id 0112) ; это поле пока что не задействовано
		(value none)   ; значение пустое
		(messages)     ; мультислот messages изначально пуст
	)
)

(defrule clear-messages
	(declare (salience 90))
	?clear-msg-flg <- (clearmessage)
	?proxy <- (ioproxy)
	=>
	(modify ?proxy (messages))
	(retract ?clear-msg-flg)
	(printout t "Messages cleared ..." crlf)	
)

(defrule set-output-and-halt
	(declare (salience 98))
	?current-message <- (sendmessagehalt ?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Message set : " ?new-msg " ... halting ..." crlf)
	(modify ?proxy (messages ?new-msg))
	(retract ?current-message)
	(halt)
)

; Аналогичен предыдущему, но с добавлением сообщения, а не с заменой
(defrule append-output-and-halt
	(declare (salience 99))
	?current-message <- (sendmessagehalt ?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Message appended : " ?new-msg " ... halting ..." crlf)
	(modify ?proxy (messages $?msg-list ?new-msg))
	(retract ?current-message)
	(halt)
)

; 	Аналогичен предыдущему, но с установкой сообщения и продолжением работы (извлекая факт с текущим сообщением)
(defrule set-output-and-proceed
	(declare (salience 100))
	?current-message <- (sendmessage ?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Message appended : " ?new-msg " ... proceeding ..." crlf)
	(modify ?proxy (messages ?new-msg))
	(retract ?current-message)
)

; По аналогии
(defrule append-output-and-proceed
	(declare (salience 101))
	?current-message <- (sendmessage ?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Message appended : " ?new-msg " ... proceeding ..." crlf)
	(modify ?proxy (messages $?msg-list ?new-msg))
	(retract ?current-message)
)

;======================================================================================

(defrule handle-user-input
	?inp <- (user-input $?val)
	=>
	(retract ?inp)
	(assert (available-food $?val))
)

;======================================================================================

(deffacts food-facts
    (food Кастрюля)
    (food Сковорода)
    (food Печь)
    (food Рацион)
    (food Завтрак)
    (food Обед)
    (food Ужин)
    (food Напиток)
    (food Закуска)
    (food Основное блюдо)
    (food Суп)
    (food Десерт)
    (food Мясо)
    (food Сырая рыба)
    (food Жареное мясо)
    (food Жареная рыба)
    (food Лук)
    (food Томат)
    (food Хлеб)
    (food Яйцо)
    (food Капуста)
    (food Морковь)
    (food Сырая говядина)
    (food Сырая свинина)
    (food Сырая баранина)
    (food Сырая курица)
    (food Сырая крольчатина)
    (food Шампиньон)
    (food Вода)
    (food Мука)
    (food Молоко)
    (food Свёкла)
    (food Картофель)
    (food Сырая красная рыба)
    (food Сырая белая рыба)
    (food Рис)
    (food Водоросли нори)
    (food Яблоко)
    (food Ягоды)
    (food Долька арбуза)
    (food Долька тыквы)
    (food Кости)
    (food Чернила каракатицы)
    (food Мёд)
    (food Ветчина)
    (food Сахар)
    (food Какао)
    (food Жареное яйцо)
    (food Жареная курица)
    (food Жареное куриное филе)
    (food Капустный лист)
    (food Говяжья котлета)
    (food Говяжий фарш)
    (food Жареный бекон)
    (food Сырой бекон)
    (food Кусочки жареной баранины)
    (food Жареная баранина)
    (food Сырые кусочки баранины)
    (food Жареная крольчатина)
    (food Тесто)
    (food Печёный картофель)
    (food Сырой ломтик красной рыбы)
    (food Сырой ломтик белой рыбы)
    (food Куриное филе)
    (food Томатный соус)
    (food Сырая паста)
    (food Стейк)
    (food Запечённая ветчина)
    (food Основа пирога)
    (food Шашлычок на шпажке)
    (food Сэндвич с яйцом)
    (food Сэндвич с курицей)
    (food Гамбургер)
    (food Сэндвич с беконом)
    (food Шаурма)
    (food Пельмени)
    (food Картофельные лодочки)
    (food Голубцы)
    (food Суши с красной рыбой)
    (food Суши с белой рыбой)
    (food Ролл)
    (food Фруктовый салат)
    (food Овощной салат)
    (food Грибной салат)
    (food Варёный рис)
    (food Рагу из говядины)
    (food Куриный суп)
    (food Овощной суп)
    (food Рыбное томатное рагу)
    (food Жареный рис с яйцом)
    (food Тыквенный суп)
    (food Уха)
    (food Рамен)
    (food Яичница с беконом)
    (food Спагетти с фрикадельками)
    (food Спагетти с бараниной)
    (food Рис с грибами)
    (food Жареные бараньи рёбрышки с рисом)
    (food Рагу из крольчатины)
    (food Паста с овощами)
    (food Стейк с картофелем)
    (food Рататуй)
    (food Чёрная паста с чернилами каракатицы)
    (food Красная рыба на гриле)
    (food Жаркое из курицы)
    (food Запечённая тыква)
    (food Ветчина в медовом соусе с рисом)
    (food Пастуший пирог)
    (food Сет роллов)
    (food Яблочный пирог)
    (food Чизкейк с ягодами)
    (food Шоколадный пирог)
    (food Медовое печенье)
    (food Ягодное печенье)
    (food Ягодный сорбет)
    (food Арбузное мороженое)
    (food Горячий какао)
    (food Арбузный сок)
    (food Тыквенный сок)
    (food Яблочный компот)
)

(defrule r001
    (available-food Завтрак)
    (available-food Обед)
    (available-food Ужин)
    (not (exists (available-food Рацион)))
    =>
    (assert (available-food Рацион))
    (assert (sendmessage "Рацион состоит из завтрака, обеда и ужина"))
)

(defrule r002
    (available-food Закуска)
    (not (exists (available-food Завтрак)))
    =>
    (assert (available-food Завтрак))
    (assert (sendmessage "Завтрак состоит из закуски"))
)

(defrule r003
    (available-food Напиток)
    (available-food Основное блюдо)
    (available-food Суп)
    (not (exists (available-food Обед)))
    =>
    (assert (available-food Обед))
    (assert (sendmessage "Обед состоит из супа, основного блюда и напитка"))
)

(defrule r004
    (available-food Напиток)
    (available-food Основное блюдо)
    (available-food Десерт)
    (not (exists (available-food Ужин)))
    =>
    (assert (available-food Ужин))
    (assert (sendmessage "Ужин состоит из основного блюда, напитка и десерта"))
)

(defrule r005
    (available-food Сырая говядина)
    (not (exists (available-food Мясо)))
    =>
    (assert (available-food Мясо))
    (assert (sendmessage "Мясо из говядины"))
)

(defrule r006
    (available-food Сырая свинина)
    (not (exists (available-food Мясо)))
    =>
    (assert (available-food Мясо))
    (assert (sendmessage "Мясо из свинины"))
)

(defrule r007
    (available-food Сырая баранина)
    (not (exists (available-food Мясо)))
    =>
    (assert (available-food Мясо))
    (assert (sendmessage "Мясо из баранины"))
)

(defrule r008
    (available-food Сырая курица)
    (not (exists (available-food Мясо)))
    =>
    (assert (available-food Мясо))
    (assert (sendmessage "Мясо из курицы"))
)

(defrule r009
    (available-food Сырая крольчатина)
    (not (exists (available-food Мясо)))
    =>
    (assert (available-food Мясо))
    (assert (sendmessage "Мясо из крольчатины"))
)

(defrule r010
    (available-food Сырая красная рыба)
    (not (exists (available-food Сырая рыба)))
    =>
    (assert (available-food Сырая рыба))
    (assert (sendmessage "Рыба из красной рыбы"))
)

(defrule r011
    (available-food Сырая белая рыба)
    (not (exists (available-food Сырая рыба)))
    =>
    (assert (available-food Сырая рыба))
    (assert (sendmessage "Рыба из белой рыбы"))
)

(defrule r012
    (available-food Сковорода)
    (available-food Мясо)
    (not (exists (available-food Жареное мясо)))
    =>
    (assert (available-food Жареное мясо))
    (assert (sendmessage "Жареное мясо из мяса на сковороде"))
)

(defrule r013
    (available-food Сковорода)
    (available-food Сырая рыба)
    (not (exists (available-food Жареная рыба)))
    =>
    (assert (available-food Жареная рыба))
    (assert (sendmessage "Жареная рыба из рыбы на сковороде"))
)

(defrule r014
    (available-food Сковорода)
    (available-food Яйцо)
    (not (exists (available-food Жареное яйцо)))
    =>
    (assert (available-food Жареное яйцо))
    (assert (sendmessage "Жареное яйцо из яйца на сковороде"))
)

(defrule r015
    (available-food Сковорода)
    (available-food Сырая курица)
    (not (exists (available-food Жареная курица)))
    =>
    (assert (available-food Жареная курица))
    (assert (sendmessage "Жареная курица из сырой курицы на сковороде"))
)

(defrule r016
    (available-food Печь)
    (available-food Сырая курица)
    (not (exists (available-food Жареная курица)))
    =>
    (assert (available-food Жареная курица))
    (assert (sendmessage "Жареная курица из сырой курицы в печи"))
)

(defrule r017
    (available-food Жареная курица)
    (not (exists (available-food Жареное куриное филе)))
    =>
    (assert (available-food Жареное куриное филе))
    (assert (sendmessage "Жареное куриное филе из жареной курицы"))
)

(defrule r018
    (available-food Капуста)
    (not (exists (available-food Капустный лист)))
    =>
    (assert (available-food Капустный лист))
    (assert (sendmessage "Капустный лист из капусты"))
)

(defrule r019
    (available-food Сковорода)
    (available-food Говяжий фарш)
    (not (exists (available-food Говяжья котлета)))
    =>
    (assert (available-food Говяжья котлета))
    (assert (sendmessage "Говяжья котлета из говяжьего фарша на сковороде"))
)

(defrule r020
    (available-food Сырая говядина)
    (not (exists (available-food Говяжий фарш)))
    =>
    (assert (available-food Говяжий фарш))
    (assert (sendmessage "Говяжий фарш из говядины"))
)

(defrule r021
    (available-food Сковорода)
    (available-food Сырой бекон)
    (not (exists (available-food Жареный бекон)))
    =>
    (assert (available-food Жареный бекон))
    (assert (sendmessage "Жареный бекон из сырого бекона на сковороде"))
)

(defrule r022
    (available-food Печь)
    (available-food Сырой бекон)
    (not (exists (available-food Жареный бекон)))
    =>
    (assert (available-food Жареный бекон))
    (assert (sendmessage "Жареный бекон из сырого бекона в печи"))
)

(defrule r023
    (available-food Сырая свинина)
    (not (exists (available-food Сырой бекон)))
    =>
    (assert (available-food Сырой бекон))
    (assert (sendmessage "Сырой бекон из сырой свинины"))
)

(defrule r024
    (available-food Жареная баранина)
    (not (exists (available-food Кусочки жареной баранины)))
    =>
    (assert (available-food Кусочки жареной баранины))
    (assert (sendmessage "Жареные кусочки баранины из жареной баранины"))
)

(defrule r025
    (available-food Печь)
    (available-food Сырые кусочки баранины)
    (not (exists (available-food Кусочки жареной баранины)))
    =>
    (assert (available-food Кусочки жареной баранины))
    (assert (sendmessage "Жареные кусочки баранины из кусочков сырой баранины и печки"))
)

(defrule r026
    (available-food Сырая баранина)
    (not (exists (available-food Сырые кусочки баранины)))
    =>
    (assert (available-food Сырые кусочки баранины))
    (assert (sendmessage "Кусочки баранины из баранины"))
)

(defrule r027
    (available-food Сковорода)
    (available-food Сырая баранина)
    (not (exists (available-food Жареная баранина)))
    =>
    (assert (available-food Жареная баранина))
    (assert (sendmessage "Жареная баранина из баранины на сковороде"))
)

(defrule r028
    (available-food Печь)
    (available-food Сырая баранина)
    (not (exists (available-food Жареная баранина)))
    =>
    (assert (available-food Жареная баранина))
    (assert (sendmessage "Жареная баранина из баранины в печи"))
)

(defrule r029
    (available-food Сковорода)
    (available-food Сырая крольчатина)
    (not (exists (available-food Жареная крольчатина)))
    =>
    (assert (available-food Жареная крольчатина))
    (assert (sendmessage "Жареная крольчатина из крольчатины на сковороде"))
)

(defrule r030
    (available-food Печь)
    (available-food Сырая крольчатина)
    (not (exists (available-food Жареная крольчатина)))
    =>
    (assert (available-food Жареная крольчатина))
    (assert (sendmessage "Жареная крольчатина из крольчатины в печи"))
)

(defrule r031
    (available-food Вода)
    (available-food Мука)
    (not (exists (available-food Тесто)))
    =>
    (assert (available-food Тесто))
    (assert (sendmessage "Тесто из муки и воды"))
)

(defrule r032
    (available-food Яйцо)
    (available-food Мука)
    (not (exists (available-food Тесто)))
    =>
    (assert (available-food Тесто))
    (assert (sendmessage "Тесто из муки и яйца"))
)

(defrule r033
    (available-food Печь)
    (available-food Картофель)
    (not (exists (available-food Печёный картофель)))
    =>
    (assert (available-food Печёный картофель))
    (assert (sendmessage "Печёный картофель из картофеля в печи"))
)

(defrule r034
    (available-food Сковорода)
    (available-food Картофель)
    (not (exists (available-food Печёный картофель)))
    =>
    (assert (available-food Печёный картофель))
    (assert (sendmessage "Печёный картофель из картофеля на сковороде"))
)

(defrule r035
    (available-food Сырая красная рыба)
    (not (exists (available-food Сырой ломтик красной рыбы)))
    =>
    (assert (available-food Сырой ломтик красной рыбы))
    (assert (sendmessage "Ломтик красной рыбы из красной рыбы"))
)

(defrule r036
    (available-food Сырая белая рыба)
    (not (exists (available-food Сырой ломтик белой рыбы)))
    =>
    (assert (available-food Сырой ломтик белой рыбы))
    (assert (sendmessage "Ломтик белой рыбы из белой рыбы"))
)

(defrule r037
    (available-food Сырая курица)
    (not (exists (available-food Куриное филе)))
    =>
    (assert (available-food Куриное филе))
    (assert (sendmessage "Куриное филе из курицы"))
)

(defrule r038
    (available-food Кастрюля)
    (available-food Томат)
    (not (exists (available-food Томатный соус)))
    =>
    (assert (available-food Томатный соус))
    (assert (sendmessage "Томатный соус из томатов в кастрюле"))
)

(defrule r039
    (available-food Тесто)
    (not (exists (available-food Сырая паста)))
    =>
    (assert (available-food Сырая паста))
    (assert (sendmessage "Сырая паста из теста"))
)

(defrule r040
    (available-food Сковорода)
    (available-food Сырая говядина)
    (not (exists (available-food Стейк)))
    =>
    (assert (available-food Стейк))
    (assert (sendmessage "Стейк из говядины на сковороде"))
)

(defrule r041
    (available-food Сковорода)
    (available-food Ветчина)
    (not (exists (available-food Запечённая ветчина)))
    =>
    (assert (available-food Запечённая ветчина))
    (assert (sendmessage "Запечённая ветчина из ветчины на сковороде"))
)

(defrule r042
    (available-food Печь)
    (available-food Ветчина)
    (not (exists (available-food Запечённая ветчина)))
    =>
    (assert (available-food Запечённая ветчина))
    (assert (sendmessage "Запечённая ветчина из ветчины в печи"))
)

(defrule r043
    (available-food Вода)
    (available-food Мука)
    (not (exists (available-food Основа пирога)))
    =>
    (assert (available-food Основа пирога))
    (assert (sendmessage "Основа для пирога из воды и муки"))
)

(defrule r044
    (available-food Мука)
    (available-food Молоко)
    (not (exists (available-food Основа пирога)))
    =>
    (assert (available-food Основа пирога))
    (assert (sendmessage "Основа для пирога из молока и муки"))
)

(defrule r045
    (available-food Лук)
    (available-food Томат)
    (available-food Жареная курица)
    (not (exists (available-food Шашлычок на шпажке)))
    =>
    (assert (available-food Шашлычок на шпажке))
    (assert (sendmessage "Шашлычок на шпажке из жареной курицы, лука и томата"))
)

(defrule r046
    (available-food Шашлычок на шпажке)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Шашлычок на шпажке это закуска"))
)

(defrule r047
    (available-food Хлеб)
    (available-food Жареное яйцо)
    (not (exists (available-food Сэндвич с яйцом)))
    =>
    (assert (available-food Сэндвич с яйцом))
    (assert (sendmessage "Сэндвич с яйцом из хлеба и жареного яйца"))
)

(defrule r048
    (available-food Сэндвич с яйцом)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Сэндвич с яйцом это закуска"))
)

(defrule r049
    (available-food Хлеб)
    (available-food Морковь)
    (available-food Жареное куриное филе)
    (available-food Капустный лист)
    (not (exists (available-food Сэндвич с курицей)))
    =>
    (assert (available-food Сэндвич с курицей))
    (assert (sendmessage "Сэндвич с курицей из хлеба, листа капусты, жареного куриного филе и моркови"))
)

(defrule r050
    (available-food Сэндвич с курицей)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Сэндвич с курицей это закуска"))
)

(defrule r051
    (available-food Лук)
    (available-food Томат)
    (available-food Хлеб)
    (available-food Капустный лист)
    (available-food Говяжья котлета)
    (not (exists (available-food Гамбургер)))
    =>
    (assert (available-food Гамбургер))
    (assert (sendmessage "Гамбургер из хлеба, говяжьей котлеты, томата, лука и листа капусты"))
)

(defrule r052
    (available-food Гамбургер)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Гамбургер это основное блюдо"))
)

(defrule r053
    (available-food Томат)
    (available-food Хлеб)
    (available-food Капустный лист)
    (available-food Жареный бекон)
    (not (exists (available-food Сэндвич с беконом)))
    =>
    (assert (available-food Сэндвич с беконом))
    (assert (sendmessage "Сэндвич с беконом из хлеба, жареного бекона, томата и листа капусты"))
)

(defrule r054
    (available-food Сэндвич с беконом)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Сэндвич с беконом это закуска"))
)

(defrule r055
    (available-food Лук)
    (available-food Хлеб)
    (available-food Капустный лист)
    (available-food Кусочки жареной баранины)
    (not (exists (available-food Шаурма)))
    =>
    (assert (available-food Шаурма))
    (assert (sendmessage "Шаурма из хлеба, лука, листа капусты и кусочков жареной баранины"))
)

(defrule r056
    (available-food Шаурма)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Шаурма это основное блюдо"))
)

(defrule r057
    (available-food Шаурма)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Шаурма это закуска"))
)

(defrule r058
    (available-food Мясо)
    (available-food Лук)
    (available-food Тесто)
    (not (exists (available-food Пельмени)))
    =>
    (assert (available-food Пельмени))
    (assert (sendmessage "Пельмени из теста, лука и мяса"))
)

(defrule r059
    (available-food Лук)
    (available-food Шампиньон)
    (available-food Тесто)
    (not (exists (available-food Пельмени)))
    =>
    (assert (available-food Пельмени))
    (assert (sendmessage "Пельмени из теста, лука и шампиньонов"))
)

(defrule r060
    (available-food Пельмени)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Пельмени это основное блюдо"))
)

(defrule r061
    (available-food Молоко)
    (available-food Говяжья котлета)
    (available-food Печёный картофель)
    (not (exists (available-food Картофельные лодочки)))
    =>
    (assert (available-food Картофельные лодочки))
    (assert (sendmessage "Картофельные лодочки из печёного картофеля, говяжьей котлеты и молока"))
)

(defrule r062
    (available-food Картофельные лодочки)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Картофельные лодочки это основное блюдо"))
)

(defrule r063
    (available-food Кастрюля)
    (available-food Мясо)
    (available-food Лук)
    (available-food Яйцо)
    (available-food Капуста)
    (not (exists (available-food Голубцы)))
    =>
    (assert (available-food Голубцы))
    (assert (sendmessage "Голубцы в кастрюле из капусты с мясом, яйцом и луком"))
)

(defrule r064
    (available-food Кастрюля)
    (available-food Мясо)
    (available-food Капуста)
    (available-food Морковь)
    (not (exists (available-food Голубцы)))
    =>
    (assert (available-food Голубцы))
    (assert (sendmessage "Голубцы в кастрюле из капусты с мясом и морковью"))
)

(defrule r065
    (available-food Кастрюля)
    (available-food Мясо)
    (available-food Капуста)
    (available-food Шампиньон)
    (not (exists (available-food Голубцы)))
    =>
    (assert (available-food Голубцы))
    (assert (sendmessage "Голубцы в кастрюле из капусты с мясом и грибами"))
)

(defrule r066
    (available-food Голубцы)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Голубцы это основное блюдо"))
)

(defrule r067
    (available-food Сырой ломтик красной рыбы)
    (available-food Варёный рис)
    (not (exists (available-food Суши с красной рыбой)))
    =>
    (assert (available-food Суши с красной рыбой))
    (assert (sendmessage "Суши с красной рыбой из ломтика красной рыбы и варёного риса"))
)

(defrule r068
    (available-food Суши с красной рыбой)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Суши с красной рыбой это закуска"))
)

(defrule r069
    (available-food Сырой ломтик белой рыбы)
    (available-food Варёный рис)
    (not (exists (available-food Суши с белой рыбой)))
    =>
    (assert (available-food Суши с белой рыбой))
    (assert (sendmessage "Суши с белой рыбой из ломтика белой рыбы и варёного риса"))
)

(defrule r070
    (available-food Суши с белой рыбой)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Суши с белой рыбой это закуска"))
)

(defrule r071
    (available-food Морковь)
    (available-food Водоросли нори)
    (available-food Варёный рис)
    (not (exists (available-food Ролл)))
    =>
    (assert (available-food Ролл))
    (assert (sendmessage "Ролл из моркови, варёного риса и листа нори"))
)

(defrule r072
    (available-food Ролл)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Ролл это закуска"))
)

(defrule r073
    (available-food Яблоко)
    (available-food Ягоды)
    (available-food Долька арбуза)
    (not (exists (available-food Фруктовый салат)))
    =>
    (assert (available-food Фруктовый салат))
    (assert (sendmessage "Фруктовый салат из ягод, яблока и долек арбуза"))
)

(defrule r074
    (available-food Яблоко)
    (available-food Ягоды)
    (available-food Долька тыквы)
    (not (exists (available-food Фруктовый салат)))
    =>
    (assert (available-food Фруктовый салат))
    (assert (sendmessage "Фруктовый салат из ягод, яблока, долек тыквы"))
)

(defrule r075
    (available-food Фруктовый салат)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Фруктовый салат это десерт"))
)

(defrule r076
    (available-food Томат)
    (available-food Свёкла)
    (available-food Капустный лист)
    (not (exists (available-food Овощной салат)))
    =>
    (assert (available-food Овощной салат))
    (assert (sendmessage "Овощной салат из томата, листа капусты и свёклы"))
)

(defrule r077
    (available-food Томат)
    (available-food Морковь)
    (available-food Капустный лист)
    (not (exists (available-food Овощной салат)))
    =>
    (assert (available-food Овощной салат))
    (assert (sendmessage "Овощной салат из томата, листа капусты и моркови"))
)

(defrule r078
    (available-food Лук)
    (available-food Томат)
    (available-food Капустный лист)
    (not (exists (available-food Овощной салат)))
    =>
    (assert (available-food Овощной салат))
    (assert (sendmessage "Овощной салат из томата, листа капусты и лука"))
)

(defrule r079
    (available-food Овощной салат)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Овощной салат это закуска"))
)

(defrule r080
    (available-food Шампиньон)
    (available-food Капустный лист)
    (not (exists (available-food Грибной салат)))
    =>
    (assert (available-food Грибной салат))
    (assert (sendmessage "Грибной салат из шампиньона и листа капусты"))
)

(defrule r081
    (available-food Грибной салат)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Грибной салат это закуска"))
)

(defrule r082
    (available-food Кастрюля)
    (available-food Рис)
    (not (exists (available-food Варёный рис)))
    =>
    (assert (available-food Варёный рис))
    (assert (sendmessage "Варёный рис в кастрюле из риса"))
)

(defrule r083
    (available-food Кастрюля)
    (available-food Морковь)
    (available-food Картофель)
    (available-food Говяжий фарш)
    (not (exists (available-food Рагу из говядины)))
    =>
    (assert (available-food Рагу из говядины))
    (assert (sendmessage "Рагу из говядины в кастрюле из говяжьего фарша, моркови и картофеля"))
)

(defrule r084
    (available-food Рагу из говядины)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Рагу из говядины это суп"))
)

(defrule r085
    (available-food Кастрюля)
    (available-food Лук)
    (available-food Капуста)
    (available-food Морковь)
    (available-food Куриное филе)
    (not (exists (available-food Куриный суп)))
    =>
    (assert (available-food Куриный суп))
    (assert (sendmessage "Куриный суп в кастрюле из моркови, лука, капусты и куриного филе"))
)

(defrule r086
    (available-food Куриный суп)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Куриный суп это суп"))
)

(defrule r087
    (available-food Кастрюля)
    (available-food Томат)
    (available-food Капуста)
    (available-food Свёкла)
    (available-food Картофель)
    (not (exists (available-food Овощной суп)))
    =>
    (assert (available-food Овощной суп))
    (assert (sendmessage "Овощной суп в кастрюле из свёклы, картофеля, томата и капусты"))
)

(defrule r088
    (available-food Кастрюля)
    (available-food Лук)
    (available-food Капуста)
    (available-food Свёкла)
    (available-food Картофель)
    (not (exists (available-food Овощной суп)))
    =>
    (assert (available-food Овощной суп))
    (assert (sendmessage "Овощной суп в кастрюле из свёклы, картофеля, лука и капусты"))
)

(defrule r089
    (available-food Кастрюля)
    (available-food Томат)
    (available-food Морковь)
    (available-food Свёкла)
    (available-food Картофель)
    (not (exists (available-food Овощной суп)))
    =>
    (assert (available-food Овощной суп))
    (assert (sendmessage "Овощной суп в кастрюле из свёклы, картофеля, томата и моркови"))
)

(defrule r090
    (available-food Кастрюля)
    (available-food Лук)
    (available-food Морковь)
    (available-food Свёкла)
    (available-food Картофель)
    (not (exists (available-food Овощной суп)))
    =>
    (assert (available-food Овощной суп))
    (assert (sendmessage "Овощной суп в кастрюле из свёклы, картофеля, лука и моркови"))
)

(defrule r091
    (available-food Овощной суп)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Овощной суп это суп"))
)

(defrule r092
    (available-food Кастрюля)
    (available-food Сырая рыба)
    (available-food Лук)
    (available-food Томатный соус)
    (not (exists (available-food Рыбное томатное рагу)))
    =>
    (assert (available-food Рыбное томатное рагу))
    (assert (sendmessage "Рыбное томатное рагу в кастрюле из рыбы, томатного соуса и лука"))
)

(defrule r093
    (available-food Рыбное томатное рагу)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Рыбное томатное рагу это суп"))
)

(defrule r094
    (available-food Сковорода)
    (available-food Лук)
    (available-food Яйцо)
    (available-food Морковь)
    (available-food Рис)
    (not (exists (available-food Жареный рис с яйцом)))
    =>
    (assert (available-food Жареный рис с яйцом))
    (assert (sendmessage "Жареный рис с яйцом на сковороде из риса, яйца, лука и моркови"))
)

(defrule r095
    (available-food Жареный рис с яйцом)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Жареный рис с яйцом это основное блюдо"))
)

(defrule r096
    (available-food Кастрюля)
    (available-food Капуста)
    (available-food Сырая свинина)
    (available-food Молоко)
    (available-food Долька тыквы)
    (not (exists (available-food Тыквенный суп)))
    =>
    (assert (available-food Тыквенный суп))
    (assert (sendmessage "Тыквенный суп в кастрюле из тыквы, молока, капусты и свинины"))
)

(defrule r097
    (available-food Тыквенный суп)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Тыквенный суп это суп"))
)

(defrule r098
    (available-food Кастрюля)
    (available-food Томат)
    (available-food Яйцо)
    (available-food Картофель)
    (available-food Сырая белая рыба)
    (not (exists (available-food Уха)))
    =>
    (assert (available-food Уха))
    (assert (sendmessage "Уха в кастрюле из ломтиков сырой белой рыбы, томатов, яйца и картофеля"))
)

(defrule r099
    (available-food Кастрюля)
    (available-food Лук)
    (available-food Яйцо)
    (available-food Картофель)
    (available-food Сырая белая рыба)
    (not (exists (available-food Уха)))
    =>
    (assert (available-food Уха))
    (assert (sendmessage "Уха в кастрюле из ломтиков сырой белой рыбы, лука, яйца и картофеля"))
)

(defrule r100
    (available-food Уха)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Уха это суп"))
)

(defrule r101
    (available-food Кастрюля)
    (available-food Сырая говядина)
    (available-food Водоросли нори)
    (available-food Жареное яйцо)
    (available-food Сырая паста)
    (not (exists (available-food Рамен)))
    =>
    (assert (available-food Рамен))
    (assert (sendmessage "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и говядины"))
)

(defrule r102
    (available-food Кастрюля)
    (available-food Сырая свинина)
    (available-food Водоросли нори)
    (available-food Жареное яйцо)
    (available-food Сырая паста)
    (not (exists (available-food Рамен)))
    =>
    (assert (available-food Рамен))
    (assert (sendmessage "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и свинины"))
)

(defrule r103
    (available-food Кастрюля)
    (available-food Сырая баранина)
    (available-food Водоросли нори)
    (available-food Жареное яйцо)
    (available-food Сырая паста)
    (not (exists (available-food Рамен)))
    =>
    (assert (available-food Рамен))
    (assert (sendmessage "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и баранины"))
)

(defrule r104
    (available-food Кастрюля)
    (available-food Сырая курица)
    (available-food Водоросли нори)
    (available-food Жареное яйцо)
    (available-food Сырая паста)
    (not (exists (available-food Рамен)))
    =>
    (assert (available-food Рамен))
    (assert (sendmessage "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и курицы"))
)

(defrule r105
    (available-food Рамен)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Рамен это суп"))
)

(defrule r106
    (available-food Жареное яйцо)
    (available-food Жареный бекон)
    (not (exists (available-food Яичница с беконом)))
    =>
    (assert (available-food Яичница с беконом))
    (assert (sendmessage "Яичница с беконом из жареного яйца и жареного бекона"))
)

(defrule r107
    (available-food Яичница с беконом)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Яичница с беконом это закуска"))
)

(defrule r108
    (available-food Сковорода)
    (available-food Говяжий фарш)
    (available-food Томатный соус)
    (available-food Сырая паста)
    (not (exists (available-food Спагетти с фрикадельками)))
    =>
    (assert (available-food Спагетти с фрикадельками))
    (assert (sendmessage "Спагетти с фрикадельками на сковороде из говяжьего фарша, томатного соуса и сырой пасты"))
)

(defrule r109
    (available-food Спагетти с фрикадельками)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Спагетти с фрикадельками это основное блюдо"))
)

(defrule r110
    (available-food Сковорода)
    (available-food Сырые кусочки баранины)
    (available-food Томатный соус)
    (available-food Сырая паста)
    (not (exists (available-food Спагетти с бараниной)))
    =>
    (assert (available-food Спагетти с бараниной))
    (assert (sendmessage "Спагетти с бараниной на сковороде из кусочков баранины, томатного соуса и сырой пасты"))
)

(defrule r111
    (available-food Спагетти с бараниной)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Спагетти с бараниной это основное блюдо"))
)

(defrule r112
    (available-food Кастрюля)
    (available-food Морковь)
    (available-food Шампиньон)
    (available-food Рис)
    (not (exists (available-food Рис с грибами)))
    =>
    (assert (available-food Рис с грибами))
    (assert (sendmessage "Рис с грибами в кастрюле из шампиньонов, риса и моркови"))
)

(defrule r113
    (available-food Кастрюля)
    (available-food Шампиньон)
    (available-food Картофель)
    (available-food Рис)
    (not (exists (available-food Рис с грибами)))
    =>
    (assert (available-food Рис с грибами))
    (assert (sendmessage "Рис с грибами в кастрюле из шампиньонов, риса и картофеля"))
)

(defrule r114
    (available-food Рис с грибами)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Рис с грибами это основное блюдо"))
)

(defrule r115
    (available-food Томат)
    (available-food Свёкла)
    (available-food Кусочки жареной баранины)
    (available-food Варёный рис)
    (not (exists (available-food Жареные бараньи рёбрышки с рисом)))
    =>
    (assert (available-food Жареные бараньи рёбрышки с рисом))
    (assert (sendmessage "Жареные бараньи ребрышки с рисом из жареных кусочков баранины, томатов, свёклы и варёного риса"))
)

(defrule r116
    (available-food Жареные бараньи рёбрышки с рисом)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Жареные бараньи ребрышки с рисом это основное блюдо"))
)

(defrule r117
    (available-food Кастрюля)
    (available-food Морковь)
    (available-food Сырая крольчатина)
    (available-food Шампиньон)
    (available-food Картофель)
    (not (exists (available-food Рагу из крольчатины)))
    =>
    (assert (available-food Рагу из крольчатины))
    (assert (sendmessage "Рагу из крольчатины в кастрюле из крольчатины, шампиньона, картофеля и моркови"))
)

(defrule r118
    (available-food Кастрюля)
    (available-food Томат)
    (available-food Сырая крольчатина)
    (available-food Шампиньон)
    (available-food Картофель)
    (not (exists (available-food Рагу из крольчатины)))
    =>
    (assert (available-food Рагу из крольчатины))
    (assert (sendmessage "Рагу из крольчатины в кастрюле из крольчатины, шампиньона, картофеля и томата"))
)

(defrule r119
    (available-food Рагу из крольчатины)
    (not (exists (available-food Суп)))
    =>
    (assert (available-food Суп))
    (assert (sendmessage "Рагу из крольчатины это суп"))
)

(defrule r120
    (available-food Кастрюля)
    (available-food Томат)
    (available-food Капуста)
    (available-food Морковь)
    (available-food Шампиньон)
    (available-food Капустный лист)
    (available-food Сырая паста)
    (not (exists (available-food Паста с овощами)))
    =>
    (assert (available-food Паста с овощами))
    (assert (sendmessage "Паста с овощами в кастрюле из сырой пасты, моркови, шампиньонов, листа капусты и томата"))
)

(defrule r121
    (available-food Кастрюля)
    (available-food Лук)
    (available-food Капуста)
    (available-food Морковь)
    (available-food Шампиньон)
    (available-food Капустный лист)
    (available-food Сырая паста)
    (not (exists (available-food Паста с овощами)))
    =>
    (assert (available-food Паста с овощами))
    (assert (sendmessage "Паста с овощами в кастрюле из сырой пасты, моркови, шампиньонов, листа капусты и лука"))
)

(defrule r122
    (available-food Паста с овощами)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Паста с овощами это основное блюдо"))
)

(defrule r123
    (available-food Лук)
    (available-food Печёный картофель)
    (available-food Стейк)
    (available-food Варёный рис)
    (not (exists (available-food Стейк с картофелем)))
    =>
    (assert (available-food Стейк с картофелем))
    (assert (sendmessage "Стейк с картофелем из стейка, варёного риса, печёного картофеля и лука"))
)

(defrule r124
    (available-food Стейк с картофелем)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Стейк с картофелем это основное блюдо"))
)

(defrule r125
    (available-food Кастрюля)
    (available-food Лук)
    (available-food Томат)
    (available-food Морковь)
    (available-food Свёкла)
    (not (exists (available-food Рататуй)))
    =>
    (assert (available-food Рататуй))
    (assert (sendmessage "Рататуй в кастрюле из свёклы, томатов, лука и моркови"))
)

(defrule r126
    (available-food Рататуй)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Рататуй это основное блюдо"))
)

(defrule r127
    (available-food Кастрюля)
    (available-food Сырая рыба)
    (available-food Томат)
    (available-food Чернила каракатицы)
    (available-food Сырая паста)
    (not (exists (available-food Чёрная паста с чернилами каракатицы)))
    =>
    (assert (available-food Чёрная паста с чернилами каракатицы))
    (assert (sendmessage "Чёрная паста с чернилами каракатицы в кастрюле из сырой пасты, чернил каракатицы, томатов и рыбы"))
)

(defrule r128
    (available-food Чёрная паста с чернилами каракатицы)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Чёрная паста с чернилами каракатицы это основное блюдо"))
)

(defrule r129
    (available-food Сковорода)
    (available-food Лук)
    (available-food Ягоды)
    (available-food Сырой ломтик красной рыбы)
    (not (exists (available-food Красная рыба на гриле)))
    =>
    (assert (available-food Красная рыба на гриле))
    (assert (sendmessage "Красная рыба на гриле в сковороде из ломтиков красной рыбы, ягод и лука"))
)

(defrule r130
    (available-food Красная рыба на гриле)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Красная рыба на гриле это основное блюдо"))
)

(defrule r131
    (available-food Лук)
    (available-food Хлеб)
    (available-food Яйцо)
    (available-food Морковь)
    (available-food Картофель)
    (available-food Жареная курица)
    (not (exists (available-food Жаркое из курицы)))
    =>
    (assert (available-food Жаркое из курицы))
    (assert (sendmessage "Жаркое из курицы из жареной курицы, лука, яйца, хлеба, моркови, картофеля"))
)

(defrule r132
    (available-food Лук)
    (available-food Томат)
    (available-food Хлеб)
    (available-food Яйцо)
    (available-food Картофель)
    (available-food Жареная курица)
    (not (exists (available-food Жаркое из курицы)))
    =>
    (assert (available-food Жаркое из курицы))
    (assert (sendmessage "Жаркое из курицы из жареной курицы, лука, яйца, хлеба, томата, картофеля"))
)

(defrule r133
    (available-food Жаркое из курицы)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Жаркое из курицы это основное блюдо"))
)

(defrule r134
    (available-food Печь)
    (available-food Томат)
    (available-food Морковь)
    (available-food Долька тыквы)
    (available-food Варёный рис)
    (not (exists (available-food Запечённая тыква)))
    =>
    (assert (available-food Запечённая тыква))
    (assert (sendmessage "Запеченная тыква в печи из тыквы, варёного риса, моркови и томата"))
)

(defrule r135
    (available-food Запечённая тыква)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Запечённая тыква это основное блюдо"))
)

(defrule r136
    (available-food Ягоды)
    (available-food Мёд)
    (available-food Запечённая ветчина)
    (available-food Варёный рис)
    (not (exists (available-food Ветчина в медовом соусе с рисом)))
    =>
    (assert (available-food Ветчина в медовом соусе с рисом))
    (assert (sendmessage "Ветчина в медовом соусе с рисом из запечённой ветчины, ягод, мёда и варёного риса"))
)

(defrule r137
    (available-food Ветчина в медовом соусе с рисом)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Ветчина в медовом соусе с рисом это основное блюдо"))
)

(defrule r138
    (available-food Печь)
    (available-food Лук)
    (available-food Молоко)
    (available-food Жареная баранина)
    (available-food Печёный картофель)
    (not (exists (available-food Пастуший пирог)))
    =>
    (assert (available-food Пастуший пирог))
    (assert (sendmessage "Пастуший пирог в печи из молока, жареной баранины, лука, печёного картофеля"))
)

(defrule r139
    (available-food Пастуший пирог)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Пастуший пирог это основное блюдо"))
)

(defrule r140
    (available-food Пастуший пирог)
    (not (exists (available-food Закуска)))
    =>
    (assert (available-food Закуска))
    (assert (sendmessage "Пастуший пирог это закуска"))
)

(defrule r141
    (available-food Суши с красной рыбой)
    (available-food Суши с белой рыбой)
    (available-food Ролл)
    (not (exists (available-food Сет роллов)))
    =>
    (assert (available-food Сет роллов))
    (assert (sendmessage "Сет роллов из суши с красной рыбой, суши с белой рыбой и роллов"))
)

(defrule r142
    (available-food Сет роллов)
    (not (exists (available-food Основное блюдо)))
    =>
    (assert (available-food Основное блюдо))
    (assert (sendmessage "Сет роллов это основное блюдо"))
)

(defrule r143
    (available-food Печь)
    (available-food Мука)
    (available-food Яблоко)
    (available-food Сахар)
    (available-food Основа пирога)
    (not (exists (available-food Яблочный пирог)))
    =>
    (assert (available-food Яблочный пирог))
    (assert (sendmessage "Яблочный пирог в печи из муки, яблок, сахара и основы для пирога"))
)

(defrule r144
    (available-food Яблочный пирог)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Яблочный пирог это десерт"))
)

(defrule r145
    (available-food Печь)
    (available-food Молоко)
    (available-food Ягоды)
    (available-food Основа пирога)
    (not (exists (available-food Чизкейк с ягодами)))
    =>
    (assert (available-food Чизкейк с ягодами))
    (assert (sendmessage "Чизкейк с ягодами в печи из ягод, молока и основы для пирога"))
)

(defrule r146
    (available-food Чизкейк с ягодами)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Чизкейк с ягодами это десерт"))
)

(defrule r147
    (available-food Печь)
    (available-food Молоко)
    (available-food Сахар)
    (available-food Какао)
    (available-food Основа пирога)
    (not (exists (available-food Шоколадный пирог)))
    =>
    (assert (available-food Шоколадный пирог))
    (assert (sendmessage "Шоколадный пирог в печи из какао, молока, сахара и основы для пирога"))
)

(defrule r148
    (available-food Шоколадный пирог)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Шоколадный пирог это десерт"))
)

(defrule r149
    (available-food Печь)
    (available-food Мёд)
    (available-food Тесто)
    (not (exists (available-food Медовое печенье)))
    =>
    (assert (available-food Медовое печенье))
    (assert (sendmessage "Медовое печенье в печи из мёда и теста"))
)

(defrule r150
    (available-food Медовое печенье)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Медовое печенье это десерт"))
)

(defrule r151
    (available-food Печь)
    (available-food Ягоды)
    (available-food Сахар)
    (available-food Тесто)
    (not (exists (available-food Ягодное печенье)))
    =>
    (assert (available-food Ягодное печенье))
    (assert (sendmessage "Ягодное печенье в печи из ягод, сахара и теста"))
)

(defrule r152
    (available-food Ягодное печенье)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Ягодное печенье это десерт"))
)

(defrule r153
    (available-food Кастрюля)
    (available-food Яйцо)
    (available-food Молоко)
    (available-food Ягоды)
    (available-food Сахар)
    (not (exists (available-food Ягодный сорбет)))
    =>
    (assert (available-food Ягодный сорбет))
    (assert (sendmessage "Ягодный сорбет в кастрюле из ягод, молока, яйца и сахара"))
)

(defrule r154
    (available-food Ягодный сорбет)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Ягодный сорбет это десерт"))
)

(defrule r155
    (available-food Вода)
    (available-food Долька арбуза)
    (available-food Сахар)
    (not (exists (available-food Арбузное мороженое)))
    =>
    (assert (available-food Арбузное мороженое))
    (assert (sendmessage "Арбузное мороженое из воды, арбуза и сахара"))
)

(defrule r156
    (available-food Арбузное мороженое)
    (not (exists (available-food Десерт)))
    =>
    (assert (available-food Десерт))
    (assert (sendmessage "Арбузное мороженое это десерт"))
)

(defrule r157
    (available-food Кастрюля)
    (available-food Молоко)
    (available-food Сахар)
    (available-food Какао)
    (not (exists (available-food Горячий какао)))
    =>
    (assert (available-food Горячий какао))
    (assert (sendmessage "Горячий какао в кастрюле из молока, какао и сахара"))
)

(defrule r158
    (available-food Горячий какао)
    (not (exists (available-food Напиток)))
    =>
    (assert (available-food Напиток))
    (assert (sendmessage "Горячий какао это напиток"))
)

(defrule r159
    (available-food Долька арбуза)
    (available-food Сахар)
    (not (exists (available-food Арбузный сок)))
    =>
    (assert (available-food Арбузный сок))
    (assert (sendmessage "Арбузный сок из арбуза и сахара"))
)

(defrule r160
    (available-food Арбузный сок)
    (not (exists (available-food Напиток)))
    =>
    (assert (available-food Напиток))
    (assert (sendmessage "Арбузный сок это напиток"))
)

(defrule r161
    (available-food Морковь)
    (available-food Долька тыквы)
    (available-food Сахар)
    (not (exists (available-food Тыквенный сок)))
    =>
    (assert (available-food Тыквенный сок))
    (assert (sendmessage "Тыквенный сок из тыквы и моркови и сахара"))
)

(defrule r162
    (available-food Тыквенный сок)
    (not (exists (available-food Напиток)))
    =>
    (assert (available-food Напиток))
    (assert (sendmessage "Тыквенный сок это напиток"))
)

(defrule r163
    (available-food Яблоко)
    (available-food Сахар)
    (not (exists (available-food Яблочный компот)))
    =>
    (assert (available-food Яблочный компот))
    (assert (sendmessage "Яблочный компот в кастрюле из яблок и сахара"))
)

(defrule r164
    (available-food Яблочный компот)
    (not (exists (available-food Напиток)))
    =>
    (assert (available-food Напиток))
    (assert (sendmessage "Яблочный компот это напиток"))
)

