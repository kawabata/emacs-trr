;;; trr.el --- a type-writing training program on GNU Emacs.
;;; Copyright (C) 1996 YAMAMOTO Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;; Last modified on Mon Jul  1 09:02:54 1996

;; Author: YAMAMOTO Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;	KATO Kenji <kato@suri.co.jp>
;;		*Original Author
;;	INAMURA You <inamura@icot.or.jp>
;;		*Original Author
;; Maintainer: YAMAMOTO Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;; Created: 1 July 1996
;; Version: 1.0 beta5
;; Keywords: games faces

;;; Commentary:

;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; this software, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with this software so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.

;;(eval-when-compile
;;  ;; Shut Emacs' byte-compiler up
;;  (setq byte-compile-warnings '(redefine callargs)))

;;; Code:
;; Site Constaints.
;; consider to modify Makefile instead of this file.

;;(defconst TRR:default-directory "/var/lib/trr22"
;;  "*Default directory for TRR elc files.")

;;(defconst TRR:default-bin-directory "/usr/share/emacs/site-lisp/trr22"
;;  "*Default directory for TRR binary files.")

;;(defconst TRR:default-japanese t
;;  "* if t, TRR displays its messages in Japanese by default.")

(defconst TRR:installator "shuji.narazaki@gmail.com"
  "instllators name or e-mail address")

;; User Customizable Variables.

(defgroup TRR nil
  "Play a game of TRR."
  :prefix "TRR:"
  :group 'games)

(defface TRR:text-face '((((background dark)) (:foreground "LightBlue"))
                            (t (:foreground "blue")))
  "Color name for text characters. If nil, coloring not support." :group 'TRR)

(defface TRR:correct-face '((((background dark)) (:foreground "RoyalBlue"))
                            (t (:foreground "RoyalBlue")))
  "Color name for correct typed character. If nil, coloring not support." :group 'TRR)

(defface TRR:miss-face '((((background dark)) (:foreground "red"))
                        (t (:foreground "red")))
  "Color name for correct typed character. If nil, coloring not support." :group 'TRR)

(defface TRR:graph-face '((((background dark)) (:foreground "blue"))
                        (t (:foreground "blue")))
  "Color name for the stars in Graph. If nil, coloring not support." :group 'TRR)

(defface TRR:self-face '((((background dark)) (:foreground "aquamarine"))
                        (t (:foreground "aquamarine")))
  "Color name for highlighting the name of yourself.\
If nil, coloring not support." :group 'TRR)

(defcustom TRR:un-hyphenate t "Whether deny hyphnenations."
  :type 'boolean :group 'TRR)		; ハイフネーションを消すかどうか

(defcustom TRR:return-is-space nil "Whether return & space is equal."
  :type 'boolean :group 'TRR)		; リターンをスペースで代用するかどうか

(defcustom TRR:ding-when-miss t "Whether enabled to `ding' when miss type."
  :type 'boolean :group 'TRR)		; 間違えた時に ding するかどうか

(defcustom TRR:japanese t "If t, TRR talk to you in Japanese."
  :type 'boolean :group 'TRR)		; TRRのメッセージを日本語にするかどうか

;; Hooks
(defvar TRR:load-hook nil
  "*This hook is run only when TRR files are loaded.")
(defvar TRR:start-hook nil
  "*This hook is run everytime TRR start.")
(defvar TRR:end-hook nil
  "*This hook is run when TRR is finished.")

;; TRR flags
(defvar TRR:start-flag nil "whether TRR is running")
					; TRRが始まっているかどうか
(defvar TRR:quit-flag nil "whether TRR will be finished")
					; TRRを終了させるかどうか
(defvar TRR:update-flag nil "whether the record is broken")
					; 記録更新したかどうか
(defvar TRR:pass-flag nil "whether current-step is passed")
					; ステップをパスしたかどうか
(defvar TRR:cheat-flag nil "whether TRR text is too easy")
					; いんちきしたかどうか
(defvar TRR:beginner-flag nil "whether this play is the first time")
					; 初めてTRRをしたかどうか
(defvar TRR:random-flag t "whether TRR choose the position in file at random")
					; 文書の位置をランダムに選ぶかどうか
(defvar TRR:secret-flag t "whether the record will be updated")
					; updateしないかどうか
(defvar TRR:typist-flag t "whether you are Typist")
					; タイピストを目指すかどうか
(defvar TRR:small-window-flag nil "whether the frame is too narrow")
					; ウィンドウが小さいかどうか
(defvar TRR:skip-session-flag nil "whether TRR skip session")
					; セッションを実行しないかどうか

;; face support
;;(if TRR:text-color-name
;;    (progn
;;      (defconst TRR:text-face-name (intern TRR:text-color-name))
;;      (make-face TRR:text-face-name)
;;      (set-face-foreground TRR:text-face-name TRR:text-color-name)))
;;(if TRR:correct-color-name
;;    (progn
;;      (defconst TRR:correct-face-name (intern TRR:correct-color-name))
;;      (make-face TRR:correct-face-name)
;;      (set-face-foreground TRR:correct-face-name TRR:correct-color-name)))
;;(if TRR:miss-color-name
;;    (progn
;;      (defconst TRR:miss-face-name (intern TRR:miss-color-name))
;;      (make-face TRR:miss-face-name)
;;      (set-face-foreground TRR:miss-face-name TRR:miss-color-name)))
;;(if TRR:graph-color-name
;;    (progn
;;      (defconst TRR:top-face-name (intern TRR:graph-color-name))
;;      (make-face TRR:top-face-name)
;;      (set-face-foreground TRR:top-face-name TRR:graph-color-name)))
;;(if TRR:self-color-name
;;    (progn
;;      (defconst TRR:self-face-name (intern (concat TRR:self-color-name
;;                                               "-back")))
;;      (make-face TRR:self-face-name)
;;      (set-face-background TRR:self-face-name TRR:self-color-name)))

;; Buffer names
(defun TRR:trainer-menu-buffer ()
  (if TRR:japanese "タイプ＆メニュー" "Type & Menu"))
(defun TRR:result-buffer ()
  (if TRR:japanese "-----結果-----" "----Result----"))
(defun TRR:data-buffer ()
  (if TRR:japanese "成績表示" "Display Record"))
(defun TRR:message-buffer ()
  (if TRR:japanese "メッセージ" "TRR Message"))
(defun TRR:log-buffer ()
  (if TRR:japanese "過去の成績" "Past Records"))
(defun TRR:graph-buffer ()
  (if TRR:japanese "グラフ" "Display Graph"))
(defun TRR:record-buffer ()
  (if TRR:japanese "実行記録!!" "Result!!"))
(defun TRR:display-buffer ()
  (if TRR:japanese "各種表示" "TRR Display"))
(defvar TRR:text-file-buffer "")

;; Window Configuration
(defvar TRR:prev-win-conf    nil)
(defvar TRR:win-conf         nil)
(defvar TRR:win-conf-typist  nil)
(defvar TRR:win-conf-display nil)

;; Variables for Session
(defvar TRR:eval               -1 "Score")
					; 今回出した点数
(defvar TRR:whole-char-count   0 "the number of characters of the text")
					; テキストの文字数
(defvar TRR:correct-char-count 0 "the number of correct typed characters")
					; 正しく入力した文字数
(defvar TRR:start-time         0 "start time for a session")
					; TRR(1 session)を初めた時間
(defvar TRR:end-time           0 "end time for a session")
					; TRR(1 session)を終えた時間
(defvar TRR:miss-type-ratio    0 "miss type ratio")
					; ミス率 (/1000)
(defvar TRR:type-speed         0 "the number of characters typed per minute")
					;タイピング速度（文字数／分）
(defvar TRR:ch                 0)

;; Variables for STEP
(defvar TRR:steps                       0 "current step")
					; 現在のステップ
(defvar TRR:times-of-current-step       0
  "total times of the execution of TRR in this step")
					; このステップでの実行回数
(defvar TRR:time-of-current-step        0
  "total time of the execution of TRR in this step")
					; このステップでの実行時間
(defvar TRR:whole-chars-of-current-step 0 "the number of typing in this step")
					; このステップでのタイプ回数
(defvar TRR:whole-miss-of-current-step  0
   "the number of miss typing in this step")
					; このステップでのミスタイプ回数
(defvar TRR:times-for-message                  0 "used in trr-message.el")
					; trr-message.elで使用する

;; other variables
(defvar TRR:directory
  (file-name-directory (or byte-compile-current-file
                           load-file-name
                           buffer-file-name)))
  ;;(let ((drt (or (getenv "TRRDIR") TRR:default-directory)))
  ;;  (while (string= "/" (substring drt (1- (length drt)) (length drt)))
  ;;    (setq drt (substring drt 0 (1- (length drt)))))
  ;;  (concat drt "/")))

;; (defvar TRR:bin-directory
;;   (let ((drt (or (getenv "TRRBINDIR") TRR:default-bin-directory)))
;;     (while (string= "/" (substring drt (1- (length drt)) (length drt)))
;;       (setq drt (substring drt 0 (1- (length drt)))))
;;     (concat drt "/")))

(defvar TRR:number-of-text-lines 0 "(the number of lines in text) - 18")
					; テキストの行数 - 18
(defvar TRR:text-lines           0
   "the number of lines which should be displayed") ; 表示すべきテキストの行数
(defvar TRR:total-times          0 "times of execution of TRR")
					; 今までの実行回数
(defvar TRR:total-time           0 "total time of execution of TRR")
					; 今までの実行時間
(defvar TRR:high-score           -1 "User's High Score")
					; 今回までの最高得点
(defvar TRR:high-score-old       -1  "User's previous High Score")
					; 前回までの最高得点
(defvar TRR:elapsed-time         0)
(defvar TRR:debug		 nil)

;; other functions
(defun TRR:history-of-trr ()
  (if TRR:japanese
      " Original(Pascal&C) -- 守山 貢\n\
 Original Author -- 加藤研児\n\
 Rewritten by -- 山本泰宇 \n\
 TRR Emacs19 Ver.1.1 Apr. 1996"
    " Original(Pascal&C) -- Moriyama Mitugu\n\
 Original Author -- Katou Kenji\n\
 Rewritten by -- Yamamoto Hirotaka\n\
 TRR Emacs19 Ver.1.1 Apr. 1996"))
(defun TRR:current-trr ()
  (cond
   (TRR:typist-flag (if TRR:japanese "上級者" "Typist"))
   (TRR:secret-flag (if TRR:japanese "秘密主義者" "Sealed"))
   (TRR:random-flag (if TRR:japanese "中級者" "Trainee"))
   (t               (if TRR:japanese "初級者" "Novice"))))
(defun TRR:random-num ()
  (let (num
	(num1 (random))
	(num2 (random t)))
    (if (> num1 0) t
      (setq num1 (- num1)))
    (if (> num2 0) t
      (setq num2 (- num2)))
    (setq num (+ (/ num1 2) (/ num2 2)))
    (% num TRR:number-of-text-lines)))


;; files used by TRR
;;(defvar TRR:update-program (expand-file-name "trr_update" TRR:bin-directory))
(defvar TRR:update-program (expand-file-name "update-game-score" exec-directory))
;;(defvar TRR:format-program (expand-file-name "trr_format" TRR:bin-directory))
(defvar TRR:select-text-file (expand-file-name "CONTENTS" TRR:directory))

;;; load files
(require 'picture)
(require 'trr-mesg)
(require 'trr-files)
(require 'trr-menus)
(require 'trr-graphs)
(require 'trr-sess)
(run-hooks 'TRR:load-hook)

;;; Scoring function
;;; (number_of_type-(number_of_typo*10))*60/seconds  regular
;;; (number_of_type-(number_of_typo*50))*60/seconds  for Typist
(defun TRR:evaluate-point (whole miss time)
  (if TRR:typist-flag
      (max 0 (if (= time 0) 0 (/ (* (- whole (* miss 50)) 60) time)))
    (max 0 (if (= time 0) 0 (/ (* (- whole (* miss 10)) 60) time)))))

(defun trr ()
  "Start TRR."
  (interactive)
  (or TRR:prev-win-conf
      (setq TRR:prev-win-conf (current-window-configuration)))
  (setq TRR:skip-session-flag nil)
  (delete-other-windows)
  (if (or (< (window-height) 20) (< (window-width) 60))
      (message (if TRR:japanese
		   "ウィンドウが小さすぎるわ。"
		 "Too narrow to execute TRR!"))
    (unwind-protect
	(progn
	  (TRR:start)
	  (setq TRR:ch 0)
	  (while (TRR:play-p)
	    (set-window-configuration TRR:win-conf)
	    (if TRR:skip-session-flag
		(progn
		  (setq TRR:start-flag t)
		  (setq TRR:skip-session-flag nil)
		  (set-window-configuration TRR:win-conf-display)
		  (set-buffer (get-buffer-create (TRR:display-buffer)))
		  (TRR:print-log-for-display))
	      (TRR:one-session)
	      (if (= TRR:ch 3)              ; interrupt!
		  (setq TRR:quit-flag t)
		(if (= TRR:ch 18)           ; restart!
		    (progn
		      (TRR:finish t)
		      (trr))
		  (TRR:update-variables)
		  (TRR:display-variables-message-graph)
		  (if (and TRR:update-flag (not TRR:secret-flag))
		      (TRR:update-score-file TRR:eval))
		  (widen))))))
      (TRR:finish))))


(defun TRR:start ()
  (message (if TRR:japanese "ちょっと待って..." "Wait a moment!"))
  (setq TRR:secret-flag nil)
  (setq TRR:random-flag t)
  (setq TRR:typist-flag nil)
  (setq TRR:start-flag nil)
  (setq TRR:quit-flag nil)
  (TRR:prepare-buffers)
  (picture-move-down 1)
  (picture-move-up 1)
  (run-hooks 'TRR:start-hook))


(defun TRR:play-p ()
  (and (not TRR:quit-flag)
       (if (not TRR:start-flag) ; if TRR have not started
	   (progn (TRR:select-text) ; then let player select text
		  (not TRR:quit-flag))
	 (TRR:select-menu) ; if started, let player select menu
	 (not TRR:quit-flag))))


(defun TRR:prepare-buffers ()
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (setq mode-line-format "   %b")
  (force-mode-line-update)
  (split-window (get-buffer-window (current-buffer)) 5) ; create 4 lines buffer
  (other-window 1)
  (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
  (setq mode-line-format "   %b")
  (force-mode-line-update)
  (setq TRR:win-conf-display (current-window-configuration)) ; 4 lines + others
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (setq TRR:win-conf-typist (current-window-configuration)) ; full screen
  (let* ((height (- (window-height) 5))
	 (text-buffer-height (1+ (- (/ height 2) (% (/ height 2) 3)))))
    (if TRR:typist-flag
	(setq TRR:text-lines (/ (1- (window-height)) 3)); 1 line + 2 null lines
      (setq TRR:text-lines (/ (1- text-buffer-height) 3))
      (if (< TRR:text-lines 3)
	  (progn
	    (setq TRR:small-window-flag t)
	    (setq TRR:text-lines (/ (1- (window-height)) 3)))
	(setq TRR:small-window-flag nil)))
    (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
    (split-window (get-buffer-window (current-buffer))
		  text-buffer-height)
    (set-buffer (get-buffer-create (TRR:result-buffer)))
    (setq truncate-lines t)
    (setq mode-line-format "   %b")
    (force-mode-line-update)
    (erase-buffer)
    (TRR:print-first-message-as-result)
    (switch-to-buffer-other-window (TRR:result-buffer))
    (split-window (get-buffer-window (current-buffer)) 5)
    (split-window-horizontally 24)
    (other-window 1)
    (switch-to-buffer (get-buffer-create (TRR:data-buffer)))
    (setq truncate-lines t)
    (setq mode-line-format "   %b")
    (force-mode-line-update)
    (TRR:print-data)
    (split-window-horizontally 20)
    (other-window 1)
    (switch-to-buffer (get-buffer-create (TRR:message-buffer)))
    (setq mode-line-format "   %b")
    (force-mode-line-update)
    (delete-region (point-min) (point-max))
    (insert (TRR:history-of-trr))
    (other-window 1)
    (switch-to-buffer (get-buffer-create (TRR:log-buffer)))
    (setq truncate-lines t)
    (setq mode-line-format "   %b")
    (force-mode-line-update)
    (split-window-horizontally 32)
    (TRR:print-log)
    (other-window 1)
    (switch-to-buffer (get-buffer-create (TRR:graph-buffer)))
    (setq mode-line-format "   %b")
    (force-mode-line-update)
    (TRR:write-graph TRR:list-of-eval 0
		     (if TRR:japanese
			 "今回の得点グラフ"
		       "Score Graph for this time"))
    (recenter -1) ; move point to the last line of the graph-buffer
    (other-window 1)
    (setq TRR:win-conf (current-window-configuration))))


(defun TRR:print-data ()
  (save-excursion
    (switch-to-buffer (get-buffer-create (TRR:data-buffer)))
    (erase-buffer)
    (insert
     (format (if TRR:japanese
		 "\
 ステップ：%5d\n\
  目  標 ：%5d点\n\
 最高記録：%5d点\n\
  trr回数：%5d回"
	       "\
  STEP  : %5d\n\
 Target : %5dpt.\n\
  High  : %5dpt.\n\
  TIMES : %5d")
	     (1+ TRR:steps)
	     (* (1+ TRR:steps) 10)
	     (if (< TRR:high-score 0) 0 TRR:high-score)
	     TRR:total-times))))


(defun TRR:print-log ()
  (save-excursion
    (switch-to-buffer (get-buffer-create (TRR:log-buffer)))
    (erase-buffer)
    (let (curstep       curtimes                curtime
       ;; current step  exec.times by each step total time by each step
	  wc          mc         curdate     curmiss curspeed curpoint)
       ;; whole count miss count update date
      (switch-to-buffer (get-buffer-create (TRR:record-buffer)))
      (goto-char (point-min))
      (setq curstep 1)
      (while (not (eobp)) ; if point is not at the end of the buffer
	(setq curpoint (point))
	(setq curtimes (string-to-number
			   (buffer-substring
			    (+ curpoint 4) (+ curpoint  8))))
	(setq curtime (string-to-number
			  (buffer-substring
			   (+ curpoint 9) (+ curpoint 15))))
	(setq wc (string-to-number
			  (buffer-substring
			   (+ curpoint 16) (+ curpoint 22))))
	(setq mc (string-to-number
			  (buffer-substring
			   (+ curpoint 23) (+ curpoint 28))))
	(setq curmiss
	      (if (= wc 0) 0 (/ (* mc 1000) wc)))
	(setq curspeed
	      (if (= curtime 0) 0 (/ (* wc 60) curtime)))
	(let (j)
	  (save-excursion
	    (end-of-line)
	    (setq j (point)))
	  (setq curdate (buffer-substring (+ curpoint 29) j)))
	(forward-line) ; this causes no error if there's no line.
	(switch-to-buffer (get-buffer-create (TRR:log-buffer)))
	(if (not (= wc 0))
	    (insert (format "%2d:%4d%4d%5d%4d %s\n"
			    curstep
			    curtimes
			    (/ curtime 60)
			    curspeed
			    curmiss
			    curdate)))
	(setq curstep (+ curstep 1))
	(switch-to-buffer (get-buffer-create (TRR:record-buffer)))))
      (switch-to-buffer (get-buffer-create (TRR:log-buffer)))
      (forward-line (- 3 (window-height))) ; if lines flood
      (delete-region (point-min) (point)) ; then delete heading records
      (if TRR:japanese
	  (insert (TRR:current-trr) "向けタイプトレーナ\n")
	(insert "TRR for " (TRR:current-trr) "\n"))
      (if TRR:japanese
	  (insert "step 回  分   速  率   突破日\n")
	(insert "step tms min spd rate date\n"))))


(defun TRR:print-log-for-display ()
  (save-excursion
    (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
    (erase-buffer)
    (let (curstep curtimes curtime curpoint passpoint
		  avepoint curmiss curspeed wc mc curdate)
      (switch-to-buffer (get-buffer-create (TRR:record-buffer)))
      (goto-char (point-min))
      (setq curstep 1)
      (while (not (eobp))
	(setq curpoint (point))
	(setq passpoint (string-to-number
			   (buffer-substring
			    curpoint (+ curpoint 3))))
	(setq curtimes (string-to-number
			   (buffer-substring
			    (+ curpoint 4) (+ curpoint  8))))
	(setq curtime (string-to-number
			  (buffer-substring
			   (+ curpoint 9) (+ curpoint 15))))
	(setq wc (string-to-number
			  (buffer-substring
			   (+ curpoint 16) (+ curpoint 22))))
	(setq mc (string-to-number
			  (buffer-substring
			   (+ curpoint 23) (+ curpoint 28))))
	(setq curmiss
	      (if (= wc 0) 0 (/ (* mc 1000) wc)))
	(setq curspeed
	      (if (= curtime 0) 0 (/ (* wc 60) curtime)))
	(setq avepoint (if (= curtime 0) 0
			 (TRR:evaluate-point wc mc curtime)))
	(let (j)
	  (save-excursion
	    (end-of-line)
	    (setq j (point)))
	  (setq curdate (buffer-substring (+ curpoint 29) j)))
	(forward-line)
	(switch-to-buffer (get-buffer-create (TRR:display-buffer)))
	(if (not (= wc 0))
	    (insert (format (if TRR:japanese
				"\
 %2d:  %3d回  %3d分  %4d字/分  %3d.%d%%  %4d点   %s   %4d\n"
			      "\
 %2d:  %3dtms %3dmin %4dtyp/mn %3d.%d%%      %4dpts. %s   %4d\n")
			    curstep
			    curtimes
			    (/ curtime 60)
			    curspeed
			    (/ curmiss 10)
			    (% curmiss 10)
			    avepoint
			    curdate
			    passpoint)))
	(setq curstep (+ curstep 1))
	(switch-to-buffer (get-buffer-create (TRR:record-buffer)))))
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (forward-line (- 6 (window-height))) ; if lines flood
      (delete-region (point-min) (point)) ; then delete lines.
      (insert
       (format (if TRR:japanese
		   "\
最高記録：%d点,   総実行回数：%d回,   総実行時間：%d分\n"
		 "\
HighScore: %dpts, total times: %dtimes, total time: %dmin\n")
	       (if (< TRR:high-score 0) 0 TRR:high-score)
	       TRR:total-times
	       (/ TRR:total-time 60)))
      (and window-system
	   TRR:graph-color-name
	   (put-text-property (point-min) (point) 'face
			      TRR:top-face-name))
      (if TRR:japanese
	  (insert (concat (TRR:current-trr)
			  "用での "
			  TRR:text-name
			  " の記録だよ\n\n\
step   実行   実行     平均     平均     平均     突破日   突破\n\
       回数   時間   入力速度  ミス率    得点              得点\n\
---------------------------------------------------------------\n"))
	(insert (concat "TRR for "
			(TRR:current-trr)
			" with "
			TRR:text-name
			"\n\n\
step   times  minutes  speed  miss-ratio avg-score date  the Score\n\
------------------------------------------------------------------\n")))))


(defun TRR:print-result ()
  (erase-buffer)
  (insert
   (format (if TRR:japanese
	       "\
 所要時間：%4d 秒\n\
  ミス率 ：%2d.%1d %%\n\
 字数／分：%4d\n\
  評  価 ：%4d %s"
	     "\
  Time   : %4d seconds\n\
miss rate: %2d.%1d %%\n\
speed    : %4d\n\
  Score  : %4d %s")
	   TRR:elapsed-time
	   (/ TRR:miss-type-ratio 10)
	   (% TRR:miss-type-ratio 10)
	   TRR:type-speed
	   TRR:eval
	   (if TRR:pass-flag " Pass" "Retry")))
  (goto-char (point-min)))


(defun TRR:finish (&optional fl)
  (TRR:kill-buffer (TRR:trainer-menu-buffer))
  (TRR:kill-buffer (TRR:result-buffer))
  (TRR:kill-buffer (TRR:graph-buffer))
  (TRR:kill-buffer (TRR:message-buffer))
  (TRR:kill-buffer (TRR:data-buffer))
  (TRR:kill-buffer (TRR:log-buffer))
  (TRR:kill-buffer (TRR:display-buffer))
  (TRR:save-file (TRR:record-buffer) TRR:record-file)
  (TRR:kill-file TRR:record-file)
  (TRR:kill-file TRR:score-file)
  (TRR:kill-buffer (TRR:record-buffer))
  (TRR:kill-file TRR:record-file)
  (or (zerop (length TRR:text-file-buffer))
      (kill-buffer (get-buffer-create TRR:text-file-buffer)))
  (and TRR:prev-win-conf
       (set-window-configuration TRR:prev-win-conf))
  (or fl
      (progn
	(setq TRR:prev-win-conf nil)
	(run-hooks 'TRR:end-hook)
	(message (if TRR:japanese "また会う日まで...." "See you later...")))))


(defun TRR:kill-buffer (buffer)
  (let ((tb (get-buffer buffer)))
    (if tb (kill-buffer tb))))


(defun TRR:cheat-p ()
  (setq TRR:cheat-flag
	(or
	 (if TRR:typist-flag
	     (< TRR:whole-char-count 520)
	   (< TRR:whole-char-count 270))
	 (> TRR:eval 750))))


(defun TRR:update-variables ()
  (setq TRR:quit-flag nil)
  (let ((started-from (TRR:convert-time-string-to-second TRR:start-time))
	(ended-at (TRR:convert-time-string-to-second TRR:end-time)))
    (setq TRR:elapsed-time (- ended-at started-from))
    (if (< ended-at started-from)
	(setq TRR:elapsed-time (+ TRR:elapsed-time 86400))))
  (setq TRR:eval
	(TRR:evaluate-point TRR:whole-char-count
			    (- TRR:whole-char-count TRR:correct-char-count)
			    TRR:elapsed-time))
  (setq TRR:list-of-eval (cons TRR:eval TRR:list-of-eval))
  (setq TRR:pass-flag
	(and (>= TRR:eval (* 10 (1+ TRR:steps)))
	     (not (TRR:cheat-p))))
  (setq TRR:update-flag
        (and (or (> TRR:eval TRR:high-score)
        	 (< TRR:high-score-old 0))
  	     (not (TRR:cheat-p))))
  ;; (setq TRR:update-flag t) ; for debugging
  (setq TRR:beginner-flag (< TRR:high-score-old 0))
  (if TRR:cheat-flag nil
    (setq TRR:total-time (+ TRR:total-time TRR:elapsed-time))
    (setq TRR:total-times (1+ TRR:total-times))
    (setq TRR:time-of-current-step
	  (+ TRR:time-of-current-step TRR:elapsed-time))
    (setq TRR:times-of-current-step (1+ TRR:times-of-current-step))
    (setq TRR:whole-chars-of-current-step
	  (+ TRR:whole-char-count TRR:whole-chars-of-current-step))
    (setq TRR:whole-miss-of-current-step
	  (+ (- TRR:whole-char-count TRR:correct-char-count)
	     TRR:whole-miss-of-current-step)))
  (or TRR:cheat-flag (TRR:write-current-data))
  (if TRR:pass-flag
      (progn
	(setq TRR:times-for-message TRR:times-of-current-step)
	(setq TRR:time-of-current-step 0)
	(setq TRR:times-of-current-step 0)
	(setq TRR:whole-chars-of-current-step 0)
	(setq TRR:whole-miss-of-current-step 0)
	(if TRR:beginner-flag
	    (setq TRR:steps (/ TRR:eval 10))
	  (setq TRR:steps (1+ TRR:steps)))))
  (if TRR:update-flag
      (progn
	(setq TRR:high-score-old TRR:high-score)
	(setq TRR:high-score TRR:eval)))
  (and (< TRR:high-score-old 0)
       (not TRR:cheat-flag)
       (setq TRR:high-score-old TRR:eval))
  (let (diff)
    (setq diff (- TRR:whole-char-count TRR:correct-char-count))
    (setq TRR:miss-type-ratio (/ (* 1000 diff) TRR:whole-char-count)))
  (setq TRR:type-speed (/ (* TRR:whole-char-count 60) TRR:elapsed-time)))


(defun TRR:write-current-data ()
  (with-current-buffer (get-buffer-create (TRR:record-buffer))
    (if TRR:beginner-flag
	(let ((count (/ TRR:eval 10)))
	  (erase-buffer)
	  (while (> count 0)
	    (if TRR:japanese
		(insert "  0    0      0      0     0 ふぁいと!\n")
	      (insert "  0    0      0      0     0 cheers!  \n"))
	    (setq count (1- count)))))
    (goto-char (point-max))
    (forward-line -1)
    (delete-region (point) (point-max))
    (insert (format "%3d %4d %6d %6d %5d %s\n"
		    TRR:eval
		    TRR:times-of-current-step
		    TRR:time-of-current-step
		    TRR:whole-chars-of-current-step
		    TRR:whole-miss-of-current-step
		    (TRR:get-date)))
    (if TRR:pass-flag ; if current step is passed, new entry should be added.
	(if TRR:japanese
	    (insert "  0    0      0      0     0 ふぁいと!\n")
	  (insert "  0    0      0      0     0 cheers!  \n")))))


(defun TRR:initiate-variables ()
  (setq TRR:total-times 0)
  (setq TRR:total-time  0)
  (setq TRR:times-of-current-step 0)
  (setq TRR:time-of-current-step  0)
  (setq TRR:whole-chars-of-current-step 0)
  (setq TRR:whole-miss-of-current-step 0)
  (set-buffer (get-buffer-create TRR:text-file-buffer))
  (setq TRR:number-of-text-lines (- (count-lines (point-min) (point-max)) 18))
  (set-buffer (get-buffer-create (TRR:display-buffer)))
  (erase-buffer)
  (TRR:read-file)
  (setq TRR:high-score (TRR:get-high-score))
  (setq TRR:high-score-old TRR:high-score)
  (setq TRR:beginner-flag (< TRR:high-score-old 0))
  (set-buffer (get-buffer-create (TRR:record-buffer)))
  (setq TRR:steps (1- (count-lines (point-min) (point-max))))
  (goto-char (point-min))
  (while (not (eobp))
    (setq TRR:times-of-current-step
	     (string-to-number
	      (buffer-substring (+ (point) 4) (+ (point) 8))))
    (setq TRR:total-times
	  (+ TRR:total-times TRR:times-of-current-step))
    (setq TRR:time-of-current-step
	     (string-to-number
	      (buffer-substring (+ (point) 9) (+ (point) 15))))
    (setq TRR:total-time
	  (+ TRR:total-time TRR:time-of-current-step))
    (setq TRR:whole-chars-of-current-step
	     (string-to-number
	      (buffer-substring (+ (point) 16) (+ (point) 22))))
    (setq TRR:whole-miss-of-current-step
	     (string-to-number
	      (buffer-substring (+ (point) 23) (+ (point) 28))))
    (forward-line)))


(defun TRR:get-date ()
  (if (not TRR:pass-flag) ; in not passed
      (if TRR:japanese
	  "ふぁいと!"
	"cheers!  ")
    (let ((in-string (current-time-string))
	  (out-string nil))
      (setq out-string (concat out-string (substring in-string 22 24))); year
      (setq out-string (concat out-string "/"))
      (setq out-string (concat out-string (substring in-string 4 7))); month
      (setq out-string (concat out-string "/"))
      (if (= (string-to-char (substring in-string 8 10)) 32)
	  (setq out-string (concat out-string (substring in-string 9 10) " "))
	(setq out-string (concat out-string (substring in-string 8 10)))))))

(defun TRR:convert-time-string-to-second (st)
  (let ((hr (string-to-number (substring st 11 13))) ; hour
	(min (string-to-number (substring st 14 16))) ; minute
	(sec (string-to-number (substring st 17 19)))) ; second
    (+ sec (* 60 (+ min (* 60 hr))))))

(provide 'trr)
;;; trr.el ends here
