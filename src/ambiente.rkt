#lang eopl
;Autores: Aura Maria Pelaez Luna 2459422, Valentina Valencia Lopez 2459626

;; Taller 2 — El intérprete de Cauca.
;; El TAD ambiente, la búsqueda de ligaduras y el ambiente inicial.
;; Requiere sintaxis.rkt y valores.rkt.
;;
;; Aquí se declara con define-datatype el tipo ambiente, con tres
;; variantes:
;;
;;   ambiente-vacio()
;;   ambiente-extendido(ids, valores, env)
;;     ids      (list-of symbol?)
;;     valores  list?
;;     env      ambiente?
;;   ambiente-recursivo(proc-names, idss, bodies, env)
;;     proc-names  (list-of symbol?)   los nombres declarados en el letrec
;;     idss        list?               la lista de parámetros de cada uno
;;     bodies      (list-of expresion?) los cuerpos, guardados sin evaluar
;;     env         ambiente?
;;
;; La variante recursiva no construye clausuras: las arma apply-env en el
;; momento de la búsqueda, y el ambiente que les entrega es el propio
;; ambiente-recursivo (EOPL, sección 3.4, figura 3.9).

(require "sintaxis.rkt")
(require "valores.rkt")

(define-datatype ambiente ambiente?
  (ambiente-vacio)
  (ambiente-extendido
   (ids(list-of symbol?))
   (valores list?)
   (env ambiente?)
   )
   (ambiente-recursivo
   (proc-names (list-of symbol?))
   (idss list?)
   (bodies (list-of expresion?))
   (env ambiente?)))

;; buscar-posicion : symbol x (list-of symbol) -> número o #f
;; Devuelve el índice (desde 0) de id dentro de la lista ids,
;; o #f si id no está en la lista. 
(define buscar-posicion
  (lambda (id ids)
    (cond
      ((null? ids)#f)
      ((eqv? id(car ids))
       0)(else
          (let((resto(buscar-posicion id(cdr ids))))
            (if resto
                (+ resto 1) #f
                )
            )
        ))))
