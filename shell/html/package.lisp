;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.html
  (:use)
  (:export
   :get-title
   :with-output-to-browser))


(defpackage :g000001.html.internal
  (:use :g000001.html :tao :named-readtables
        :series))

