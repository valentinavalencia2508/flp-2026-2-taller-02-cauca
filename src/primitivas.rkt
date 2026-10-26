#lang eopl
;Autores: Aura Maria Pelaez Luna 2459422, Valentina Valencia Lopez 2459626

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.
;;
;; Aridades: +, -, *, / son n-arias; add1, sub1, not y abs son unarias;
;; las relacionales, and, or, xor e implica son binarias; entre es
;; ternaria; mcd y mcm son n-arias sobre enteros con al menos dos
;; argumentos; promedio es n-aria sobre números con al menos uno.

(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son números; si no, levanta
;; eopl:error a nombre de quien hizo la verificación.
(define exigir-numeros
  (lambda (args quien)
    (cond
      ((null? args)#t)
      ((number? (car args))
       (exigir-numeros(cdr args)quien))
       (else(eopl:error quien "Todos los argumentos deben ser numeros, lo que recibi fue: ~s" args))
      )))

;; exigir-enteros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son enteros; si no, levanta error.
(define exigir-enteros
  (lambda (args quien)
    (cond
      ((null? args)#t)
      ((and (integer? (car args)) (exact? (car args))) (exigir-enteros (cdr args) quien))
      (else(eopl:error quien "Todos los argumentos deben ser enteros, lo que recibi fue: ~s" args))
      )))

;; exigir-booleanos : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son booleanos; si no, levanta error.
(define exigir-booleanos
  (lambda (args quien)
    (cond
      ((null? args)#t)
      ((boolean? (car args)) (exigir-booleanos(cdr args)quien))
       (else(eopl:error quien "Todos los argumentos deben ser booleanos, lo que recibi fue: ~s" args))
      )))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Retorna #t si llegaron exactamente n argumentos; si no, levanta error.
(define exigir-cantidad
  (lambda (args n quien)
    (if (=(length args)n)
        #t
        (eopl:error quien "Se esperaban ~s argumentos, recibi ~s" n (length args)))
      ))

;; exigir-minimo : lista x int x symbol -> boolean
;; Retorna #t si llegaron al menos n argumentos; si no, levanta error.
(define exigir-minimo
  (lambda (args n quien)
    (if(>=(length args)n)
       #t
       (eopl:error quien "Se esperaban al menos ~s argumentos, recibi ~s" n (length args))
       )))


;; hay-cero? : lista de números -> boolean
;; Retorna #t si algún elemento de la lista es igual a cero.
(define hay-cero?
  (lambda (lista)
    (cond
      ((null? lista) #f)
      ((= (car lista) 0) #t)
      (else (hay-cero? (cdr lista))))
    ))
