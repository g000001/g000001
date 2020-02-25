;;;; climacs-g000001.asd

(asdf:defsystem #:climacs-g000001
  :serial t
  :depends-on (:climacs
               :drakma
               :kmrcl
               :mcclim-uim
               :mcclim-freetype
               :cl-ppcre
               :url-rewrite)
  :components ((:file "package")
               (:file "hw")
               (:file "climacs-g000001" :depends-on ("hw"))
               (:file "prev-and-next")
               ))

