;;;;
;;;; super-p/n で隣のファイルに行ったりきたり
;;;;

(in-package :esa-io)

(define-command (com-open-prev-file :name t :command-table esa-io-table)
    ()
  ""
  (let* ((file (filepath (current-buffer)))
         (filetype (pathname-type (filepath (current-buffer)))))
    (handler-case (esa-io:com-find-file
                   (prev-file (directory-namestring (filepath (current-buffer)))
                              file
                              filetype))
      (file-error (e)
        (display-message "~A" e)))))

(set-key `(com-open-prev-file ,*unsupplied-argument-marker*)
         'esa-io-table '((#\p :super)))

(define-command (com-open-next-file :name t :command-table esa-io-table)
    ()
  ""
  (let* ((file (filepath (current-buffer)))
         (filetype (pathname-type (filepath (current-buffer)))))
    (handler-case (esa-io:com-find-file
                   (next-file (directory-namestring (filepath (current-buffer)))
                              file
                              filetype))
      (file-error (e)
        (display-message "~A" e)))))

(set-key `(com-open-next-file ,*unsupplied-argument-marker*)
         'esa-io-table '((#\n :super)))

(defun all-same-files (directory type)
  (directory (merge-pathnames
              (make-pathname :name :wild :type type)
              (merge-pathnames directory (user-homedir-pathname)))))

(defun *next-file (next-fun directory file type)
  (let* ((files (sort (all-same-files directory type)
                      #'string<
                      :key #'namestring))
         (pos (position (truename file) files :test #'equal)))
    (when pos
      (nth (funcall next-fun pos) files))))

(defun prev-file (directory file type)
  (*next-file #'1- directory file type))

(defun next-file (directory file type)
  (*next-file #'1+ directory file type))

;; end.

