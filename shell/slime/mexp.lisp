;;;; g000001.dev.macro.lisp -*- Mode: Lisp;-*-

(defpackage :g000001.dev.macro
  (:use :cl :swank)
  (:Export :*ignore-expands*
           :swank-macroexpand-all-foo))

(cl:in-package :g000001.dev.macro)


#|(DefVar *ignore-expands*
  '((Unless . #:unless)
    (DefMacro . #:defmacro)
    (When . #:when)
    (DeFun . #:defun)
    (Cond . _cond)
    (Return . #:return)
    ))|#


#|(defmacro _cond (&rest body)
  `(#:cond ,@body))|#

#+sbcl
(defun source-transform (form &optional (env (sb-kernel:make-null-lexenv)))
  (if (and (consp form)
           (symbolp (car form))
           (not (special-operator-p (car form))) )
      (let ((sb-c::*lexenv* env))
        (or (and (fboundp (car form))
                 (funcall (sb-int:info :function :source-transform (car form))
                          form ))
            (values form t) ))
      (values form T) ))


#+sbcl
(defun source-transform-string (form-string)
  (let ((swank::*macroexpand-printer-bindings*
         (cons '(*print-gensym*)
               swank::*macroexpand-printer-bindings* ) ))
    (swank::apply-macro-expander #'source-transform form-string) ))


(Defun st-expand (form &Optional (env (sb-kernel:make-null-lexenv)) &Aux it)
  (Cond ((Atom form) form)
        ((Setq it (let ((sb-c::*lexenv* env))
                    (sb-int:info :function :source-transform (car form))))
         (let ((sb-c::*lexenv* env))
           (Funcall it form)))
        (T (cons (Car form)
                 (st-expand (Cdr form) env)))))


(defun st-expand-string (form-string)
  (let ((swank::*macroexpand-printer-bindings*
         (cons '(*print-gensym*)
               swank::*macroexpand-printer-bindings* ) ))
    (swank::apply-macro-expander #'st-expand form-string) ))


(defvar *partial-macroexpanders*
  (make-hash-table))


(defun macroexpand-all (form &optional environment)
  (let ((sb-walker::*walk-form-expand-macros-p* t)
        (it nil)
        (form form #|(st-expand form (sb-kernel:make-null-lexenv))|#))
    (sb-walker:walk-form
     form environment
     (lambda (subform context env)
       (cond ((setq it
                    (and (eq context :eval)
                         (listp subform)
                         (symbolp (car subform))
                         (gethash (car subform) *partial-macroexpanders*)))
              ;; The partial expander must return T as its second value
              ;; if it wants to stop the walk.
              (funcall it subform env))
             (t
              subform))))))


(defun expand-all (form &optional environment)
  (Labels ((expand-all (form &optional environment)
             (let ((sb-walker::*walk-form-expand-macros-p* t)
                   (it nil)
                   (form form #|(st-expand form (sb-kernel:make-null-lexenv))|#))
               (sb-walker:walk-form
                form environment
                (lambda (subform context env)
                  (cond ((setq it
                               (and (eq context :eval)
                                    (listp subform)
                                    (symbolp (car subform))
                                    (gethash (car subform) *partial-macroexpanders*)))
                         ;; The partial expander must return T as its second value
                         ;; if it wants to stop the walk.
                         (funcall it subform env))
                        (t
                         subform)))))))
    (expand-all (st-expand (expand-all form environment))
                environment)))


(defun expand-all-string (form-string)
  (let ((swank::*macroexpand-printer-bindings*
         (cons '(*Print-Gensym* . nil)
               swank::*macroexpand-printer-bindings* ) ))
    (swank::apply-macro-expander #'expand-all form-string) ))


(defun macroexpand-all-string (form-string)
  (let ((swank::*macroexpand-printer-bindings*
         (cons '(*Print-Gensym* . T)
               swank::*macroexpand-printer-bindings* ) ))
    (swank::apply-macro-expander #'macroexpand-all form-string) ))


(defun macroexpand-decls+forms (body env) ; a bit of a kludge, but it works
  (mapcar (lambda (x)
            (if (and (listp x) (eq (car x) 'declare))
                x
                (macroexpand-all x env)))
          body))


(defmacro def (name (&rest args) &body body)
  `(setf (gethash ',name *partial-macroexpanders*)
         (lambda (,@args)
           ,@body)))


#+sbcl
(def sb-int:quasiquote (form env)
  (destructuring-bind (arg) (cdr form) ; sanity-check the shape
    (declare (ignore arg))
    (values (sb-cltl2::%quasiquoted-macroexpand-all form env) t)))


(def defun (form env)
  (destructuring-bind (name args &Body body)
                      (cdr form)
    (values `(Defun ,name (,@args)
               ,@(macroexpand-decls+forms body env))
            t)))


(def Cond (form env)
  (destructuring-bind (&rest clauses)
                      (cdr form)
    (values `(Cond ,@(Mapcar (Lambda (c)
                               (mapcar (Lambda (b) (sb-cltl2:macroexpand-all b env))
                                       c))
                             clauses))
            t)))


#|(swank::defslimefun swank-macroexpand-all-foo (string)
  (Let ((*Macroexpand-Hook*
          (Lambda (expander form env)
            (cond ((Assoc (car form) *ignore-expands*)
                   (progn
                     (Cons (Cdr (Assoc (Car form) *ignore-expands*)) (cdr form))))
                  (T
                   (progn
                     (Funcall expander form env)))))))
    (swank::apply-macro-expander (Lambda (form)
                                   (Reduce (Lambda (ans r)
                                             (Subst (Car r) (Cdr r)
                                                    ans))
                                           *ignore-expands*
                                           :initial-value
                                           (swank/backend::macroexpand-all form)))
                                 string)))|#


(swank::defslimefun swank-macroexpand-all* (string)
  (swank::apply-macro-expander 'macroexpand-all
                               string))


(defun mexp-string (form)
  (let ((swank::*macroexpand-printer-bindings*
          (list* '(*print-gensym* . nil)
                 ;;'(*Print-Circle* . t)
               swank::*macroexpand-printer-bindings* ) ))
    (swank:swank-macroexpand-all form) ))


#+sbcl
(progn
  (sb-walker:define-walker-template SB-C::%FUNCALL (nil sb-walker::repeat (eval)))
  (sb-walker:define-walker-template SB-SYS:%PRIMITIVE (nil eval sb-walker::repeat (eval)))
  (sb-walker:define-walker-template SB-C::GLOBAL-FUNCTION (nil quote))
  (sb-walker:define-walker-template SB-C::%WITHIN-CLEANUP
      (nil eval eval sb-walker::repeat (eval)))
  (sb-walker:define-walker-template SB-C::%ESCAPE-FUN (nil quote))
  (sb-walker:define-walker-template SB-C::%CLEANUP-FUN (nil quote))
  (sb-walker:define-walker-template SB-C::%%ALLOCATE-CLOSURES (nil sb-walker::repeat (quote))))


;;; *EOF*


