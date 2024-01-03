;;; -*- mode :Lisp -*-

(cl:in-package "BCL-USER")


;;; utils
(defun <o (obj)
  (display-message "~S" obj))


#||

Function               Keystroke
                       [shift]         key:
                       [control][meta] [        ]

Contains: 
[      ]   

ED-END-OF-BUFFER       Home
...
..

Documentation

ED-END-OF-BUFFER window
[Generic Function]
.....

||#


(defun find-commands ()
  (for (each elt (the vector (slot-value editor::*command-names* 'editor::table )))
       (appending
        (when (and elt
                   (typep elt 'editor::string-table-entry))
          (let* ((cmd (slot-value elt 'editor::value ))
                 (cmdname (editor::command-%name cmd))
                 (interesting-command (editor::describe-command cmd)))
            (if (not (member cmdname editor::*uninteresting-commands* :test #'string-equal))
                (or interesting-command
                    (list (list nil cmdname nil)))
                nil))))))

;;(find-commands)


(define-interface ed-help-window ()
  ((all-commands :reader all-commands 
                 :initform (mapcar (^ (c)
                                     (destructuring-bind (gs name style)
                                                         c
                                       (declare (ignore style))
                                       (list name
                                             ;;(editor::sub-print-key-to-string gs)
                                             gs)))
                                   ;;(editor::find-interesting-commands :modes :all)
                                   (find-commands))))
  (:layouts
   (main column-layout '(contains mods commands documentation)))
  (:panes
   (mods key-monitor-pane
         :notifee (^ (gs press/release) 
                    (update-by-keypress interface gs press/release))
         :max-height 48.)
   (contains filtering-layout :title "Contains:" :title-position :frame
             :reader ed-help-window-contains
             :change-callback #'update-by-wordsearch)
   (commands multi-column-list-panel 
             :columns '((:title "Name") (:title "Keystroke"))
             :items all-commands
             :reader ed-help-window-list-panel
             :item-print-functions (list #'identity
                                         (^ (x)
                                           (if x
                                               (editor::sub-print-key-to-string x)
                                               "")))
             :selection-callback 
             (^ (item itf)
               (flet ((update ()
                        (setf (text-input-pane-text documentation)
                              (editor::full-command-documentation (editor::find-command (car item))))))
                 (apply-in-pane-process itf #'update))))
   (documentation multi-line-text-input-pane :title "Documentation" :title-position :frame))
  (:default-initargs :title "LW-Editor Commands"
   :best-width 600.
   :best-height 800.))


(defun update-by-wordsearch (ed-help-window)
  (let* ((things (all-commands ed-help-window))
         (filtered-things
          (multiple-value-bind (regexp excludep)
                               (filtering-layout-match-object-and-exclude-p
                                (ed-help-window-contains ed-help-window)
                                nil)
            (if regexp
                (for (let (name gs) :in things) 
                     (when (if (lw:find-regexp-in-string regexp name)
                               (not excludep)
                               excludep))
                     (collect (list name gs)))
                things))))
    (setf (collection-items 
           (ed-help-window-list-panel ed-help-window))
          filtered-things)
    (let* ((doc (~ ed-help-window 'documentation))
           (lp (ed-help-window-list-panel ed-help-window)))
      (flet ((update ()
               (setf (text-input-pane-text doc)
                     (editor::full-command-documentation 
                      (editor::find-command (car (choice-selected-item lp)))))))
        (apply-in-pane-process doc #'update)))))


(defun update-by-keypress (ed-help-window gs press/release)
  (let* ((things (all-commands ed-help-window))
         (filtered-things
          (ecase press/release
            (:press
             (for (let (lname lgs) :in things)
                  (when (and (find (sys:gesture-spec-modifiers gs)
                                   lgs
                                   :key #'sys:gesture-spec-modifiers)
                             (or (null (sys:gesture-spec-data gs))
                                 (find (sys:gesture-spec-data gs)
                                       lgs
                                       :key #'sys:gesture-spec-data))))
                  (collect (list lname lgs))))
            (:release things))))
    (setf (collection-items 
           (ed-help-window-list-panel ed-help-window))
          filtered-things)
    (let* ((doc (~ ed-help-window 'documentation))
           (lp (ed-help-window-list-panel ed-help-window)))
      (flet ((update ()
               (setf (text-input-pane-text doc)
                     (editor::full-command-documentation 
                      (editor::find-command (car (choice-selected-item lp)))))))
        (apply-in-pane-process doc #'update)))))


(editor:defcommand "Editor Help" (p)
     ""
     ""
  (declare (ignore p))
  (find-interface 'ed-help-window))


(defvar *keys*
  " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")


(define-interface key-monitor-pane ()
  ((notifee :initform (constantly nil) :initarg :notifee))
  (:panes
   (sensor output-pane
           :input-model `((:modifier-change
                           ,(^ (itf x y mod)
                              (declare (ignore itf x y))
                              (setf (simple-pane-background shift)
                                    (and (ldb-test (byte 1 0) mod) 
                                         :skyblue))
                              (setf (simple-pane-background control)
                                    (and (ldb-test (byte 1 1) mod)
                                         :red))
                              (setf (simple-pane-background meta)
                                    #+cocoa
                                    (and (ldb-test (byte 1 3) mod) ;command
                                         :green)
                                    #-cocoa
                                    (and (ldb-test (byte 1 2) mod)
                                         :green))
                              (if (zerop mod)
                                  (progn
                                    (setf (simple-pane-background shift) :white)
                                    (setf (simple-pane-background control) :white)
                                    (setf (simple-pane-background meta) :white)
                                    (funcall notifee nil :release))
                                  (funcall notifee (sys:make-gesture-spec nil mod)
                                           :press))))
                          ,@(map 'list
                                 (^ (c)
                                   `((:key ,c :release)
                                     ,(^ (itf x y gs)
                                        (declare (ignore x y gs))
                                        (funcall notifee nil :release)
                                        (gp:clear-graphics-port itf))))
                                 *keys*)
                          (:gesture-spec 
                           ,(^ (itf x y gs)
                              (declare (ignore x y))
                              (gp:clear-graphics-port itf)
                              (gp:draw-string itf
                                              (string (code-char (sys:gesture-spec-data gs)))
                                              10
                                              18)
                              (funcall notifee gs :press))))
           :title "Key:" :title-position :left)
   (shift title-pane :background :white :text "Shift" :title-position :frame)
   (meta title-pane :background :white :text "Meta" :title-position :frame)
   (control title-pane :background :white :text "Ctrl" :title-position :frame)
   (char title-pane :background nil :text "" :title-position :frame))
  (:layouts 
   (main column-layout '(mods sensor))
   (mods row-layout '(shift meta control))))


(editor:defcommand "run" (p)
     ""
     ""
  (declare (ignore p))
  (find-interface 'key-monitor-pane))


;;; *EOF*
