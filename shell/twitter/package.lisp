;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(eval-when (:compile-toplevel :load-toplevel :execute)
  (setq *readtable* (copy-readtable nil)))


(defpackage :g000001.twitter
  (:use)
  (:export))


(defpackage :g000001.twitter.internal
  (:use g000001.twitter arc named-readtables st-json srfi-19)
  (:shadowing-import-from bcl fstring)
  (:shadowing-import-from lambda.output output ostring))


;;; *EOF*
