;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :g000001.npr-utils
  (:use)
  (:export :npr-media-url
           :npr-media-download-url))

(defpackage :g000001.npr-utils.internal
  (:use :g000001.npr-utils :arc :named-readtables))

