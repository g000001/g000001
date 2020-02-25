(in-package :cl-user)

(defpackage "https://github.com/g000001/g000001"
  (:use :cl)
  (:nicknames #:g1))

#||
(defpackage :root.package.g000001
  (:use :cl)
  (:export :*package-path*
           :pkg-bind
           :use-package-soft
           :show-packages))


(defpackage :root.function.g000001
  (:use :cl #+sbcl :sb-ext))


(defpackage :root.user.g000001
  (:use :cl
        ;; :shibuya.lisp
        :series
        ;; :f-underscore
        :series-ext
        :named-readtables
        :root.package.g000001
        :root.function.g000001
        :snow-match
        )
  (:nicknames :g1 :g000001 :g1.cl)
  #-allegro (:import-from :cl-user
                          :quit )
  #-asdf2 (:import-from :asdf
                        :oos :load-op)
  #-asdf2 (:import-from :asdf-install
                        :install )
  #|(:import-from :alexandria
                :curry )|#
  #|(:import-from :sclf
  :be )|#
  #|(:shadowing-import-from :cl
                          . #.(cl:let ((tao-symbols '() )
                                       (cl-symbols '() ) )
                                (cl:do-external-symbols (s :cl)
                                  (unless (member s '(cl:loop))
                                    (cl:push s cl-symbols)) )
                                (cl:do-external-symbols (s :tao)
                                  (cl:push s tao-symbols) )
                                (cl:set-difference cl-symbols tao-symbols) ))|#
  (:export :with->
           :with-<
           :with->>
           :pkg-bind
           :with-output-to-browser
           :with-html-output-to-browser
           :beep
           :delete-package*
           ;; 
           :tw
           :ttw
           :tu
           :fav
           :favl
           :twcl
           :mentions
           :repcar
           :lisper-blog
           :get-title
           :dn
           :notify-send
           :find-unbalanced-parentheses
           :decode-jp
           )
  (:shadow :fmakunbound))


(defpackage :root.user.g000001.tao
  (:use :tao
        :g1
        ;; :shibuya.lisp
        :series
        ;; :f-underscore
        :series-ext
        :named-readtables
        :root.package.g000001
        :root.function.g000001
        :snow-match
        )
  ;; types
  (:shadowing-import-from
   :cl :nil
   :synonym-stream :control-error :concatenated-stream :double-float
   :floating-point-inexact :real :file-stream :undefined-function
   :standard-method :unbound-variable :reader-error :float :simple-base-string
   :integer :standard-object :simple-warning :stream :error :standard-class
   :simple-type-error :class :base-string :null :parse-error :stream-error
   :readtable :condition :simple-error :built-in-class :vector :t :restart
   :serious-condition :character :ratio :package :simple-string :complex
   :storage-condition :method :string :simple-vector :broadcast-stream
   :arithmetic-error :structure-class :cons :rational :simple-condition
   :standard-generic-function :division-by-zero :string-stream
   :floating-point-underflow :unbound-slot :end-of-file :fixnum :structure-object
   :list :echo-stream :style-warning :warning :simple-bit-vector :program-error
   :number :simple-array :two-way-stream :function :type-error :package-error
   :print-not-readable :logical-pathname :pathname :symbol :file-error
   :single-float :sequence :array :bignum :floating-point-invalid-operation
   :method-combination :hash-table :floating-point-overflow :cell-error
   :generic-function :bit-vector :random-state)
  (:nicknames :g1.tao)
  #-allegro (:import-from :cl-user
                          :quit )
  #-asdf2 (:import-from :asdf
                        :oos :load-op)
  #-asdf2 (:import-from :asdf-install
                        :install )
  #|(:import-from :alexandria
                :curry )|#
  #|(:import-from :sclf
  :be )|#
  #|(:shadowing-import-from :cl
                          . #.(cl:let ((tao-symbols '() )
                                       (cl-symbols '() ) )
                                (cl:do-external-symbols (s :cl)
                                  (unless (member s '(cl:loop))
                                    (cl:push s cl-symbols)) )
                                (cl:do-external-symbols (s :tao)
                                  (cl:push s tao-symbols) )
                                (cl:set-difference cl-symbols tao-symbols) ))|#
  )


(defpackage :root.user.g000001.arc
  (:use :arc
        ;; :shibuya.lisp
        ;:series
        ;; :f-underscore
        ;:series-ext
        :named-readtables
        ;:root.package.g000001
        ;:root.function.g000001
        ;:snow-match
        :g1
        #-(:or :lispworks :ccl) :co
        #-(:or :lispworks :ccl) :obj
        :lambda.output
        )
  (:intern :tw :showtl :showl :red)
  (:import-from :cl :in-package )
  (:import-from :g1 :lisper-blog :repcar :get-title)
  (:import-from :arc :_)
  (:shadowing-import-from :arc :plural)
  (:shadowing-import-from :lambda.output :output)
  (:nicknames :g1.arc :g000001.arc))


(defpackage :root.user.g000001.scheme
  (:use :rnrs
        :gauche-keyword
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
        :srfi-26
        :srfi-89
        :srfi-42
        :srfi-115
        :srfi-19
        :fmt
        :snow-match
        )
  (:import-from :cl :in-package :***)
  (:import-from :g1.arc :tw :ttw :showtl :showl :mentions :tu)
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
                          :letrec-syntax)
  #|(:shadowing-import-from :srfi-115
                          :any)|#
  (:shadowing-import-from :g1.arc :red)
  ;; (:shadowing-import-from :fmt :fmt :nl)
  (:shadowing-import-from :srfi-1 :assoc :member)
  (:shadowing-import-from :gauche-keyword :_)
  (:nicknames :g1.scm))


(in-package :g1)

#||
#-SCL
 (PROGN
  ;; ASDFのOOSをcl-userへインポート
  (SHADOWING-IMPORT '(ASDF:OOS ASDF:LOAD-OP))
  (SHADOWING-IMPORT '(ASDF-INSTALL:INSTALL) :CL-USER)

  (SHADOW 'WGET)
  (SHADOW '!)
  (USE-PACKAGE :SHIBUYA.LISP)

  (SHADOWING-IMPORT '(ALEXANDRIA:CURRY) :CL-USER)
  )
||#
||#
