;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.tools
  (:nicknames :?)
  (:use)
  (:import-from :cl :apropos :apropos-list :describe :inspect :dribble)
  (:import-from :ppcre :regex-apropos)
  (:import-from :ql-dist :system-apropos)
  (:import-from :asdf :load-system :test-system :initialize-source-registry)
  #-:scl (:import-from :quicksearch :?)
  #-(:or :scl :allegro :abcl :cmu :clisp :lispworks) (:import-from :tinaa :document-system)
  (:import-from :qpj3 :make-project)
  ;; #-(:or :clisp :allegro :cmu :lispworks :ccl) (:import-from :cl-api :api-gen)
  #+:sbcl (:import-from :disasm1 :disasm)
  ;;
  (:export :?)
  #+sbcl (:export :disasm)
  (:export :apropos :describe :inspect :dribble :apropos-list)
  (:export :regex-apropos)
  (:export :system-apropos)
  (:export :load-system :test-system :initialize-source-registry)
  (:export :tw :fav :tu :twll :twllr :red :showtl :mentions)
  (:export :qload :d)
  #-(:or :cmu :lispworks :abcl) (:export :document-system)
  (:export :make-project)
  ;; #-(:or :cmu :lispworks :allegro) (:export :api-gen)
  (:export :current-clock-face-char
           :current-clock-face-string
           :twe)
  (:export :notify-send
           :beep
           :inst=
           :cloogle
           :delete-package*
           :kd :deftool :tool-search :print-yaml
           :wget)
  (:export #:deftool
           #:tool-search))


(defpackage :g000001.tools.internal
  (:use :g000001.tools :cl :named-readtables :fiveam)
  )

