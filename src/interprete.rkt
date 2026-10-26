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

;; prim-exp: una primitiva aplicada a operandos. Evalúa los operandos de
;; izquierda a derecha con evaluar-rands y le pasa la lista de valores a
;; evaluar-primitiva, que verifica cantidad y tipo y calcula el resultado.
      (prim-exp(prim rands)(evaluar-primitiva prim(evaluar-rands rands env)))

;; if-exp: el condicional. Evalúa la condición y liga el resultado a
;; test-value. Con boolean? verifica que sea booleano; si no lo es, levanta
;; eopl:error, así un número no cuenta como verdadero. Si es #t evalúa la
;; rama then y si es #f la rama else; la otra rama nunca se evalúa.
       (if-exp (test true-exp false-exp)
        (let ((test-value (evaluar-expresion test env)))
          (cond((not (boolean? test-value))
             (eopl:error 'if "La condicion debe ser booleana, recibi: ~s" test-value))
            (test-value (evaluar-expresion true-exp env))(else (evaluar-expresion false-exp env))
            )))

;; let-exp: ligaduras locales. Evalúa las expresiones en el ambiente actual,
;; crea un ambiente extendido con los identificadores ligados a esos valores
;; y evalúa el cuerpo en ese ambiente nuevo. Las ligaduras no se ven entre sí.
      (let-exp(ids rands body)
         (let((valores(evaluar-rands rands env)))
           (evaluar-expresion body(ambiente-extendido ids valores env))
           ))

;; letrec-exp: ligadura recursiva. Crea un ambiente-recursivo con los nombres,
;; parámetros y cuerpos sin evaluar, y evalúa el cuerpo del letrec en él.
;; apply-env arma las clausuras con ese mismo ambiente, así cada procedimiento
;; se ve a sí mismo y a los demás.

      (letrec-exp (proc-names idss bodies body)
          (evaluar-expresion body(ambiente-recursivo proc-names idss bodies env)))

;; proc-exp: la definición de un procedimiento. No evalúa el cuerpo; construye
;; una cerradura que guarda los parámetros, el cuerpo sin evaluar y el
;; ambiente actual, que es el ambiente donde el procedimiento nace.
      (proc-exp(ids body)
         (cerradura ids body env))

;; app-exp: la aplicación de un procedimiento. Evalúa el operador y verifica
;; con procval? que sea un procedimiento; si no, levanta eopl:error. Luego
;; evalúa los argumentos de izquierda a derecha en el ambiente de la llamada
;; y delega en apply-procedure, que ejecuta el cuerpo.
      (app-exp(rator rands)
         (let((proc (evaluar-expresion rator env)))
           (cond((not (procval? proc))
                 (eopl:error 'apply "El operador no es un procedimiento: ~s" proc))
                (else(let((args(evaluar-rands rands env)))
                        (apply-procedure proc args)
                        )))))



;; case-exp: selección por valor. Evalúa el control una sola vez y verifica
;; con number? que sea número (si no, eopl:error). Recorre las ramas en orden
;; comparando con =; evalúa la acción de la primera coincidencia, o la rama
;; otherwise si no hay ninguna.

      (case-exp (exp valores acciones default)
  (let ((control (evaluar-expresion exp env)))
    (if (not (number? control))
        (eopl:error 'case "El valor de control debe ser un numero, recibi: ~s" control)
        (let buscar ((vs valores) (as acciones))
          (cond
            ((null? vs) (evaluar-expresion default env))
            ((= control (car vs)) (evaluar-expresion (car as) env))
            (else (buscar (cdr vs) (cdr as))))))))
      
      )))
(provide (all-defined-out))