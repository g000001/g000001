;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :g000001.comic-natalie-utils
  (:use)
  (:export :check-comics))

(defpackage :g000001.comic-natalie-utils.internal
  (:use :g000001.comic-natalie-utils :arc :named-readtables :fiveam
        :cool)
  (:shadowing-import-from :arc :is))

