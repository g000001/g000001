(in-package :g1)

#+sbcl ;; see src/code/pprint.lisp
(set-pprint-dispatch '(cons (eql sb-cltl2:compiler-let))
                     (symbol-function 'sb-pretty::pprint-let))
