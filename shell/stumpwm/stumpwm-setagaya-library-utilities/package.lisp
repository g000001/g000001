;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :stumpwm-setagaya-library-utilities
  (:use)
  (:export :reservation-status-uri
           :rental-status-uri
           :reservation-status
           :reservation-status-string
           :watch-reservation-status
           :checked-out-books))

(defpackage :stumpwm-setagaya-library-utilities-internal
  (:use :stumpwm-setagaya-library-utilities :cl :fiveam))

