
#lang eopl
;Autores: Aura Maria Pelaez Luna 2459422, Valentina Valencia Lopez 2459626

;; Taller 2 — El intérprete de Cauca.
;; Fachada: reúne los seis módulos de src/ y reexporta todo lo que
;; definen, de modo que quien la requiera vea todos los nombres sin
;; requerir los módulos uno por uno.
;;
;;   src/sintaxis.rkt    especificación léxica y gramatical, scanner, parser
;;   src/valores.rkt     el valor procedimiento
;;   src/ambiente.rkt    el TAD ambiente y el ambiente inicial
;;   src/primitivas.rkt  las primitivas y sus verificaciones
;;   src/interprete.rkt  la evaluación y la aplicación de procedimientos
;;   src/interfaz.rkt    el punto de entrada y el REPL
;;
;; Los require van en un solo sentido. Racket no carga dos módulos que se
;; requieran entre sí.

(require "src/sintaxis.rkt")
(require "src/valores.rkt")
(require "src/ambiente.rkt")
(require "src/primitivas.rkt")
(require "src/interprete.rkt")
(require "src/interfaz.rkt")

(provide (all-from-out "src/sintaxis.rkt"
                       "src/valores.rkt"
                       "src/ambiente.rkt"
                       "src/primitivas.rkt"
                       "src/interprete.rkt"
                       "src/interfaz.rkt"))

;;-----------------------------------
;;; Ejemplos
;;-----------------------------------

#|
  Aquí van los ejemplos que pide el enunciado: 5 del scanner, 5 del
  parser y los de ejecución de cada parte, con el resultado de cada uno
  escrito al lado. Las pruebas con rackunit viven en pruebas-cauca.rkt.

  Scanner
    1.(scanner "+(1, 2)")   => ((literal-string31 "+" 1)
                             (literal-string31 "(" 1)
                             (numero 1 1)
                             (literal-string31 "," 1)
                             (numero 2 1)
                             (literal-string31 ")" 1))
  
    2.(scanner "let x = 5 in x end") => ((literal-string31 "let" 1)
                                         (identificador x 1)
                                         (literal-string31 "=" 1)
                                         (numero 5 1)
                                         (literal-string31 "in" 1)
                                         (identificador x 1)
                                         (literal-string31 "end" 1))
    
    3. (scanner "// comentario\n42")  => ((numero 42 2))
    
    4. (scanner "-3.5") => ((numero -3.5 1))

    5. (scanner "es_par?") => ((identificador es_par? 1))
  
          
  Parser
   1. (parser "42") => #(struct:a-program #(struct:lit-exp 42))

   2. (parser "x") => #(struct:a-program #(struct:var-exp x))

   3. (parser "+(1, 2)") => #(struct:a-program
                             #(struct:prim-exp
                              #(struct:sum-prim)
                             (#(struct:lit-exp 1) #(struct:lit-exp 2))))

   4. (parser "if true then 1 else 0 end") =>  #(struct:a-program
                                                #(struct:if-exp
                                                 #(struct:true-exp)
                                                 #(struct:lit-exp 1)
                                                 #(struct:lit-exp 0)))

   5. (parser "let x = 5 in x end") => #(struct:a-program
                                        #(struct:let-exp (x) (#(struct:lit-exp 5)) #(struct:var-exp x)))
     
  
  
  Ejecución del lenguaje base
   
   1. (interpretar "+(1, 2, 3)") => 6

   2. (interpretar "n") => 10

   3. (interpretar "true")  => #t

   4. (interpretar "if >(n, 5) then 1 else 0 end") => 1

   5. (interpretar "let x = 5 y = 3 in +(x, y) end") => #<procedure:>>
                                                        8
   6. (interpretar "let n = 1 in n end") => 1

   7. (interpretar "and(>(n, 0), <(m, 10))") => #t

   8. (interpretar "if 3 then 1 else 0 end") =>  . . interprete.rkt:88:13: if: La condicion debe ser booleana, recibi: 3

   9. (interpretar "z") => . . ambiente.rkt:60:10: apply-env: La variable no esta ligada: z

   10. (interpretar "/(10, 0)") => . . primitivas.rkt:97:14: /: No se puede dividir por cero

   11. (interpretar "false") => #f

   12. (interpretar "-(10, 3)") => 7

   13. (interpretar "*(4, 5)") => 20

   14. (interpretar "/(20, 4)") => 5

   15. (interpretar "add1(4)") => 5

   16. (interpretar "sub1(4)") => 3

   17. (interpretar ">=(5, 5)") => #t

   18. (interpretar "<=(3, 2)") => #f

   19. (interpretar "==(4, 4)") => #t

   20. (interpretar "not(false)") => #t

   21. (interpretar "or(false, true)") => #t

   22. Ejemplo del enunciado: el área del rectángulo
       (interpretar "let base = 8
                         altura = 5
                     in
                       if and(>(base, 0), >(altura, 0))
                       then *(base, altura)
                       else 0
                       end
                     end") => 40

   23. Error: tipo equivocado en una primitiva
       (interpretar "+(1, true)")
       => +: Todos los argumentos deben ser numeros, lo que recibi fue: (1 #t)

   24. Error: cantidad de argumentos incorrecta
       (interpretar "add1(1, 2)")
       => add1: Se esperaban 1 argumentos, recibi 2
   

 