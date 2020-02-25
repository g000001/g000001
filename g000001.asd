(asdf:defsystem :g000001
  :name "g000001"
  :description "g000001"
  :version "8"
  :serial t
  :components ((:file "shell/package")
               #||
               (:file "readtable")
               (:file "decl-utils")
               (:file "decls")
               (:file "package.g000001")
               (:file "function.g000001")
               (:file "g000001")
               (:file "lispm")
               (:file "tools.tao")
               (:file "tools.cl")
               ;; (:file "pprint")
               (:file "tools.arc")
               (:file "twitter.arc")
               (:file "tools.scm")
               ||#
               )
  :depends-on
  ()
  #|(:root
   :star
   :g000001.xpath
   ;; :cl-chatwork
   :g000001.tools
   :fmt
   :reader.r6rs
   :cl-unicode
   :root.package.it
   :root.package.scheme-keyword
   :SRFI-87
   :SRFI-19
   :SRFI-46
   :cl-json
   :lambda.time
   :named-readtables
   :yaclml
   :cl-html-parse
   :tao-compat
   :gauche-compat
   :babel
   :swank
   :series
   :xpath
   :cxml-stp
   :series-ext
   :kmrcl
   :macroexpand-dammit
   :fare-utils
   :alexandria
   :shibuya.lisp
   :cl-who
   :drakma
   :closure-html
               ;:cl-twitter
   :xyzzy-compat
   :zl-compat
   :snow-match
   :arc-compat
   :gauche-compat.text.tr
   #-ecl :srfi-13
   :srfi-48
   :srfi-26
;               :executor
;               :sclf
   :colorize
   :cl-twitter
   :objectlisp
   :cl-delicious
   #-(:or lispworks ccl) :cool
   :g000001.npr-utils
   #-(:or lispworks ccl) :g000001.comic-natalie-utils
   :g000001.utils.booklog
   :g000001.html
   :g000001.twitter
   ;; :cl-markdown
   :toot
   )|#)
