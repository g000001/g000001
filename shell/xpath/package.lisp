;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.xpath
  (:use)
  (:nicknames :g1.xpath)
  (:export :doxpath :w/empty-ns :html->stp))


(defpackage :g000001.xpath.internal
  (:use :g000001.xpath :arc :named-readtables))


;;; *EOF*
