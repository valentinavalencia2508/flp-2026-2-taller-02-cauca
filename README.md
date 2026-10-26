# Taller 2 — El intérprete de Cauca

**Fundamentos de Interpretación y Compilación de Lenguajes de Programación**
Escuela de Ingeniería de Sistemas y Computación, Universidad del Valle

## Integrantes

| Nombre | Código | Correo institucional |
|---|---|---|
| Aura Maria Pelaez Luna | 2459422 | aura.pelaez@correounivalle.edu.co |
| Valentina Valencia Lopez | 2459626 | valentina.valencia.lopez@correounivalle.edu.co |

## Descripción

Cauca es un lenguaje de programación pequeño con números, booleanos, primitivas, condicionales y ligaduras locales, al que se le agregan procedimientos con clausuras y recursión. Este repositorio contiene su intérprete, escrito en Racket con `#lang eopl` y la librería SLLGEN para el análisis léxico y sintáctico.

El intérprete convierte el texto de un programa en un árbol de sintaxis abstracta (AST) y lo evalúa recorriendo ese árbol con un ambiente, que es la tabla que liga cada nombre a su valor.

```
texto  →  scanner / parser  →  AST  →  evaluar-expresion + ambiente  →  valor
```

## Partes del proyecto

1. **Intérprete base.** Especificación léxica y gramatical con SLLGEN, ambiente con `ambiente-vacio` y `ambiente-extendido`, `apply-env`, evaluación de literales, variables, primitivas, `if` y `let`, y un REPL. El ambiente inicial liga `n = 10`, `m = 3`, `p = 7`, `q = 2` y `r = 5`.
2. **Extensión de primitivas.** Se agregan `abs`, `mcd`, `mcm`, `promedio`, `xor`, `implica` y `entre`, todas con verificación de tipo y de cantidad de argumentos.
3. **Procedimientos y clausuras.** `proc` y `apply`. Un procedimiento guarda su cuerpo y el ambiente donde fue definido, y se evalúa en ese ambiente extendido con sus parámetros.
4. **Recursión y selección por valor.** `letrec`, con la variante `ambiente-recursivo` para que los procedimientos se llamen a sí mismos y entre sí, y `case`, que compara una expresión de control contra literales.
5. **Informe de AST y traza.** El AST de un programa y la traza de una evaluación con su cadena de ambientes, con diagramas en Mermaid.
6. **Informe de corrección.** Demostraciones formales de `apply-procedure`, de la ligadura recursiva y de `case`.

## Estructura del repositorio

```
src/sintaxis.rkt             Especificación léxica y gramatical, scanner, parser
src/valores.rkt              El valor procedimiento: la clausura
src/ambiente.rkt             El TAD ambiente, apply-env y el ambiente inicial
src/primitivas.rkt           Las primitivas y sus verificaciones
src/interprete.rkt           La evaluación y la aplicación de procedimientos
src/interfaz.rkt             El punto de entrada y el REPL
interprete-cauca.rkt         La fachada: reúne los seis módulos y los reexporta
pruebas-cauca.rkt            Batería de pruebas con rackunit
docs/informe-ast.md          Informe de AST y traza (Parte 5)
docs/informe-correccion.md   Informe de corrección (Parte 6)
```

## Cómo usarlo

Abre `interprete-cauca.rkt` en DrRacket, pulsa **Run** y evalúa programas en la consola:

```racket
(interpretar "let x = 5 y = 3 in +(x, y) end")
;; => 8

(interpretar "letrec fact (k) = if ==(k, 0) then 1
                                else *(k, apply fact (sub1(k))) end
              in apply fact (5) end")
;; => 120
```

Para abrir el REPL de Cauca:

```racket
(interpretador)
```

## Pruebas

Abre `pruebas-cauca.rkt` en DrRacket y pulsa **Run**, o desde la terminal:

```
racket pruebas-cauca.rkt
```

Al final se imprime el total de pruebas fallidas, que debe ser `0`.

## Ejemplos del lenguaje

Los ejemplos de scanner, parser y ejecución de cada parte, con su resultado, están en el bloque de comentarios al final de `interprete-cauca.rkt`.
