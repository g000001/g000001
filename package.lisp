(DEFPACKAGE :G000001
  (:USE :CL :SHIBUYA.LISP)
  (:IMPORT-FROM :CL-USER 
                :QUIT)
  (:IMPORT-FROM :ASDF 
                :OOS :LOAD-OP)
  (:IMPORT-FROM :ASDF-INSTALL
                :INSTALL)
  (:IMPORT-FROM :ALEXANDRIA
                :CURRY))

(IN-PACKAGE :G000001)

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