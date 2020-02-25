;;;; package.lisp -*- Mode: Lisp;-*- 

(cl:in-package :cl-user)


(defpackage :g000001.ja
  (:use)
  (:export
   :decode-jp
   :strans
   :japanese-hankaku-string
   :nkf
   :encode-tenji
   :decode-tenji
   ;; 
   :string-katakana
   :string-hiragana
   :string-maru-katakana
   :dedakutenize
   :deyouonize
   :senzen
   :knum
   ))


(defpackage :g000001.ja.internal
  (:use :g000001.ja :cl :named-readtables))


(defpackage :g000001.ja.internal.arc
  (:use :g000001.ja :arc :named-readtables))

