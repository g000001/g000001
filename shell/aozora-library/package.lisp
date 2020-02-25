;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.utils.aozora-library
  (:use)
  (:export))


(defpackage :g000001.utils.aozora-library.internal
  (:use :g000001.utils.aozora-library :arc :cool
        :named-readtables))

