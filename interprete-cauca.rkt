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
   

  Primitivas nuevas
  1. (interpretar "abs(-5)") => 5
  
  2. (interpretar "abs(7)") => 7

  3. (interpretar "abs(0)") => 0

  4. (interpretar "mcd(12, 18)") => 6

  5. (interpretar "mcd(12, 18, 24)")  => 6

  6. (interpretar "mcd(7, 13)") => 1

  7. (interpretar "mcm(4, 6)") => 12

  8.  (interpretar "promedio(2, 4, 6)") => 4

  9. (interpretar "xor(true, false)") => #t

  10. (interpretar "implica(true, false)") => #f

  11. (interpretar "entre(5, 1, 10)") => #t

  12.  (interpretar "abs(true)") => . . src\primitivas.rkt:24:12: abs: Todos los argumentos deben ser numeros, lo que recibi fue: (#t)

  13. (interpretar "mcd(2.5, 3)") => . . src\primitivas.rkt:34:11: mcd: Todos los argumentos deben ser enteros, lo que recibi fue: (2.5 3)

  14. (interpretar "xor(1, true)") => . . src\primitivas.rkt:44:12: xor: Todos los argumentos deben ser booleanos, lo que recibi fue: (1 #t)

  15. (interpretar "mcm(3, 5)") => 15

  16. (interpretar "mcm(2, 4, 6)") => 12

  17. (interpretar "promedio(5)") => 5

  18. (interpretar "promedio(1, 2, 3)") => 2

  19. (interpretar "xor(true, true)") => #f

  20. (interpretar "xor(false, false)") => #f

  21. (interpretar "implica(false, true)") => #t

  22. (interpretar "implica(true, true)") => #t

  23. (interpretar "entre(0, 1, 10)") => #f

  24. (interpretar "entre(10, 1, 10)") => #t

  25. Error: mcm con un no entero
      (interpretar "mcm(2.5, 4)")
      => mcm: Todos los argumentos deben ser enteros, lo que recibi fue: (2.5 4)

  26. Error: promedio con un booleano
      (interpretar "promedio(true, 1)")
      => promedio: Todos los argumentos deben ser numeros, lo que recibi fue: (#t 1)

  27. Error: implica con un número
      (interpretar "implica(1, true)")
      => implica: Todos los argumentos deben ser booleanos, lo que recibi fue: (1 #t)

  28. Error: entre con un booleano
      (interpretar "entre(true, 1, 10)")
      => entre: Todos los argumentos deben ser numeros, lo que recibi fue: (#t 1 10)
  

  Procedimientos
   1. Cero parámetros
     (interpretar "apply proc () 7 end ()")  => 7
   
   2. Un parámetro
      (interpretar "let f = proc (x) add1(x) end in apply f (4) end") => 5

   3. Varios parámetros (interpretar "let s = proc (a, b) +(a, b) end in apply s (3, 4) end")

   4. Procedimiento que recibe otro como argumento
      (interpretar "let dos_veces = proc (f, v) apply f (apply f (v)) end
                  inc = proc (x) add1(x) end
              in apply dos_veces (inc, 5) end") => 7

   5. Procedimiento que retorna otro (el intermedio se liga con let)
      (interpretar "let suma = proc (a) proc (b) +(a, b) end end
              in let suma3 = apply suma (3)
                 in apply suma3 (4) end
              end") => 7

   6. Error: el operador no es un procedimiento
     (interpretar "apply 5 (1)") => . . src\interprete.rkt:113:17: apply: El operador no es un procedimiento: 5

   7. Error: cantidad de argumentos incorrecta
     (interpretar "let f = proc (x) x end in apply f (1, 2) end") => . . src\interprete.rkt:30:11: apply-procedure: Se esperaban 1 argumentos, recibi 2

   8. Ejemplo de contraste: debe dar 50
     (interpretar "let factor = 10  
              in let escalar = proc (v) *(v, factor) end
                 in let factor = 1000
                    in apply escalar (5) end
                 end
              end") => 50  

  
  Recursión y case
   
   1. Recursivo simple: factorial
      (interpretar "letrec fact (k) = if ==(k, 0) then 1
                                else *(k, apply fact (sub1(k)))end
              in apply fact (5) end")   => 120

   2. Dos parámetros: potencia
      (interpretar "letrec potencia (base, exp) = if ==(exp, 0) then 1
                                            else *(base, apply potencia (base, sub1(exp))) end
              in apply potencia (2, 10) end")  => 1024

   3. Mutuamente recursivos: espar / esimpar
      (interpretar "letrec espar (k) = if ==(k, 0) then true
                                 else apply esimpar (sub1(k)) end
                     esimpar (k) = if ==(k, 0) then false
                                   else apply espar (sub1(k)) end
              in apply espar (10) end")  =>  #t

   4. letrec con un procedimiento pasado como argumento
      (interpretar "letrec aplicarn (f, k, v) = if ==(k, 0) then v
                                  else apply aplicarn (f, sub1(k), apply f (v)) end
              in let inc = proc (x) add1(x) end
                 in apply aplicarn (inc, 3, 10) end
              end")  => 13

   CASES

   1. Coincide con la primera rama
      (interpretar "case 1 of 1 => 100 of 3 => 300 otherwise => 0 end") => 100 

   2. Ejemplo del enunciado: coincide con la segunda
      (interpretar "let dia = 3
              in case dia of 1 => 100 of 3 => 300 of 7 => 700 otherwise => 0 end
              end") => 300

   3. Rama otherwise activa
      (interpretar "case 9 of 1 => 100 of 3 => 300 otherwise => 0 end") => 0

   4. Error: valor de control no numérico
      (interpretar "case true of 1 => 100 otherwise => 0 end") => . . src\interprete.rkt:124:8: case: El valor de control debe ser un numero, recibi: #t






|#