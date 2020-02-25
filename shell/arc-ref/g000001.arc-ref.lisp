;;;; g000001.arc-ref.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.arc-ref.internal)
(in-readtable :arc)


;;; ///
(cl:in-package :cl-user)
(defmacro g000001.arc-ref.internal::with-< (spec &body body)
  (etypecase spec
    (cons (destructuring-bind (in filename &rest args)
                              spec
            `(with-open-file (,in ,filename ,@args) ,@body)))
    ((or cl:string cl:pathname)
     `(with-open-file (< ,spec) ,@body))))
(defmacro g000001.arc-ref.internal::with-output-to-browser ((stream &key (browser "firefox")) &body body)
  (let ((filename (format nil "/mc/tmp/~A.html" (gensym "__tempfile-"))))
    `(macrolet ((#0=#:command-output-status (form) `(nth-value 2 ,form)))
       (with-open-file (,stream ,filename :direction :output :if-exists :supersede)
         ,@body)
       (zerop (#0# (kl:command-output "~A ~A" ,browser ,filename))))))
(cl:in-package :g000001.arc-ref.internal)
;;; ///


;;; ================================================================
(define-type arc-ref
  (:var @stp))


(define-method (arc-ref :make-stp) ()
  (= @stp 
     (chtml:parse (drakma:http-request "http://files.arcfn.com/doc/fnindex.html")
                  (stp:make-builder))))

(define-method (arc-ref :reduce-stp) ()
  (xpath:with-namespaces (("" (stp:namespace-uri (stp:document-element @stp))))
    (= @stp (xpath:all-nodes (xpath:evaluate "//a" @stp)))))


(define-method (arc-ref :make) ()
  (call-method :make-stp)
  (call-method :reduce-stp)
  (accum acc
    (each node @stp
      (let node-name (stp:string-value node)
        (when (cl:search node-name 
                         (stp:attribute-value node "href"))
          (acc (list node-name (stp:attribute-value node "href"))))))))


(def arc-ref ()
  (=> (make-instance 'arc-ref) :make))

;;; ================================================================
(define-type syms
  (:var file (:init "/home/mc/lisp/work/g000001-cl-daily-scratch/arc-cl.lisp"))
  (:var arc-base-url (:init "http://files.arcfn.com/doc/"))
  (:var cl-base-url (:init ""))
  (:var source)
  (:var data :gettable))


(define-method (syms :nomalize-data) ()
  (= data
     (map (fn ((arc arc-url . rest))
            (let cl (if (acons rest) car.rest "")
              (list arc
                    (+ arc-base-url arc-url) 
                    cl
                    (or (clhs-lookup:symbol-lookup cl) ""))))
          source)))


(define-method (syms :setup) ()
  (= clhs-lookup::*hyperspec-pathname*
   #P"/usr/local/lispworks/6-0-0-0/lib/6-0-0-0/manual/online/web/HyperSpec/Data/")
  (= clhs-lookup::*hyperspec-map-file*
     "/usr/local/lispworks/6-0-0-0/lib/6-0-0-0/manual/online/web/HyperSpec/Data/Map_Sym.txt")
  (with-< (in file)
    (= source (read in)))
  (call-method :nomalize-data))


(define-method (syms :output) ()
  (with-output-to-browser (out)
    (yaclml:with-yaclml-stream out
      (<:html
       (<:table
        (each (arc arc-url cl cl-url) data
          (<:tr (<:td (<:a :href arc-url (<:format arc)))
                (<:td (<:a :href cl-url (<:format cl))))))))))


(def arc-cl-xref ()
  (let o (make-instance 'syms)
    (=> o :setup)
    #|(co:=> o :describe)|#
    (=> o :output)))


;;; *EOF*
