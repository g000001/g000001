;;;; readtable.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.arc-ref.internal)
(in-readtable :common-lisp)


(defreadtable :g000001.arc-ref
  (:merge :standard)
  (:macro-char char fctn opt...)
  (:syntax-from readtable to-char from-char)
  (:case :upcase))


;;; *EOF*
