;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.twitter
  (:use)
  (:export))


#-(:or :lispworks8)
(defpackage :g000001.twitter.internal
  (:use :g000001.twitter :arc :named-readtables)
  (:shadowing-import-from :lambda.output :output :ostring))

;#+(:or :lispworks7)
#|(defpackage :g000001.twitter.internal
  (:use :g000001.twitter :cl)
  (:shadowing-import-from :lambda.output :output :ostring))|#

