(DEFUN GET-CALENDAR-JSON (UT)
  (LET ((REQUEST-URL
         (KMRCL:MAKE-URL
          "full"
          :BASE-DIR "http://www.google.com/calendar/feeds/japanese@holiday.calendar.google.com/public/"
          :VARS `(("start-min" . ,(XYZZY:FORMAT-DATE-STRING "%Y-%m-%d" UT))
                  ("start-max" . ,(XYZZY:FORMAT-DATE-STRING
                                   "%Y-%m-%d"
                                   (+ UT (* 24 60 60))))
                  ("max-results" . "1")
                  ("alt" . "json-in-script")
                  ("callback" . "handleJson")))))
    (STRING-TRIM "handleJson();"
                 (#-SBCL TRIVIAL-UTF-8:UTF-8-BYTES-TO-STRING
                  #+SBCL SB-EXT:OCTETS-TO-STRING
                  (DRAKMA:HTTP-REQUEST REQUEST-URL :FORCE-BINARY 'T)))))

(DEFUN -> (LIST &REST KEYS)
  (IF (ENDP KEYS)
      LIST
      (KMRCL:AWHEN (FIND (CAR KEYS) LIST :KEY #'ZL:CAR-SAFE)
        (APPLY #'-> KMRCL:IT (CDR KEYS)))))

(DEFUN HOLIDAY-P (&OPTIONAL (UT (GET-UNIVERSAL-TIME)))
  (LET ((DAY (NTH-VALUE 6 (DECODE-UNIVERSAL-TIME UT))))
    (OR (<= 5 DAY)                      ; (sat 5) (sun 6)
        ;; google calencar
        (< 0
           (CDR
            (-> (JSON:DECODE-JSON-FROM-STRING (GET-CALENDAR-JSON UT))
                :FEED
                :OPEN-SEARCH$TOTAL-RESULTS
                :$T))))))