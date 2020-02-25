(in-package :g1.scm)
(in-readtable :g1.scm)


(define* (tw-statuses tw (rev #'cl:identity))
  (_rev (cdr (assoc :statuses tw))))


(define* (twq (q "Common Lisp") (:lang lang "ja") (:rev rev #'cl:identity))
  (do-ec (:- tw (tw-statuses 
                 (g1.arc::twclient :get "search/tweets"
                                   :? `(("q" . ,q) ("lang" . ,lang)))
                 rev))
    (cond ((regexp-match `(seq (* nonl) (w/nocase ,q) (* nonl))
                         (cdr (assoc :text tw)))
           (g1.arc::print-tweet tw)))))



(define (ie-bin url . opts)
  (apply #'drakma:http-request
         url
         :force-binary #t
         :user-agent
         "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET4.0C; .NET4.0E; .NET CLR 2.0.50727)"
         opts))


(define* (?::wget uri (:outfile outfile #f))
  (let* ((file/uri (ppcre:regex-replace ".*/(.*)\\?.*$" uri "\\1"))
         (outfile (or outfile file/uri "/tmp/foo.foo")))
    (fmt #t uri " ==> " outfile #'nl)
    #|(call-with-output-file
    outfile
    (lambda (out)
    (cl:with-open-stream (str (ie-bin uri :want-stream #t))
    (do ((s (cl:read-byte str #f -1) (cl:read-byte str #f -1))
    (cnt 0 (+ 1 cnt)))
    ((= -1 s) (fmt #t "end" cnt "." #'nl))
    (cl:write-byte s out)
    (cond ((and (zero? (remainder cnt 1024)) (not (zero? cnt)))
    (fmt #t ".")
    (cond ((zero? (remainder cnt (* 50 1024)))
    (fmt #t cnt #'nl))))))))
    :if-exists :supersede
    :element-type 'cl:unsigned-byte)|#
    (cl:handler-case 
        (cl:with-open-file (out outfile
                                :if-exists :supersede
                                :element-type 'cl:unsigned-byte
                                :direction :output)
          (cl:with-open-stream (str (ie-bin uri :want-stream #t))
            (do ((s (cl:read-byte str #f -1) (cl:read-byte str #f -1))
                 (cnt 0 (+ 1 cnt)))
                ((= -1 s)
                 (fmt #t "end" cnt "." #'nl)
                 (cl:probe-file outfile))
              (cl:write-byte s out)
              (cond ((and (zero? (remainder cnt 1024)) (not (zero? cnt)))
                     (fmt #t ".")
                     (cond ((zero? (remainder cnt (* 50 1024)))
                            (fmt #t cnt #'nl))))))))
      (usocket:timeout-error (c) 
        c
        (fmt cl:*error-output* 
             #'fl
             ;; "(" c ")"
             ";;; <<< timeout!! >>>" #'nl
             ";;; " uri #'nl))
      (#+sbcl sb-int:simple-stream-error
        #+lispworks conditions:file-stream-error
        (c)
        c
        (fmt cl:*error-output* 
             ;; "(" c ")"
             #'fl
             ";;; <<< reseted by host!! >>> "
             ";;; " uri #'nl)))))


(define (qload item)
  (let ((cl:*package* (cl:find-package :cl-user))
        (cl:*readtable* (cl:copy-readtable #f)))
    (ql:quickload item)))


(define (|remove-""| list)
  (filter (^x (not (string= "" x))) list))


(define (my-blog-md-filter string)
  (ppcre:regex-replace-all "(?s:(\\|[^\\n]*\\|\\n)+)"
                           string
    (lambda (match . rest)
      rest
      (ppcre:regex-replace-all          ;for yaclml indent...
       "(?s:\\s*\\>)"
       (yaclml:with-yaclml-output-to-string 
         (<:table
             (cl:dolist (tr (|remove-""| (ppcre:split "\\n" match)))
               (<:tr 
                   (cl:dolist (td (|remove-""| (ppcre:split "\\|" tr)))
                     (<:td (<:format td)))))))
       ">"))
    :simple-calls #t))


#|(define (g1::md source . args)
  (let ((source (my-blog-md-filter source)))
    (apply #'markdown:markdown source args)))|#


#|(define (swank::markdown-file infile outfile)
  (g1:with-> (out outfile)
    (g1::md (kl:read-file-to-string infile)
            :stream out)))|#



(define (?::twll url)
  (g1.arc::*tw (string-append/shared "#lisplib365 でライブラリ紹介 / "
                                     (?::tu url))
               #f))


(define (?::twllr url)
  (g1.arc::*tw (string-append/shared "#lisplib365 でライブラリ紹介 / "
                                     (?::tu url))
               #f)
  (write (?::red url)))


#|(define (scan-node-set node-set)
  (series:scan-fn 'series:series 
                  (lambda () (xpath:make-node-set-iterator node-set))
                  #'xpath:node-set-iterator-next
                  #'xpath:node-set-iterator-end-p))|#


(series:defuns scan-node-set (node-set)
  (series:scan-fn #t
                  (lambda () (xpath:make-node-set-iterator node-set))
                  #'xpath:node-set-iterator-next
                  #'xpath:node-set-iterator-end-p))


;;; *EOF*

