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
	(printout t "Сообщения очищены ..." crlf)	
)

(defrule set-output-and-halt
	(declare (salience 99))
	?current-message <- (sendmessagehalt ?new-msg)
	?proxy <- (ioproxy (messages $?msg-list))
	=>
	(printout t "Сообщение установлено : " ?new-msg " ... останавливаюсь ..." crlf)
	(modify ?proxy (messages ?new-msg))
	(retract ?current-message)
	(halt)
)

; (defrule append-output-and-halt
; 	//  Аналогичен предыдущему, но с добавлением сообщения, а не с заменой
; )

; (defrule set-output-and-proceed
; 	//  Аналогичен предыдущему, но с установкой сообщения и продолжением работы (извлекая факт с текущим сообщением)
; )

; (defrule append-output-and-proceed
; 	//  По аналогии
; )

;======================================================================================
(deftemplate person 
	(slot name) 
	(slot eyes)
	(slot age)
	(slot hair)
)

(defrule greeting
   =>
   (printout t "Hello! " crlf)
)

(deffacts some-of-candidates
	(person (name Джон) (eyes Black) (age 30) (hair Black))
	(person (name Jane) (eyes Violet) (age 20) (hair Red))
	(person (name Джек) (eyes Green) (age 27) (hair Red))
	(person (name Jennifer) (eyes Brown) (age 50) (hair Brown))
)

(defrule complex-eye-hair-match 
	(declare (salience 40))
	?p1 <- (person (name ?name1) 
		(eyes ?eyes1)
		(age ?age1&:(< ?age1 30))
		(hair ?hair1)
	) 
	?p2 <-	(person (name ?name2&~?name1) 
		(eyes ?eyes2&~eyes1) 
		(age ?age2)
		(hair ?hair2&red|?hair1)
	)
	(test (< (abs (- ?age1 ?age2)) 10))
	;(test (< (fact-index ?p1) (fact-index ?p2)))
	=> 
	(printout t "----------------------" crlf) 
	(printout t "  " ?name1 " has " ?eyes1 " eyes and " ?hair1 " hair." crlf) 
	(printout t "  " ?name2 " has " ?eyes2 " eyes and " ?hair2 " hair." crlf)
	(assert (appendmessagehalt (str-cat "У нас есть пара! " ?name1 " и " ?name2)))
        ;(assert (appendmessagehalt "У нас есть пара!"))
)

(defrule match-pair-for-user 
	(declare (salience 10))
	=> 
	(assert (sendmessagehalt "Вам пары не досталось, но вы там держитесь!"))
) 