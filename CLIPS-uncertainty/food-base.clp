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

; (defrule handle-user-input
; 	?inp <- (user-input $?val)
; 	=>
; 	(retract ?inp)
; 	(assert (available-food $?val))
; )

(deftemplate food
    (slot name)
	(slot certainty-factor (type NUMBER))
)

(deftemplate available-food
    (slot name)
	(slot certainty-factor (type NUMBER))
)

;===========================Коэффициенты уверенности===================================

; Комбинируем два правила с общей гипотезой
(deffunction parallel-combination-function (?cf1 ?cf2)
    (if (and (>= ?cf1 0) (>= ?cf2 0)) then 
        (return (- (+ ?cf1 ?cf2) (* ?cf1 ?cf2)))
    else 
        (if (and (< ?cf1 0) (< ?cf2 0)) then
            (return (+ (+ ?cf1 ?cf2) (* ?cf1 ?cf2)))
        else 
            (return (/ (+ ?cf1 ?cf2) (- 1 (min (abs ?cf1) (abs ?cf2) ))))
        )
    )
)

; Комбинация двух правил, таких, что гипотеза первого является доказательством второго
; Более понятно: умножение cf правила на cf факта
(deffunction serial-combination-function (?cf1 ?cf2)
    (if (> ?cf1 0) then 
        (return (* ?cf1 ?cf2))
    else 
        (return 0)
    )
)

;======================================================================================

(deffacts food-facts
    (food (name "Кастрюля") (certainty-factor 1.0))
    (food (name "Сковорода") (certainty-factor 1.0))
    (food (name "Печь") (certainty-factor 1.0))
    (food (name "Рацион") (certainty-factor 1.0))
    (food (name "Завтрак") (certainty-factor 1.0))
    (food (name "Обед") (certainty-factor 1.0))
    (food (name "Ужин") (certainty-factor 1.0))
    (food (name "Напиток") (certainty-factor 1.0))
    (food (name "Закуска") (certainty-factor 1.0))
    (food (name "Основное блюдо") (certainty-factor 1.0))
    (food (name "Суп") (certainty-factor 1.0))
    (food (name "Десерт") (certainty-factor 1.0))
    (food (name "Мясо") (certainty-factor 1.0))
    (food (name "Сырая рыба") (certainty-factor 1.0))
    (food (name "Жареное мясо") (certainty-factor 1.0))
    (food (name "Жареная рыба") (certainty-factor 1.0))
    (food (name "Лук") (certainty-factor 1.0))
    (food (name "Томат") (certainty-factor 1.0))
    (food (name "Хлеб") (certainty-factor 1.0))
    (food (name "Яйцо") (certainty-factor 1.0))
    (food (name "Капуста") (certainty-factor 1.0))
    (food (name "Морковь") (certainty-factor 1.0))
    (food (name "Сырая говядина") (certainty-factor 1.0))
    (food (name "Сырая свинина") (certainty-factor 1.0))
    (food (name "Сырая баранина") (certainty-factor 1.0))
    (food (name "Сырая курица") (certainty-factor 1.0))
    (food (name "Сырая крольчатина") (certainty-factor 1.0))
    (food (name "Шампиньон") (certainty-factor 1.0))
    (food (name "Вода") (certainty-factor 1.0))
    (food (name "Мука") (certainty-factor 1.0))
    (food (name "Молоко") (certainty-factor 1.0))
    (food (name "Свёкла") (certainty-factor 1.0))
    (food (name "Картофель") (certainty-factor 1.0))
    (food (name "Сырая красная рыба") (certainty-factor 1.0))
    (food (name "Сырая белая рыба") (certainty-factor 1.0))
    (food (name "Рис") (certainty-factor 1.0))
    (food (name "Водоросли нори") (certainty-factor 1.0))
    (food (name "Яблоко") (certainty-factor 1.0))
    (food (name "Ягоды") (certainty-factor 1.0))
    (food (name "Долька арбуза") (certainty-factor 1.0))
    (food (name "Долька тыквы") (certainty-factor 1.0))
    (food (name "Кости") (certainty-factor 1.0))
    (food (name "Чернила каракатицы") (certainty-factor 1.0))
    (food (name "Мёд") (certainty-factor 1.0))
    (food (name "Ветчина") (certainty-factor 1.0))
    (food (name "Сахар") (certainty-factor 1.0))
    (food (name "Какао") (certainty-factor 1.0))
    (food (name "Жареное яйцо") (certainty-factor 1.0))
    (food (name "Жареная курица") (certainty-factor 1.0))
    (food (name "Жареное куриное филе") (certainty-factor 1.0))
    (food (name "Капустный лист") (certainty-factor 1.0))
    (food (name "Говяжья котлета") (certainty-factor 1.0))
    (food (name "Говяжий фарш") (certainty-factor 1.0))
    (food (name "Жареный бекон") (certainty-factor 1.0))
    (food (name "Сырой бекон") (certainty-factor 1.0))
    (food (name "Кусочки жареной баранины") (certainty-factor 1.0))
    (food (name "Жареная баранина") (certainty-factor 1.0))
    (food (name "Сырые кусочки баранины") (certainty-factor 1.0))
    (food (name "Жареная крольчатина") (certainty-factor 1.0))
    (food (name "Тесто") (certainty-factor 1.0))
    (food (name "Печёный картофель") (certainty-factor 1.0))
    (food (name "Сырой ломтик красной рыбы") (certainty-factor 1.0))
    (food (name "Сырой ломтик белой рыбы") (certainty-factor 1.0))
    (food (name "Куриное филе") (certainty-factor 1.0))
    (food (name "Томатный соус") (certainty-factor 1.0))
    (food (name "Сырая паста") (certainty-factor 1.0))
    (food (name "Стейк") (certainty-factor 1.0))
    (food (name "Запечённая ветчина") (certainty-factor 1.0))
    (food (name "Основа пирога") (certainty-factor 1.0))
    (food (name "Шашлычок на шпажке") (certainty-factor 1.0))
    (food (name "Сэндвич с яйцом") (certainty-factor 1.0))
    (food (name "Сэндвич с курицей") (certainty-factor 1.0))
    (food (name "Гамбургер") (certainty-factor 1.0))
    (food (name "Сэндвич с беконом") (certainty-factor 1.0))
    (food (name "Шаурма") (certainty-factor 1.0))
    (food (name "Пельмени") (certainty-factor 1.0))
    (food (name "Картофельные лодочки") (certainty-factor 1.0))
    (food (name "Голубцы") (certainty-factor 1.0))
    (food (name "Суши с красной рыбой") (certainty-factor 1.0))
    (food (name "Суши с белой рыбой") (certainty-factor 1.0))
    (food (name "Ролл") (certainty-factor 1.0))
    (food (name "Фруктовый салат") (certainty-factor 1.0))
    (food (name "Овощной салат") (certainty-factor 1.0))
    (food (name "Грибной салат") (certainty-factor 1.0))
    (food (name "Варёный рис") (certainty-factor 1.0))
    (food (name "Рагу из говядины") (certainty-factor 1.0))
    (food (name "Куриный суп") (certainty-factor 1.0))
    (food (name "Овощной суп") (certainty-factor 1.0))
    (food (name "Рыбное томатное рагу") (certainty-factor 1.0))
    (food (name "Жареный рис с яйцом") (certainty-factor 1.0))
    (food (name "Тыквенный суп") (certainty-factor 1.0))
    (food (name "Уха") (certainty-factor 1.0))
    (food (name "Рамен") (certainty-factor 1.0))
    (food (name "Яичница с беконом") (certainty-factor 1.0))
    (food (name "Спагетти с фрикадельками") (certainty-factor 1.0))
    (food (name "Спагетти с бараниной") (certainty-factor 1.0))
    (food (name "Рис с грибами") (certainty-factor 1.0))
    (food (name "Жареные бараньи рёбрышки с рисом") (certainty-factor 1.0))
    (food (name "Рагу из крольчатины") (certainty-factor 1.0))
    (food (name "Паста с овощами") (certainty-factor 1.0))
    (food (name "Стейк с картофелем") (certainty-factor 1.0))
    (food (name "Рататуй") (certainty-factor 1.0))
    (food (name "Чёрная паста с чернилами каракатицы") (certainty-factor 1.0))
    (food (name "Красная рыба на гриле") (certainty-factor 1.0))
    (food (name "Жаркое из курицы") (certainty-factor 1.0))
    (food (name "Запечённая тыква") (certainty-factor 1.0))
    (food (name "Ветчина в медовом соусе с рисом") (certainty-factor 1.0))
    (food (name "Пастуший пирог") (certainty-factor 1.0))
    (food (name "Сет роллов") (certainty-factor 1.0))
    (food (name "Яблочный пирог") (certainty-factor 1.0))
    (food (name "Чизкейк с ягодами") (certainty-factor 1.0))
    (food (name "Шоколадный пирог") (certainty-factor 1.0))
    (food (name "Медовое печенье") (certainty-factor 1.0))
    (food (name "Ягодное печенье") (certainty-factor 1.0))
    (food (name "Ягодный сорбет") (certainty-factor 1.0))
    (food (name "Арбузное мороженое") (certainty-factor 1.0))
    (food (name "Горячий какао") (certainty-factor 1.0))
    (food (name "Арбузный сок") (certainty-factor 1.0))
    (food (name "Тыквенный сок") (certainty-factor 1.0))
    (food (name "Яблочный компот") (certainty-factor 1.0))
)

(defrule r001-fact-doesnt-exist
    ?r <- (available-rule "r001")
    (available-food (name "Завтрак") (certainty-factor ?cf0))
    (available-food (name "Обед") (certainty-factor ?cf1))
    (available-food (name "Ужин") (certainty-factor ?cf2))
    (not (exists (available-food (name "Рацион"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Рацион") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рацион состоит из завтрака, обеда и ужина (Рацион: " ?newcf ")")))
)

(defrule r001-fact-exists
    ?r <- (available-rule "r001")
    (available-food (name "Завтрак") (certainty-factor ?cf0))
    (available-food (name "Обед") (certainty-factor ?cf1))
    (available-food (name "Ужин") (certainty-factor ?cf2))
    ?f <- (available-food (name "Рацион") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рацион состоит из завтрака, обеда и ужина (Рацион: " ?newcf ")")))
)

(defrule r002-fact-doesnt-exist
    ?r <- (available-rule "r002")
    (available-food (name "Закуска") (certainty-factor ?cf0))
    (not (exists (available-food (name "Завтрак"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Завтрак") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Завтрак состоит из закуски (Завтрак: " ?newcf ")")))
)

(defrule r002-fact-exists
    ?r <- (available-rule "r002")
    (available-food (name "Закуска") (certainty-factor ?cf0))
    ?f <- (available-food (name "Завтрак") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Завтрак состоит из закуски (Завтрак: " ?newcf ")")))
)

(defrule r003-fact-doesnt-exist
    ?r <- (available-rule "r003")
    (available-food (name "Напиток") (certainty-factor ?cf0))
    (available-food (name "Основное блюдо") (certainty-factor ?cf1))
    (available-food (name "Суп") (certainty-factor ?cf2))
    (not (exists (available-food (name "Обед"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Обед") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Обед состоит из супа, основного блюда и напитка (Обед: " ?newcf ")")))
)

(defrule r003-fact-exists
    ?r <- (available-rule "r003")
    (available-food (name "Напиток") (certainty-factor ?cf0))
    (available-food (name "Основное блюдо") (certainty-factor ?cf1))
    (available-food (name "Суп") (certainty-factor ?cf2))
    ?f <- (available-food (name "Обед") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Обед состоит из супа, основного блюда и напитка (Обед: " ?newcf ")")))
)

(defrule r004-fact-doesnt-exist
    ?r <- (available-rule "r004")
    (available-food (name "Напиток") (certainty-factor ?cf0))
    (available-food (name "Основное блюдо") (certainty-factor ?cf1))
    (available-food (name "Десерт") (certainty-factor ?cf2))
    (not (exists (available-food (name "Ужин"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Ужин") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ужин состоит из основного блюда, напитка и десерта (Ужин: " ?newcf ")")))
)

(defrule r004-fact-exists
    ?r <- (available-rule "r004")
    (available-food (name "Напиток") (certainty-factor ?cf0))
    (available-food (name "Основное блюдо") (certainty-factor ?cf1))
    (available-food (name "Десерт") (certainty-factor ?cf2))
    ?f <- (available-food (name "Ужин") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ужин состоит из основного блюда, напитка и десерта (Ужин: " ?newcf ")")))
)

(defrule r005-fact-doesnt-exist
    ?r <- (available-rule "r005")
    (available-food (name "Сырая говядина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Мясо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Мясо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Мясо из говядины (Мясо: " ?newcf ")")))
)

(defrule r005-fact-exists
    ?r <- (available-rule "r005")
    (available-food (name "Сырая говядина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Мясо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Мясо из говядины (Мясо: " ?newcf ")")))
)

(defrule r006-fact-doesnt-exist
    ?r <- (available-rule "r006")
    (available-food (name "Сырая свинина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Мясо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Мясо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Мясо из свинины (Мясо: " ?newcf ")")))
)

(defrule r006-fact-exists
    ?r <- (available-rule "r006")
    (available-food (name "Сырая свинина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Мясо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Мясо из свинины (Мясо: " ?newcf ")")))
)

(defrule r007-fact-doesnt-exist
    ?r <- (available-rule "r007")
    (available-food (name "Сырая баранина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Мясо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Мясо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Мясо из баранины (Мясо: " ?newcf ")")))
)

(defrule r007-fact-exists
    ?r <- (available-rule "r007")
    (available-food (name "Сырая баранина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Мясо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Мясо из баранины (Мясо: " ?newcf ")")))
)

(defrule r008-fact-doesnt-exist
    ?r <- (available-rule "r008")
    (available-food (name "Сырая курица") (certainty-factor ?cf0))
    (not (exists (available-food (name "Мясо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Мясо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Мясо из курицы (Мясо: " ?newcf ")")))
)

(defrule r008-fact-exists
    ?r <- (available-rule "r008")
    (available-food (name "Сырая курица") (certainty-factor ?cf0))
    ?f <- (available-food (name "Мясо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Мясо из курицы (Мясо: " ?newcf ")")))
)

(defrule r009-fact-doesnt-exist
    ?r <- (available-rule "r009")
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Мясо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Мясо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Мясо из крольчатины (Мясо: " ?newcf ")")))
)

(defrule r009-fact-exists
    ?r <- (available-rule "r009")
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Мясо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Мясо из крольчатины (Мясо: " ?newcf ")")))
)

(defrule r010-fact-doesnt-exist
    ?r <- (available-rule "r010")
    (available-food (name "Картофель") (certainty-factor ?cf0))
    (not (exists (available-food (name "Сырая рыба"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Сырая рыба") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рыба из красной рыбы (Сырая рыба: " ?newcf ")")))
)

(defrule r010-fact-exists
    ?r <- (available-rule "r010")
    (available-food (name "Картофель") (certainty-factor ?cf0))
    ?f <- (available-food (name "Сырая рыба") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рыба из красной рыбы (Сырая рыба: " ?newcf ")")))
)

(defrule r011-fact-doesnt-exist
    ?r <- (available-rule "r011")
    (available-food (name "Сырая красная рыба") (certainty-factor ?cf0))
    (not (exists (available-food (name "Сырая рыба"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Сырая рыба") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рыба из белой рыбы (Сырая рыба: " ?newcf ")")))
)

(defrule r011-fact-exists
    ?r <- (available-rule "r011")
    (available-food (name "Сырая красная рыба") (certainty-factor ?cf0))
    ?f <- (available-food (name "Сырая рыба") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рыба из белой рыбы (Сырая рыба: " ?newcf ")")))
)

(defrule r012-fact-doesnt-exist
    ?r <- (available-rule "r012")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареное мясо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареное мясо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареное мясо из мяса на сковороде (Жареное мясо: " ?newcf ")")))
)

(defrule r012-fact-exists
    ?r <- (available-rule "r012")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареное мясо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареное мясо из мяса на сковороде (Жареное мясо: " ?newcf ")")))
)

(defrule r013-fact-doesnt-exist
    ?r <- (available-rule "r013")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая рыба") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареная рыба"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареная рыба") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареная рыба из рыбы на сковороде (Жареная рыба: " ?newcf ")")))
)

(defrule r013-fact-exists
    ?r <- (available-rule "r013")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая рыба") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареная рыба") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареная рыба из рыбы на сковороде (Жареная рыба: " ?newcf ")")))
)

(defrule r014-fact-doesnt-exist
    ?r <- (available-rule "r014")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Яйцо") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареное яйцо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.99 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареное яйцо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареное яйцо из яйца на сковороде (Жареное яйцо: " ?newcf ")")))
)

(defrule r014-fact-exists
    ?r <- (available-rule "r014")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Яйцо") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареное яйцо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.99 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареное яйцо из яйца на сковороде (Жареное яйцо: " ?newcf ")")))
)

(defrule r015-fact-doesnt-exist
    ?r <- (available-rule "r015")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая курица") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареная курица"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареная курица") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареная курица из сырой курицы на сковороде (Жареная курица: " ?newcf ")")))
)

(defrule r015-fact-exists
    ?r <- (available-rule "r015")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая курица") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареная курица") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареная курица из сырой курицы на сковороде (Жареная курица: " ?newcf ")")))
)

(defrule r016-fact-doesnt-exist
    ?r <- (available-rule "r016")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырая курица") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареная курица"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.85 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареная курица") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареная курица из сырой курицы в печи (Жареная курица: " ?newcf ")")))
)

(defrule r016-fact-exists
    ?r <- (available-rule "r016")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырая курица") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареная курица") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.85 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареная курица из сырой курицы в печи (Жареная курица: " ?newcf ")")))
)

(defrule r017-fact-doesnt-exist
    ?r <- (available-rule "r017")
    (available-food (name "Жареная курица") (certainty-factor ?cf0))
    (not (exists (available-food (name "Жареное куриное филе"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Жареное куриное филе") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареное куриное филе из жареной курицы (Жареное куриное филе: " ?newcf ")")))
)

(defrule r017-fact-exists
    ?r <- (available-rule "r017")
    (available-food (name "Жареная курица") (certainty-factor ?cf0))
    ?f <- (available-food (name "Жареное куриное филе") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареное куриное филе из жареной курицы (Жареное куриное филе: " ?newcf ")")))
)

(defrule r018-fact-doesnt-exist
    ?r <- (available-rule "r018")
    (available-food (name "Капуста") (certainty-factor ?cf0))
    (not (exists (available-food (name "Капустный лист"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Капустный лист") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Капустный лист из капусты (Капустный лист: " ?newcf ")")))
)

(defrule r018-fact-exists
    ?r <- (available-rule "r018")
    (available-food (name "Капуста") (certainty-factor ?cf0))
    ?f <- (available-food (name "Капустный лист") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Капустный лист из капусты (Капустный лист: " ?newcf ")")))
)

(defrule r019-fact-doesnt-exist
    ?r <- (available-rule "r019")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Говяжий фарш") (certainty-factor ?cf1))
    (not (exists (available-food (name "Говяжья котлета"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1)))
    (assert (available-food (name "Говяжья котлета") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Говяжья котлета из говяжьего фарша на сковороде (Говяжья котлета: " ?newcf ")")))
)

(defrule r019-fact-exists
    ?r <- (available-rule "r019")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Говяжий фарш") (certainty-factor ?cf1))
    ?f <- (available-food (name "Говяжья котлета") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Говяжья котлета из говяжьего фарша на сковороде (Говяжья котлета: " ?newcf ")")))
)

(defrule r020-fact-doesnt-exist
    ?r <- (available-rule "r020")
    (available-food (name "Сырая говядина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Говяжий фарш"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Говяжий фарш") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Говяжий фарш из говядины (Говяжий фарш: " ?newcf ")")))
)

(defrule r020-fact-exists
    ?r <- (available-rule "r020")
    (available-food (name "Сырая говядина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Говяжий фарш") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Говяжий фарш из говядины (Говяжий фарш: " ?newcf ")")))
)

(defrule r021-fact-doesnt-exist
    ?r <- (available-rule "r021")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырой бекон") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареный бекон"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареный бекон") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареный бекон из сырого бекона на сковороде (Жареный бекон: " ?newcf ")")))
)

(defrule r021-fact-exists
    ?r <- (available-rule "r021")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырой бекон") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареный бекон") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареный бекон из сырого бекона на сковороде (Жареный бекон: " ?newcf ")")))
)

(defrule r022-fact-doesnt-exist
    ?r <- (available-rule "r022")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырой бекон") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареный бекон"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареный бекон") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареный бекон из сырого бекона в печи (Жареный бекон: " ?newcf ")")))
)

(defrule r022-fact-exists
    ?r <- (available-rule "r022")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырой бекон") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареный бекон") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареный бекон из сырого бекона в печи (Жареный бекон: " ?newcf ")")))
)

(defrule r023-fact-doesnt-exist
    ?r <- (available-rule "r023")
    (available-food (name "Сырая свинина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Сырой бекон"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Сырой бекон") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сырой бекон из сырой свинины (Сырой бекон: " ?newcf ")")))
)

(defrule r023-fact-exists
    ?r <- (available-rule "r023")
    (available-food (name "Сырая свинина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Сырой бекон") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сырой бекон из сырой свинины (Сырой бекон: " ?newcf ")")))
)

(defrule r024-fact-doesnt-exist
    ?r <- (available-rule "r024")
    (available-food (name "Жареная баранина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Кусочки жареной баранины"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0)))
    (assert (available-food (name "Кусочки жареной баранины") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареные кусочки баранины из жареной баранины (Кусочки жареной баранины: " ?newcf ")")))
)

(defrule r024-fact-exists
    ?r <- (available-rule "r024")
    (available-food (name "Жареная баранина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Кусочки жареной баранины") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареные кусочки баранины из жареной баранины (Кусочки жареной баранины: " ?newcf ")")))
)

(defrule r025-fact-doesnt-exist
    ?r <- (available-rule "r025")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырые кусочки баранины") (certainty-factor ?cf1))
    (not (exists (available-food (name "Кусочки жареной баранины"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1)))
    (assert (available-food (name "Кусочки жареной баранины") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареные кусочки баранины из кусочков сырой баранины и печки (Кусочки жареной баранины: " ?newcf ")")))
)

(defrule r025-fact-exists
    ?r <- (available-rule "r025")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырые кусочки баранины") (certainty-factor ?cf1))
    ?f <- (available-food (name "Кусочки жареной баранины") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареные кусочки баранины из кусочков сырой баранины и печки (Кусочки жареной баранины: " ?newcf ")")))
)

(defrule r026-fact-doesnt-exist
    ?r <- (available-rule "r026")
    (available-food (name "Сырая баранина") (certainty-factor ?cf0))
    (not (exists (available-food (name "Сырые кусочки баранины"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Сырые кусочки баранины") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Кусочки баранины из баранины (Сырые кусочки баранины: " ?newcf ")")))
)

(defrule r026-fact-exists
    ?r <- (available-rule "r026")
    (available-food (name "Сырая баранина") (certainty-factor ?cf0))
    ?f <- (available-food (name "Сырые кусочки баранины") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Кусочки баранины из баранины (Сырые кусочки баранины: " ?newcf ")")))
)

(defrule r027-fact-doesnt-exist
    ?r <- (available-rule "r027")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая баранина") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареная баранина"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареная баранина") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареная баранина из баранины на сковороде (Жареная баранина: " ?newcf ")")))
)

(defrule r027-fact-exists
    ?r <- (available-rule "r027")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая баранина") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареная баранина") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареная баранина из баранины на сковороде (Жареная баранина: " ?newcf ")")))
)

(defrule r028-fact-doesnt-exist
    ?r <- (available-rule "r028")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырая баранина") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареная баранина"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареная баранина") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареная баранина из баранины в печи (Жареная баранина: " ?newcf ")")))
)

(defrule r028-fact-exists
    ?r <- (available-rule "r028")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырая баранина") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареная баранина") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареная баранина из баранины в печи (Жареная баранина: " ?newcf ")")))
)

(defrule r029-fact-doesnt-exist
    ?r <- (available-rule "r029")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареная крольчатина"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареная крольчатина") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареная крольчатина из крольчатины на сковороде (Жареная крольчатина: " ?newcf ")")))
)

(defrule r029-fact-exists
    ?r <- (available-rule "r029")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареная крольчатина") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареная крольчатина из крольчатины на сковороде (Жареная крольчатина: " ?newcf ")")))
)

(defrule r030-fact-doesnt-exist
    ?r <- (available-rule "r030")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf1))
    (not (exists (available-food (name "Жареная крольчатина"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1)))
    (assert (available-food (name "Жареная крольчатина") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареная крольчатина из крольчатины в печи (Жареная крольчатина: " ?newcf ")")))
)

(defrule r030-fact-exists
    ?r <- (available-rule "r030")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf1))
    ?f <- (available-food (name "Жареная крольчатина") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареная крольчатина из крольчатины в печи (Жареная крольчатина: " ?newcf ")")))
)

(defrule r031-fact-doesnt-exist
    ?r <- (available-rule "r031")
    (available-food (name "Вода") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    (not (exists (available-food (name "Тесто"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1)))
    (assert (available-food (name "Тесто") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Тесто из муки и воды (Тесто: " ?newcf ")")))
)

(defrule r031-fact-exists
    ?r <- (available-rule "r031")
    (available-food (name "Вода") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    ?f <- (available-food (name "Тесто") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Тесто из муки и воды (Тесто: " ?newcf ")")))
)

(defrule r032-fact-doesnt-exist
    ?r <- (available-rule "r032")
    (available-food (name "Яйцо") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    (not (exists (available-food (name "Тесто"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1)))
    (assert (available-food (name "Тесто") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Тесто из муки и яйца (Тесто: " ?newcf ")")))
)

(defrule r032-fact-exists
    ?r <- (available-rule "r032")
    (available-food (name "Яйцо") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    ?f <- (available-food (name "Тесто") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Тесто из муки и яйца (Тесто: " ?newcf ")")))
)

(defrule r033-fact-doesnt-exist
    ?r <- (available-rule "r033")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Картофель") (certainty-factor ?cf1))
    (not (exists (available-food (name "Печёный картофель"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1)))
    (assert (available-food (name "Печёный картофель") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Печёный картофель из картофеля в печи (Печёный картофель: " ?newcf ")")))
)

(defrule r033-fact-exists
    ?r <- (available-rule "r033")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Картофель") (certainty-factor ?cf1))
    ?f <- (available-food (name "Печёный картофель") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Печёный картофель из картофеля в печи (Печёный картофель: " ?newcf ")")))
)

(defrule r034-fact-doesnt-exist
    ?r <- (available-rule "r034")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Картофель") (certainty-factor ?cf1))
    (not (exists (available-food (name "Печёный картофель"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1)))
    (assert (available-food (name "Печёный картофель") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Печёный картофель из картофеля на сковороде (Печёный картофель: " ?newcf ")")))
)

(defrule r034-fact-exists
    ?r <- (available-rule "r034")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Картофель") (certainty-factor ?cf1))
    ?f <- (available-food (name "Печёный картофель") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Печёный картофель из картофеля на сковороде (Печёный картофель: " ?newcf ")")))
)

(defrule r035-fact-doesnt-exist
    ?r <- (available-rule "r035")
    (available-food (name "Сырая красная рыба") (certainty-factor ?cf0))
    (not (exists (available-food (name "Сырой ломтик красной рыбы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Сырой ломтик красной рыбы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ломтик красной рыбы из красной рыбы (Сырой ломтик красной рыбы: " ?newcf ")")))
)

(defrule r035-fact-exists
    ?r <- (available-rule "r035")
    (available-food (name "Сырая красная рыба") (certainty-factor ?cf0))
    ?f <- (available-food (name "Сырой ломтик красной рыбы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ломтик красной рыбы из красной рыбы (Сырой ломтик красной рыбы: " ?newcf ")")))
)

(defrule r036-fact-doesnt-exist
    ?r <- (available-rule "r036")
    (available-food (name "Сырая белая рыба") (certainty-factor ?cf0))
    (not (exists (available-food (name "Сырой ломтик белой рыбы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Сырой ломтик белой рыбы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ломтик белой рыбы из белой рыбы (Сырой ломтик белой рыбы: " ?newcf ")")))
)

(defrule r036-fact-exists
    ?r <- (available-rule "r036")
    (available-food (name "Сырая белая рыба") (certainty-factor ?cf0))
    ?f <- (available-food (name "Сырой ломтик белой рыбы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ломтик белой рыбы из белой рыбы (Сырой ломтик белой рыбы: " ?newcf ")")))
)

(defrule r037-fact-doesnt-exist
    ?r <- (available-rule "r037")
    (available-food (name "Сырая курица") (certainty-factor ?cf0))
    (not (exists (available-food (name "Куриное филе"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Куриное филе") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Куриное филе из курицы (Куриное филе: " ?newcf ")")))
)

(defrule r037-fact-exists
    ?r <- (available-rule "r037")
    (available-food (name "Сырая курица") (certainty-factor ?cf0))
    ?f <- (available-food (name "Куриное филе") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Куриное филе из курицы (Куриное филе: " ?newcf ")")))
)

(defrule r038-fact-doesnt-exist
    ?r <- (available-rule "r038")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (not (exists (available-food (name "Томатный соус"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1)))
    (assert (available-food (name "Томатный соус") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Томатный соус из томатов в кастрюле (Томатный соус: " ?newcf ")")))
)

(defrule r038-fact-exists
    ?r <- (available-rule "r038")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    ?f <- (available-food (name "Томатный соус") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Томатный соус из томатов в кастрюле (Томатный соус: " ?newcf ")")))
)

(defrule r039-fact-doesnt-exist
    ?r <- (available-rule "r039")
    (available-food (name "Тесто") (certainty-factor ?cf0))
    (not (exists (available-food (name "Сырая паста"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.4 (min ?cf0)))
    (assert (available-food (name "Сырая паста") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сырая паста из теста (Сырая паста: " ?newcf ")")))
)

(defrule r039-fact-exists
    ?r <- (available-rule "r039")
    (available-food (name "Тесто") (certainty-factor ?cf0))
    ?f <- (available-food (name "Сырая паста") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.4 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сырая паста из теста (Сырая паста: " ?newcf ")")))
)

(defrule r040-fact-doesnt-exist
    ?r <- (available-rule "r040")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая говядина") (certainty-factor ?cf1))
    (not (exists (available-food (name "Стейк"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1)))
    (assert (available-food (name "Стейк") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Стейк из говядины на сковороде (Стейк: " ?newcf ")")))
)

(defrule r040-fact-exists
    ?r <- (available-rule "r040")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырая говядина") (certainty-factor ?cf1))
    ?f <- (available-food (name "Стейк") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Стейк из говядины на сковороде (Стейк: " ?newcf ")")))
)

(defrule r041-fact-doesnt-exist
    ?r <- (available-rule "r041")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Ветчина") (certainty-factor ?cf1))
    (not (exists (available-food (name "Запечённая ветчина"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.65 (min ?cf0 ?cf1)))
    (assert (available-food (name "Запечённая ветчина") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Запечённая ветчина из ветчины на сковороде (Запечённая ветчина: " ?newcf ")")))
)

(defrule r041-fact-exists
    ?r <- (available-rule "r041")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Ветчина") (certainty-factor ?cf1))
    ?f <- (available-food (name "Запечённая ветчина") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.65 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Запечённая ветчина из ветчины на сковороде (Запечённая ветчина: " ?newcf ")")))
)

(defrule r042-fact-doesnt-exist
    ?r <- (available-rule "r042")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Ветчина") (certainty-factor ?cf1))
    (not (exists (available-food (name "Запечённая ветчина"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1)))
    (assert (available-food (name "Запечённая ветчина") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Запечённая ветчина из ветчины в печи (Запечённая ветчина: " ?newcf ")")))
)

(defrule r042-fact-exists
    ?r <- (available-rule "r042")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Ветчина") (certainty-factor ?cf1))
    ?f <- (available-food (name "Запечённая ветчина") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Запечённая ветчина из ветчины в печи (Запечённая ветчина: " ?newcf ")")))
)

(defrule r043-fact-doesnt-exist
    ?r <- (available-rule "r043")
    (available-food (name "Вода") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    (not (exists (available-food (name "Основа пирога"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1)))
    (assert (available-food (name "Основа пирога") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Основа для пирога из воды и муки (Основа пирога: " ?newcf ")")))
)

(defrule r043-fact-exists
    ?r <- (available-rule "r043")
    (available-food (name "Вода") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    ?f <- (available-food (name "Основа пирога") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Основа для пирога из воды и муки (Основа пирога: " ?newcf ")")))
)

(defrule r044-fact-doesnt-exist
    ?r <- (available-rule "r044")
    (available-food (name "Мука") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    (not (exists (available-food (name "Основа пирога"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.65 (min ?cf0 ?cf1)))
    (assert (available-food (name "Основа пирога") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Основа для пирога из молока и муки (Основа пирога: " ?newcf ")")))
)

(defrule r044-fact-exists
    ?r <- (available-rule "r044")
    (available-food (name "Мука") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    ?f <- (available-food (name "Основа пирога") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.65 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Основа для пирога из молока и муки (Основа пирога: " ?newcf ")")))
)

(defrule r045-fact-doesnt-exist
    ?r <- (available-rule "r045")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Жареная курица") (certainty-factor ?cf2))
    (not (exists (available-food (name "Шашлычок на шпажке"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Шашлычок на шпажке") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Шашлычок на шпажке из жареной курицы, лука и томата (Шашлычок на шпажке: " ?newcf ")")))
)

(defrule r045-fact-exists
    ?r <- (available-rule "r045")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Жареная курица") (certainty-factor ?cf2))
    ?f <- (available-food (name "Шашлычок на шпажке") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Шашлычок на шпажке из жареной курицы, лука и томата (Шашлычок на шпажке: " ?newcf ")")))
)

(defrule r046-fact-doesnt-exist
    ?r <- (available-rule "r046")
    (available-food (name "Шашлычок на шпажке") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Шашлычок на шпажке это закуска (Закуска: " ?newcf ")")))
)

(defrule r046-fact-exists
    ?r <- (available-rule "r046")
    (available-food (name "Шашлычок на шпажке") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Шашлычок на шпажке это закуска (Закуска: " ?newcf ")")))
)

(defrule r047-fact-doesnt-exist
    ?r <- (available-rule "r047")
    (available-food (name "Хлеб") (certainty-factor ?cf0))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf1))
    (not (exists (available-food (name "Сэндвич с яйцом"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.95 (min ?cf0 ?cf1)))
    (assert (available-food (name "Сэндвич с яйцом") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сэндвич с яйцом из хлеба и жареного яйца (Сэндвич с яйцом: " ?newcf ")")))
)

(defrule r047-fact-exists
    ?r <- (available-rule "r047")
    (available-food (name "Хлеб") (certainty-factor ?cf0))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf1))
    ?f <- (available-food (name "Сэндвич с яйцом") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.95 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сэндвич с яйцом из хлеба и жареного яйца (Сэндвич с яйцом: " ?newcf ")")))
)

(defrule r048-fact-doesnt-exist
    ?r <- (available-rule "r048")
    (available-food (name "Сэндвич с яйцом") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сэндвич с яйцом это закуска (Закуска: " ?newcf ")")))
)

(defrule r048-fact-exists
    ?r <- (available-rule "r048")
    (available-food (name "Сэндвич с яйцом") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сэндвич с яйцом это закуска (Закуска: " ?newcf ")")))
)

(defrule r049-fact-doesnt-exist
    ?r <- (available-rule "r049")
    (available-food (name "Хлеб") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Жареное куриное филе") (certainty-factor ?cf2))
    (available-food (name "Капустный лист") (certainty-factor ?cf3))
    (not (exists (available-food (name "Сэндвич с курицей"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.95 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Сэндвич с курицей") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сэндвич с курицей из хлеба, листа капусты, жареного куриного филе и моркови (Сэндвич с курицей: " ?newcf ")")))
)

(defrule r049-fact-exists
    ?r <- (available-rule "r049")
    (available-food (name "Хлеб") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Жареное куриное филе") (certainty-factor ?cf2))
    (available-food (name "Капустный лист") (certainty-factor ?cf3))
    ?f <- (available-food (name "Сэндвич с курицей") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.95 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сэндвич с курицей из хлеба, листа капусты, жареного куриного филе и моркови (Сэндвич с курицей: " ?newcf ")")))
)

(defrule r050-fact-doesnt-exist
    ?r <- (available-rule "r050")
    (available-food (name "Сэндвич с курицей") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сэндвич с курицей это закуска (Закуска: " ?newcf ")")))
)

(defrule r050-fact-exists
    ?r <- (available-rule "r050")
    (available-food (name "Сэндвич с курицей") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сэндвич с курицей это закуска (Закуска: " ?newcf ")")))
)

(defrule r051-fact-doesnt-exist
    ?r <- (available-rule "r051")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Хлеб") (certainty-factor ?cf2))
    (available-food (name "Капустный лист") (certainty-factor ?cf3))
    (available-food (name "Говяжья котлета") (certainty-factor ?cf4))
    (not (exists (available-food (name "Гамбургер"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.89 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Гамбургер") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Гамбургер из хлеба, говяжьей котлеты, томата, лука и листа капусты (Гамбургер: " ?newcf ")")))
)

(defrule r051-fact-exists
    ?r <- (available-rule "r051")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Хлеб") (certainty-factor ?cf2))
    (available-food (name "Капустный лист") (certainty-factor ?cf3))
    (available-food (name "Говяжья котлета") (certainty-factor ?cf4))
    ?f <- (available-food (name "Гамбургер") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.89 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Гамбургер из хлеба, говяжьей котлеты, томата, лука и листа капусты (Гамбургер: " ?newcf ")")))
)

(defrule r052-fact-doesnt-exist
    ?r <- (available-rule "r052")
    (available-food (name "Гамбургер") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Гамбургер это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r052-fact-exists
    ?r <- (available-rule "r052")
    (available-food (name "Гамбургер") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Гамбургер это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r053-fact-doesnt-exist
    ?r <- (available-rule "r053")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Хлеб") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    (available-food (name "Жареный бекон") (certainty-factor ?cf3))
    (not (exists (available-food (name "Сэндвич с беконом"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.95 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Сэндвич с беконом") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сэндвич с беконом из хлеба, жареного бекона, томата и листа капусты (Сэндвич с беконом: " ?newcf ")")))
)

(defrule r053-fact-exists
    ?r <- (available-rule "r053")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Хлеб") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    (available-food (name "Жареный бекон") (certainty-factor ?cf3))
    ?f <- (available-food (name "Сэндвич с беконом") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.95 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сэндвич с беконом из хлеба, жареного бекона, томата и листа капусты (Сэндвич с беконом: " ?newcf ")")))
)

(defrule r054-fact-doesnt-exist
    ?r <- (available-rule "r054")
    (available-food (name "Сэндвич с беконом") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сэндвич с беконом это закуска (Закуска: " ?newcf ")")))
)

(defrule r054-fact-exists
    ?r <- (available-rule "r054")
    (available-food (name "Сэндвич с беконом") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сэндвич с беконом это закуска (Закуска: " ?newcf ")")))
)

(defrule r055-fact-doesnt-exist
    ?r <- (available-rule "r055")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Хлеб") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    (available-food (name "Кусочки жареной баранины") (certainty-factor ?cf3))
    (not (exists (available-food (name "Шаурма"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.85 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Шаурма") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Шаурма из хлеба, лука, листа капусты и кусочков жареной баранины (Шаурма: " ?newcf ")")))
)

(defrule r055-fact-exists
    ?r <- (available-rule "r055")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Хлеб") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    (available-food (name "Кусочки жареной баранины") (certainty-factor ?cf3))
    ?f <- (available-food (name "Шаурма") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.85 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Шаурма из хлеба, лука, листа капусты и кусочков жареной баранины (Шаурма: " ?newcf ")")))
)

(defrule r056-fact-doesnt-exist
    ?r <- (available-rule "r056")
    (available-food (name "Шаурма") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Шаурма это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r056-fact-exists
    ?r <- (available-rule "r056")
    (available-food (name "Шаурма") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Шаурма это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r057-fact-doesnt-exist
    ?r <- (available-rule "r057")
    (available-food (name "Шаурма") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Шаурма это закуска (Закуска: " ?newcf ")")))
)

(defrule r057-fact-exists
    ?r <- (available-rule "r057")
    (available-food (name "Шаурма") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Шаурма это закуска (Закуска: " ?newcf ")")))
)

(defrule r058-fact-doesnt-exist
    ?r <- (available-rule "r058")
    (available-food (name "Мясо") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Тесто") (certainty-factor ?cf2))
    (not (exists (available-food (name "Пельмени"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Пельмени") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Пельмени из теста, лука и мяса (Пельмени: " ?newcf ")")))
)

(defrule r058-fact-exists
    ?r <- (available-rule "r058")
    (available-food (name "Мясо") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Тесто") (certainty-factor ?cf2))
    ?f <- (available-food (name "Пельмени") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Пельмени из теста, лука и мяса (Пельмени: " ?newcf ")")))
)

(defrule r059-fact-doesnt-exist
    ?r <- (available-rule "r059")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Шампиньон") (certainty-factor ?cf1))
    (available-food (name "Тесто") (certainty-factor ?cf2))
    (not (exists (available-food (name "Пельмени"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.78 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Пельмени") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Пельмени из теста, лука и шампиньонов (Пельмени: " ?newcf ")")))
)

(defrule r059-fact-exists
    ?r <- (available-rule "r059")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Шампиньон") (certainty-factor ?cf1))
    (available-food (name "Тесто") (certainty-factor ?cf2))
    ?f <- (available-food (name "Пельмени") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.78 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Пельмени из теста, лука и шампиньонов (Пельмени: " ?newcf ")")))
)

(defrule r060-fact-doesnt-exist
    ?r <- (available-rule "r060")
    (available-food (name "Пельмени") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Пельмени это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r060-fact-exists
    ?r <- (available-rule "r060")
    (available-food (name "Пельмени") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Пельмени это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r061-fact-doesnt-exist
    ?r <- (available-rule "r061")
    (available-food (name "Молоко") (certainty-factor ?cf0))
    (available-food (name "Говяжья котлета") (certainty-factor ?cf1))
    (available-food (name "Печёный картофель") (certainty-factor ?cf2))
    (not (exists (available-food (name "Картофельные лодочки"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Картофельные лодочки") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Картофельные лодочки из печёного картофеля, говяжьей котлеты и молока (Картофельные лодочки: " ?newcf ")")))
)

(defrule r061-fact-exists
    ?r <- (available-rule "r061")
    (available-food (name "Молоко") (certainty-factor ?cf0))
    (available-food (name "Говяжья котлета") (certainty-factor ?cf1))
    (available-food (name "Печёный картофель") (certainty-factor ?cf2))
    ?f <- (available-food (name "Картофельные лодочки") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Картофельные лодочки из печёного картофеля, говяжьей котлеты и молока (Картофельные лодочки: " ?newcf ")")))
)

(defrule r062-fact-doesnt-exist
    ?r <- (available-rule "r062")
    (available-food (name "Картофельные лодочки") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Картофельные лодочки это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r062-fact-exists
    ?r <- (available-rule "r062")
    (available-food (name "Картофельные лодочки") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Картофельные лодочки это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r063-fact-doesnt-exist
    ?r <- (available-rule "r063")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    (available-food (name "Лук") (certainty-factor ?cf2))
    (available-food (name "Яйцо") (certainty-factor ?cf3))
    (available-food (name "Капуста") (certainty-factor ?cf4))
    (not (exists (available-food (name "Голубцы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.65 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Голубцы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Голубцы в кастрюле из капусты с мясом, яйцом и луком (Голубцы: " ?newcf ")")))
)

(defrule r063-fact-exists
    ?r <- (available-rule "r063")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    (available-food (name "Лук") (certainty-factor ?cf2))
    (available-food (name "Яйцо") (certainty-factor ?cf3))
    (available-food (name "Капуста") (certainty-factor ?cf4))
    ?f <- (available-food (name "Голубцы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.65 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Голубцы в кастрюле из капусты с мясом, яйцом и луком (Голубцы: " ?newcf ")")))
)

(defrule r064-fact-doesnt-exist
    ?r <- (available-rule "r064")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (not (exists (available-food (name "Голубцы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Голубцы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Голубцы в кастрюле из капусты с мясом и морковью (Голубцы: " ?newcf ")")))
)

(defrule r064-fact-exists
    ?r <- (available-rule "r064")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    ?f <- (available-food (name "Голубцы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Голубцы в кастрюле из капусты с мясом и морковью (Голубцы: " ?newcf ")")))
)

(defrule r065-fact-doesnt-exist
    ?r <- (available-rule "r065")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Шампиньон") (certainty-factor ?cf3))
    (not (exists (available-food (name "Голубцы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Голубцы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Голубцы в кастрюле из капусты с мясом и грибами (Голубцы: " ?newcf ")")))
)

(defrule r065-fact-exists
    ?r <- (available-rule "r065")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Мясо") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Шампиньон") (certainty-factor ?cf3))
    ?f <- (available-food (name "Голубцы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Голубцы в кастрюле из капусты с мясом и грибами (Голубцы: " ?newcf ")")))
)

(defrule r066-fact-doesnt-exist
    ?r <- (available-rule "r066")
    (available-food (name "Голубцы") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Голубцы это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r066-fact-exists
    ?r <- (available-rule "r066")
    (available-food (name "Голубцы") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Голубцы это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r067-fact-doesnt-exist
    ?r <- (available-rule "r067")
    (available-food (name "Сырой ломтик красной рыбы") (certainty-factor ?cf0))
    (available-food (name "Варёный рис") (certainty-factor ?cf1))
    (not (exists (available-food (name "Суши с красной рыбой"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1)))
    (assert (available-food (name "Суши с красной рыбой") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Суши с красной рыбой из ломтика красной рыбы и варёного риса (Суши с красной рыбой: " ?newcf ")")))
)

(defrule r067-fact-exists
    ?r <- (available-rule "r067")
    (available-food (name "Сырой ломтик красной рыбы") (certainty-factor ?cf0))
    (available-food (name "Варёный рис") (certainty-factor ?cf1))
    ?f <- (available-food (name "Суши с красной рыбой") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Суши с красной рыбой из ломтика красной рыбы и варёного риса (Суши с красной рыбой: " ?newcf ")")))
)

(defrule r068-fact-doesnt-exist
    ?r <- (available-rule "r068")
    (available-food (name "Суши с красной рыбой") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Суши с красной рыбой это закуска (Закуска: " ?newcf ")")))
)

(defrule r068-fact-exists
    ?r <- (available-rule "r068")
    (available-food (name "Суши с красной рыбой") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Суши с красной рыбой это закуска (Закуска: " ?newcf ")")))
)

(defrule r069-fact-doesnt-exist
    ?r <- (available-rule "r069")
    (available-food (name "Сырой ломтик белой рыбы") (certainty-factor ?cf0))
    (available-food (name "Варёный рис") (certainty-factor ?cf1))
    (not (exists (available-food (name "Суши с белой рыбой"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1)))
    (assert (available-food (name "Суши с белой рыбой") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Суши с белой рыбой из ломтика белой рыбы и варёного риса (Суши с белой рыбой: " ?newcf ")")))
)

(defrule r069-fact-exists
    ?r <- (available-rule "r069")
    (available-food (name "Сырой ломтик белой рыбы") (certainty-factor ?cf0))
    (available-food (name "Варёный рис") (certainty-factor ?cf1))
    ?f <- (available-food (name "Суши с белой рыбой") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Суши с белой рыбой из ломтика белой рыбы и варёного риса (Суши с белой рыбой: " ?newcf ")")))
)

(defrule r070-fact-doesnt-exist
    ?r <- (available-rule "r070")
    (available-food (name "Суши с белой рыбой") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Суши с белой рыбой это закуска (Закуска: " ?newcf ")")))
)

(defrule r070-fact-exists
    ?r <- (available-rule "r070")
    (available-food (name "Суши с белой рыбой") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Суши с белой рыбой это закуска (Закуска: " ?newcf ")")))
)

(defrule r071-fact-doesnt-exist
    ?r <- (available-rule "r071")
    (available-food (name "Морковь") (certainty-factor ?cf0))
    (available-food (name "Водоросли нори") (certainty-factor ?cf1))
    (available-food (name "Варёный рис") (certainty-factor ?cf2))
    (not (exists (available-food (name "Ролл"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Ролл") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ролл из моркови, варёного риса и листа нори (Ролл: " ?newcf ")")))
)

(defrule r071-fact-exists
    ?r <- (available-rule "r071")
    (available-food (name "Морковь") (certainty-factor ?cf0))
    (available-food (name "Водоросли нори") (certainty-factor ?cf1))
    (available-food (name "Варёный рис") (certainty-factor ?cf2))
    ?f <- (available-food (name "Ролл") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ролл из моркови, варёного риса и листа нори (Ролл: " ?newcf ")")))
)

(defrule r072-fact-doesnt-exist
    ?r <- (available-rule "r072")
    (available-food (name "Ролл") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ролл это закуска (Закуска: " ?newcf ")")))
)

(defrule r072-fact-exists
    ?r <- (available-rule "r072")
    (available-food (name "Ролл") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ролл это закуска (Закуска: " ?newcf ")")))
)

(defrule r073-fact-doesnt-exist
    ?r <- (available-rule "r073")
    (available-food (name "Яблоко") (certainty-factor ?cf0))
    (available-food (name "Ягоды") (certainty-factor ?cf1))
    (available-food (name "Долька арбуза") (certainty-factor ?cf2))
    (not (exists (available-food (name "Фруктовый салат"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Фруктовый салат") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Фруктовый салат из ягод, яблока и долек арбуза (Фруктовый салат: " ?newcf ")")))
)

(defrule r073-fact-exists
    ?r <- (available-rule "r073")
    (available-food (name "Яблоко") (certainty-factor ?cf0))
    (available-food (name "Ягоды") (certainty-factor ?cf1))
    (available-food (name "Долька арбуза") (certainty-factor ?cf2))
    ?f <- (available-food (name "Фруктовый салат") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Фруктовый салат из ягод, яблока и долек арбуза (Фруктовый салат: " ?newcf ")")))
)

(defrule r074-fact-doesnt-exist
    ?r <- (available-rule "r074")
    (available-food (name "Яблоко") (certainty-factor ?cf0))
    (available-food (name "Ягоды") (certainty-factor ?cf1))
    (available-food (name "Долька тыквы") (certainty-factor ?cf2))
    (not (exists (available-food (name "Фруктовый салат"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Фруктовый салат") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Фруктовый салат из ягод, яблока, долек тыквы (Фруктовый салат: " ?newcf ")")))
)

(defrule r074-fact-exists
    ?r <- (available-rule "r074")
    (available-food (name "Яблоко") (certainty-factor ?cf0))
    (available-food (name "Ягоды") (certainty-factor ?cf1))
    (available-food (name "Долька тыквы") (certainty-factor ?cf2))
    ?f <- (available-food (name "Фруктовый салат") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Фруктовый салат из ягод, яблока, долек тыквы (Фруктовый салат: " ?newcf ")")))
)

(defrule r075-fact-doesnt-exist
    ?r <- (available-rule "r075")
    (available-food (name "Фруктовый салат") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Фруктовый салат это десерт (Десерт: " ?newcf ")")))
)

(defrule r075-fact-exists
    ?r <- (available-rule "r075")
    (available-food (name "Фруктовый салат") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Фруктовый салат это десерт (Десерт: " ?newcf ")")))
)

(defrule r076-fact-doesnt-exist
    ?r <- (available-rule "r076")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Свёкла") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    (not (exists (available-food (name "Овощной салат"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Овощной салат") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной салат из томата, листа капусты и свёклы (Овощной салат: " ?newcf ")")))
)

(defrule r076-fact-exists
    ?r <- (available-rule "r076")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Свёкла") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    ?f <- (available-food (name "Овощной салат") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной салат из томата, листа капусты и свёклы (Овощной салат: " ?newcf ")")))
)

(defrule r077-fact-doesnt-exist
    ?r <- (available-rule "r077")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    (not (exists (available-food (name "Овощной салат"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Овощной салат") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной салат из томата, листа капусты и моркови (Овощной салат: " ?newcf ")")))
)

(defrule r077-fact-exists
    ?r <- (available-rule "r077")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    ?f <- (available-food (name "Овощной салат") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной салат из томата, листа капусты и моркови (Овощной салат: " ?newcf ")")))
)

(defrule r078-fact-doesnt-exist
    ?r <- (available-rule "r078")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    (not (exists (available-food (name "Овощной салат"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Овощной салат") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной салат из томата, листа капусты и лука (Овощной салат: " ?newcf ")")))
)

(defrule r078-fact-exists
    ?r <- (available-rule "r078")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Капустный лист") (certainty-factor ?cf2))
    ?f <- (available-food (name "Овощной салат") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной салат из томата, листа капусты и лука (Овощной салат: " ?newcf ")")))
)

(defrule r079-fact-doesnt-exist
    ?r <- (available-rule "r079")
    (available-food (name "Овощной салат") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной салат это закуска (Закуска: " ?newcf ")")))
)

(defrule r079-fact-exists
    ?r <- (available-rule "r079")
    (available-food (name "Овощной салат") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной салат это закуска (Закуска: " ?newcf ")")))
)

(defrule r080-fact-doesnt-exist
    ?r <- (available-rule "r080")
    (available-food (name "Шампиньон") (certainty-factor ?cf0))
    (available-food (name "Капустный лист") (certainty-factor ?cf1))
    (not (exists (available-food (name "Грибной салат"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.88 (min ?cf0 ?cf1)))
    (assert (available-food (name "Грибной салат") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Грибной салат из шампиньона и листа капусты (Грибной салат: " ?newcf ")")))
)

(defrule r080-fact-exists
    ?r <- (available-rule "r080")
    (available-food (name "Шампиньон") (certainty-factor ?cf0))
    (available-food (name "Капустный лист") (certainty-factor ?cf1))
    ?f <- (available-food (name "Грибной салат") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.88 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Грибной салат из шампиньона и листа капусты (Грибной салат: " ?newcf ")")))
)

(defrule r081-fact-doesnt-exist
    ?r <- (available-rule "r081")
    (available-food (name "Грибной салат") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Грибной салат это закуска (Закуска: " ?newcf ")")))
)

(defrule r081-fact-exists
    ?r <- (available-rule "r081")
    (available-food (name "Грибной салат") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Грибной салат это закуска (Закуска: " ?newcf ")")))
)

(defrule r082-fact-doesnt-exist
    ?r <- (available-rule "r082")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Рис") (certainty-factor ?cf1))
    (not (exists (available-food (name "Варёный рис"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1)))
    (assert (available-food (name "Варёный рис") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Варёный рис в кастрюле из риса (Варёный рис: " ?newcf ")")))
)

(defrule r082-fact-exists
    ?r <- (available-rule "r082")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Рис") (certainty-factor ?cf1))
    ?f <- (available-food (name "Варёный рис") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Варёный рис в кастрюле из риса (Варёный рис: " ?newcf ")")))
)

(defrule r083-fact-doesnt-exist
    ?r <- (available-rule "r083")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Картофель") (certainty-factor ?cf2))
    (available-food (name "Говяжий фарш") (certainty-factor ?cf3))
    (not (exists (available-food (name "Рагу из говядины"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.55 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Рагу из говядины") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рагу из говядины в кастрюле из говяжьего фарша, моркови и картофеля (Рагу из говядины: " ?newcf ")")))
)

(defrule r083-fact-exists
    ?r <- (available-rule "r083")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Картофель") (certainty-factor ?cf2))
    (available-food (name "Говяжий фарш") (certainty-factor ?cf3))
    ?f <- (available-food (name "Рагу из говядины") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.55 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рагу из говядины в кастрюле из говяжьего фарша, моркови и картофеля (Рагу из говядины: " ?newcf ")")))
)

(defrule r084-fact-doesnt-exist
    ?r <- (available-rule "r084")
    (available-food (name "Рагу из говядины") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рагу из говядины это суп (Суп: " ?newcf ")")))
)

(defrule r084-fact-exists
    ?r <- (available-rule "r084")
    (available-food (name "Рагу из говядины") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рагу из говядины это суп (Суп: " ?newcf ")")))
)

(defrule r085-fact-doesnt-exist
    ?r <- (available-rule "r085")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Куриное филе") (certainty-factor ?cf4))
    (not (exists (available-food (name "Куриный суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Куриный суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Куриный суп в кастрюле из моркови, лука, капусты и куриного филе (Куриный суп: " ?newcf ")")))
)

(defrule r085-fact-exists
    ?r <- (available-rule "r085")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Куриное филе") (certainty-factor ?cf4))
    ?f <- (available-food (name "Куриный суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Куриный суп в кастрюле из моркови, лука, капусты и куриного филе (Куриный суп: " ?newcf ")")))
)

(defrule r086-fact-doesnt-exist
    ?r <- (available-rule "r086")
    (available-food (name "Куриный суп") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Куриный суп это суп (Суп: " ?newcf ")")))
)

(defrule r086-fact-exists
    ?r <- (available-rule "r086")
    (available-food (name "Куриный суп") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Куриный суп это суп (Суп: " ?newcf ")")))
)

(defrule r087-fact-doesnt-exist
    ?r <- (available-rule "r087")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (not (exists (available-food (name "Овощной суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Овощной суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, томата и капусты (Овощной суп: " ?newcf ")")))
)

(defrule r087-fact-exists
    ?r <- (available-rule "r087")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    ?f <- (available-food (name "Овощной суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, томата и капусты (Овощной суп: " ?newcf ")")))
)

(defrule r088-fact-doesnt-exist
    ?r <- (available-rule "r088")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (not (exists (available-food (name "Овощной суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Овощной суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, лука и капусты (Овощной суп: " ?newcf ")")))
)

(defrule r088-fact-exists
    ?r <- (available-rule "r088")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    ?f <- (available-food (name "Овощной суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, лука и капусты (Овощной суп: " ?newcf ")")))
)

(defrule r089-fact-doesnt-exist
    ?r <- (available-rule "r089")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Морковь") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (not (exists (available-food (name "Овощной суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Овощной суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, томата и моркови (Овощной суп: " ?newcf ")")))
)

(defrule r089-fact-exists
    ?r <- (available-rule "r089")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Морковь") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    ?f <- (available-food (name "Овощной суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, томата и моркови (Овощной суп: " ?newcf ")")))
)

(defrule r090-fact-doesnt-exist
    ?r <- (available-rule "r090")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Морковь") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (not (exists (available-food (name "Овощной суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Овощной суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, лука и моркови (Овощной суп: " ?newcf ")")))
)

(defrule r090-fact-exists
    ?r <- (available-rule "r090")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Морковь") (certainty-factor ?cf2))
    (available-food (name "Свёкла") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    ?f <- (available-food (name "Овощной суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной суп в кастрюле из свёклы, картофеля, лука и моркови (Овощной суп: " ?newcf ")")))
)

(defrule r091-fact-doesnt-exist
    ?r <- (available-rule "r091")
    (available-food (name "Овощной суп") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Овощной суп это суп (Суп: " ?newcf ")")))
)

(defrule r091-fact-exists
    ?r <- (available-rule "r091")
    (available-food (name "Овощной суп") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Овощной суп это суп (Суп: " ?newcf ")")))
)

(defrule r092-fact-doesnt-exist
    ?r <- (available-rule "r092")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая рыба") (certainty-factor ?cf1))
    (available-food (name "Лук") (certainty-factor ?cf2))
    (available-food (name "Томатный соус") (certainty-factor ?cf3))
    (not (exists (available-food (name "Рыбное томатное рагу"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Рыбное томатное рагу") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рыбное томатное рагу в кастрюле из рыбы, томатного соуса и лука (Рыбное томатное рагу: " ?newcf ")")))
)

(defrule r092-fact-exists
    ?r <- (available-rule "r092")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая рыба") (certainty-factor ?cf1))
    (available-food (name "Лук") (certainty-factor ?cf2))
    (available-food (name "Томатный соус") (certainty-factor ?cf3))
    ?f <- (available-food (name "Рыбное томатное рагу") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рыбное томатное рагу в кастрюле из рыбы, томатного соуса и лука (Рыбное томатное рагу: " ?newcf ")")))
)

(defrule r093-fact-doesnt-exist
    ?r <- (available-rule "r093")
    (available-food (name "Рыбное томатное рагу") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рыбное томатное рагу это суп (Суп: " ?newcf ")")))
)

(defrule r093-fact-exists
    ?r <- (available-rule "r093")
    (available-food (name "Рыбное томатное рагу") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рыбное томатное рагу это суп (Суп: " ?newcf ")")))
)

(defrule r094-fact-doesnt-exist
    ?r <- (available-rule "r094")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Рис") (certainty-factor ?cf4))
    (not (exists (available-food (name "Жареный рис с яйцом"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Жареный рис с яйцом") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареный рис с яйцом на сковороде из риса, яйца, лука и моркови (Жареный рис с яйцом: " ?newcf ")")))
)

(defrule r094-fact-exists
    ?r <- (available-rule "r094")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Рис") (certainty-factor ?cf4))
    ?f <- (available-food (name "Жареный рис с яйцом") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареный рис с яйцом на сковороде из риса, яйца, лука и моркови (Жареный рис с яйцом: " ?newcf ")")))
)

(defrule r095-fact-doesnt-exist
    ?r <- (available-rule "r095")
    (available-food (name "Жареный рис с яйцом") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареный рис с яйцом это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r095-fact-exists
    ?r <- (available-rule "r095")
    (available-food (name "Жареный рис с яйцом") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареный рис с яйцом это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r096-fact-doesnt-exist
    ?r <- (available-rule "r096")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Капуста") (certainty-factor ?cf1))
    (available-food (name "Сырая свинина") (certainty-factor ?cf2))
    (available-food (name "Молоко") (certainty-factor ?cf3))
    (available-food (name "Долька тыквы") (certainty-factor ?cf4))
    (not (exists (available-food (name "Тыквенный суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Тыквенный суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Тыквенный суп в кастрюле из тыквы, молока, капусты и свинины (Тыквенный суп: " ?newcf ")")))
)

(defrule r096-fact-exists
    ?r <- (available-rule "r096")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Капуста") (certainty-factor ?cf1))
    (available-food (name "Сырая свинина") (certainty-factor ?cf2))
    (available-food (name "Молоко") (certainty-factor ?cf3))
    (available-food (name "Долька тыквы") (certainty-factor ?cf4))
    ?f <- (available-food (name "Тыквенный суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Тыквенный суп в кастрюле из тыквы, молока, капусты и свинины (Тыквенный суп: " ?newcf ")")))
)

(defrule r097-fact-doesnt-exist
    ?r <- (available-rule "r097")
    (available-food (name "Тыквенный суп") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Тыквенный суп это суп (Суп: " ?newcf ")")))
)

(defrule r097-fact-exists
    ?r <- (available-rule "r097")
    (available-food (name "Тыквенный суп") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Тыквенный суп это суп (Суп: " ?newcf ")")))
)

(defrule r098-fact-doesnt-exist
    ?r <- (available-rule "r098")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Картофель") (certainty-factor ?cf3))
    (available-food (name "Сырая белая рыба") (certainty-factor ?cf4))
    (not (exists (available-food (name "Уха"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Уха") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Уха в кастрюле из ломтиков сырой белой рыбы, томатов, яйца и картофеля (Уха: " ?newcf ")")))
)

(defrule r098-fact-exists
    ?r <- (available-rule "r098")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Картофель") (certainty-factor ?cf3))
    (available-food (name "Сырая белая рыба") (certainty-factor ?cf4))
    ?f <- (available-food (name "Уха") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Уха в кастрюле из ломтиков сырой белой рыбы, томатов, яйца и картофеля (Уха: " ?newcf ")")))
)

(defrule r099-fact-doesnt-exist
    ?r <- (available-rule "r099")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Картофель") (certainty-factor ?cf3))
    (available-food (name "Сырая белая рыба") (certainty-factor ?cf4))
    (not (exists (available-food (name "Уха"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Уха") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Уха в кастрюле из ломтиков сырой белой рыбы, лука, яйца и картофеля (Уха: " ?newcf ")")))
)

(defrule r099-fact-exists
    ?r <- (available-rule "r099")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Картофель") (certainty-factor ?cf3))
    (available-food (name "Сырая белая рыба") (certainty-factor ?cf4))
    ?f <- (available-food (name "Уха") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Уха в кастрюле из ломтиков сырой белой рыбы, лука, яйца и картофеля (Уха: " ?newcf ")")))
)

(defrule r100-fact-doesnt-exist
    ?r <- (available-rule "r100")
    (available-food (name "Уха") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Уха это суп (Суп: " ?newcf ")")))
)

(defrule r100-fact-exists
    ?r <- (available-rule "r100")
    (available-food (name "Уха") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Уха это суп (Суп: " ?newcf ")")))
)

(defrule r101-fact-doesnt-exist
    ?r <- (available-rule "r101")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая говядина") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    (not (exists (available-food (name "Рамен"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Рамен") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и говядины (Рамен: " ?newcf ")")))
)

(defrule r101-fact-exists
    ?r <- (available-rule "r101")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая говядина") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    ?f <- (available-food (name "Рамен") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и говядины (Рамен: " ?newcf ")")))
)

(defrule r102-fact-doesnt-exist
    ?r <- (available-rule "r102")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая свинина") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    (not (exists (available-food (name "Рамен"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Рамен") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и свинины (Рамен: " ?newcf ")")))
)

(defrule r102-fact-exists
    ?r <- (available-rule "r102")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая свинина") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    ?f <- (available-food (name "Рамен") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и свинины (Рамен: " ?newcf ")")))
)

(defrule r103-fact-doesnt-exist
    ?r <- (available-rule "r103")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая баранина") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    (not (exists (available-food (name "Рамен"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Рамен") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и баранины (Рамен: " ?newcf ")")))
)

(defrule r103-fact-exists
    ?r <- (available-rule "r103")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая баранина") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    ?f <- (available-food (name "Рамен") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и баранины (Рамен: " ?newcf ")")))
)

(defrule r104-fact-doesnt-exist
    ?r <- (available-rule "r104")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая курица") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    (not (exists (available-food (name "Рамен"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Рамен") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и курицы (Рамен: " ?newcf ")")))
)

(defrule r104-fact-exists
    ?r <- (available-rule "r104")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая курица") (certainty-factor ?cf1))
    (available-food (name "Водоросли нори") (certainty-factor ?cf2))
    (available-food (name "Жареное яйцо") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    ?f <- (available-food (name "Рамен") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рамен в кастрюле из жареного яйца, сырой пасты, листа нори и курицы (Рамен: " ?newcf ")")))
)

(defrule r105-fact-doesnt-exist
    ?r <- (available-rule "r105")
    (available-food (name "Рамен") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рамен это суп (Суп: " ?newcf ")")))
)

(defrule r105-fact-exists
    ?r <- (available-rule "r105")
    (available-food (name "Рамен") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рамен это суп (Суп: " ?newcf ")")))
)

(defrule r106-fact-doesnt-exist
    ?r <- (available-rule "r106")
    (available-food (name "Жареное яйцо") (certainty-factor ?cf0))
    (available-food (name "Жареный бекон") (certainty-factor ?cf1))
    (not (exists (available-food (name "Яичница с беконом"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.85 (min ?cf0 ?cf1)))
    (assert (available-food (name "Яичница с беконом") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Яичница с беконом из жареного яйца и жареного бекона (Яичница с беконом: " ?newcf ")")))
)

(defrule r106-fact-exists
    ?r <- (available-rule "r106")
    (available-food (name "Жареное яйцо") (certainty-factor ?cf0))
    (available-food (name "Жареный бекон") (certainty-factor ?cf1))
    ?f <- (available-food (name "Яичница с беконом") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.85 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Яичница с беконом из жареного яйца и жареного бекона (Яичница с беконом: " ?newcf ")")))
)

(defrule r107-fact-doesnt-exist
    ?r <- (available-rule "r107")
    (available-food (name "Яичница с беконом") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Яичница с беконом это закуска (Закуска: " ?newcf ")")))
)

(defrule r107-fact-exists
    ?r <- (available-rule "r107")
    (available-food (name "Яичница с беконом") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Яичница с беконом это закуска (Закуска: " ?newcf ")")))
)

(defrule r108-fact-doesnt-exist
    ?r <- (available-rule "r108")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Говяжий фарш") (certainty-factor ?cf1))
    (available-food (name "Томатный соус") (certainty-factor ?cf2))
    (available-food (name "Сырая паста") (certainty-factor ?cf3))
    (not (exists (available-food (name "Спагетти с фрикадельками"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.78 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Спагетти с фрикадельками") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Спагетти с фрикадельками на сковороде из говяжьего фарша, томатного соуса и сырой пасты (Спагетти с фрикадельками: " ?newcf ")")))
)

(defrule r108-fact-exists
    ?r <- (available-rule "r108")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Говяжий фарш") (certainty-factor ?cf1))
    (available-food (name "Томатный соус") (certainty-factor ?cf2))
    (available-food (name "Сырая паста") (certainty-factor ?cf3))
    ?f <- (available-food (name "Спагетти с фрикадельками") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.78 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Спагетти с фрикадельками на сковороде из говяжьего фарша, томатного соуса и сырой пасты (Спагетти с фрикадельками: " ?newcf ")")))
)

(defrule r109-fact-doesnt-exist
    ?r <- (available-rule "r109")
    (available-food (name "Спагетти с фрикадельками") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Спагетти с фрикадельками это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r109-fact-exists
    ?r <- (available-rule "r109")
    (available-food (name "Спагетти с фрикадельками") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Спагетти с фрикадельками это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r110-fact-doesnt-exist
    ?r <- (available-rule "r110")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырые кусочки баранины") (certainty-factor ?cf1))
    (available-food (name "Томатный соус") (certainty-factor ?cf2))
    (available-food (name "Сырая паста") (certainty-factor ?cf3))
    (not (exists (available-food (name "Спагетти с бараниной"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Спагетти с бараниной") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Спагетти с бараниной на сковороде из кусочков баранины, томатного соуса и сырой пасты (Спагетти с бараниной: " ?newcf ")")))
)

(defrule r110-fact-exists
    ?r <- (available-rule "r110")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Сырые кусочки баранины") (certainty-factor ?cf1))
    (available-food (name "Томатный соус") (certainty-factor ?cf2))
    (available-food (name "Сырая паста") (certainty-factor ?cf3))
    ?f <- (available-food (name "Спагетти с бараниной") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Спагетти с бараниной на сковороде из кусочков баранины, томатного соуса и сырой пасты (Спагетти с бараниной: " ?newcf ")")))
)

(defrule r111-fact-doesnt-exist
    ?r <- (available-rule "r111")
    (available-food (name "Спагетти с бараниной") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Спагетти с бараниной это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r111-fact-exists
    ?r <- (available-rule "r111")
    (available-food (name "Спагетти с бараниной") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Спагетти с бараниной это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r112-fact-doesnt-exist
    ?r <- (available-rule "r112")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Шампиньон") (certainty-factor ?cf2))
    (available-food (name "Рис") (certainty-factor ?cf3))
    (not (exists (available-food (name "Рис с грибами"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Рис с грибами") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рис с грибами в кастрюле из шампиньонов, риса и моркови (Рис с грибами: " ?newcf ")")))
)

(defrule r112-fact-exists
    ?r <- (available-rule "r112")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Шампиньон") (certainty-factor ?cf2))
    (available-food (name "Рис") (certainty-factor ?cf3))
    ?f <- (available-food (name "Рис с грибами") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рис с грибами в кастрюле из шампиньонов, риса и моркови (Рис с грибами: " ?newcf ")")))
)

(defrule r113-fact-doesnt-exist
    ?r <- (available-rule "r113")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Шампиньон") (certainty-factor ?cf1))
    (available-food (name "Картофель") (certainty-factor ?cf2))
    (available-food (name "Рис") (certainty-factor ?cf3))
    (not (exists (available-food (name "Рис с грибами"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Рис с грибами") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рис с грибами в кастрюле из шампиньонов, риса и картофеля (Рис с грибами: " ?newcf ")")))
)

(defrule r113-fact-exists
    ?r <- (available-rule "r113")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Шампиньон") (certainty-factor ?cf1))
    (available-food (name "Картофель") (certainty-factor ?cf2))
    (available-food (name "Рис") (certainty-factor ?cf3))
    ?f <- (available-food (name "Рис с грибами") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рис с грибами в кастрюле из шампиньонов, риса и картофеля (Рис с грибами: " ?newcf ")")))
)

(defrule r114-fact-doesnt-exist
    ?r <- (available-rule "r114")
    (available-food (name "Рис с грибами") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рис с грибами это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r114-fact-exists
    ?r <- (available-rule "r114")
    (available-food (name "Рис с грибами") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рис с грибами это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r115-fact-doesnt-exist
    ?r <- (available-rule "r115")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Свёкла") (certainty-factor ?cf1))
    (available-food (name "Кусочки жареной баранины") (certainty-factor ?cf2))
    (available-food (name "Варёный рис") (certainty-factor ?cf3))
    (not (exists (available-food (name "Жареные бараньи рёбрышки с рисом"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Жареные бараньи рёбрышки с рисом") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареные бараньи ребрышки с рисом из жареных кусочков баранины, томатов, свёклы и варёного риса (Жареные бараньи рёбрышки с рисом: " ?newcf ")")))
)

(defrule r115-fact-exists
    ?r <- (available-rule "r115")
    (available-food (name "Томат") (certainty-factor ?cf0))
    (available-food (name "Свёкла") (certainty-factor ?cf1))
    (available-food (name "Кусочки жареной баранины") (certainty-factor ?cf2))
    (available-food (name "Варёный рис") (certainty-factor ?cf3))
    ?f <- (available-food (name "Жареные бараньи рёбрышки с рисом") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареные бараньи ребрышки с рисом из жареных кусочков баранины, томатов, свёклы и варёного риса (Жареные бараньи рёбрышки с рисом: " ?newcf ")")))
)

(defrule r116-fact-doesnt-exist
    ?r <- (available-rule "r116")
    (available-food (name "Жареные бараньи рёбрышки с рисом") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жареные бараньи ребрышки с рисом это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r116-fact-exists
    ?r <- (available-rule "r116")
    (available-food (name "Жареные бараньи рёбрышки с рисом") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жареные бараньи ребрышки с рисом это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r117-fact-doesnt-exist
    ?r <- (available-rule "r117")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf2))
    (available-food (name "Шампиньон") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (not (exists (available-food (name "Рагу из крольчатины"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Рагу из крольчатины") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рагу из крольчатины в кастрюле из крольчатины, шампиньона, картофеля и моркови (Рагу из крольчатины: " ?newcf ")")))
)

(defrule r117-fact-exists
    ?r <- (available-rule "r117")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Морковь") (certainty-factor ?cf1))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf2))
    (available-food (name "Шампиньон") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    ?f <- (available-food (name "Рагу из крольчатины") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рагу из крольчатины в кастрюле из крольчатины, шампиньона, картофеля и моркови (Рагу из крольчатины: " ?newcf ")")))
)

(defrule r118-fact-doesnt-exist
    ?r <- (available-rule "r118")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf2))
    (available-food (name "Шампиньон") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (not (exists (available-food (name "Рагу из крольчатины"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Рагу из крольчатины") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рагу из крольчатины в кастрюле из крольчатины, шампиньона, картофеля и томата (Рагу из крольчатины: " ?newcf ")")))
)

(defrule r118-fact-exists
    ?r <- (available-rule "r118")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Сырая крольчатина") (certainty-factor ?cf2))
    (available-food (name "Шампиньон") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    ?f <- (available-food (name "Рагу из крольчатины") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рагу из крольчатины в кастрюле из крольчатины, шампиньона, картофеля и томата (Рагу из крольчатины: " ?newcf ")")))
)

(defrule r119-fact-doesnt-exist
    ?r <- (available-rule "r119")
    (available-food (name "Рагу из крольчатины") (certainty-factor ?cf0))
    (not (exists (available-food (name "Суп"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Суп") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рагу из крольчатины это суп (Суп: " ?newcf ")")))
)

(defrule r119-fact-exists
    ?r <- (available-rule "r119")
    (available-food (name "Рагу из крольчатины") (certainty-factor ?cf0))
    ?f <- (available-food (name "Суп") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рагу из крольчатины это суп (Суп: " ?newcf ")")))
)

(defrule r120-fact-doesnt-exist
    ?r <- (available-rule "r120")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Шампиньон") (certainty-factor ?cf4))
    (available-food (name "Капустный лист") (certainty-factor ?cf5))
    (available-food (name "Сырая паста") (certainty-factor ?cf6))
    (not (exists (available-food (name "Паста с овощами"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5 ?cf6)))
    (assert (available-food (name "Паста с овощами") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Паста с овощами в кастрюле из сырой пасты, моркови, шампиньонов, листа капусты и томата (Паста с овощами: " ?newcf ")")))
)

(defrule r120-fact-exists
    ?r <- (available-rule "r120")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Шампиньон") (certainty-factor ?cf4))
    (available-food (name "Капустный лист") (certainty-factor ?cf5))
    (available-food (name "Сырая паста") (certainty-factor ?cf6))
    ?f <- (available-food (name "Паста с овощами") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5 ?cf6)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Паста с овощами в кастрюле из сырой пасты, моркови, шампиньонов, листа капусты и томата (Паста с овощами: " ?newcf ")")))
)

(defrule r121-fact-doesnt-exist
    ?r <- (available-rule "r121")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Шампиньон") (certainty-factor ?cf4))
    (available-food (name "Капустный лист") (certainty-factor ?cf5))
    (available-food (name "Сырая паста") (certainty-factor ?cf6))
    (not (exists (available-food (name "Паста с овощами"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5 ?cf6)))
    (assert (available-food (name "Паста с овощами") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Паста с овощами в кастрюле из сырой пасты, моркови, шампиньонов, листа капусты и лука (Паста с овощами: " ?newcf ")")))
)

(defrule r121-fact-exists
    ?r <- (available-rule "r121")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Капуста") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Шампиньон") (certainty-factor ?cf4))
    (available-food (name "Капустный лист") (certainty-factor ?cf5))
    (available-food (name "Сырая паста") (certainty-factor ?cf6))
    ?f <- (available-food (name "Паста с овощами") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5 ?cf6)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Паста с овощами в кастрюле из сырой пасты, моркови, шампиньонов, листа капусты и лука (Паста с овощами: " ?newcf ")")))
)

(defrule r122-fact-doesnt-exist
    ?r <- (available-rule "r122")
    (available-food (name "Паста с овощами") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Паста с овощами это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r122-fact-exists
    ?r <- (available-rule "r122")
    (available-food (name "Паста с овощами") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Паста с овощами это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r123-fact-doesnt-exist
    ?r <- (available-rule "r123")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Печёный картофель") (certainty-factor ?cf1))
    (available-food (name "Стейк") (certainty-factor ?cf2))
    (available-food (name "Варёный рис") (certainty-factor ?cf3))
    (not (exists (available-food (name "Стейк с картофелем"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Стейк с картофелем") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Стейк с картофелем из стейка, варёного риса, печёного картофеля и лука (Стейк с картофелем: " ?newcf ")")))
)

(defrule r123-fact-exists
    ?r <- (available-rule "r123")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Печёный картофель") (certainty-factor ?cf1))
    (available-food (name "Стейк") (certainty-factor ?cf2))
    (available-food (name "Варёный рис") (certainty-factor ?cf3))
    ?f <- (available-food (name "Стейк с картофелем") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Стейк с картофелем из стейка, варёного риса, печёного картофеля и лука (Стейк с картофелем: " ?newcf ")")))
)

(defrule r124-fact-doesnt-exist
    ?r <- (available-rule "r124")
    (available-food (name "Стейк с картофелем") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Стейк с картофелем это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r124-fact-exists
    ?r <- (available-rule "r124")
    (available-food (name "Стейк с картофелем") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Стейк с картофелем это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r125-fact-doesnt-exist
    ?r <- (available-rule "r125")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Томат") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Свёкла") (certainty-factor ?cf4))
    (not (exists (available-food (name "Рататуй"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.66 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Рататуй") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рататуй в кастрюле из свёклы, томатов, лука и моркови (Рататуй: " ?newcf ")")))
)

(defrule r125-fact-exists
    ?r <- (available-rule "r125")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Томат") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Свёкла") (certainty-factor ?cf4))
    ?f <- (available-food (name "Рататуй") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.66 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рататуй в кастрюле из свёклы, томатов, лука и моркови (Рататуй: " ?newcf ")")))
)

(defrule r126-fact-doesnt-exist
    ?r <- (available-rule "r126")
    (available-food (name "Рататуй") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Рататуй это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r126-fact-exists
    ?r <- (available-rule "r126")
    (available-food (name "Рататуй") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Рататуй это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r127-fact-doesnt-exist
    ?r <- (available-rule "r127")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая рыба") (certainty-factor ?cf1))
    (available-food (name "Томат") (certainty-factor ?cf2))
    (available-food (name "Чернила каракатицы") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    (not (exists (available-food (name "Чёрная паста с чернилами каракатицы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Чёрная паста с чернилами каракатицы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Чёрная паста с чернилами каракатицы в кастрюле из сырой пасты, чернил каракатицы, томатов и рыбы (Чёрная паста с чернилами каракатицы: " ?newcf ")")))
)

(defrule r127-fact-exists
    ?r <- (available-rule "r127")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Сырая рыба") (certainty-factor ?cf1))
    (available-food (name "Томат") (certainty-factor ?cf2))
    (available-food (name "Чернила каракатицы") (certainty-factor ?cf3))
    (available-food (name "Сырая паста") (certainty-factor ?cf4))
    ?f <- (available-food (name "Чёрная паста с чернилами каракатицы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.4 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Чёрная паста с чернилами каракатицы в кастрюле из сырой пасты, чернил каракатицы, томатов и рыбы (Чёрная паста с чернилами каракатицы: " ?newcf ")")))
)

(defrule r128-fact-doesnt-exist
    ?r <- (available-rule "r128")
    (available-food (name "Чёрная паста с чернилами каракатицы") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Чёрная паста с чернилами каракатицы это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r128-fact-exists
    ?r <- (available-rule "r128")
    (available-food (name "Чёрная паста с чернилами каракатицы") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Чёрная паста с чернилами каракатицы это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r129-fact-doesnt-exist
    ?r <- (available-rule "r129")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Ягоды") (certainty-factor ?cf2))
    (available-food (name "Сырой ломтик красной рыбы") (certainty-factor ?cf3))
    (not (exists (available-food (name "Красная рыба на гриле"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.65 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Красная рыба на гриле") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Красная рыба на гриле в сковороде из ломтиков красной рыбы, ягод и лука (Красная рыба на гриле: " ?newcf ")")))
)

(defrule r129-fact-exists
    ?r <- (available-rule "r129")
    (available-food (name "Сковорода") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Ягоды") (certainty-factor ?cf2))
    (available-food (name "Сырой ломтик красной рыбы") (certainty-factor ?cf3))
    ?f <- (available-food (name "Красная рыба на гриле") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.65 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Красная рыба на гриле в сковороде из ломтиков красной рыбы, ягод и лука (Красная рыба на гриле: " ?newcf ")")))
)

(defrule r130-fact-doesnt-exist
    ?r <- (available-rule "r130")
    (available-food (name "Красная рыба на гриле") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Красная рыба на гриле это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r130-fact-exists
    ?r <- (available-rule "r130")
    (available-food (name "Красная рыба на гриле") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Красная рыба на гриле это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r131-fact-doesnt-exist
    ?r <- (available-rule "r131")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Хлеб") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (available-food (name "Жареная курица") (certainty-factor ?cf5))
    (not (exists (available-food (name "Жаркое из курицы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5)))
    (assert (available-food (name "Жаркое из курицы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жаркое из курицы из жареной курицы, лука, яйца, хлеба, моркови, картофеля (Жаркое из курицы: " ?newcf ")")))
)

(defrule r131-fact-exists
    ?r <- (available-rule "r131")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Хлеб") (certainty-factor ?cf1))
    (available-food (name "Яйцо") (certainty-factor ?cf2))
    (available-food (name "Морковь") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (available-food (name "Жареная курица") (certainty-factor ?cf5))
    ?f <- (available-food (name "Жаркое из курицы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жаркое из курицы из жареной курицы, лука, яйца, хлеба, моркови, картофеля (Жаркое из курицы: " ?newcf ")")))
)

(defrule r132-fact-doesnt-exist
    ?r <- (available-rule "r132")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Хлеб") (certainty-factor ?cf2))
    (available-food (name "Яйцо") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (available-food (name "Жареная курица") (certainty-factor ?cf5))
    (not (exists (available-food (name "Жаркое из курицы"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5)))
    (assert (available-food (name "Жаркое из курицы") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жаркое из курицы из жареной курицы, лука, яйца, хлеба, томата, картофеля (Жаркое из курицы: " ?newcf ")")))
)

(defrule r132-fact-exists
    ?r <- (available-rule "r132")
    (available-food (name "Лук") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Хлеб") (certainty-factor ?cf2))
    (available-food (name "Яйцо") (certainty-factor ?cf3))
    (available-food (name "Картофель") (certainty-factor ?cf4))
    (available-food (name "Жареная курица") (certainty-factor ?cf5))
    ?f <- (available-food (name "Жаркое из курицы") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.68 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4 ?cf5)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жаркое из курицы из жареной курицы, лука, яйца, хлеба, томата, картофеля (Жаркое из курицы: " ?newcf ")")))
)

(defrule r133-fact-doesnt-exist
    ?r <- (available-rule "r133")
    (available-food (name "Жаркое из курицы") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Жаркое из курицы это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r133-fact-exists
    ?r <- (available-rule "r133")
    (available-food (name "Жаркое из курицы") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Жаркое из курицы это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r134-fact-doesnt-exist
    ?r <- (available-rule "r134")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Морковь") (certainty-factor ?cf2))
    (available-food (name "Долька тыквы") (certainty-factor ?cf3))
    (available-food (name "Варёный рис") (certainty-factor ?cf4))
    (not (exists (available-food (name "Запечённая тыква"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.8 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Запечённая тыква") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Запеченная тыква в печи из тыквы, варёного риса, моркови и томата (Запечённая тыква: " ?newcf ")")))
)

(defrule r134-fact-exists
    ?r <- (available-rule "r134")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Томат") (certainty-factor ?cf1))
    (available-food (name "Морковь") (certainty-factor ?cf2))
    (available-food (name "Долька тыквы") (certainty-factor ?cf3))
    (available-food (name "Варёный рис") (certainty-factor ?cf4))
    ?f <- (available-food (name "Запечённая тыква") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.8 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Запеченная тыква в печи из тыквы, варёного риса, моркови и томата (Запечённая тыква: " ?newcf ")")))
)

(defrule r135-fact-doesnt-exist
    ?r <- (available-rule "r135")
    (available-food (name "Запечённая тыква") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Запечённая тыква это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r135-fact-exists
    ?r <- (available-rule "r135")
    (available-food (name "Запечённая тыква") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Запечённая тыква это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r136-fact-doesnt-exist
    ?r <- (available-rule "r136")
    (available-food (name "Ягоды") (certainty-factor ?cf0))
    (available-food (name "Мёд") (certainty-factor ?cf1))
    (available-food (name "Запечённая ветчина") (certainty-factor ?cf2))
    (available-food (name "Варёный рис") (certainty-factor ?cf3))
    (not (exists (available-food (name "Ветчина в медовом соусе с рисом"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.45 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Ветчина в медовом соусе с рисом") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ветчина в медовом соусе с рисом из запечённой ветчины, ягод, мёда и варёного риса (Ветчина в медовом соусе с рисом: " ?newcf ")")))
)

(defrule r136-fact-exists
    ?r <- (available-rule "r136")
    (available-food (name "Ягоды") (certainty-factor ?cf0))
    (available-food (name "Мёд") (certainty-factor ?cf1))
    (available-food (name "Запечённая ветчина") (certainty-factor ?cf2))
    (available-food (name "Варёный рис") (certainty-factor ?cf3))
    ?f <- (available-food (name "Ветчина в медовом соусе с рисом") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.45 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ветчина в медовом соусе с рисом из запечённой ветчины, ягод, мёда и варёного риса (Ветчина в медовом соусе с рисом: " ?newcf ")")))
)

(defrule r137-fact-doesnt-exist
    ?r <- (available-rule "r137")
    (available-food (name "Ветчина в медовом соусе с рисом") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ветчина в медовом соусе с рисом это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r137-fact-exists
    ?r <- (available-rule "r137")
    (available-food (name "Ветчина в медовом соусе с рисом") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ветчина в медовом соусе с рисом это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r138-fact-doesnt-exist
    ?r <- (available-rule "r138")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Молоко") (certainty-factor ?cf2))
    (available-food (name "Жареная баранина") (certainty-factor ?cf3))
    (available-food (name "Печёный картофель") (certainty-factor ?cf4))
    (not (exists (available-food (name "Пастуший пирог"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Пастуший пирог") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Пастуший пирог в печи из молока, жареной баранины, лука, печёного картофеля (Пастуший пирог: " ?newcf ")")))
)

(defrule r138-fact-exists
    ?r <- (available-rule "r138")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Лук") (certainty-factor ?cf1))
    (available-food (name "Молоко") (certainty-factor ?cf2))
    (available-food (name "Жареная баранина") (certainty-factor ?cf3))
    (available-food (name "Печёный картофель") (certainty-factor ?cf4))
    ?f <- (available-food (name "Пастуший пирог") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.6 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Пастуший пирог в печи из молока, жареной баранины, лука, печёного картофеля (Пастуший пирог: " ?newcf ")")))
)

(defrule r139-fact-doesnt-exist
    ?r <- (available-rule "r139")
    (available-food (name "Пастуший пирог") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Пастуший пирог это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r139-fact-exists
    ?r <- (available-rule "r139")
    (available-food (name "Пастуший пирог") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Пастуший пирог это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r140-fact-doesnt-exist
    ?r <- (available-rule "r140")
    (available-food (name "Пастуший пирог") (certainty-factor ?cf0))
    (not (exists (available-food (name "Закуска"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Закуска") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Пастуший пирог это закуска (Закуска: " ?newcf ")")))
)

(defrule r140-fact-exists
    ?r <- (available-rule "r140")
    (available-food (name "Пастуший пирог") (certainty-factor ?cf0))
    ?f <- (available-food (name "Закуска") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Пастуший пирог это закуска (Закуска: " ?newcf ")")))
)

(defrule r141-fact-doesnt-exist
    ?r <- (available-rule "r141")
    (available-food (name "Суши с красной рыбой") (certainty-factor ?cf0))
    (available-food (name "Суши с белой рыбой") (certainty-factor ?cf1))
    (available-food (name "Ролл") (certainty-factor ?cf2))
    (not (exists (available-food (name "Сет роллов"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Сет роллов") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сет роллов из суши с красной рыбой, суши с белой рыбой и роллов (Сет роллов: " ?newcf ")")))
)

(defrule r141-fact-exists
    ?r <- (available-rule "r141")
    (available-food (name "Суши с красной рыбой") (certainty-factor ?cf0))
    (available-food (name "Суши с белой рыбой") (certainty-factor ?cf1))
    (available-food (name "Ролл") (certainty-factor ?cf2))
    ?f <- (available-food (name "Сет роллов") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сет роллов из суши с красной рыбой, суши с белой рыбой и роллов (Сет роллов: " ?newcf ")")))
)

(defrule r142-fact-doesnt-exist
    ?r <- (available-rule "r142")
    (available-food (name "Сет роллов") (certainty-factor ?cf0))
    (not (exists (available-food (name "Основное блюдо"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Основное блюдо") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Сет роллов это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r142-fact-exists
    ?r <- (available-rule "r142")
    (available-food (name "Сет роллов") (certainty-factor ?cf0))
    ?f <- (available-food (name "Основное блюдо") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Сет роллов это основное блюдо (Основное блюдо: " ?newcf ")")))
)

(defrule r143-fact-doesnt-exist
    ?r <- (available-rule "r143")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    (available-food (name "Яблоко") (certainty-factor ?cf2))
    (available-food (name "Сахар") (certainty-factor ?cf3))
    (available-food (name "Основа пирога") (certainty-factor ?cf4))
    (not (exists (available-food (name "Яблочный пирог"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.75 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Яблочный пирог") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Яблочный пирог в печи из муки, яблок, сахара и основы для пирога (Яблочный пирог: " ?newcf ")")))
)

(defrule r143-fact-exists
    ?r <- (available-rule "r143")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Мука") (certainty-factor ?cf1))
    (available-food (name "Яблоко") (certainty-factor ?cf2))
    (available-food (name "Сахар") (certainty-factor ?cf3))
    (available-food (name "Основа пирога") (certainty-factor ?cf4))
    ?f <- (available-food (name "Яблочный пирог") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.75 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Яблочный пирог в печи из муки, яблок, сахара и основы для пирога (Яблочный пирог: " ?newcf ")")))
)

(defrule r144-fact-doesnt-exist
    ?r <- (available-rule "r144")
    (available-food (name "Яблочный пирог") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Яблочный пирог это десерт (Десерт: " ?newcf ")")))
)

(defrule r144-fact-exists
    ?r <- (available-rule "r144")
    (available-food (name "Яблочный пирог") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Яблочный пирог это десерт (Десерт: " ?newcf ")")))
)

(defrule r145-fact-doesnt-exist
    ?r <- (available-rule "r145")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    (available-food (name "Ягоды") (certainty-factor ?cf2))
    (available-food (name "Основа пирога") (certainty-factor ?cf3))
    (not (exists (available-food (name "Чизкейк с ягодами"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Чизкейк с ягодами") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Чизкейк с ягодами в печи из ягод, молока и основы для пирога (Чизкейк с ягодами: " ?newcf ")")))
)

(defrule r145-fact-exists
    ?r <- (available-rule "r145")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    (available-food (name "Ягоды") (certainty-factor ?cf2))
    (available-food (name "Основа пирога") (certainty-factor ?cf3))
    ?f <- (available-food (name "Чизкейк с ягодами") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.7 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Чизкейк с ягодами в печи из ягод, молока и основы для пирога (Чизкейк с ягодами: " ?newcf ")")))
)

(defrule r146-fact-doesnt-exist
    ?r <- (available-rule "r146")
    (available-food (name "Чизкейк с ягодами") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Чизкейк с ягодами это десерт (Десерт: " ?newcf ")")))
)

(defrule r146-fact-exists
    ?r <- (available-rule "r146")
    (available-food (name "Чизкейк с ягодами") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Чизкейк с ягодами это десерт (Десерт: " ?newcf ")")))
)

(defrule r147-fact-doesnt-exist
    ?r <- (available-rule "r147")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (available-food (name "Какао") (certainty-factor ?cf3))
    (available-food (name "Основа пирога") (certainty-factor ?cf4))
    (not (exists (available-food (name "Шоколадный пирог"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.75 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Шоколадный пирог") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Шоколадный пирог в печи из какао, молока, сахара и основы для пирога (Шоколадный пирог: " ?newcf ")")))
)

(defrule r147-fact-exists
    ?r <- (available-rule "r147")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (available-food (name "Какао") (certainty-factor ?cf3))
    (available-food (name "Основа пирога") (certainty-factor ?cf4))
    ?f <- (available-food (name "Шоколадный пирог") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.75 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Шоколадный пирог в печи из какао, молока, сахара и основы для пирога (Шоколадный пирог: " ?newcf ")")))
)

(defrule r148-fact-doesnt-exist
    ?r <- (available-rule "r148")
    (available-food (name "Шоколадный пирог") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Шоколадный пирог это десерт (Десерт: " ?newcf ")")))
)

(defrule r148-fact-exists
    ?r <- (available-rule "r148")
    (available-food (name "Шоколадный пирог") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Шоколадный пирог это десерт (Десерт: " ?newcf ")")))
)

(defrule r149-fact-doesnt-exist
    ?r <- (available-rule "r149")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Мёд") (certainty-factor ?cf1))
    (available-food (name "Тесто") (certainty-factor ?cf2))
    (not (exists (available-food (name "Медовое печенье"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Медовое печенье") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Медовое печенье в печи из мёда и теста (Медовое печенье: " ?newcf ")")))
)

(defrule r149-fact-exists
    ?r <- (available-rule "r149")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Мёд") (certainty-factor ?cf1))
    (available-food (name "Тесто") (certainty-factor ?cf2))
    ?f <- (available-food (name "Медовое печенье") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Медовое печенье в печи из мёда и теста (Медовое печенье: " ?newcf ")")))
)

(defrule r150-fact-doesnt-exist
    ?r <- (available-rule "r150")
    (available-food (name "Медовое печенье") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Медовое печенье это десерт (Десерт: " ?newcf ")")))
)

(defrule r150-fact-exists
    ?r <- (available-rule "r150")
    (available-food (name "Медовое печенье") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Медовое печенье это десерт (Десерт: " ?newcf ")")))
)

(defrule r151-fact-doesnt-exist
    ?r <- (available-rule "r151")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Ягоды") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (available-food (name "Тесто") (certainty-factor ?cf3))
    (not (exists (available-food (name "Ягодное печенье"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Ягодное печенье") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ягодное печенье в печи из ягод, сахара и теста (Ягодное печенье: " ?newcf ")")))
)

(defrule r151-fact-exists
    ?r <- (available-rule "r151")
    (available-food (name "Печь") (certainty-factor ?cf0))
    (available-food (name "Ягоды") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (available-food (name "Тесто") (certainty-factor ?cf3))
    ?f <- (available-food (name "Ягодное печенье") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.77 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ягодное печенье в печи из ягод, сахара и теста (Ягодное печенье: " ?newcf ")")))
)

(defrule r152-fact-doesnt-exist
    ?r <- (available-rule "r152")
    (available-food (name "Ягодное печенье") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ягодное печенье это десерт (Десерт: " ?newcf ")")))
)

(defrule r152-fact-exists
    ?r <- (available-rule "r152")
    (available-food (name "Ягодное печенье") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ягодное печенье это десерт (Десерт: " ?newcf ")")))
)

(defrule r153-fact-doesnt-exist
    ?r <- (available-rule "r153")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Яйцо") (certainty-factor ?cf1))
    (available-food (name "Молоко") (certainty-factor ?cf2))
    (available-food (name "Ягоды") (certainty-factor ?cf3))
    (available-food (name "Сахар") (certainty-factor ?cf4))
    (not (exists (available-food (name "Ягодный сорбет"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)))
    (assert (available-food (name "Ягодный сорбет") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ягодный сорбет в кастрюле из ягод, молока, яйца и сахара (Ягодный сорбет: " ?newcf ")")))
)

(defrule r153-fact-exists
    ?r <- (available-rule "r153")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Яйцо") (certainty-factor ?cf1))
    (available-food (name "Молоко") (certainty-factor ?cf2))
    (available-food (name "Ягоды") (certainty-factor ?cf3))
    (available-food (name "Сахар") (certainty-factor ?cf4))
    ?f <- (available-food (name "Ягодный сорбет") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2 ?cf3 ?cf4)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ягодный сорбет в кастрюле из ягод, молока, яйца и сахара (Ягодный сорбет: " ?newcf ")")))
)

(defrule r154-fact-doesnt-exist
    ?r <- (available-rule "r154")
    (available-food (name "Ягодный сорбет") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Ягодный сорбет это десерт (Десерт: " ?newcf ")")))
)

(defrule r154-fact-exists
    ?r <- (available-rule "r154")
    (available-food (name "Ягодный сорбет") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Ягодный сорбет это десерт (Десерт: " ?newcf ")")))
)

(defrule r155-fact-doesnt-exist
    ?r <- (available-rule "r155")
    (available-food (name "Вода") (certainty-factor ?cf0))
    (available-food (name "Долька арбуза") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (not (exists (available-food (name "Арбузное мороженое"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Арбузное мороженое") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Арбузное мороженое из воды, арбуза и сахара (Арбузное мороженое: " ?newcf ")")))
)

(defrule r155-fact-exists
    ?r <- (available-rule "r155")
    (available-food (name "Вода") (certainty-factor ?cf0))
    (available-food (name "Долька арбуза") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    ?f <- (available-food (name "Арбузное мороженое") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.5 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Арбузное мороженое из воды, арбуза и сахара (Арбузное мороженое: " ?newcf ")")))
)

(defrule r156-fact-doesnt-exist
    ?r <- (available-rule "r156")
    (available-food (name "Арбузное мороженое") (certainty-factor ?cf0))
    (not (exists (available-food (name "Десерт"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Десерт") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Арбузное мороженое это десерт (Десерт: " ?newcf ")")))
)

(defrule r156-fact-exists
    ?r <- (available-rule "r156")
    (available-food (name "Арбузное мороженое") (certainty-factor ?cf0))
    ?f <- (available-food (name "Десерт") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Арбузное мороженое это десерт (Десерт: " ?newcf ")")))
)

(defrule r157-fact-doesnt-exist
    ?r <- (available-rule "r157")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (available-food (name "Какао") (certainty-factor ?cf3))
    (not (exists (available-food (name "Горячий какао"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2 ?cf3)))
    (assert (available-food (name "Горячий какао") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Горячий какао в кастрюле из молока, какао и сахара (Горячий какао: " ?newcf ")")))
)

(defrule r157-fact-exists
    ?r <- (available-rule "r157")
    (available-food (name "Кастрюля") (certainty-factor ?cf0))
    (available-food (name "Молоко") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (available-food (name "Какао") (certainty-factor ?cf3))
    ?f <- (available-food (name "Горячий какао") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2 ?cf3)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Горячий какао в кастрюле из молока, какао и сахара (Горячий какао: " ?newcf ")")))
)

(defrule r158-fact-doesnt-exist
    ?r <- (available-rule "r158")
    (available-food (name "Горячий какао") (certainty-factor ?cf0))
    (not (exists (available-food (name "Напиток"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Напиток") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Горячий какао это напиток (Напиток: " ?newcf ")")))
)

(defrule r158-fact-exists
    ?r <- (available-rule "r158")
    (available-food (name "Горячий какао") (certainty-factor ?cf0))
    ?f <- (available-food (name "Напиток") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Горячий какао это напиток (Напиток: " ?newcf ")")))
)

(defrule r159-fact-doesnt-exist
    ?r <- (available-rule "r159")
    (available-food (name "Долька арбуза") (certainty-factor ?cf0))
    (available-food (name "Сахар") (certainty-factor ?cf1))
    (not (exists (available-food (name "Арбузный сок"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1)))
    (assert (available-food (name "Арбузный сок") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Арбузный сок из арбуза и сахара (Арбузный сок: " ?newcf ")")))
)

(defrule r159-fact-exists
    ?r <- (available-rule "r159")
    (available-food (name "Долька арбуза") (certainty-factor ?cf0))
    (available-food (name "Сахар") (certainty-factor ?cf1))
    ?f <- (available-food (name "Арбузный сок") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Арбузный сок из арбуза и сахара (Арбузный сок: " ?newcf ")")))
)

(defrule r160-fact-doesnt-exist
    ?r <- (available-rule "r160")
    (available-food (name "Арбузный сок") (certainty-factor ?cf0))
    (not (exists (available-food (name "Напиток"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Напиток") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Арбузный сок это напиток (Напиток: " ?newcf ")")))
)

(defrule r160-fact-exists
    ?r <- (available-rule "r160")
    (available-food (name "Арбузный сок") (certainty-factor ?cf0))
    ?f <- (available-food (name "Напиток") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Арбузный сок это напиток (Напиток: " ?newcf ")")))
)

(defrule r161-fact-doesnt-exist
    ?r <- (available-rule "r161")
    (available-food (name "Морковь") (certainty-factor ?cf0))
    (available-food (name "Долька тыквы") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    (not (exists (available-food (name "Тыквенный сок"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)))
    (assert (available-food (name "Тыквенный сок") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Тыквенный сок из тыквы и моркови и сахара (Тыквенный сок: " ?newcf ")")))
)

(defrule r161-fact-exists
    ?r <- (available-rule "r161")
    (available-food (name "Морковь") (certainty-factor ?cf0))
    (available-food (name "Долька тыквы") (certainty-factor ?cf1))
    (available-food (name "Сахар") (certainty-factor ?cf2))
    ?f <- (available-food (name "Тыквенный сок") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.9 (min ?cf0 ?cf1 ?cf2)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Тыквенный сок из тыквы и моркови и сахара (Тыквенный сок: " ?newcf ")")))
)

(defrule r162-fact-doesnt-exist
    ?r <- (available-rule "r162")
    (available-food (name "Тыквенный сок") (certainty-factor ?cf0))
    (not (exists (available-food (name "Напиток"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Напиток") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Тыквенный сок это напиток (Напиток: " ?newcf ")")))
)

(defrule r162-fact-exists
    ?r <- (available-rule "r162")
    (available-food (name "Тыквенный сок") (certainty-factor ?cf0))
    ?f <- (available-food (name "Напиток") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Тыквенный сок это напиток (Напиток: " ?newcf ")")))
)

(defrule r163-fact-doesnt-exist
    ?r <- (available-rule "r163")
    (available-food (name "Яблоко") (certainty-factor ?cf0))
    (available-food (name "Сахар") (certainty-factor ?cf1))
    (not (exists (available-food (name "Яблочный компот"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 0.88 (min ?cf0 ?cf1)))
    (assert (available-food (name "Яблочный компот") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Яблочный компот в кастрюле из яблок и сахара (Яблочный компот: " ?newcf ")")))
)

(defrule r163-fact-exists
    ?r <- (available-rule "r163")
    (available-food (name "Яблоко") (certainty-factor ?cf0))
    (available-food (name "Сахар") (certainty-factor ?cf1))
    ?f <- (available-food (name "Яблочный компот") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 0.88 (min ?cf0 ?cf1)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Яблочный компот в кастрюле из яблок и сахара (Яблочный компот: " ?newcf ")")))
)

(defrule r164-fact-doesnt-exist
    ?r <- (available-rule "r164")
    (available-food (name "Яблочный компот") (certainty-factor ?cf0))
    (not (exists (available-food (name "Напиток"))))
    =>
    (retract ?r)
    (bind ?newcf (serial-combination-function 1.0 (min ?cf0)))
    (assert (available-food (name "Напиток") (certainty-factor ?newcf)))
    (assert (sendmessage (str-cat "Яблочный компот это напиток (Напиток: " ?newcf ")")))
)

(defrule r164-fact-exists
    ?r <- (available-rule "r164")
    (available-food (name "Яблочный компот") (certainty-factor ?cf0))
    ?f <- (available-food (name "Напиток") (certainty-factor ?cf))
    =>
    (retract ?r)
    (bind ?newcf (parallel-combination-function (serial-combination-function 1.0 (min ?cf0)) ?cf))
    (modify ?f (certainty-factor ?newcf))
    (assert (sendmessage (str-cat "Яблочный компот это напиток (Напиток: " ?newcf ")")))
)

; Правила немножечко зацикливаются... поэтому разрешим правилам выполняться только один раз, вот список доступных
(deffacts available-rules
    (available-rule "r001")
    (available-rule "r002")
    (available-rule "r003")
    (available-rule "r004")
    (available-rule "r005")
    (available-rule "r006")
    (available-rule "r007")
    (available-rule "r008")
    (available-rule "r009")
    (available-rule "r010")
    (available-rule "r011")
    (available-rule "r012")
    (available-rule "r013")
    (available-rule "r014")
    (available-rule "r015")
    (available-rule "r016")
    (available-rule "r017")
    (available-rule "r018")
    (available-rule "r019")
    (available-rule "r020")
    (available-rule "r021")
    (available-rule "r022")
    (available-rule "r023")
    (available-rule "r024")
    (available-rule "r025")
    (available-rule "r026")
    (available-rule "r027")
    (available-rule "r028")
    (available-rule "r029")
    (available-rule "r030")
    (available-rule "r031")
    (available-rule "r032")
    (available-rule "r033")
    (available-rule "r034")
    (available-rule "r035")
    (available-rule "r036")
    (available-rule "r037")
    (available-rule "r038")
    (available-rule "r039")
    (available-rule "r040")
    (available-rule "r041")
    (available-rule "r042")
    (available-rule "r043")
    (available-rule "r044")
    (available-rule "r045")
    (available-rule "r046")
    (available-rule "r047")
    (available-rule "r048")
    (available-rule "r049")
    (available-rule "r050")
    (available-rule "r051")
    (available-rule "r052")
    (available-rule "r053")
    (available-rule "r054")
    (available-rule "r055")
    (available-rule "r056")
    (available-rule "r057")
    (available-rule "r058")
    (available-rule "r059")
    (available-rule "r060")
    (available-rule "r061")
    (available-rule "r062")
    (available-rule "r063")
    (available-rule "r064")
    (available-rule "r065")
    (available-rule "r066")
    (available-rule "r067")
    (available-rule "r068")
    (available-rule "r069")
    (available-rule "r070")
    (available-rule "r071")
    (available-rule "r072")
    (available-rule "r073")
    (available-rule "r074")
    (available-rule "r075")
    (available-rule "r076")
    (available-rule "r077")
    (available-rule "r078")
    (available-rule "r079")
    (available-rule "r080")
    (available-rule "r081")
    (available-rule "r082")
    (available-rule "r083")
    (available-rule "r084")
    (available-rule "r085")
    (available-rule "r086")
    (available-rule "r087")
    (available-rule "r088")
    (available-rule "r089")
    (available-rule "r090")
    (available-rule "r091")
    (available-rule "r092")
    (available-rule "r093")
    (available-rule "r094")
    (available-rule "r095")
    (available-rule "r096")
    (available-rule "r097")
    (available-rule "r098")
    (available-rule "r099")
    (available-rule "r100")
    (available-rule "r101")
    (available-rule "r102")
    (available-rule "r103")
    (available-rule "r104")
    (available-rule "r105")
    (available-rule "r106")
    (available-rule "r107")
    (available-rule "r108")
    (available-rule "r109")
    (available-rule "r110")
    (available-rule "r111")
    (available-rule "r112")
    (available-rule "r113")
    (available-rule "r114")
    (available-rule "r115")
    (available-rule "r116")
    (available-rule "r117")
    (available-rule "r118")
    (available-rule "r119")
    (available-rule "r120")
    (available-rule "r121")
    (available-rule "r122")
    (available-rule "r123")
    (available-rule "r124")
    (available-rule "r125")
    (available-rule "r126")
    (available-rule "r127")
    (available-rule "r128")
    (available-rule "r129")
    (available-rule "r130")
    (available-rule "r131")
    (available-rule "r132")
    (available-rule "r133")
    (available-rule "r134")
    (available-rule "r135")
    (available-rule "r136")
    (available-rule "r137")
    (available-rule "r138")
    (available-rule "r139")
    (available-rule "r140")
    (available-rule "r141")
    (available-rule "r142")
    (available-rule "r143")
    (available-rule "r144")
    (available-rule "r145")
    (available-rule "r146")
    (available-rule "r147")
    (available-rule "r148")
    (available-rule "r149")
    (available-rule "r150")
    (available-rule "r151")
    (available-rule "r152")
    (available-rule "r153")
    (available-rule "r154")
    (available-rule "r155")
    (available-rule "r156")
    (available-rule "r157")
    (available-rule "r158")
    (available-rule "r159")
    (available-rule "r160")
    (available-rule "r161")
    (available-rule "r162")
    (available-rule "r163")
    (available-rule "r164")
)