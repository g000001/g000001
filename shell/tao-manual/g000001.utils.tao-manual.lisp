;;;; g000001.utils.tao-manual.lisp

(cl:in-package :g000001.utils.tao-manual.internal)
(in-readtable :rnrs)

#|(def-suite g000001.utils.tao-manual)|#

#|(in-suite g000001.utils.tao-manual)|#

;;; "g000001.utils.tao-manual" goes here. Hacks and glory await!


(cl:defmacro ^x (cl:&body body)
  `(lambda (x) . ,body))


(cl:declaim (cl:ftype (cl:function (cl:string) 
                                   (cl:values cl:string cl:&optional))
                      escape-file-name))


(define (manual.index) 
  (call-with-input-file "/l/elis-utf8/manual/manual.index"
                        (^x (read x)
                            (read x))))


(define (make-entry elt refs)
  (match-let* (((name man-no type (start . end))
                elt)
               (man (vector-ref refs (+ -1 (cl:parse-integer man-no)))))
    (g1:with-> (out (fmt #f
                         "/tmp/taoman/"
                         (escape-file-name name)
                         ".html"))
      (yaclml:with-yaclml-stream out
        (<:html
            (<:body
                (<:h3 (match type
                        ("f" (<:format "Function"))
                        (:_ "?")))
              (<:pre 
                  (fmt out (pick-entry man start end) ))))))))


(define (escape-file-name name)
  (define (esc name x y)
    (ppcre:regex-replace-all x name y))
  (let* ((name (esc name #\/ "_slash_"))
         (name (esc name #\* "_star_"))
         (name (esc name #\/ "_backslash_"))
         (name (esc name #\: "_colon_"))
         (name (esc name #\; "_semicolon_")))
    name))


(define (make-man-name no)
  (fmt #f 
       "/l/elis/manual/" 
       "tao"
       (pad-char #\0 (pad/left 2 no))
       ".ref"))


(define (read-man file)
  (cl:with-open-file (in file
                         :element-type '(cl:unsigned-byte 8))
    (let ((buf (cl:make-array (cl:file-length in)
                              :element-type '(cl:unsigned-byte 8))))
      (cl:read-sequence buf in)
      buf)))


(define (pick-entry buf start end)
  (define (chomp s)
    (regexp-replace-all #\Return s ""))
  (chomp (babel:octets-to-string (cl:subseq buf start end)
                                 :encoding :eucjp)))


(cl:defvar *tao-mans*
  (let* ((files 31) 
         (refs (make-vector files)))
    (do-ec (:- i 0 files)
      (vector-set! refs i
                   (read-man (make-man-name (+ 1 i)))))
    refs))


(define (make-tao-manual-index)
  (cl:ensure-directories-exist "/tmp/taoman/")
  (g1:with-> (out "/tmp/taoman/tao-index.html") 
    (yaclml:with-yaclml-stream out
      (<:html
          (<:head)
          (<:body
              (<:h1 "Tao index")
            (<:ol
                (do-ec (:- ent (manual.index))
                  (match-let (((name . ignore)
                               ent))
                    ignore
                    (let ((file (fmt #f
                                     (escape-file-name name)
                                     ".html")))
                      (<:li
                        (<:a :href file (fmt out name))))))))))))


(define (make-tao-manual)
  (display "start:")
  (time:print-current-time)
  (do-ec (:- ent (index i) (manual.index))
    (begin
      (fmt #t i #'nl)
      (make-entry ent *tao-mans*)))
  (time:print-current-time)
  (display "...done"))


#|(begin
  (make-tao-manual-index)
  (make-tao-manual))|#

