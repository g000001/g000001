;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.techp
  (:use)
  (:export))


(defpackage :g000001.techp.internal
  (:use :g000001.techp :arc :named-readtables))

