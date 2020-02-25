;;;; info-lispm-at-mit-ai-utils.lisp

(cl:in-package :info-lispm-at-mit-ai-utils-internal)

(def-suite info-lispm-at-mit-ai-utils)

(in-suite info-lispm-at-mit-ai-utils)

;;; "info-lispm-at-mit-ai-utils" goes here. Hacks and glory await!

(defvar *info.lispm1*
  "/home/mc/lisp/src/impl/CADR-System-99/doc/info.lispm1.1")

(defvar *info.lispm2*
  "/home/mc/lisp/src/impl/CADR-System-99/doc/info.lispm2.1")

(defconstant delimiter-char #\Us)

(defparameter *data*
  (let ((file *info.lispm1*))
    (ppcre:split (string #\Us)
                 (concatenate 'string
                              (kmrcl:read-file-to-string *info.lispm1*)
                              (kmrcl:read-file-to-string *info.lispm2*)))))

(defun output-mails (out)
  (dolist (mail *data*)
    (when (ppcre:scan "release" mail)
      (write-line "---")
      (dolist (line (print (ppcre:split "\\n" (string-left-trim #(#\Newline)
                                                                mail))))
        (if (ppcre:scan "^Date:" line)

            (let ((date (to-rfc2822-date line)))
              (if date
                  (write-line (format nil "Date: ~A" date) out)
                  (write-line line out)))

            (write-line line out))))))

#|(output-mails *standard-output*)|#


(defun output-mails ()
  (dolist (mail *data*)
    (when (ppcre:scan "release" mail)
      (alexandria:with-output-to-file
          (out (format nil "/tmp/rel/~A" (gensym "foo-")))
        (dolist (line (ppcre:split "\\n" (string-left-trim #(#\Newline)
                                                           mail)))
          (if (ppcre:scan "^Date:" line)

              (let ((date (to-rfc2822-date line)))
                (if date
                    (write-line (format nil "Date: ~A" date) out)
                    (write-line line out)))

              (write-line line out)))))))


(defun output-mails ()
  (dolist (mail *data*)
    (when 'T;(ppcre:scan "release" mail)
      (alexandria:with-output-to-file
          (out (format nil "/tmp/rel/~A" (gensym "foo-")))
        (dolist (line (ppcre:split "\\n" (string-left-trim #(#\Newline)
                                                           mail)))
          (if (ppcre:scan "^Date:" line)

              (let ((date (to-rfc2822-date line)))
                (if date
                    (write-line (format nil "Date: ~A" date) out)
                    (write-line line out)))

              (write-line line out)))))))

#|(output-mails)|#



;;; 汚ない卑怯ばかりするコードですね?
(defun to-metatime (str)
  (or
   ;; 1
   (ppcre:register-groups-bind (date
                                mon
                                year
                                hour
                                min)
       ("Date: (\\d{1,2}) ([A-z]+) (\\d{4}) (\\d{2}):*(\\d{2})"
        str)
     (format nil "~A ~A ~A ~A:~A" date mon year hour min))
   ;; 2
   (ppcre:register-groups-bind (date
                                mon
                                year
                                hour
                                min)
       ("Date: [A-z]+,*\\s+(\\d{1,2})\\s+([A-z]+)\\s+(\\d{4}),*\\s+(\\d{2}):*(\\d{2})"
        str)
     (format nil "~A ~A ~A ~A:~A" date mon year hour min))
   ;; 3
   (ppcre:register-groups-bind (date
                                mon
                                year
                                hour
                                min)
       ("Date:\\s+(\\d{1,2})\\s+([A-z]+)\\s+(\\d{4}),*\\s+(\\d{2}):*(\\d{2})"
        str)
     (format nil "~A ~A ~A ~A:~A" date mon year hour min))
   ;; 4
   (ppcre:register-groups-bind (date
                                mon
                                year
                                hour
                                min)
       ("Date:\\s+(\\d{1,2})[\\s-]+([A-z]+)[\\s+-](\\d{2}),*\\s+(\\d{1,2}):*(\\d{2})"
        str)
     (format nil "~A ~A ~A ~A:~A" date mon year hour min))
   ))

;;; 汚ない卑怯ばかりするコードですね?
(defun to-rfc2822-date (str)
  (net.telent.date:UNIVERSAL-TIME-TO-RFC2822-DATE
   (+ (metatilities:PARSE-DATE-AND-TIME
       (to-metatime str))
      (* 3600 (+ 9 4)))
   0))