;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.unicode
  (:use)
  (:export))


(defpackage :g000001.unicode.internal
  (:use :g000001.unicode :arc :named-readtables))

