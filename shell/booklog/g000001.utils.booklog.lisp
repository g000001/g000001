;;;; g000001.utils.booklog.lisp

(cl:in-package :g000001.utils.booklog.internal)
(in-readtable :rnrs)

(def-suite g000001.utils.booklog)

(in-suite g000001.utils.booklog)

;;; "g000001.utils.booklog" goes here. Hacks and glory await!


(cl:defparameter *booklog-base-url* "http://booklog.jp")

(define-syntax with-string-value 
  (syntax-rules ()
    ((_ ((var val) ***) body ***)
     (let ((var (cl:princ-to-string val)) ***)
          body ***))))


(define-syntax w/str 
  (syntax-rules ()
    ((_ (var ***) body ***)
     (with-string-value ((var var) ***)
       body ***))))


(define-syntax with-null-namespace
  (syntax-rules ()
    ((_ (var ***) body ***)
     (xpath:with-namespaces (("" (stp:namespace-uri (stp:document-element var))) ***)
       body ***))))


(define* (booklog-client (:page page 1)
                         (:service_id service_id 1)
                         (:keyword keyword ""))
  (with-string-value ((page page) 
                      (service_id service_id) 
                      (keyword keyword))
    (drakma:http-request "http://booklog.jp/search"
                         :parameters `(("page" . ,page)
                                       ("service_id" . ,service_id)
                                       ("keyword" . ,keyword)))))


#|(define (number-of-items stp)
  (xpath:with-namespaces (("" (stp:namespace-uri 
                               (stp:document-element stp))))
    (and-let* ((tag (xpath:first-node
                     (xpath:evaluate "//div[@class='pagerTxt']" stp)))
               (txt (xpath:string-value tag))
               (nums? (regexp-extract '(+ numeric) txt))
               (nums (not (null? nums?)))
               (n (string->number (car nums?))))
      (or n 0))))|#


(define (number-of-items stp)
  (xpath:with-namespaces (("" (stp:namespace-uri 
                               (stp:document-element stp))))
    (or (and-let* ((tag (xpath:first-node
                         (xpath:evaluate "//div[@class='pagerTxt']" stp)))
                   (nums (regexp-extract '(+ numeric) 
                                         (xpath:string-value tag)))
                   ( (not (null? nums)) )
                   ( (string->number (car nums)) ))
          0))))


(define (html->stp string)
  (chtml:parse string (stp:make-builder)))


(define (kindle? x)
  (and (pair? x)
       (= 2 (length x))
       (string-contains (list-ref x 1) "/B00")
       #t))


(define (trash? word item)
  (and (pair? item)
       (= 2 (length item))
       (not (string-contains (list-ref item 0) word))))


(define* (booklog-search k (brief? #f) (include-kindle? #f))
  (let ((limit (if brief? 1 5)))
    (let iter ((p 1)
               (ans '() ))
      (define page
        (let* ((html (booklog-client :keyword k :page p))
               (stp (html->stp html)))
          (with-null-namespace (stp)
            (xpath:map-node-set->list 
             (lambda (elt)
               (let ((url (string-append/shared *booklog-base-url*
                                                (stp:attribute-value elt "href")))
                     (s (regexp-replace-all '(+ space)
                                            (xpath:string-value elt)
                                            " ")))
                    `(,s ,url)))
             (xpath:evaluate "//table//a[@class='titleLink']" stp)))))
      
      (if (or (> p limit) (null? page))
          (let ((ans (reverse! ans)))
            (cond (include-kindle? ans)
                  (else
                   (cl:sort (remove (lambda (x)
                                      (or (kindle? x)
                                          (trash? k x)))
                                    ans)
                            #'string<
                            :key #'cl:second))))
          (iter (+ 1 p) 
                `(,@page ,@ans))))))




#|(booklog-search "lisp")|#


;;; *EOF*
