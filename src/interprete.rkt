#lang eopl
;Autores: Aura Maria Pelaez Luna 2459422, Valentina Valencia Lopez 2459626

;; Taller 2 — El intérprete de Cauca.
;; El recorrido de la sintaxis abstracta y la aplicación de
;; procedimientos. Requiere sintaxis.rkt, valores.rkt, ambiente.rkt y
;; primitivas.rkt.
;;
;; apply-procedure vive aquí y no en valores.rkt porque llama a
;; evaluar-expresion.

(require "sintaxis.rkt")
(require "valores.rkt")
(require "ambiente.rkt")
(require "primitivas.rkt")

;; apply-procedure : procval x lista de valores -> valor
;; Propósito: ejecuta un procedimiento ya construido. Primero abre la
;; cerradura para sacar sus parámetros, su cuerpo y el ambiente donde fue
;; definido. Si la cantidad de argumentos no coincide con la de parámetros,
;; levanta eopl:error. Si coincide, evalúa el cuerpo en el ambiente de la
;; cerradura extendido con los parámetros ligados a los argumentos, y no en
;; el ambiente de la llamada; por eso el ejemplo de contraste da 50 y no 5000.

(define apply-procedure
        (lambda (proc args)
          (cases procval proc
            (cerradura (ids body env-clausura)
               (cond((not (= (length ids) (length args)))
           (eopl:error 'apply-procedure "Se esperaban ~s argumentos, recibi ~s"(length ids) (length args)))
          (else(evaluar-expresion body (ambiente-extendido ids args env-clausura))))))))
      
;; evaluar-programa : programa -> valor
;; Propósito: es el punto de entrada del intérprete. Un programa es una sola
;; expresión (a-program), así que la saca del programa y la evalúa en el
;; ambiente inicial, donde ya están ligadas n = 10, m = 3, p = 7, q = 2 y r = 5..

(define evaluar-programa
  (lambda (pgm)
    (cases programa pgm
      (a-program (exp)(evaluar-expresion exp (ambiente-inicial)))
      )))

;; evaluar-rands : lista de expresiones x ambiente -> lista de valores
;; Propósito: convierte una lista de expresiones (operandos) en la lista de
;; sus valores, todas evaluadas en el mismo ambiente. Evalúa de izquierda a
;; derecha: guarda con let el valor de la primera expresión antes de seguir
;; con el resto, porque Racket no garantiza el orden de evaluación de los
;; argumentos de una función. Con la lista vacía devuelve la lista vacía.

(define evaluar-rands
  (lambda (rands env)
    (cond((null? rands)'())
         (else(let((valor-actual(evaluar-expresion(car rands)env)))
           (cons valor-actual (evaluar-rands (cdr rands)env)))))))


;; evaluar-expresion : expresion x ambiente -> valor
;; Propósito: recorre el AST con cases y calcula el valor de cada expresión
;; en el ambiente dado.
(define evaluar-expresion
  (lambda (exp env)

    (cases expresion exp
;; lit-exp: un número literal. Su valor es el propio número, sin más cálculo.
      (lit-exp (dato) dato)
      
;; var-exp: una variable. Busca el identificador en el ambiente con apply-env,
;; respetando el shadowing; si no está ligado, apply-env levanta eopl:error.
      (var-exp(id)(apply-env env id))
      
;; true-exp / false-exp: los booleanos literales. Devuelven #t y #f.      
      (true-exp()#t)   
      (false-exp()#f)