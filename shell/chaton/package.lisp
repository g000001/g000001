;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.chaton
  (:use)
  (:export))


(defpackage :g000001.chaton.internal
  (:use :g000001.chaton :arc :named-readtables))

