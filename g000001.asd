(asdf:defsystem :g000001
  :name "g000001"
  :description "g000001"
  :version "5"
  :serial t
  :components ((:file "package")
               (:file "package.g000001")
               (:file "function.g000001")
               (:file "g000001")
               (:file "lispm"))
  :depends-on (:root
               :named-readtables
               :tao-compat
               :swank
               :series
               :series-ext
               :kmrcl
               :fare-utils
               :alexandria
               :shibuya.lisp
               ;:cl-twitter
               :xyzzy-compat
               :zl-compat
;               :executor
;               :sclf
               ))