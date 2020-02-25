;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :g000001.utils.booklog
  (:use)
  (:export :booklog-search))
;; (delete-package :g000001.utils.booklog.internal)
(defpackage :g000001.utils.booklog.internal
  (:use :g000001.utils.booklog :rnrs-compat :named-readtables :fiveam
        :srfi-1
        :srfi-2
        :srfi-9
        :srfi-13
        :srfi-14
        :srfi-23
        :srfi-89
        :srfi-42
        ;; :srfi-46
        :srfi-115)
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
  #|(:shadowing-import-from :srfi-46
                          :define-syntax
                          :syntax-rules
                          :let-syntax
                          :letrec-syntax)|#
  ;; (:shadowing-import-from :srfi-115 :any)
  (:shadowing-import-from :srfi-1 :assoc :member)
  (:import-from :cl :***))

