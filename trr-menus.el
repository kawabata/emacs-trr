;;; trr-menus - (C) 1996 Yamamoto Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;; Last modified on Mon Jul  1 00:10:59 1996

;; This file is a part of TRR19, a type training package for Emacs19.
;; See the copyright notice in trr.el.base

;;(eval-when-compile
;;  ;; Shut Emacs' byte-compiler up
;;  (setq byte-compile-warnings '(redefine callargs)))


;; answer getting function
(defun TRR:get-answer (string1 string2 max)
  (let ((answer (string-to-number (read-from-minibuffer string1))))
    (while (or (<= answer 0) (> answer max))
      (message string2)
      (sleep-for 1.2)
      (setq answer (string-to-number (read-from-minibuffer string1))))
    answer))

(defun TRR:select-text ()
  "Menus definition."
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (erase-buffer)
  (insert-file-contents TRR:select-text-file)
  (untabify (point-min) (point-max))
  (goto-char (point-min))
  (let ((kill-whole-line t))
    (while (not (eobp))
      (if (or (= (char-after (point)) 35) ; comment begins with #
	      (= (char-after (point)) 10))
	  (kill-line)
	(forward-line))))
  (goto-char (point-min))
  (let ((num 1) max-num)
    (while (not (eobp))
      (insert
       (format "%4d. " num))
      (while (not (= (char-after (point)) 32)) (forward-char))
      (while      (= (char-after (point)) 32)  (forward-char))
      (while (not (= (char-after (point)) 32)) (forward-char))
      (while      (= (char-after (point)) 32)  (forward-char)) ; need comment
      (while (not (= (char-after (point)) 32)) (forward-char))
      (kill-line)
      (forward-line 1)
      (setq num (1+ num)))
    (setq max-num num)
    (goto-char (point-min))
    (if TRR:japanese
	(insert (TRR:current-trr)
		"向けタイプトレーナー：\n\nテキストの選択：\n")
      (insert "TRR for " (TRR:current-trr) ": \n\nChoose a text: \n"))
    (goto-char (point-max))
    (insert (if TRR:japanese
		(concat "\n\n  何か入れて欲しい document があれば\n "
			TRR:installator
			" までお問い合わせ下さい。\n")
	      (concat "\n  If you have some document to use in TRR, consult with\n "
		      TRR:installator
		      "\n")))
    (insert (if TRR:japanese
		"\n各種の設定：\n  97. TRRの終了\n  98. 設定値の変更\n"
	      "\nSet up: \n  97. Quit TRR\n  98. Change options.\n"))
    (if (not TRR:skip-session-flag)
	(insert (if TRR:japanese
		    "  99. テキスト選択後メニュー画面に移行\n"
		  "  99. move to menu after choose a text\n"))
      (insert (if TRR:japanese
		  "\nテキスト選択後メニュー画面に移行"
		"\nmove to menu after choose a text")))
    (setq num
	  (if TRR:japanese
	      (TRR:get-answer "どれにする？ " "はっきりしなさい！" 99)
	    (TRR:get-answer "Input an integer: " "Don't hesitate!" 99)))
    (if (and (or (< num 0) (> num max-num))
	     (/= num 97)
	     (/= num 98)
	     (or TRR:skip-session-flag
		 (/= num 99)))
	(setq num (if TRR:japanese
		      (TRR:get-answer "もう一度選んで "
				      "テキストしか選べないわ"
				      max-num)
		    (TRR:get-answer "Choose again: "
				    "Text is the only way left to you!"
				    max-num))))
    (cond
     ((= num 97) (setq TRR:quit-flag t))
     ((= num 98) (TRR:change-flag) (TRR:select-text))
     ((= num 99)
      (setq TRR:skip-session-flag t)
      (TRR:select-text))
     (t
      (TRR:decide-trr-text num)
      (TRR:initiate-files)
      (TRR:initiate-variables)
      (TRR:print-log)
      (TRR:print-data)
      (bury-buffer)
      (set-window-configuration TRR:win-conf)))))


(defun TRR:change-flag (&optional loop)
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (erase-buffer)
  (let (num)
    (insert (if TRR:japanese
		(concat "\
次の中から選んで下さい。\n\
\n\
1. 初級者向けのタイプトレーナ\n\
   評価関数は（打文字数−（誤打数＊１０））＊６０／（秒数）\n\
   テキストはステップ毎に同じものを表示\n\
\n\
2. 中級者向けのタイプトレーナ（デフォールトはこれに設定される）\n\
   評価関数は（打文字数−（誤打数＊１０））＊６０／（秒数）\n\
\n\
3. 上級者向けのタイプトレーナ\n\
   評価関数は（打文字数−（誤打数＊５０））＊６０／（秒数）\n\
   １回の実行で必要なタイプ量が多い\n\
\n\
4. 秘密主義者向けのタイプトレーナ\n\
   初級者向けのタイプトレーナと同じであるが、\n\
   ハイスコアの登録を行なわない\n\
\n"
			(if TRR:return-is-space
			    "5. [toggle] 行末のリターンはスペースで代替できる\n\n"
			  "5. [toggle] 行末のリターンはリターンを押さなければならない\n\n")
			"\
6. [toggle] メッセージは日本語で表示\n\n"
			(if TRR:ding-when-miss
			    "7. [toggle] 間違えた時に ding(音を鳴らす) する\n\n"
			  "7. [toggle] 間違えた時に ding(音を鳴らす) しない\n\n")
			(if TRR:un-hyphenate
			    "8. [toggle] ハイフネートされた単語を元に戻す\n\n"
			  "8. [toggle] ハイフネーションを残したままにする\n\n")
			"9. 最初のメニューに戻る\n\n")
	      (concat "Select a number (1 - 9)\n\n\
1. TRR for Novice.\n\
The function which evaluate your score is,\n\
(key - (wrong * 10)) * 60 / time\n\
where key is the number of your key stroke,\n\
wrong is the number of your miss type, and\n\
time is the seconds that is taken your finishing typing the text.\n\
In every STEP, TRR shows the same text.\n\
\n\
2. TRR for Trainee.\n\
The function which evaluate your score is the same as Novice.\n\
This is the default level.\n\
\n\
3. TRR for Typist.\n\
The function which evaluate your score is,\n\
(key - (wrong * 50)) * 60 / time\n\
In this level you have to type much more than Trainee or Novice.\n\
\n\
4. TRR in Secret mode.\n\
same as Novice, except that your score won't be recorded\n\
in Score-file.\n\n"
(if TRR:return-is-space
    "5. If select, TRR will require that you type RET for the return code\n\
at the end of a line.\n\n"
  "5. If select, TRR will allow you to type SPC for the return code\n\
at the end of a line.\n\n")
"6. [toggle] Display messages in English\n\n"
(if TRR:ding-when-miss
    "7. Make TRR shut when miss-type\n\n"
  "7. Make TRR ding when miss-type\n\n")
(if TRR:un-hyphenate
    "8. [toggle] deny hyphenation from text\n"
    "8. [toggle] leave hyphenated words untouched\n")
    "9. Back to top menu\n\n")))
  (setq num (if TRR:japanese
                (TRR:get-answer "どれにする？ " "いったいどれにするの？" 9)
                (TRR:get-answer "which do you want to change? "
                                "Don't waver!" 9)))
  (cond
   ((= num 1)
    (setq TRR:random-flag nil)
    (setq TRR:typist-flag nil)
    (setq TRR:secret-flag nil))
   ((= num 2)
    (setq TRR:random-flag t)
    (setq TRR:typist-flag nil)
    (setq TRR:secret-flag nil))
   ((= num 3)
    (setq TRR:random-flag t)
    (setq TRR:typist-flag t)
    (setq TRR:secret-flag nil))
   ((= num 4)
    (setq TRR:random-flag nil)
    (setq TRR:typist-flag nil)
    (setq TRR:secret-flag t))
   ((= num 5)
    (setq TRR:return-is-space (not TRR:return-is-space))
    (TRR:change-flag t))
   ((= num 6)
    (TRR:finish t)
    (setq TRR:japanese (not TRR:japanese))
    (TRR:prepare-buffers)
    (TRR:change-flag t))
   ((= num 7)
    (setq TRR:ding-when-miss (not TRR:ding-when-miss))
    (TRR:change-flag t))
   ((= num 8)
    (setq TRR:un-hyphenate (not TRR:un-hyphenate))
    (TRR:change-flag t)))
  (if (or (not loop) (= num 9))
      (progn
        (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
        (let* ((height (- (window-height) 5))
	       (text-buffer-height (1+ (- (/ height 2) (% (/ height 2) 3)))))
          (if TRR:typist-flag
	      (setq TRR:text-lines (/ (1- (window-height)) 3))
            (setq TRR:text-lines (/ (1- text-buffer-height) 3))))))))


(defun TRR:select-menu ()
  (set-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (erase-buffer)
  (if TRR:japanese
      (insert "\
 1. 終了               2. 実行                3. ハイスコア\n\
 4. 平均速度グラフ     5. 平均ミス率グラフ    6. 平均得点グラフ\n\
 7. 実行時間グラフ     8. 実行回数グラフ      9. 突破点数グラフ\n\
10. 過去の成績        11. テキストの変更     12. 設定の変更")
    (insert "\
 1. Quit	       2. Execute again	       3. High Scores\n\
 4. Typing Speed Graph 5. Freq. of Typo Graph  6. Score Graph\n\
 7. Time Graph	       8. Num. of Trial Graph  9. Breaking Score Graph\n\
10. Past results      11. Choose another text 12. Change options"))
  (let ((num (if TRR:japanese
		 (TRR:get-answer "どうするの？ " "はっきりしなさい！" 12)
	       (TRR:get-answer "What do you want to do? "
			       "Commit yourself!" 12))))
    (cond
     ((= num 1) (setq TRR:quit-flag t) nil)
     ((= num 2) 
      (TRR:read-file) ;  Read next text
      t)
     ((= num 3)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:show-ranking)
      (TRR:select-menu))
     ((= num 4)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-speed TRR:skipped-step
		       (concat (if TRR:japanese
				   "ステップ−平均スピード（文字／分）グラフ"
				 "STEP <-> SPEED(type / minute) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 5)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-miss TRR:skipped-step
		       (concat (if TRR:japanese
				   "ステップ−平均ミス率（/1000）グラフ"
				 "STEP <-> avg.Miss-ratio(/1000) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 6)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-average TRR:skipped-step
		       (concat (if TRR:japanese
				   "ステップ−平均得点グラフ"
				 "STEP <-> avg.SCORE Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 7)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-time TRR:skipped-step
		       (concat (if TRR:japanese
				   "ステップ−実行時間（分）グラフ"
				 "STEP <-> TIME(min) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 8)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-times TRR:skipped-step
		       (concat (if TRR:japanese
				   "ステップ−実行回数グラフ"
				 "STEP <-> times (the number of execution of TRR) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 9)
      (set-window-configuration TRR:win-conf-display)
      (set-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-value TRR:skipped-step
		       (concat (if TRR:japanese
				   "ステップ−突破点数グラフ"
				 "STEP <-> ACHIEVEMENT_SCORE Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 10)
      (set-window-configuration TRR:win-conf-display)
      (set-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:print-log-for-display)
      (TRR:select-menu))
     ((= num 11)
      (TRR:save-file (TRR:record-buffer) TRR:record-file)
      (TRR:kill-file TRR:record-file)
      (TRR:kill-file TRR:score-file)
      (TRR:kill-file TRR:record-file)
      (or (zerop (length TRR:text-file-buffer))
	  (kill-buffer TRR:text-file-buffer))
      (TRR:select-text)
      (not TRR:quit-flag))
     ((= num 12)
      (TRR:save-file (TRR:record-buffer) TRR:record-file)
      (TRR:kill-file TRR:record-file)
      (TRR:kill-file TRR:score-file)
      (TRR:kill-file TRR:record-file)
      (or (zerop (length TRR:text-file-buffer))
	  (kill-buffer TRR:text-file-buffer))
      (TRR:change-flag)
      (TRR:select-text)
      (not TRR:quit-flag))
     )))


(provide 'trr-menus)
;;; trr-menus.el ends here
