;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.euler
  (:use)
  (:export))


(defpackage :g000001.euler.internal
  (:use :g000001.euler :arc :named-readtables))

