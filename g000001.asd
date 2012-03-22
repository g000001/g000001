(asdf:defsystem :g000001
  :name "g000001"
  :description "g000001"
  :version "5"
  :serial t
  :components ((:file "package")
               (:file "readtable")
               (:file "package.g000001")
               (:file "function.g000001")
               (:file "g000001")
               (:file "lispm")
               #-lispworks (:file "ja")
               (:file "tools")
               (:file "pprint")
               )
  :depends-on (:root
               :named-readtables
               :yaclml
               :cl-html-parse
               :tao-compat
               :swank
               :series
               :series-ext
               :kmrcl
               :fare-utils
               :alexandria
               :shibuya.lisp
               :cl-who
               ;:cl-twitter
               :xyzzy-compat
               :zl-compat
               :snow-match
               #-ecl :srfi-13
;               :executor
;               :sclf
               ))
