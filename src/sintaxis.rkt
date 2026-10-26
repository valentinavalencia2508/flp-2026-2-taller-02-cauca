#lang eopl
;Autores: Aura Maria Pelaez Luna 2459422, Valentina Valencia Lopez 2459626

;; Taller 2 — El intérprete de Cauca.
;; Especificación léxica, especificación gramatical, scanner y parser.
;; Este módulo no requiere ningún otro.
;;
;; Lo que se escribe aquí:
;;
;;   especificacion-lexica      comentarios que empiezan con //, espacios
;;                              en blanco, números enteros y flotantes con
;;                              signo, e identificadores que empiezan por
;;                              letra y siguen con letras, dígitos, guion
;;                              bajo o signo de interrogación
;;   especificacion-gramatical  las producciones de <programa>,
;;                              <expresion> y <primitiva>, con los nombres
;;                              de constructor que indican los recuadros
;;                              del enunciado
;;   scanner : string -> lista de tokens   se construye con
;;                                         sllgen:make-string-scanner
;;   parser  : string -> programa          se construye con
;;                                         sllgen:make-string-parser
;;
;; La llamada a sllgen:make-define-datatypes genera los datatypes
;; programa, expresion y primitiva a partir de la gramática, con sus
;; constructores y sus predicados. Mientras la gramática esté vacía no
;; genera ninguno.

(define especificacion-lexica
  '((espacio-blanco(whitespace)skip)
    (comentario("//" (arbno(not #\newline)))skip)
    (identificador(letter(arbno(or letter digit "_" "?"))) symbol)
    (numero(digit(arbno digit)) number)
    (numero("-" digit(arbno digit))number)
    (numero(digit(arbno digit) "."digit(arbno digit))number)
    (numero("-" digit(arbno digit) "." digit(arbno digit))number)
    ))

(define especificacion-gramatical
 ;;<programa>
  '((programa(expresion)a-program)
    ;;<expresion>
    (expresion(numero)lit-exp)
    (expresion(identificador)var-exp)
    (expresion("true")true-exp)
    (expresion("false")false-exp)
    (expresion(primitiva "(" (separated-list expresion ",")")") prim-exp)
    (expresion("if" expresion "then" expresion "else" expresion "end") if-exp)
    (expresion("let" (arbno identificador "=" expresion)"in" expresion "end" )let-exp)
    (expresion ("proc" "(" (separated-list identificador ",") ")" expresion "end") proc-exp)
    (expresion("apply" expresion "(" (separated-list expresion ",")")")app-exp)
    (expresion ("letrec" (arbno identificador "(" (separated-list identificador ",") ")" "=" expresion) "in" expresion "end")letrec-exp)
    (expresion ("case" expresion(arbno "of" numero "=>" expresion)"otherwise" "=>" expresion "end")case-exp)
 ;;<primitiva>
    ;;n-arias (+, -, *, /)
    (primitiva("+") sum-prim)
    (primitiva("-") minus-prim)
    (primitiva("*") mult-prim)
    (primitiva("/") div-prim)
    ;;unarias (add1, sub1, not, abs)
    (primitiva("add1") add-prim)
    (primitiva("sub1") sub-prim)
    (primitiva("not") not-prim)
    (primitiva("abs") abs-prim)
    ;;binarias: relacionales
    (primitiva(">") mayor-prim)
    (primitiva(">=") mayorigual-prim)
    (primitiva("<") menor-prim)
    (primitiva("<=") menorigual-prim)
    (primitiva("==") igual-prim)
    ;;binarias: and, or, xor, implica
    (primitiva("and") and-prim)
    (primitiva("or") or-prim)
    (primitiva("xor") xor-prim)
    (primitiva("implica") implica-prim)
    ;;n-arias sobre enteros, mínimo 2 (mcd, mcm)
    (primitiva("mcd") mcd-prim)
    (primitiva("mcm") mcm-prim)
    ;;n-aria sobre números, mínimo 1 (promedio) 
    (primitiva("promedio") promedio-prim)
    ;;ternaria (entre)
    (primitiva("entre") entre-prim)
    ))

(sllgen:make-define-datatypes especificacion-lexica especificacion-gramatical)

;; mostrar-datatypes : -> void
;; Lista en pantalla los datatypes que SLLGEN genera a partir de la
;; gramática. Sirve para revisar los nombres de los constructores.
(define mostrar-datatypes
  (lambda ()
    (sllgen:list-define-datatypes especificacion-lexica especificacion-gramatical)))

;; scanner : string -> lista de tokens
;; Convierte el texto de un programa en la lista de sus tokens.
(define scanner
  (lambda (texto)
    ((sllgen:make-string-scanner especificacion-lexica especificacion-gramatical)texto)))

;; parser : string -> programa
;; Convierte el texto de un programa en su árbol de sintaxis abstracta.
(define parser
  (lambda (texto)
    ((sllgen:make-string-parser especificacion-lexica especificacion-gramatical)texto)))

(provide (all-defined-out))