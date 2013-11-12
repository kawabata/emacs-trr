;;; trr-sessions - (C) 1996 Yamamoto Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;; Last modified on Sun Jun 30 03:12:17 1996

;; This file is a part of TRR19, a type training package for Emacs19.
;; See the copyright notice in trr.el.base

(eval-when-compile
  ;; Shut Emacs' byte-compiler up
  (setq byte-compile-warnings '(redefine callargs)))

;; for now, there is only one type of session is supported.
(defun TRR:get-event ()
  (let ((ev (TRR:read-event)))
    (while (listp ev)
      (message (if TRR:japanese "ずるは駄目だよう" "Don't play foul!"))
      (ding)
      (setq ev (TRR:read-event)))
    (if (integerp ev)
	(if (/= ev 12)
	    ev
	  (redraw-display)
	  (TRR:get-event))
      (cond ((eq ev 'return) ?\r)
	    ((eq ev 'tab) ?\t)
	    ((eq ev 'backspace) ?\b)
	    ((eq ev 'newline) ?\n)
	    ((eq ev 'escape) ?\e)
	    (t ?\a)))))

(defun TRR:read-event ()
  (cond
   ((fboundp 'read-event)
    (read-event))
   ((fboundp 'next-command-event)
    (let (char)
      (while (null (setq char (event-to-character
			       (next-command-event)))))
      (char-to-int char)))
   (t
    (error "no read-event"))))

(defun TRR:one-session ()
  (other-window -1)
  (TRR:write-graph TRR:list-of-eval 0
		   (if TRR:japanese
		       "今回の得点グラフ"
		     "Score Graph for this time"))
  (other-window -1)
  (TRR:print-log)
  (other-window 2)
  (if (or TRR:typist-flag TRR:small-window-flag)
      (set-window-configuration TRR:win-conf-typist))
  (erase-buffer)
  (with-current-buffer (TRR:display-buffer)
    (if (not TRR:start-flag)
	(setq TRR:start-flag t))
    (copy-to-buffer (TRR:trainer-menu-buffer)
		    (point)
		    (progn
		      (forward-line (* 3 TRR:text-lines))
		      (point))))
  (goto-char (point-min))
  (forward-line 1)
  (setq TRR:correct-char-count 0)
  (setq TRR:whole-char-count 0)
  (if (eobp) t
    (let ((inhibit-quit 't)
	  (echo-keystrokes 0)
	  (lines (/ (count-lines (point-min) (point-max)) 3))
	  (text-pos (save-excursion (forward-line -1) (point)))
	  (started nil))
      (message (if TRR:japanese "ようい!" "Ready!"))
      (setq TRR:ch (TRR:get-event))
      (message (if TRR:japanese "スタート!" "start!"))
      (setq TRR:start-time (current-time-string))
      (while (and (> lines 0)
		  (/= TRR:ch 18)   ;; if TRR:ch = ^R then restart
		  (/= TRR:ch 3))   ;; if TRR:ch = ^C then quit
	(setq TRR:whole-char-count (1+ TRR:whole-char-count))
	(if (if TRR:return-is-space ; if correct typed
		(if (= (char-after text-pos) 13)
		    (or (= TRR:ch 13)
			(= TRR:ch 32))
		  (= TRR:ch (char-after text-pos)))
	      (= TRR:ch (char-after text-pos)))
	    (progn
	      (setq TRR:correct-char-count (+ TRR:correct-char-count 1))
	      (setq text-pos (1+ text-pos))
	      (if (if TRR:return-is-space
		      (if (= (char-after (1- text-pos)) 13)
			  (and (/= TRR:ch 13)
			       (/= TRR:ch 32))
			(/= TRR:ch 13))
		    (/= TRR:ch 13))
		  (progn
		    (insert-char TRR:ch 1)
		    (and window-system
			 ;;TRR:correct-color-name
			 (put-text-property (1- (point)) (point) 'face
					    'TRR:correct-face))
		    (setq TRR:ch (TRR:get-event)))
		(insert-char 13 1)         ; cr mark
		(and window-system
		     ;;TRR:correct-color-name
		     (put-text-property (1- (point)) (point) 'face
					'TRR:correct-face))
		(setq lines (1- lines))
		(if (/= lines 0)
		    (progn (forward-line 3)
			   (setq text-pos (save-excursion
					    (forward-line -1) (point)))
			   (setq TRR:ch (TRR:get-event))))))
	  (if (= TRR:ch 10)
	      (insert " ")
	    (if (= TRR:ch 7)
		(setq quit-flag 'nil))
	    (insert-char TRR:ch 1))
	  (and TRR:ding-when-miss (ding))
	  (backward-char 1) ; if incorrect typed
	  (while (and (if TRR:return-is-space
			  (if (= (char-after text-pos) 13)
			      (and (/= TRR:ch 13)
				   (/= TRR:ch 32))
			    (/= TRR:ch (char-after text-pos)))
			(/= TRR:ch (char-after text-pos)))
		      (/= TRR:ch 18)
		      (/= TRR:ch  3))
	    (and window-system
		 ;; TRR:miss-color-name
		 (put-text-property (point) (1+ (point))
				    'face
				    'TRR:miss-face))
	    (setq TRR:ch (TRR:get-event))
	    (delete-char 1)
	    (if (= TRR:ch 10)
		(insert " ")
	      (if (= TRR:ch 7)
		  (setq quit-flag 'nil))
	      (insert-char TRR:ch 1))
	    (backward-char 1)) ; end of while
	  (picture-move-down 1)
	  (insert "^")
	  (forward-line -1)
	  (end-of-line)
	  (backward-char 1)
	  (delete-char 1)
	  (setq text-pos (1+ text-pos))
	  (if (if TRR:return-is-space
		  (if (= (char-after (1- text-pos)) 13)
		      (and (/= TRR:ch 13)
			   (/= TRR:ch 32))
		    (/= TRR:ch 13))
		(/= TRR:ch 13))
	      (if (or (= TRR:ch 3) (= TRR:ch 18))
		  (setq lines 0)
		(insert-char TRR:ch 1)        ; blink or reverse mode
		(and window-system
		     ;;TRR:miss-color-name
		     (put-text-property (1- (point))  (point)
					'face 'TRR:miss-face))
		(setq TRR:ch (TRR:get-event)))
	    (setq lines (1- lines))
	    (insert-char 13 1)             ; cr mark
	    (and window-system
		 ;;TRR:miss-color-name
		 (put-text-property (1- (point))  (point)
				    'face 'TRR:miss-face))
	    (if (/= lines 0)
		(progn (forward-line 3)
		       (setq text-pos (save-excursion
					(forward-line -1) (point)))
		       (setq TRR:ch (TRR:get-event)))))))
      ;; dummy
      (setq TRR:end-time (current-time-string))
      (recenter -2)))
  (if (or TRR:typist-flag TRR:small-window-flag)
      (set-window-configuration TRR:win-conf)))

(provide 'trr-sess)
;;; trr-sess.el ends here
