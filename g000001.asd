(asdf:DEFSYSTEM :G000001
  :NAME "g000001"
  :DESCRIPTION "g000001"
  :VERSION "3"
  :COMPONENTS ((:FILE "package")
               (:FILE "g000001" :DEPENDS-ON ("package")))
  :DEPENDS-ON (:swank
               :SERIES
               :SERIES-EXT
               :KMRCL
               :FARE-UTILS
               :ALEXANDRIA
               :SHIBUYA.LISP
               :CL-TWITTER
               :XYZZY-COMPAT
               :ZL-COMPAT
               :EXECUTOR
               :SCLF
               ))