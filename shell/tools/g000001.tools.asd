;;;; g000001.tools.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.tools
  :serial t
  :depends-on (;; :fiveam
               ;; :named-readtables
               :cl-ppcre
               :quicklisp
               #-(:or :scl :cmu :clisp :lispworks :abcl :allegro) :tinaa.patch
               :qpj3
               ;; #-(:or :cmu :allegro :lispworks :ccl) :cl-api.patch
               #+:sbcl :disasm1
               #-:scl :quicksearch
               )
  :components ((:file "package")
               #|(:file "readtable")|#
               (:file "g000001.tools")
               #|(:file "test")|#
               ))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.tools))))
  (load-system :g000001.tools)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.tools.internal :g000001.tools))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
