(asdf:DEFSYSTEM :G000001
  :NAME "g000001"
  :DESCRIPTION "g000001"
  :VERSION "2"
  :COMPONENTS ((:FILE "package")
               (:FILE "g000001" :DEPENDS-ON ("package")))
  :DEPENDS-ON (:SERIES
               :kmrcl
               :fare-utils
               :ALEXANDRIA
               :SHIBUYA.LISP
               :CL-TWITTER
               :xyzzy-compat
               :zl-compat
               :executor))