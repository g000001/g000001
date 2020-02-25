;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.arc-ref
  (:use)
  (:export))


(defpackage :g000001.arc-ref.internal
  (:use :g000001.arc-ref :arc :named-readtables
        :co))

