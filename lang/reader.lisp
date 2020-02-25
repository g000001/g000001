(in-package :g000001)


(defun |#/-READER| (stream char arg)
  (declare (cl:ignore char arg))
  (let ((g (gensym))
        (re (ppcre:regex-replace-all
             "\\\\/"
             (collect 'string
                      (choose
                       (let ((prev nil))
                         (until-if (lambda (c)
                                     (cond ((and (eql #\/ c)
                                                 (not (eql #\\ prev)))
                                            'T)
                                           (:else (setq prev c)
                                                  nil)))
                                   (scan-stream stream #'read-char)))))
             "/")))
    `(lambda (,g)
       (ppcre:scan ,re ,g))))


#|(defun qq-expand-list (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         `(list (cons ',(car x) ,(qq-expand (cdr x) (+ depth 1)))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                `(list (cons ',(car x) ,(qq-expand (cdr x) (- depth 1)))))
               ((eq 'unquote (car x))
                `(list . ,(cdr x)))
               (:else
                `(append . ,(cdr x)))))
        (otherwise
         `(list (append ,(qq-expand-list (car x) depth)
                        ,(qq-expand (cdr x) depth)))))
      `'(,x)))|#

(defun qq-expand-list (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         (list (quote list)
               (list 'cons (list (quote quote) (car x))
                     (qq-expand (cdr x) (+ depth 1)))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                (list (quote list)
                      (list (quote cons)
                            (list (quote quote)
                                  (car x))
                            (qq-expand (cdr x) (- depth 1)))))
               ((eq (quote unquote) (car x))
                (list* (quote list)
                       (cdr x)))
               (:else
                (list* (quote append)
                       (cdr x)))))
        (otherwise
         (list (quote list)
               (list (quote append)
                     (qq-expand-list (car x) depth)
                     (qq-expand (cdr x) depth)))))
      (list (quote quote)
            (list x))))


#|(defun qq-expand (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         `(cons ',(car x) ,(qq-expand (cdr x) (+ depth 1))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                `(cons ',(car x) ,(qq-expand (cdr x) (- depth 1))))
               ((and (eq 'unquote (car x))
                     (not (null (cdr x)))
                     (null (cddr x)))
                (cadr x))
               (:else
                (error "Illegal"))))
        (otherwise
         `(append ,(qq-expand-list (car x) depth)
                  ,(qq-expand (cdr x) depth))))
      `',x))|#

(defun qq-expand (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         (list (quote cons)
               (list (quote quote)
                     (car x))
               (qq-expand (cdr x) (+ depth 1))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                (list (quote cons)
                      (list (quote quote)
                            (car x))
                      (qq-expand (cdr x) (- depth 1))))
               ((and (eq (quote unquote) (car x))
                     (not (null (cdr x)))
                     (null (cddr x)))
                (cadr x))
               (:else
                (error "Illegal"))))
        (otherwise
         (list (quote append)
               (qq-expand-list (car x) depth)
               (qq-expand (cdr x) depth))))
      (list (quote quote) x)))


(defmacro quasiquote (&whole form expr)
  (if (eq (quote quasiquote) (car form))
      (qq-expand expr 0)
      form))


(defun enable-quasiquote ()
  (set-macro-character #\,
                       (lambda (stream char)
                         (declare (ignore char))
                         (let ((next (peek-char t stream t nil t)))
                           (if (char= #\@ next)
                               (progn
                                 (read-char stream t nil t)
                                 (list (quote unquote-splicing)
                                       (read stream t nil t) ))
                               (list (quote unquote)
                                     (read stream t nil t) )))))
  (set-macro-character #\`
                       (lambda (stream char)
                         (declare (ignore char))
                         (list (quote quasiquote)
                               (read stream t nil t) ))))


;;; eof

