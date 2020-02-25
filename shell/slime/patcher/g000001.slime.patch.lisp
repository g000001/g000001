;;;; g000001.slime.patch.lisp

(cl:in-package :g000001.slime.patch.internal)


(defvar *slime-patches* (make-hash-table))


(defmacro defun-patch (name (&rest args) &body body)
  (let ((orig (gensym "ORIG-FCTN-")))
    `(let ((,orig ',(intern (format nil "~A.ORIGINAL" name)
                            (symbol-package name) )))
       (cond ((fboundp ,orig)
              (warn "Already patched.") )
             (T (setf (symbol-function ,orig)
                      (symbol-function ',name) )
                (defun ,name (,@args) ,@body) )))))


(defmacro revert-patch (name)
  (let ((orig (gensym "ORIG-FCTN-")))
    `(let ((,orig ',(intern (format nil "~A.ORIGINAL" name)
                            (symbol-package name) )))
       (setf (symbol-function ',name)
             (symbol-function ,orig) )
       (fmakunbound ,orig)
       ',name)))





