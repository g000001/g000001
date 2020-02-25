(cl:in-package :stumpwm-setagaya-library-utilities-internal)


(defun request (url &key (method :get) parameters)
  (multiple-value-bind (body stat)
                       (drakma:http-request url
                                            :parameters parameters
                                            :method method
                                            :force-binary T)
    #|(values (babel:octets-to-string body :encoding :cp932)
            stat )|#
    (values body stat)))

(let ((drakma:*drakma-default-external-format* :utf-8))
  (request *setagaya-library-login-uri*
           :method :post
           :parameters (load-password)))

(type-of(make-array 0 :adjustable t
             :fill-pointer 0
             :element-type '(UNSIGNED-BYTE 8)))

(SB-GRAY:STREAM-WRITE-SEQUENCE *standard-output* #(1 2))

(TRIVIAL-GRAY-STREAMS:TRIVIAL-GRAY-STREAM-MIXIN T)


(SB-GRAY:STREAM-WRITE-SEQUENCE)


/home/mc/quicklisp/dists/quicklisp/software/cl+ssl-20130312-git/streams.lisp
stream-write-sequence

(check-type thing (simple-array (unsigned-byte 8) (*)))

(TRIVIAL-GRAY-STREAMS:STREAM-WRITE-SEQUENCE )


(DRAKMA::SEND-CONTENT )

(subtypep '(SIMPLE-ARRAY (UNSIGNED-BYTE 8) (*))
          '(AND (VECTOR (UNSIGNED-BYTE 8) 31) (NOT SIMPLE-ARRAY)))

(type-of (make-array 3 :element-type '(UNSIGNED-BYTE 8)))


(subtypep '(SIMPLE-ARRAY (UNSIGNED-BYTE 8) 31)
          '(SIMPLE-ARRAY (UNSIGNED-BYTE 8) (*)))

(coerce #(85 73 68 61 48 48 48 54 51 56 55 51 49 48 38 80 65 83 83 61 116 114 105
          116 111 110 101 55)
        '(SIMPLE-ARRAY (UNSIGNED-BYTE 8) (28)))
(type-of
 (coerce #(85 73 68 61 48 48 48 54 51 56 55 51 49 48 38 80 65 83 83 61 116 114 105
           116 111 110 101 55)
         '(AND (VECTOR (UNSIGNED-BYTE 8) 28) (NOT SIMPLE-ARRAY))))


(typep #(1 2 3) '(SIMPLE-ARRAY t 3))

(typep (make-array '(0 0 0)) '(SIMPLE-ARRAY t 3))

(typep (make-array '(0 0 0)) '(SIMPLE-ARRAY t 3))



(coerce (make-array '(0 0 0)
                    :element-type '(UNSIGNED-BYTE 8))
        '(SIMPLE-ARRAY (UNSIGNED-BYTE 8) (*)))

(check-type thing (simple-array (unsigned-byte 8) (*)))

