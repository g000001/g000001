;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :g000001.utils.tao-manual
  (:use)
  (:export))


(defpackage :g000001.utils.tao-manual.internal
  (:use :rnrs
        ;; :shibuya.lisp
        ;:series
        ;; :f-underscore
        ;:series-ext
        :named-readtables
        ;:root.package.g000001
        ;:root.function.g000001
        :srfi-1
        :srfi-2
        :srfi-9
        :srfi-13
        :srfi-14
        :srfi-23
        :srfi-89
        :srfi-42
        :srfi-115
        :fmt
        :snow-match
        )
  (:import-from :cl :in-package :***)
  (:shadowing-import-from :srfi-13
                          :list->string
                          :string-copy
                          :string-ref
                          :string-append
                          :string-length
                          :string?
                          :string->list
                          :string
                          :make-string
                          :STRING-FILL!
                          :STRING-SET!)
  (:shadowing-import-from :srfi-46
                          :define-syntax
                          :syntax-rules
                          :let-syntax 
                          :letrec-syntax))

