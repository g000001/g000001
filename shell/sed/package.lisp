;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :g000001.sed
  (:use)
  (:export))

(defpackage :g000001.sed.internal
  (:use :g000001.sed :cl :named-readtables :fiveam))

