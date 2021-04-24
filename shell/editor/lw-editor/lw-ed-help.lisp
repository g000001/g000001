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


(define-interface ed-help-window ()
  ((all-commands :reader all-commands 
                 :initform (mapcar (^ (c)
                                     (destructuring-bind (gs name style)
                                                         c
                                       (declare (ignore style))
                                       (list name
                                             ;;(editor::sub-print-key-to-string gs)
                                             gs)))
                                   (editor::find-interesting-commands :modes :all))))
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
                                         #'editor::sub-print-key-to-string)
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
    (let* ((doc (get ed-help-window 'documentation))
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
    (let* ((doc (get ed-help-window 'documentation))
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
                              (declare (ignore x y))
                              (setf (simple-pane-background shift)
                                    (and (ldb-test (byte 1 0) mod) 
                                         :blue))
                              (setf (simple-pane-background control)
                                    (and (ldb-test (byte 1 1) mod)
                                         :red))
                              (setf (simple-pane-background meta)
                                    (and (ldb-test (byte 1 2) mod)
                                         :green))
                              (if (zerop mod)
                                  (progn
                                    (gp:clear-graphics-port itf)
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
   (shift title-pane :background nil :text "Shift" :title-position :frame)
   (meta title-pane :background nil :text "Meta" :title-position :frame)
   (control title-pane :background nil :text "Ctrl" :title-position :frame)
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
