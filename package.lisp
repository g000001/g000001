(in-package :cl-user)

(defpackage :root.package.g000001
  (:use :cl)
  (:export :*package-path*
           :pkg-bind
           :use-package-soft
           :show-packages))

(defpackage :root.function.g000001
  (:use :cl #+sbcl :sb-ext))

(defpackage :root.user.g000001
  (:use :tao
        ;; :shibuya.lisp
        :series
        ;; :f-underscore
        :series-ext
        :named-readtables
        :root.package.g000001
        :root.function.g000001
        )
  (:nicknames :g1 :g000001)
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
  (:shadowing-import-from :cl
                          . #.(cl:let ((tao-symbols '() )
                                       (cl-symbols '() ) )
                                (cl:do-external-symbols (s :cl)
                                  (unless (member s '(cl:loop))
                                    (cl:push s cl-symbols)) )
                                (cl:do-external-symbols (s :tao)
                                  (cl:push s tao-symbols) )
                                (cl:set-difference cl-symbols tao-symbols) ))
  (:export :with->
           :with-<
           :with->>
           :pkg-bind
           :with-output-to-browser
           :with-html-output-to-browser))

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
