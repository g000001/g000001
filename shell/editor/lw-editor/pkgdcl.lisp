;;; -*- mode :Lisp -*-

(cl:in-package "CL-USER")


(eval-when (:compile-toplevel :load-toplevel :execute)
  (or (find-package 'puri) (ql:quickload :puri))
  (or (find-package :xpath) (ql:quickload :closure-foo))
  (or (find-package :g000001.ja) (ql:quickload :g000001.ja))
  (or (find-package :g000001.html) (ql:quickload :g000001.html)))


(defpackage bcl-editor
  (:nicknames bed)
  (:use bcl editor)
  (:shadowing-import-from editor
   . #.(let ((homepkg (find-package :editor))
             (syms '()))
         (do-symbols (s :editor)
           (multiple-value-bind (sym stat)
                                (find-symbol (string s) :editor)
             (case stat
               (:internal
                (when (eq homepkg (symbol-package s))
                  (push s syms)))
               (:external))))
         syms)))


;;; *EOF*
