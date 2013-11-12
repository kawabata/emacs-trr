;;; trr-graphs - (C) 1996 Yamamoto Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;; Last modified on Sun Jun 30 03:11:22 1996

;; This file is a part of TRR19, a type training package for Emacs19.
;; See the copyright notice in trr.el.base

;;(eval-when-compile
;;  ;; Shut Emacs' byte-compiler up
;;  (setq byte-compile-warnings '(redefine callargs)))

;; Variables for writing graphs
(defvar TRR:skipped-step         0 "the number of skipped steps")
					; スキップしたステップ数
(defvar TRR:list-of-eval       nil)
(defvar TRR:list-of-speed      nil)
(defvar TRR:list-of-miss       nil)
(defvar TRR:list-of-average    nil)
(defvar TRR:list-of-time       nil)
(defvar TRR:list-of-times      nil)
(defvar TRR:list-of-value      nil)

(defun TRR:display-variables-message-graph ()
  (other-window 1)
  (TRR:print-result)
  (other-window 1)
  (TRR:print-data)
  (other-window 1)
  (TRR:print-message)
  (other-window 1)
  (TRR:print-log)
  (other-window 1)
  (TRR:write-graph TRR:list-of-eval 0
		   (if TRR:japanese
		       "今回の得点グラフ"
		     "Score Graph for this play"))
  (other-window 1))


(defun TRR:write-graph (data-list skip string)
  (erase-buffer)
  (insert string "\n")
  (let ((fill-column (window-width)))
    (center-region (point-min) (point)))
  (let ((max 0)
	(min 10000)
	(rest data-list)
	(revlist nil)
	(move-count 0)
	(scale-x 1)
	(steps 0)
	;;steps
        temp graph-steps horizontal-steps scale-y)
    (if (not rest) t
      (setq steps 1)
      (setq temp (car rest))
      (setq rest (cdr rest))
      (setq max (max max temp))
      (setq min (min min temp))
      (setq revlist (cons temp revlist)))
    (while rest
      (setq steps (1+ steps))
      (setq temp (car rest))
      (setq rest (cdr rest))
      (setq max (max max temp))
      (setq min (min min temp))
      (setq revlist (cons temp revlist)))
    (setq graph-steps (/ (- (window-height) 5) 2)       ; row
	  horizontal-steps (/ (- (window-width) 8) 4)   ; column
	  fill-column (- (window-width) 4))
    (and (> steps horizontal-steps)
	 (let ((diff (- steps (* horizontal-steps 2))))
	   (setq scale-x 2)
	   (if (> diff 0)
	       (progn 
		 (while (> diff 0)
		   (setq revlist (cdr revlist))
		   (setq move-count (1+ move-count))
		   (setq diff (1- diff)))
		 (setq steps (* horizontal-steps 2))
		 (setq rest revlist)
		 (setq max 0)
		 (setq min 10000)
		 (while rest
		   (setq max (max max (car rest)))
		   (setq min (min min (car rest)))
		   (setq rest (cdr rest)))))))
    (if (> min max) (setq min 0)
      (setq min
	    (cond
	     ((< (- max min) 10) (- min (% min 10)))
	     ((< (- max min) 20) (- min (% min 20)))
	     (t (- min (% min 50))))))
    (setq scale-y (max 1
		       (if (= (% (- max min) graph-steps) 0)
					; if (- max min) is mutiple of 10
			   (/ (- max min) graph-steps)
					; then draw just in display.
			 (1+ (/ (- max min) graph-steps)))))
    ;; 1 2 3 4 5 6 8 10 12 15 20 25 30 40 50 60 70 80 90 100 120 140 160 180..
    (cond ((> scale-y 100)                                 ;; round by 20
	   (if (= (% scale-y 20) 0)
	       (setq scale-y (* (/ scale-y 20) 20))
	     (setq scale-y (+ (* (/ scale-y 20) 20) 20))))
	  ((> scale-y 30)                                  ;; round by 10
	   (if (= (% scale-y 10) 0)
	       (setq scale-y (* (/ scale-y 10) 10))
	     (setq scale-y (+ (* (/ scale-y 10) 10) 10))))
	  ((> scale-y 13)                                  ;; round by 5
	   (if (= (% scale-y 5) 0)
	       (setq scale-y (* (/ scale-y 5) 5))
	     (setq scale-y (+ (* (/ scale-y 5) 5) 5))))
	  ((> scale-y 6)                                   ;; round by 2
	   (if (= (% scale-y 2) 0)
	       (setq scale-y (* (/ scale-y 2) 2))
	     (setq scale-y (+ (* (/ scale-y 2) 2) 2)))))
    (if (< graph-steps 2)
	t
      (let ((i graph-steps))
	(while (> i 0)
	  (insert (if TRR:japanese
		      "     ┃\n"
		      "      |\n")
		  (format "%4d" (+ min (* i scale-y)))
		  (if TRR:japanese
		      " ┣\n"
		    "  +\n"))
	  (setq i (1- i)))
	(insert (if TRR:japanese
		    "     ┃\n"
		  "      |\n")
		(format "%4d" min)
		(if TRR:japanese
		    " ┗"
		  "  +"))
	(while (< i horizontal-steps)
	  (insert (if TRR:japanese
		      "━┻"
		    "---+"))
	  (setq i (1+ i)))
	(insert (format "\n   %4d" move-count))
	(setq i 1)
	(while (<= i horizontal-steps)
	  (insert (format "%4d" (+ (* i scale-x) skip move-count)))
	  (setq i (1+ i))))
      (goto-char (point-max))
      (beginning-of-line)
      (forward-char 5)
      (let ((times (/ 4 scale-x))
	    (inter (max 1 (/ scale-x 4)))
	    (templist revlist)
	    (i 1)
	    data height)
	(save-excursion
	  (while templist
	    (setq data (car templist))
	    (setq templist (cdr templist))
	    (let ((th (/ (* (- data min) 4) scale-y)))
	      (setq height (+ (/ th 2) (% th 2))))
	    (forward-char times)
	    (save-excursion
	      (or TRR:japanese
		  (forward-char))
	      (picture-move-up (1+ height))
	      (if (and (= i 1) (= times 1))
		  (progn
		    (delete-char 1)
		    (insert " ")))
	      (let ((j nil))
		(if (= height 0)
		    (progn (delete-char 1)
			   (setq j (point))
			   (insert (if TRR:japanese
				       "*"
				     "*")))
		  (setq j (point))
		  (insert (if TRR:japanese
			      "★"
			    "*")))
		(and window-system
		     ;;TRR:graph-color-name
		     j
		     (put-text-property j (point)
					;;'face TRR:top-face-name))))
					'face 'TRR:graph-face))))
	    (setq i (1+ i)))))))
  (switch-to-buffer (get-buffer (current-buffer))))


(defun TRR:show-ranking ()
  (set-buffer (get-buffer-create (TRR:display-buffer)))
  (erase-buffer)
  (insert (if TRR:japanese
	      "\
順位\tスコア\tログイン名\tstep\t総回数\t総時間\t  日付,   時間\n"
	    "\
Order\tScore\tName\t\tstep\ttimes\ttime\tdate,     hour\n"))
  (insert-file-contents TRR:score-file)
  (goto-char (point-min))
  (forward-line 1)
  ;; TRR graphs :: spaces -> TAB
  (while (re-search-forward " " nil t) (replace-match "\t"))
  (goto-char (point-min))
  (forward-line 1)
  (let ((i 1)
	(j 0)
	(self nil))
    (while (not (eobp))
      (insert (format "%d\t" i))
      (if (looking-at (format "%s\t" (user-login-name)))
	  (progn
	    (beginning-of-line)
	    (while (not (looking-at "\t")) (forward-char 1))
	    (forward-char 1)
	    (insert "> ")
	    (setq self (point))
	    (while (not (looking-at "\t")) (forward-char 1))
	    (and window-system
		 ;;TRR:self-color-name
		 (put-text-property self (point) 'face
				    ;;TRR:self-face-name))
				    'TRR:self-face))
	    (insert " <")
	    (and (< (length (user-login-name)) 4)
		 (insert "\t"))
	    (forward-char 1)
	    (if (looking-at "\t") (delete-char 1))))
      (forward-line 1)
      (setq i (1+ i)))
    (goto-char (point-min))
    (forward-line 1)
    (beginning-of-line)
    (setq j (point))
    (end-of-line)
    (and window-system
	 ;;TRR:graph-color-name
	 (/= j (point))
	 (put-text-property j (1+ (point)) 'face
			    ;;TRR:top-face-name))
			    'TRR:graph-face))
    (switch-to-buffer (TRR:display-buffer))
    (if self
	(progn
	  (goto-char self)
	  (beginning-of-line))
      (goto-char (point-min)))))


(defun TRR:get-graph-points ()
  (setq TRR:skipped-step 0)
  (setq TRR:list-of-speed nil)
  (setq TRR:list-of-miss nil)
  (setq TRR:list-of-time nil)
  (setq TRR:list-of-times nil)
  (setq TRR:list-of-value nil)
  (setq TRR:list-of-average nil)
  (with-current-buffer (get-buffer-create (TRR:record-buffer))
    (goto-char (point-min))
    (let ((curstep 1)
	  (curpoint (point))
	  curtime wc mc)
      (while (not (eobp))
	(setq wc (string-to-number
		  (buffer-substring
		   (+ curpoint 16) (+ curpoint 22))))
	(setq mc (string-to-number
		  (buffer-substring
		   (+ curpoint 23) (+ curpoint 28))))
	(setq curtime (string-to-number
		       (buffer-substring
			(+ curpoint 9) (+ curpoint 15))))
	(if (= curtime 0)
	    (setq TRR:skipped-step (1+ TRR:skipped-step))
	  (setq TRR:list-of-value
		(cons
		 (string-to-number
		  (buffer-substring
		   curpoint (+ curpoint 3)))
		 TRR:list-of-value))
	  (setq TRR:list-of-times
		(cons
		 (string-to-number
		  (buffer-substring
		   (+ curpoint 4) (+ curpoint 8)))
		 TRR:list-of-times))
	  (setq TRR:list-of-time
		(cons
		 (/ curtime 60)
		 TRR:list-of-time))
	  (setq TRR:list-of-speed
		(cons
		 (if (= curtime 0) 0 (/ (* wc 60) curtime))
		 TRR:list-of-speed))
	  (setq TRR:list-of-miss
		(cons
		 (if (= wc 0) 0 (/ (* mc 1000) wc))
		 TRR:list-of-miss))
	  (setq TRR:list-of-average
		(cons
		 (TRR:evaluate-point wc mc curtime)
		 TRR:list-of-average)))
 	(forward-line)
	(setq curpoint (point))
	(setq curstep (+ curstep 1))))))


(provide 'trr-graphs)
;;; trr-graphs.el ends here
