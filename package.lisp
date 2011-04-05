(DEFPACKAGE :G000001
  (:USE :CL
        :SHIBUYA.LISP
        :SERIES
        :F-UNDERSCORE
        :series-ext
        )
  #-ALLEGRO (:IMPORT-FROM :CL-USER
                          :QUIT)
  #-asdf2 (:IMPORT-FROM :ASDF
                        :OOS :LOAD-OP)
  #+sbcl (:import-from :sb-ext
                       :without-package-locks)
  #-asdf2 (:IMPORT-FROM :ASDF-INSTALL
                        :INSTALL)
  (:IMPORT-FROM :ALEXANDRIA
                :CURRY)
  (:import-from :sclf
                :be)
  (:export :with->
           :with-<
           :with->>))

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