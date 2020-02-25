;;;; g000001.xpath.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.xpath.internal)


(in-readtable :arc)


(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (cl:defmethod arc:ref ((seq stp:element) index)
    (stp:attribute-value seq (cl:string-downcase index))))


(mac w/empty-ns ((stp) . body)
  `(xpath:with-namespaces (("" (stp:namespace-uri 
                                (stp:document-element ,stp))))
     ,@body))


(mac doxpath ((node stp xpath) cl:&body body)
  (w/uniq (/stp)
    `(let ,/stp ,stp
       (w/empty-ns (,/stp)
         (each ,node (xpath:all-nodes (xpath:evaluate ,xpath ,/stp))
           ,@body)))))


(def html->stp (string)
  (chtml:parse string (stp:make-builder)))


;;; *EOF*


