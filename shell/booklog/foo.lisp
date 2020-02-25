
#|(define (booklog-search k)
  (define (get-page n)
    (let* ((html (booklog-client :keyword k :page n))
           (stp (g1.arc::html->stp html)))
      (with-null-namespace (stp)
        (xpath:map-node-set->list 
         (lambda (elt)
           (let ((url (string-concatenate 
                       (list *booklog-base-url*
                             (stp:attribute-value elt "href"))))
                 (s (ppcre:regex-replace-all "\\s+" 
                                             (xpath:string-value elt) " ")))
                `(,url ,s)))
         (xpath:evaluate "//table//a[@class='titleLink']" stp)))))
  (list-ec (:- p 1 5)
           (:let page (get-page p))
           (cl:if (not (null? page)))
           page))|#




#|(define* (booklog-search (:keyword k ""))
  (let* ((html *dat*)
         (stp (g1.arc::html->stp html)))
    (list (number-of-items stp)
          (arc:accum a
            (g1.arc::doxpath (elt stp "//table//a[@class='titleLink']")
              (if (regexp-match '(seq (* nonl) "item" (* nonl))
                                (stp:attribute-value elt "href"))
                  (a `(,(string-concatenate 
                         (list *booklog-base-url*
                               (stp:attribute-value elt "href")))
                        ,(ppcre:regex-replace-all 
                          "\\s+" 
                          (xpath:string-value elt) " ")))))))))|#


#|(define* (booklog-search k)
  (let* ((html (booklog-client :keyword k))
         (stp (g1.arc::html->stp html)))
    (with-null-namespace (stp)
      (let* ((nset (xpath:evaluate "//table//a[@class='titleLink']" stp))
             (ans '() ))
        (do ((iter (xpath:make-node-set-iterator nset)
                   (xpath:node-set-iterator-next iter)))
            ((xpath:node-set-iterator-end-p iter)
             (reverse! ans))
          (let ((elt (xpath:node-set-iterator-current iter)))
            (cl:push `(,(string-concatenate 
                         (list *booklog-base-url*
                               (stp:attribute-value elt "href")))
                        ,(ppcre:regex-replace-all 
                          "\\s+" 
                          (xpath:string-value elt) " "))
                     ans)))))))|#
