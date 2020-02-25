;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :g000001.slime.patch
  (:use)
  (:export :defun-patch
           :revert-patch))

(defpackage :g000001.slime.patch.internal
  (:use :g000001.slime.patch :cl :fiveam))

