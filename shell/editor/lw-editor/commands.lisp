;;;; -*- Mode: Lisp; coding: utf-8 -*- 
;;; "l:src;rw;g000001;shell;editor;lw-editor;commands.lisp"

(eval-when (:compile-toplevel :load-toplevel :execute)
  (or (find-package 'puri) (ql:quickload :puri))
  (or (find-package :xpath) (ql:quickload :closure-foo))
  (or (find-package :g000001.ja) (ql:quickload :g000001.ja))
  (or (find-package :g000001.html) (ql:quickload :g000001.html)))


(in-package editor)


(defvar *bind-key-forms* '())


(defun stash-bind-key-form (form)
  (pushnew form *bind-key-forms* :test #'equalp))


(defun funcall-or-never (pkg name &rest args)
  (let ((name (string name))
        (pkg (string pkg)))
    (if-let (fctn (find-symbol name pkg))
        (apply fctn args)
        (warn "Function: ~A::~A not found." pkg name))))


(defcommand "Tweet Region" (p)
     ""
     ""
  (declare (ignore p))
  (funcall-or-never :? :twe (buffer-region-as-string (current-buffer))))


(defcommand "Cat Tweet" (p)
     ""
     ""
  (declare (ignore p))
  (funcall-or-never :? :twe/catface (buffer-region-as-string (current-buffer))))


(defcommand "Cat Tweet Continuosly" (p)
       ""
       ""
    (declare (ignore p))
    (funcall-or-never :? :con/catface (buffer-region-as-string (current-buffer))))


(defcommand "Markdownify" (p)
     ""
     ""
  (declare (ignore p))
  (let ((remarkable.exe 
         (format nil
                 "remarkable ~S"
                 (namestring
                  (buffer-pathname (current-buffer))))))
    (message remarkable.exe)
    (system:run-shell-command remarkable.exe)))


(defcommand "Editor Only" (p)
     ""
     ""
  (declare (ignore p))
  (let* ((ifs (capi:screen-interfaces (car (capi:screens))))
         (editor (find-if (lambda (x)
                            (search "Editor" (capi:interface-title x)))
                          ifs)))
    (capi:raise-interface editor)
    (dolist (i ifs)
      (unless (typep i 'lispworks-tools:editor)
        ;; (capi:quit-interface i)
        (capi:destroy i)))))


(defun count-white-spaces-to-the-next-sxp ()
  (let ((cnt 0))
    (block nil
      (map nil
           (lambda (c)
             (if (find c #(#\Space #\Newline #\Return #\Tab))
                 (incf cnt)
                 (return)))
           (points-to-string (current-point)
                             (point-next (current-point)))))
    cnt))


(defun list-all-interfaces ()
  (let* ((ans (list nil))
         (tem ans))
    (dolist (s (capi:screens) (cdr ans))
      (dolist (i (capi:screen-interfaces s))
        (setf (cdr tem)
              (setq tem (list i)))))))


(defun the-top-interface ()
  (first (capi:collect-interfaces 'capi:interface :sort-by :visible)))


(defcommand "The Top Interface" (p)
     ""
     ""
  (declare (ignore p))
  (message (format nil "~A" (the-top-interface))))


(defcommand "Insert -" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point) "-"))


(bind-key "Insert -" "Meta-Space" :global :emacs)


(defcommand "Insert \"\"" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point) "\"\"")
  (backward-character-command 1))


(bind-key "Insert \"\"" "Meta-\"" :global :emacs)


(defcommand "Insert **" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point) "**")
  (backward-character-command 1))


(defcommand "Go Output" (p)
     ""
     ""
  (declare (ignore p))
  (with-random-typeout-to-window
      ((let ((window (car (buffer-windows (current-buffer)))))
         (and window (window-text-pane window))))
    nil))


(bind-key "Go Output" #("Meta-g" #\Space) :global :emacs)


(defcommand "Raise Listener" (p) 
     "Raise Listener pane"
     "Raise Listener pane"
  (declare (ignore p))
  (capi:raise-interface
   (find-if (lambda (x)
              (search "Listener" (capi:interface-title x)))
            (capi:collect-interfaces 'lispworks-tools:listener))))


(bind-key "Raise Listener" #("Meta-g" #\r) :global :emacs)


(defcommand "Raise Editor" (p) 
     "Raise Editor pane"
     "Raise Ediror pane"
  (declare (ignore p))
  (capi:raise-interface
   (find-if (lambda (x)
              (search "Editor" (capi:interface-title x)))
            (capi:collect-interfaces 'lispworks-tools:editor))))


(bind-key "Raise Editor" #("Meta-g" #\e) :global :emacs)


(defun read-to-string (&optional (stream *standard-input*)
                                 (eof-error-p T)
                                 (eof-value stream)
                                 recursivep
                                 (junk-allowed T))
  (with-output-to-string (outstring)
    (let* ((stream (make-echo-stream stream outstring))
           (*read-suppress* junk-allowed))
      (when (read stream eof-error-p eof-value recursivep)
        (return-from read-to-string eof-value)))))


(defun split-forms-evenly (path)
  (let* ((file path)
         (forms (with-open-stream (in (open file))
                  (loop :for xpr := (read-to-string in nil in)
                        :until (eq in xpr)
                        :collect xpr))))
    (with-open-stream (out (open file 
                                 :direction :output
                                 :if-exists :supersede
                                 :if-does-not-exist :create))
      (dolist (f forms (format out ";;; *EOF*~%"))
        (let ((op (ignore-errors (car (read-from-string f))))
              (xp (string-trim #(#\Space #\Newline #\Tab) f)))
          (format out
                  "~&~A~A~3%" 
                  xp
                  (case op
                    (eval-when "")
                    (otherwise ""))))))))


(defcommand "Lfmt" (p)
     ""
     ""
  (let ((path (buffer-pathname (current-buffer))))
    (split-forms-evenly path)
    (revert-buffer-command p)))


(defcommand "Just One Space *" (p)
     ""
     ""
  (declare (ignore p))
  (let ((cp (current-point)))
    (delete-characters cp (count-white-spaces-to-the-next-sxp))
    (insert-string cp " ")))


(bind-key "Just One Space *" #("Control-[" #\Space) :global :emacs)


(defcommand "Evaluate Defun *" (p)
     ""
     ""
  (evaluate-defun-command p)
  (when p (go-output-command p)))


(bind-key "Evaluate Defun *" "Control-E" :global :emacs)


(defcommand "Sort Lines" (reversep)
     ""
     ""
  (let ((buf (current-buffer)))
    (with-buffer-point-and-mark (buf)
      (with-point ((start %point% :before-insert)
                   (end   %mark%  :after-insert))
        (let ((orig  (points-to-string start end))
              (modifiedp (buffer-modified buf)))
          (unwind-protect 
              (progn
                (delete-between-points editor::%point% editor::%mark%)
                (insert-string %point%
                               (format nil
                                       "~{~A~%~}"
                                       (sort (ppcre:split "\\n" orig)
                                             (if reversep #'string> #'string<)))))
            (record-replace-region start end orig modifiedp)))))))


(bind-key "Insert **" "Meta-*" :global :emacs)


(bind-key "undo" "Control-U" :global :emacs)


(bind-key "redo" "control-R" :global :emacs)


(defun listener-save-history ()
  (let ((hist (slot-value (find 'lispworks-tools:listener (capi:screen-interfaces (car (capi:screens)))
                                :key #'type-of)
                          'capi-toolkit::history)))
    (with-open-stream (out (open (merge-pathnames ".lispworks_listener_history" (user-homedir-pathname))
                                 :direction :output
                                 :if-exists :supersede
                                 :if-does-not-exist :create))
      (with-standard-io-syntax 
        (print hist out)))))


(defun listener-load-history ()
  (let ((hist (find 'lispworks-tools:listener (capi:screen-interfaces (car (capi:screens)))
                    :key #'type-of)))
    (with-open-stream (in (open (merge-pathnames ".lispworks_listener_history" (user-homedir-pathname))))
      (with-standard-io-syntax 
        (let ((ohist (read in)))
          (when ohist
            (setf (slot-value hist 'capi-toolkit::history)
                  (append (slot-value hist 'capi-toolkit::history)
                          ohist))
            (let ((histlen (length (slot-value hist 'capi-toolkit::history))))
              (if (> (length (slot-value hist 'capi-toolkit::history))
                     (slot-value hist 'capi-toolkit::history-limit))
                  (setf (slot-value hist 'capi-toolkit::history-limit)
                        (* 2 histlen))))))))))


(bind-key "Insert ()" "Meta-L" :global :emacs)


(bind-key "Move Over )" "Meta-:" :global :emacs)


(defcommand "Clear Output Immediately" (p)
     "clear the output"
     "clear the output"
  (declare (ignore p))
  (let ((buf (current-buffer)))
    (when (eq (buffer-major-mode buf)
              (getstring "Output" *mode-names*))
      (clear-buffer buf))))


(bind-key "Clear Output Immediately" #("Control-c" "Meta-o") :global :emacs)


(bind-key "Activate Interface" "Control-;" :global :emacs)


(defcommand "Close Current Interface" (p)
     "Close Current Window"
     "Close Current Window"
  (declare (ignore p))
  (let ((prevwin (previous-window (current-window))))
    (call-with-a-text-pane #'invoke-menu-item
                           '("works" "exit" "window"))
    (goto-to-window-and-buffer prevwin)))


(bind-key "Close Current Interface" #("Control-x" "Control-c"))


(progn
  ;; Echo Area
  (bind-key "Complete Field" #\Space :mode "Echo Area")
  (bind-key "illegal" "Control-m" :mode "Echo Area")
  (bind-key "illegal" "Control-j" :mode "Echo Area")
  (bind-key "illegal" "Control-n" :mode "Echo Area")
  (bind-key "illegal" "Control-p" :mode "Echo Area")
  (bind-key "Complete Input" "Control-i" :mode "Echo Area"))


(defcommand "Insert HH:MM" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point)
                 (apply #'format
                        nil 
                        "~2,'0D:~2,'0D "
                        (reverse
                         (subseq 
                          (multiple-value-list (get-decoded-time))
                          1 3)))))


(bind-key "Delete Previous Character" "Control-h" :global :emacs)


(defcommand "Show Background Output Window" (p)
     "Show Background Output Window"
     "Show Background Output Window"
  (declare (ignore p))
  (make-window (buffer-point 
                (find "Background Output"
                      *buffer-list*
                      :key #'buffer-name 
                      :test #'string=))))


(bind-key "Show Background Output Window" #("Control-c" #\o))


(defcommand "Delete Other Editor Interfaces" (p)
     "Delete Other Editor Interfaces"
     "Delete Other Editor Interfaces"
  (declare (ignore p))
  (dolist (i (cdr (capi:collect-interfaces 'lw-tools:editor
                                           :sort-by :visible)))
    (capi:destroy i))
  (message "...Destroyed."))


(bind-key "Delete Other Editor Interfaces" #("Control-c" #\d))


(defcommand "One Window Per Buffer" (p)
     "One Window Per Buffer"
     "One Window Per Buffer"
  (declare (ignore p))
  (let ((bufs (remove-if-not #'file-buffer-p
                             (remove "*Messages Buffer*"
                                     *buffer-list*
                                     :key #'buffer-name
                                     :test #'string=))))
    (dolist (b bufs)
      (unless (buffer-windows b)
        (make-window (buffer-point b))))))


(bind-key "One Window Per Buffer" #("Control-c" #\x))


(bind-key "Just One Space" #("Control-c" #\Space))


(bind-key "New Window" "Control-Meta-I")


(bind-key "Delete Window" "Control-Meta-!")


(defcommand "Browse Url" (arg)
     "WIP"
     "WIP"
  (declare (ignore arg))
  (let ((curline (line-string (current-point)))
        (url-re (ppcre:create-scanner
                 "(?x:
                    (.*)
                    (http(s)*://[A-z\\$-_\\.\\+!\\*'\\(\\),]+)
                    (.*))")))
    (multiple-value-bind (url win)
                         (ppcre:regex-replace url-re curline "\\2")
      (hqn-web:browse 
       (if win
           (string-trim #(#\( #\)) url)
           (prompt-for-string 
            :default-string "http://g000001.cddddr.org"))))))


;; --:=&?$+@-z_[:alpha:]~#,%;*()!'


(bind-key "Browse Url"
          #("Control-c" "."))


(bind-key "Evaluate Last Form In Listener"
          #("Control-c" "Control-e"))


(bind-key "Disassemble Definition" #("Control-c" "Meta-d"))


(bind-key "Insert Space and Show Arglist" #\Space :global :emacs)


(bind-key "Walk Form" "Control-Meta-M" :global :emacs)


(defun toggle-interface-toolbar ()
  (dolist (i (capi:collect-interfaces 'capi:interface))
    (ignore-errors
      (setf (lispworks-tools::lispworks-interface-toolbar-visible-p i)
            (not (lispworks-tools::lispworks-interface-toolbar-visible-p i))))))


(defcommand "Toggle Toolbar" (p)
     ""
     ""
  (declare (ignore p))
  (toggle-interface-toolbar))


(defcommand "Region To String List" (more)
     "Region To String List"
     "Region To String List"
  (let* ((s (buffer-region-as-string (current-buffer)))
         (ss (split-sequence #(#\Newline #\Linefeed) s ))
         (ss (if more 
                 (mapcar (lambda (s)
                           (split-sequence #(#\Space #\Tab) s
                                           :coalesce-separators T)) 
                         ss)
                 ss)))
    (insert-string (current-point) 
                   (string-append (string #\Newline)
                                  "'"
                                  (prin1-to-string ss)))))


(when-let (sym (find-symbol "*DESCRIBE-ATTRIBUTE-FORMATTER*" 
                            :sys))
  (defun cl-user::slot-printer (stream arg colon at)
    (declare (ignore colon at))
    (format stream "~A (~(~A~))" arg (package-name (symbol-package arg))))
  (set sym "~S"))


(defun indent-n (n str)
  (with-output-to-string (out)
    (dolist (line (ppcre:split "\\n" str))
      (format out "~VT~A~%" n line))))


(defcommand "Evaluate Last Form*" (p &optional (point (current-point)))
     "evaluates lisp forms before point."
     "evaluates lisp forms before point."
  (declare (ignore p))
  (with-point ((start point)
               (end point))
    (unless (form-offset start -1 t 0)
      (editor-error "cannot find start of the form to evaluate"))
    (let ((*package* (or (get-buffer-current-package (point-buffer point))
                         (find-package 'cl-user)))
          (*standard-output* (make-string-output-stream))
          (*error-output* (make-string-output-stream))
          (result (list)))
      (setq result 
            (multiple-value-list 
             (ignore-errors
               (eval
                (read-from-string 
                 (points-to-string start end))))))
      (flet ((insert-result ()
               (insert-string (current-point)
                              (if result
                                  (format nil "~%→ ~S" (car result))
                                  (format nil "~%→ <no values>" (car result))))
               (dolist (r (cdr result))
                 (when (typep r 'simple-condition)
                   (apply #'format *error-output* 
                          (simple-condition-format-control r)
                          (simple-condition-format-arguments r)))
                 (insert-string (current-point)
                                (format nil "~%  ~S" r)))
               (insert-string (current-point)
                              (format nil "~%")))
             (insert-output ()
               (let ((lines (ppcre:split "\\n" (get-output-stream-string *standard-output*))))
                 (dolist (line lines)
                   (insert-string (current-point)
                                  (format nil "~%▻ ~A" line)))))
             (insert-error ()
               (let ((lines (ppcre:split "\\n" (get-output-stream-string *error-output*))))
                 (dolist (line lines)
                   (insert-string (current-point)
                                  (format nil "~%⏏ ~A" line))))))
        (insert-output)
        (insert-error)
        (insert-result)))))


(bind-key "Evaluate Last Form*" "Control-J" :global :emacs)


(defcommand "Browse Class" (p)
     "browse class"
     "browse class"
  (let ((name (prompt-for-symbol p 
                                 :prompt "Symbol: "
                                 :tag 'lw-tools:class-browser)))
    (capi:display (make-instance 'lw-tools:class-browser :class name))))


(defun |Mon d, yyyy | ()
  (multiple-value-bind (.s .m .h d m y)
                       (get-decoded-time)
    (declare (ignore .s .m .h))
    (format nil 
            "~[~;Jan~;Feb~;Mar~;Apr~;May~;Jun~;~
                Jul~;Aug~;Sep~;Oct~;Nov~;Dec~] ~
                ~D, ~D "
            m
            d
            y)))


(defcommand "insert Mon d, yyyy" (p)
     "insert Mon d, yyyy"
     "insert Mon d, yyyy"
  (declare (ignore p))
  (insert-string (current-point)
                 (|Mon d, yyyy |)))


(defun in-string-p (pt)
  (let ((face (getf (text-properties-at pt)
                    'face)))
    (and face
         (typecase face
           (face T)
           (T nil)))))


(defun get-out-in-string ()
  (loop
   (let ((pt (current-point)))
     (if (in-string-p pt)
         (character-offset pt -1)
         (return)))))


(compiler-let ((*packages-for-warn-on-redefinition* nil))
  (defcommand "Backward Up List" (p)
       "Move backward past one containing (."
       "Move backward past one containing (."
    (let ((point (current-point))
          (count (or p 1)))
      (when (in-string-p point)
        (get-out-in-string)
        (decf count))
      (if (minusp count)
          (forward-up-list-command (- count))
          (with-point ((m point))
            (dotimes (i count (move-point point m))
              (unless (backward-up-list m) (editor-error))))))))


(progn
  (defcommand "Paredit Forward Slurp Sexp" (p)
       ""
       ""
    (declare (ignore p))
    (forward-up-list (current-point))
    (let ((close (character-at (current-point) -1)))
      (delete-characters (current-point) -1)
      (loop
       (handler-case 
           (progn
             (form-offset (current-point) 1 T 0)
             (indent-command 1)
             (return nil))))
      (insert-character (current-point) close)))
  
  (bind-key "Paredit Forward Slurp Sexp" #("Control-c" "<") :global :emacs)
  (bind-key "Paredit Forward Slurp Sexp" "Control-<" :global :emacs))


(defcommand "Insert UNIVERSAL-TIME" (p)
     ""
     ""
  (declare (ignore p))
  (let ((ut (get-universal-time)))
    (multiple-value-bind (s m h d mo y)
                         (decode-universal-time ut)
      (declare (ignore s))
      (insert-string (current-point)
                     (format nil
                             "~D ;~D-~2,'0D-~2,'0DT~2,'0D~2,'0D"
                             ut y mo d h m)))))


(mapc #'eval *bind-key-forms*)


(eval-when (:compile-toplevel :load-toplevel :execute)
(unless (fboundp 'with-defun-start-end-points)
  (defmacro with-defun-start-end-points ((start end &key (errorp t)) the-point
                                         &body body)
    (with-unique-names (point res)
      `(let ((,point ,the-point)
             (,res nil))
         (prog1 
           (with-point-locked
               (,point :for-modification nil)
             (with-point ((,start ,point) (,end ,point))
               (when (eq (setq, res 
                              (get-defun-start-and-end-points ,point ,start ,end ))
                         t)
                 ,@body)))
           (unless (or (not ,errorp) (not ,res) (eq ,res t))
             (editor-error ,res))))))))


(defun toplevel-form-to-string (point)
  (let (str form-beg form-end)
    (with-defun-start-end-points (beg end :errorp nil) point
      (setq str (points-to-string beg end))
      (setq form-beg (copy-point beg))
      (setq form-end (copy-point end)))
    (values str form-beg form-end)))


(defun form-to-string (point)
  (let (str form-beg form-end)
    (save-excursion
      (with-point ((beg point))
        (setq form-beg (copy-point beg))
        (forward-form-command 1)
        (setq str (points-to-string beg (current-point)))
        (setq form-end (copy-point (current-point)))))
    (values str form-beg form-end)))


(defmacro bind-env (&body body &environment env)
  `(let (,@(mapcar (lambda (x)
                     (if (walker:variable-special-p x env)
                         `(,x ,x)
                         `(,x ,x)))
                   (walker::env-lexical-variables env)))
     '.bind-env.
     ,@body))


(defun extract-binds (form)
  (labels ((%extract-binds (form)
             (cond ((atom form) form)
                   ((and (consp form)
                         (eq 'let (elt form 0))
                         (equal ''.bind-env. (elt form 2)))
                    (return-from extract-binds (elt form 1)))
                   (T (%extract-binds (print (car form)))
                      (%extract-binds (cdr form))))))
    (%extract-binds form)))


(defcommand "Save Form With Env" (p)
     "Save Form With Env"
     "Save Form With Env"
  (declare (ignore p))
  (multiple-value-bind (killed killed-beg killed-end)
                       (form-to-string (current-point))
    (with-point ((point (current-point)))
      (multiple-value-bind (whole whole-beg whole-end)
                           (toplevel-form-to-string (current-point))
        (declare (ignore whole))
        (let* ((killed/env (concatenate 'string
                                        "(editor::bind-env "
                                        killed 
                                        ")"))
               (whole/env (concatenate 'string
                                       (points-to-string whole-beg killed-beg)
                                       killed/env
                                       (points-to-string killed-end whole-end)))
               (expanded (with-compilation-environment-at-point (point)
                           (walker:walk-form (read-from-string whole/env))))
               (binds (format nil 
                              "~&(let ~A~%  ~A)"
                              (write-to-string (extract-binds expanded))
                              killed)))
          (set-current-cut-buffer-string (current-window) binds))))))


(defcommand "Clear Listener*" (p)
     "Clear the listener"
     "Clear the listener"
  (declare (ignore p))
  (let ((buffer (print (current-buffer))))
    (when (buffer-execute-p buffer)
      (when T
        (clear-listener)))))


(defun canonicalize-amazon-url (url &optional (affiliatep T))
  (let ((uri (puri:parse-uri url)))
  (flet ((canonicalize-path (path)
           (ppcre:regex-replace ".*/dp/([^/]+)/.*"
                                path
                                "/dp/\\1/"))
         (canonicalize-path/affiliate (path)
           (ppcre:regex-replace ".*/dp/([^/]+)/.*"
                                path
                                "/exec/obidos/ASIN/\\1/lisphub-22"))
         (uri-to-string (uri)
           (with-output-to-string (out)
             (puri:render-uri uri out))))
  (multiple-value-bind (path win)
                       (funcall (if affiliatep 
                                    #'canonicalize-path/affiliate
                                    #'canonicalize-path)
                                (puri:uri-path uri))
  (and win
       (uri-to-string
        (make-instance 'puri:uri 
                       :scheme (puri:uri-scheme uri)
                       :host (puri:uri-host uri)
                       :path path)))))))


(defcommand "Canonicalize Amazon Url Region" (p)
     "Canonicalize Amazon Url Region"
     "Canonicalize Amazon Url Region"
  (insert-string (current-point)
                 (lw:string-append
                  (string #\Newline)
                  (canonicalize-amazon-url
                   (buffer-region-as-string (current-buffer))
                   p))))


(defcommand "Get Title by Url Region" (p)
     "Get Title by Url Region"
     "Get Title by Url Region"
  (declare (ignore p))
  (insert-string 
   (current-point)
   (lw:string-append
    (string #\Newline)
    (uiop:symbol-call :g000001.html
                      :get-title
                      (buffer-region-as-string (current-buffer))))))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun reddit-post-link (sub uri)
    (let* ((title (g000001.html:get-title uri))
           (base (lw:string-append "https://www.reddit.com/r/"
                                   sub
                                   "/submit")))
      (flet ((enc (uri)
               (drakma:url-encode uri :utf-8)))
        (format nil
                "~A?url=~A&title=~A"
                base
                (enc uri)
                (enc title))))))


(defcommand "/r/nicovideo" (arg)
     "WIP"
     "WIP"
  (declare (ignore arg))
  (let ((curline (line-string (current-point)))
        (url-re (ppcre:create-scanner
                 "(?x:
                    (.*)
                    (http(s)*://[A-z\\$-_\\.\\+!\\*'\\(\\),]+)
                    (.*))")))
    (multiple-value-bind (uri win)
                         (ppcre:regex-replace url-re curline "\\2")
      (hqn-web:browse 
       (if win
           (reddit-post-link "nicovideo" uri)
           (prompt-for-string 
            :default-string "https://www.reddit.com/submit"))))))


(defcommand "/r/lisp_ja" (arg)
     "WIP"
     "WIP"
  (declare (ignore arg))
  (let ((curline (line-string (current-point)))
        (url-re (ppcre:create-scanner
                 "(?x:
                    (.*)
                    (http(s)*://[A-z\\$-_\\.\\+!\\*'\\(\\),]+)
                    (.*))")))
    (multiple-value-bind (uri win)
                         (ppcre:regex-replace url-re curline "\\2")
      (hqn-web:browse 
       (if win
           (reddit-post-link "lisp_ja" uri)
           (prompt-for-string 
            :default-string "https://www.reddit.com/submit"))))))


(defcommand "/r/programming_jp" (arg)
     "WIP"
     "WIP"
  (declare (ignore arg))
  (let ((curline (line-string (current-point)))
        (url-re (ppcre:create-scanner
                 "(?x:
                    (.*)
                    (http(s)*://[A-z\\$-_\\.\\+!\\*'\\(\\),]+)
                    (.*))")))
    (multiple-value-bind (uri win)
                         (ppcre:regex-replace url-re curline "\\2")
      (hqn-web:browse 
       (if win
           (reddit-post-link "programming_jp" uri)
           (prompt-for-string 
            :default-string "https://www.reddit.com/submit"))))))


(defun expand-env-var (str)
  (typecase str
    (pathname (setq str (namestring str))))
  (or (find #\$ str)
      (return-from expand-env-var (pathname str)))
  (multiple-value-bind (mat sub)
                       (ppcre:scan-to-strings "\\$(.+?)[\\b/]*?" str)
    (declare (ignore mat))
    (if-let (env (getenv (elt sub 0)))
        (pathname (getenv (elt sub 0)))
        str)))


(defcommand "Find File*" (p &optional pathname (external-format :default) (warp t))
     ""
     ""
  (let* ((pn (expand-env-var
              (or pathname
                  (prompt-for-file 
                   :prompt "Find File: "
                   :must-exist nil
                   :wildp *find-file-wild-pathname-p*
                   :help "Name of file to read into its own buffer."
                   :file-directory-p *find-file-file-directory-p*
                   :default (buffer-default-directory (current-buffer))))))
	 (buffer (if (wild-pathname-p pn)
                     (new-buffer-for-directory pn
                                               (if (or (pathname-name pn)
                                                       (pathname-type pn))
                                                   nil
                                                 *ignorable-file-suffices*))
                   (find-file-buffer-verbose pn nil external-format))))
    (when buffer
      (record-active-buffer-pathname buffer :open)
      (goto-buffer-if-unflagged-current p buffer warp))
    buffer))


(bind-key "Find File*" #("Control-x" "Control-f") :global :emacs)


(compiler-let ((*compile-print* nil))
  (eval
   '(defcommand "←" (p)
         ""
         ""
      (declare (ignore p))
      (insert-string (current-point) "← ")))
  (bind-key "←" "Control-Z" :global :emacs))


;;; *EOF*
