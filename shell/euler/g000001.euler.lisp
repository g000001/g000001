;;;; g000001.euler.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.euler.internal)
(in-readtable :arc)


(def int->list (num)
  (map #'cl:digit-char-p 
       (coerce (cl:write-to-string num) 'cl:list)))


(def list->int (numl)
  (let fig -1
    (reduce (fn (res x)
              (++ fig)
              (+ res (* x (expt 10 fig))))
            (cons 0 (rev numl)))))


(def fig (n)
  (len:cl:format nil "~D" n))





;;; "g000001.euler" goes here. Hacks and glory await!


;;; *EOF*
