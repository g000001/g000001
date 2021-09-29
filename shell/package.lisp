(in-package cl-user)

#|||
           Put             Provide 
           IN              IN-package 
           Seven           Shadow 
           EXtremely       EXport 
           Random          Require 
           USEr            USE-package 
           Interface       Import 
           COmmands        COntents of package/module
|||#

(eval-when (:compile-toplevel :load-toplevel :execute)
  (let ((pkg "https://github.com/g000001/shell/package"))
    ;; Put
    (provide "https://github.com/g000001/shell/package")
    (when (find-package pkg)
      (delete-package pkg))
    ;; In
    (setq *package*
          (make-package pkg
                        :nicknames '(#:shell.pkg)
                        :use '(#:cl)))))
(progn
  ;; Seven
  (shadow '())
  ;; Extremely
  (export '(*package-path*
            pkg-bind
            use-package-soft
            show-packages))
  ;; Random
  '(require)
  ;; User
  (use-package "CL")
  ;; Interface
  (import '())
  ;; Commands
  )

;;; --------------------------------------------------------------------------
;;; use-package-soft
;;; --------------------------------------------------------------------------
(defun use-package-soft (package-to-use
                         &optional (package #+sbcl (sb-int:sane-package)
                                            #-sbcl *package*))
  (let ((not-imported () ))
    (do-external-symbols (s package-to-use)
      (if (find-symbol (string s))
          (push s not-imported)
          (import s package)))
    not-imported))


;;; ---------------------------------------------------------------------------
;;; package path
;;; ---------------------------------------------------------------------------
(defvar *PACKAGE-PATH* '() )

(defun auto-import (name)
  (let (ans)
    (dolist (pkg (reverse *package-path*))
      (when (and (find-package pkg)
                 (find-symbol (string name) pkg))
        (let ((sym (intern (string name) pkg)))
          (shadowing-import sym)
          (push pkg ans))))
    ans))


;;; -------------------------------------------------------------------------
;;; pkg-bind
;;; -------------------------------------------------------------------------
(defclass intern-form ()
  ((name :initarg :name)
   (package :initarg :package)))


(defmethod print-object ((obj intern-form) stream)
  (format stream
          "#.(CL:INTERN ~S ~S)"
          (slot-value obj 'name)
          (slot-value obj 'package)))

;(make-instance 'intern-form :name "FOO" :package "CL")
;=> #.(CL:INTERN "FOO" "CL")

(defun up-symbol (elt pkg)
  (typecase elt
    (symbol
       (let ((name (string elt)))
         (make-instance 'intern-form
                  :name name
               :package (package-name
                         (let ((elt-pkg (symbol-package elt)))
                           (cond ((eq elt-pkg (find-package pkg))
                                  ;; current (pkg-bind :foo foo::x) => (progn foo::x)
                                  pkg)
                                 ;;
                                 ((and (eq elt-pkg (find-package *package*))
                                       (find-symbol (string elt) pkg))
                                  ;; current (pkg-bind :foo x) => (progn foo::x) or (progn current::x)
                                  pkg)
                                 ;; current (pkg-bind :foo bar::x) => (progn bar::x)
                                 ('T elt-pkg)))))))
    ;;
    (otherwise elt)))

(defun symbol-to-intern-form (tree pkg)
  (cond ((null tree)
         tree)
        ;;
        ((atom (car tree))
         (let ((elt (car tree)))
           (cons (if (eq 'pkg-bind elt)
                     'pkg-bind
                     (up-symbol elt pkg))
                 (symbol-to-intern-form (cdr tree) pkg))))
        ;;
        ('T (cons (symbol-to-intern-form (car tree) pkg)
                  (symbol-to-intern-form (cdr tree) pkg)))))

(defmacro pkg-bind (pkg &body body)
  `(progn
     ,@(read-from-string
        (write-to-string
         (symbol-to-intern-form body (package-name pkg))))))


(defun package-exports (pkg)
  (setq pkg (find-package pkg))
  (let ((ans '() ))
    (do-external-symbols (s pkg ans)
      (push s ans))))


;;; eof
