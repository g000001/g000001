(in-package :root.function.g000001)

;;; -------------------------------------------------------------------------
;;; setf
;;; -------------------------------------------------------------------------


;;; from cadr system 99 sys2;setf.lisp.1

;;; Handle SETF of backquote expressions, for decomposition.
;;; For example, (SETF `(A ,B (D ,XYZ)) FOO)
;;; sets B to the CADR and XYZ to the CADADDR of FOO.
;;; The constants in the pattern are ignored.

;;; Backquotes which use ,@ or ,. other than at the end of a list
;;; expand into APPENDs or NCONCs and cannot be SETF'd.

;;; This was used for making (setf `(a ,b) foo) return t if
;;; foo matched the pattern (had A as its car).
;;; The other change for reinstalling this
;;; would be to replace the PROGNs with ANDs
;;; in the expansions produced by (LIST SETF), etc.
;;;(DEFUN SETF-MATCH (PATTERN OBJECT)
;;;  (COND ((NULL PATTERN) T)
;;;	((SYMBOLP PATTERN)
;;;	 `(PROGN (SETQ ,PATTERN ,OBJECT) T))
;;;	((EQ (CAR PATTERN) 'QUOTE)
;;;	 `(EQUAL ,PATTERN ,OBJECT))
;;;	((MEMQ (CAR PATTERN)
;;;	       '(CONS LIST LIST*))
;;;	 `(SETF ,PATTERN ,OBJECT))
;;;	(T `(PROGN (SETF ,PATTERN ,OBJECT) T))))

;;; This is used for ignoring any constants in the
;;; decomposition pattern, so that (setf `(a ,b) foo)
;;; always sets b and ignores a.
(defun setf-match (pattern object)
  (cond ((eq (zl:car-safe pattern) 'quote)
	 nil)
	(t `(setf ,pattern ,object))))

#+sbcl
(without-package-locks
  (define-setf-expander list (&rest elts)
    (let ((storevar (gensym)))
      (values nil nil (list storevar)
              (do ((i 0 (1+ i))
                   (accum)
                   (args elts (cdr args)))
                  ((null args)
                   (cons 'progn (nreverse accum)))
                (push (setf-match (car args) `(nth ,i ,storevar)) accum))
              `(incorrect-structure-setf list . ,elts)))))

#+sbcl
(without-package-locks
  (define-setf-expander sb-impl::backq-list (&rest elts)
    (let ((storevar (gensym)))
      (values nil nil (list storevar)
              (do ((i 0 (1+ i))
                   (accum)
                   (args elts (cdr args)))
                  ((null args)
                   (cons 'progn (nreverse accum)))
                (push (setf-match (car args) `(nth ,i ,storevar)) accum))
              `(incorrect-structure-setf list . ,elts)))))

#+sbcl
(without-package-locks
  (define-setf-expander list* (&rest elts)
    (let ((storevar (gensym)))
      (values nil nil (list storevar)
              (do ((i 0 (1+ i))
                   (accum)
                   (args elts (cdr args)))
                  ((null args)
                   (cons 'progn (nreverse accum)))
                (cond ((cdr args)
                       (push (setf-match (car args) `(nth ,i ,storevar)) accum))
                      (t (push (setf-match (car args) `(nthcdr ,i ,storevar)) accum))))
              `(incorrect-structure-setf list* . ,elts)))))

#+sbcl
(without-package-locks
  (define-setf-expander sb-impl::backq-list* (&rest elts)
    (let ((storevar (gensym)))
      (values nil nil (list storevar)
              (do ((i 0 (1+ i))
                   (accum)
                   (args elts (cdr args)))
                  ((null args)
                   (cons 'progn (nreverse accum)))
                (cond ((cdr args)
                       (push (setf-match (car args) `(nth ,i ,storevar)) accum))
                      (t (push (setf-match (car args) `(nthcdr ,i ,storevar)) accum))))
              `(incorrect-structure-setf list* . ,elts)))))

#+sbcl
(without-package-locks
  (define-setf-expander cons (car cdr)
    (let ((storevar (gensym)))
      (values nil nil (list storevar)
              `(progn ,(setf-match car `(car ,storevar))
                      ,(setf-match cdr `(cdr ,storevar)))
              `(incorrect-structure-setf cons ,car ,cdr)))))

#+sbcl
(without-package-locks
  (define-setf-expander sb-impl::backq-cons (car cdr)
    (let ((storevar (gensym)))
      (values nil nil (list storevar)
              `(progn ,(setf-match car `(car ,storevar))
                      ,(setf-match cdr `(cdr ,storevar)))
              `(incorrect-structure-setf cons ,car ,cdr)))))

(defmacro incorrect-structure-setf (&rest args)
  (error "You cannot SETF the place ~S~% in a way that refers to its old contents." args))
