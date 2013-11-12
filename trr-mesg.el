;;; trr-message.el - (C) 1996 Yamamoto Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;; Last modified on Sun Jun 30 03:11:31 1996

;; This file is a part of TRR19, a type training package for Emacs19.
;; See the copyright notice in trr.el.base

(eval-when-compile
  ;; Shut Emacs' byte-compiler up
  (setq byte-compile-warnings '(redefine callargs)))

;; メッセージは以下の変数の値によって決められる。
;; 暇な人が現れてもっと適切なメッセージ体系を構築してくれることを望む。
;; TRR decide its messages according to the following variables.
;; I hope you build more proper messaging system.

;; TRR:beginner-flag         初めて TRR をしたかどうか
;;			     whether this is the first play or not
;; TRR:random-flag           テキストがランダムかどうか
;;			     whether random selecting is enabled or not
;; TRR:update-flag           記録更新したかどうか
;;			     whether there's necessity of updating high scores
;; TRR:pass-flag             ステップをパスしたかどうか
;;			     whether the player achieved the mark point
;; TRR:secret-flag           秘密主義者かどうか
;;			     whether TRR won't record the player's score or not
;; TRR:cheat-flag            何らかの疑わしき行為をしたかどうか
;;			     whether there's something doubtful or not
;; TRR:typist-flag           タイピストを目指すかどうか
;;			     whether TRR runs in typist mode or not
;; TRR:steps                 現在のステップ
;;			     the player's current step
;; TRR:eval                  今回出した点数
;;			     the player's current mark
;; TRR:whole-char-count      テキストの文字数
;;			     the number of characters in the text
;; TRR:high-score-old        前回までの最高得点
;;			     the previous high score record
;; TRR:high-score            今回までの最高得点
;;			     high score record
;; TRR:miss-type-ratio       ミス率 (千分率)
;;			     miss type ratio
;; TRR:type-speed            タイピング速度（文字数／分）
;;			     the number of characters typed per minute
;; TRR:total-times           今までの累積実行回数
;;			     the total number of TRR trials
;; TRR:total-time            今までの累積実行時間
;;			     the total time spends in TRR trials
;; TRR:times-for-message     このステップでの累積実行回数
;;			     the total number of TRR trials in the current step


(defun TRR:print-first-message-as-result ()
  (insert  (if TRR:japanese
	       " ようこそTRRの世界へ！\n\
 昼休みや仕事の後に、\n\
 或いは仕事の最中にも\n\
 頑張ってTRRに励もう！"
	     " Welcome to TRR world! \n\
 Let's play TRR\n\
 After lunch, class,\n\
 Even during works!")))


(defun TRR:print-message ()
  (let ((fill-column (- (window-width) 3)))
    (delete-region (point-min) (point-max))
    (insert "  ")
    (TRR:print-message-main)
    (fill-region (point-min) (point-max))
    (goto-char (point-min))))


(defun TRR:print-message-main ()
  (let ((diff (- (* (1+ TRR:steps) 10) TRR:eval)))
    (cond
     (TRR:cheat-flag
      (TRR:message-for-cheater))
     (TRR:secret-flag
      (TRR:message-for-secret-player))
     (TRR:typist-flag
      (TRR:message-for-typist))
     (TRR:beginner-flag
      (TRR:message-for-beginner))
     ((and TRR:update-flag TRR:pass-flag)
      (insert
       (format (if TRR:japanese
		   "ステップ%d突破そして記録更新おめでとう。"
		 "Great. You've cleared the step %d with the new record!")
	       TRR:steps))
      (if (< (% TRR:high-score 100) (% TRR:high-score-old 100))
	  (progn
	    (TRR:message-specially-for-record-breaker))
	(TRR:message-for-record-breaker))
      (setq TRR:high-score-old TRR:high-score))
     (TRR:update-flag
      (insert (if TRR:japanese
		  "記録更新おめでとう！"
		"Congratulations! You've marked the new record!"))
      (TRR:message-for-record-breaker)
      (setq TRR:high-score-old TRR:high-score))
     (TRR:pass-flag
      (insert
       (format (if TRR:japanese
		   "ステップ%d突破おめでとう。"
		 "Nice! You've cleared the step %d.")
	       TRR:steps))
      (TRR:message-for-success))
     ((= TRR:eval 0)
      (insert (if TRR:japanese
		  "０点なんて恥ずかしいわ。もっと努力しなさい。"
		"Arn't you ashmed of having marked such an amazing score 0!")))
     ((< diff  60)
      (TRR:message-for-failed-one-1 diff))
     ((or (< diff 100) (> TRR:miss-type-ratio 30))
      (TRR:message-for-failed-one-2 diff))
     (t
      (TRR:message-for-failed-one-3 diff)))))


(defun TRR:message-for-cheater ()
  (cond 
   ((> TRR:eval 750)
    (insert (if TRR:japanese
		"そんなことでいいの？恥を知りなさい。"
	      "Aren't you ashamed of having done such a thing?")))
   ((< TRR:whole-char-count 270)
    (insert (if TRR:japanese
		"卑怯よ。テキストが少な過ぎるわ。それでうれしい？"
	      "That's not fair! Too few letters in the text!")))
   ((and (< TRR:whole-char-count 520) TRR:typist-flag)
    (insert (if TRR:japanese
		"卑怯よ。テキストが少な過ぎるわ。それでうれしい？"
	      "That's not fair! Too few letters in the text!")))))


(defun TRR:message-for-secret-player ()
  (cond
   (TRR:pass-flag
    (setq TRR:secret-flag nil)
    (setq TRR:update-flag nil)
    (setq TRR:beginner-flag nil)
    (TRR:print-message-main)
    (setq TRR:secret-flag t))
   ((> TRR:eval 300)
    (insert (if TRR:japanese
		"こんな高い得点を出す方がどうして秘密にしておくの？"
	      "What a good typist you are! You'd unveil your score.")))
   ((> TRR:eval 200)
    (insert (if TRR:japanese
		"業界標準を越えてるわ。秘密にする必要は全くないわよ。"
	      "Your score now reaches to the World standard. Go out public TRR world!")))
   ((> TRR:eval 120)
    (insert (if TRR:japanese
		"恥ずかしくない点だわ。秘密にするのはもうやめましょう。"
	      "Good score! Put an end to play in this secret world.")))
   (t
    (insert (if TRR:japanese
		"公開するとちょっと恥ずかしい点だわ。しばらく秘密で続けましょう。"
	      "Keep your score secret for a while.")))))


(defun TRR:message-for-beginner ()
  (cond
   ((= TRR:eval 0)
    (insert (if TRR:japanese
		"０点というのは問題だわ。これからかなりの努力が必要よ。道のりは長いけど頑張りましょう。"
	      "0point... hopeless it is! You have to do much effort to step your level up.")))
   ((< TRR:eval 40)
    (insert (if TRR:japanese
		"少なくとも英文字ぐらいは絶対覚えること。業界必須の100点に向けてこれから頑張りましょう。"
	      "You need to learn at least the position of the alphabet keys. Set your sights on 100pt: the World indispensable point.")))
   ((< TRR:eval 80)
    (insert (if TRR:japanese
		"キー配置も大分覚えたようだけどまだまだだわ。業界必須の100点に向けてこれから頑張りましょう。"
	      "Yes, you've learned the positions of keys; but still more! Set your sights on 100pt: the World indispensable point.")))
   ((< TRR:eval 130)
    (insert (if TRR:japanese
		"基礎的な技術は身に付けているようだけどまだまだだわ。業界標準の200点に向けてこれから頑張りましょう。"
	      "You've learned some basic techniques; but still more! Go forward to 200pt: the World standard point.")))
   ((< TRR:eval 180)
    (insert (if TRR:japanese
		"なかなかの実力ね。でもスピードと正確さが少し足りないわ。業界標準の200点に向けてもう少し頑張りましょう。"
	      "Your typing skill is rather high. More speedy & exactly! Go forward to 200pt: the World standard point.")))
   ((< TRR:eval 280)
    (insert (if TRR:japanese
		"なかなかやるわね。もう少し頑張れば業界目標の300点をきっと突破できるわ。"
	      "Nice. With some effort, you will surely reach 300pt: the World highly standard.")))
   ((< TRR:eval 380)
    (insert (if TRR:japanese
		"すごいわね。初めてでこれぐらい出せれば十分だわ。でも業界一流の400点に向けてもう少し頑張りましょう。"
	      "Great. You have had sufficient skill. But push yourself to 400pt: the World firstclass.")))
   ((< TRR:eval 480)
    (insert (if TRR:japanese
		"すっごい！こんな点を出す人は滅多にいないわよ。ひょっとしてプロではないかしら？"
	      "Wonderful score! You may be a proffesional typist?")))
   (t
    (insert (if TRR:japanese
		"あまりにも超人的だわ。きっとギネスブックに載るわよ。"
	      "Too high score. You are sure to get a entry of the Guiness Book.")))))


(defun TRR:message-for-success ()
  (cond
   ((>= (- TRR:eval (* 10 (1+ TRR:steps))) 100)
    (insert (if TRR:japanese
		"あなたには簡単過ぎたようね。"
	      "This step must have been quite easy for you.")))
   ((<= TRR:times-for-message 2)
    (insert (if TRR:japanese
		"軽く突破したわね。"
	      "You made it effortlessly.")))
   ((<= TRR:times-for-message 4)
    (insert (if TRR:japanese
		"わりと簡単に突破したわね。"
	      "You made it!")))
   ((<= TRR:times-for-message 8)
    (insert (if TRR:japanese
		"ちょっとてこずったようね。"
	      "You carried out with a little trouble.")))
   ((<= TRR:times-for-message 16)
    (insert (if TRR:japanese
		"だいぶてこずったようね。"
	      "With much trouble, you accomplished this step's mark!")))
   ((<= TRR:times-for-message 32)
    (insert (if TRR:japanese
		"よく頑張ったわね。"
	      "You've sweat it out. Nice record.")))
   ((<= TRR:times-for-message 64)
    (insert (if TRR:japanese
		"随分苦労したようね。"
	      "You've had a very hard time.")))
   ((<= TRR:times-for-message 128)
    (insert (if TRR:japanese
		"苦しみぬいたわね。"
	      "You've gone through all sorts of hardships. ")))
   (t
    (insert 
     (format (if TRR:japanese
		 "%d回も挑戦するなんてすごいわ。執念でやりとげたわね。"
	       "You've challenged this step %d times. Great efforts! ")
	     TRR:times-for-message)))))


(defun TRR:message-for-failed-one-1 (diff)
  (cond 
   ((< diff 10)
    (insert (if TRR:japanese
		"あとほんの少しだったのに....本当に惜しかったわね。"
	      "Your score is slightly lower than the mark... How maddening!")))
   ((< diff 20)
    (insert (if TRR:japanese
		"惜しかったわね。"
	      "Disappointing!")))
   ((< diff 30)
    (insert (if TRR:japanese
		"その調子よ。"
	      "That's it!")))
   ((< diff 40)
    (insert (if TRR:japanese
		"もう一息だわ。でも息抜きはだめよ。"
	      "Just one more effort. Don't goof off!")))
   ((< diff 50)
    (insert (if TRR:japanese
		"頑張ればきっとできるわ。"
	      "With much effort, and you will make it.")))
   (t
    (insert (if TRR:japanese
		"努力あるのみよ。"
	      "What you have to do is nothing but making all possible effort.")))))


(defun TRR:message-for-failed-one-2 (diff)
  (cond 
   ((> TRR:miss-type-ratio 60)
    (insert (if TRR:japanese
		"ミスがあまりにも多過ぎるからダメなのよ。とにかく正確に打つ練習に励みなさい。もうそれしか方法はないわ。"
	      "Your hopeless point is based on your enormous misses! Practice the typing paying attention to correctness of typing keys.")))
   ((> TRR:miss-type-ratio 40)
    (insert (if TRR:japanese
		"ミスが多過ぎるわ。初心に帰って一つ一つ慎重に打つ練習をしなさい。"
	      "Too many wrong types! Remember your original purpose.")))
   ((> TRR:miss-type-ratio 24)
    (insert (if TRR:japanese
		"ミスが多いわ。正確に打つ練習をしなさい。"
	      "You failed frequently. Type accurate!")))
   ((> TRR:miss-type-ratio  8)
    (insert (if TRR:japanese
		"練習に練習を重ねなさい。"
	      "Keep in practice.")))
   (t
    (insert (if TRR:japanese
		"正確に打ってるようだけどスピードが遅すぎるわ。速く打つ練習に励みなさい。"
	      "You typed accurately, but too slow! Type more quickly.")))))


(defun TRR:message-for-failed-one-3 (diff)
  (cond 
   ((< diff 110)
    (insert (if TRR:japanese
		"「TRRの道は一日にしてならず」"
	      "\"TRR was not built in a day.\"")))
   ((< diff 120)
    (insert (if TRR:japanese
		"「TRRに王道なし」"
	      "\"There is no royal road to TRRing.\"")))
   ((< diff 130)
    (insert
     (format (if TRR:japanese
		 "あらまぁ。%d点を出した人がたったの%d点なんていったいどうしたのよ。"
	       "Oh, no! Your best is %d, however marked %d point this time! What on earth be with you?")
	     TRR:high-score TRR:eval)))
   ((< diff 140)
    (insert
     (format (if TRR:japanese
		 "%d点はまぐれだったの？"
	       "Is the fact once you marked %d point an illusion?")
	     TRR:high-score)))
   (t
    (insert (if TRR:japanese
		"あなたの実力ってこの程度だったのね。"
	      "Your real ability is no more than this point. isn't it?")))))


(defun TRR:message-specially-for-record-breaker ()
  (cond 
   ((< TRR:high-score-old 100)
    (insert (if TRR:japanese
		"ついに業界必須の100点突破ね！これからは業界標準の200点を目指して頑張りましょう。"
	      "Congratulations! You reaches 100pt: the World indispensable. Next your target is 200pt: the World standard.")))
   ((< TRR:high-score-old 200)
    (insert (if TRR:japanese
		"ついに業界標準の200点突破ね！これからは業界目標の300点を目指して頑張りましょう。"
	      "Congratulations! You reaches 200pt: the World standard. Next your target is 300pt: the World highly standard.")))
   ((< TRR:high-score-old 300)
    (insert (if TRR:japanese
		"ついに業界目標の300点突破ね！これからは業界一流の400点を目指して頑張りましょう。"
	      "Congratulations! You reaches 300pt: the World highly standard. Next your target is 400pt: the World firstclass.")))
   ((< TRR:high-score-old 400)
    (insert (if TRR:japanese
		"ついに業界一流の400点突破ね！これからは業界超一流の500点を目指して頑張りましょう。"
	      "Congratulations! You reaches 400pt: the World firstclass. Next your target is 500pt: the world superclass.")))
   ((< TRR:high-score-old 500)
    (insert (if TRR:japanese
		"ついに業界超一流の500点突破ね！これからは業界頂点の600点を目指して頑張りましょう。"
	      "Congratulations! You reaches 500pt: the world superclass. Next your target is 600pt: the World supreme.")))
   (t
    (insert (if TRR:japanese
		"あなたのようなすごい人は初めてよ。プロになれるわ。"
	      "You are the most marvelous typist I've ever met. The title \"TRRer\" suits you well!")))))


(defun TRR:message-for-record-breaker ()
  (cond
   ((< TRR:high-score  67)
    (insert (if TRR:japanese
		"業界必須の100点指して頑張って。"
	      "Keep aiming at 100pt: the World indispensable.")))
   ((< TRR:high-score 100)
    (insert (if TRR:japanese
		"業界必須の100点までもうすぐよ。"
	      "You are close to 100pt: the World indispensable.")))
   ((< TRR:high-score 167)
    (insert (if TRR:japanese
		"業界標準の200点目指して頑張って。"
	      "Keep aiming at 200pt: the World standard.")))
   ((< TRR:high-score 200)
    (insert (if TRR:japanese
		"業界標準の200点までもうすぐよ。"
	      "You are close to 200pt: the World standard.")))
   ((< TRR:high-score 267)
    (insert (if TRR:japanese
		"業界目標の300点目指して頑張って。"
	      "Keep aiming at 300pt: the World highly standard.")))
   ((< TRR:high-score 300)
    (insert (if TRR:japanese
		"業界目標の300点までもうすぐよ。"
	      "You are close to 300pt: the World highly standard.")))
   ((< TRR:high-score 367)
    (insert (if TRR:japanese
		"業界一流の400点目指して頑張って。"
	      "Keep aiming at 400pt: the World firstclass.")))
   ((< TRR:high-score 400)
    (insert (if TRR:japanese
		"業界一流の400点までもうすぐよ。"
	      "You are close to 400pt: the World firstclass.")))
   ((< TRR:high-score 467)
    (insert (if TRR:japanese
		"業界超一流の500点目指して頑張って。"
	      "Keep aiming at 500pt: the world superclass.")))
   ((< TRR:high-score 500)
    (insert (if TRR:japanese
		"業界超一流の500点までもうすぐよ。"
	      "You are close to 500pt: the world superclass.")))
   ((< TRR:high-score 567)
    (insert (if TRR:japanese
		"業界頂点の600点まで目指して頑張って。"
	      "Keep aiming at 600pt: the World supreme.")))
   ((< TRR:high-score 600)
    (insert (if TRR:japanese
		"業界頂点の600点までもうすぐよ。"
	      "You are close to 600pt: the World supreme.")))
   (t
    (insert (if TRR:japanese
		"よくここまでやるわね。あなたの目標は一体何なの？"
	      "What is interesting to you? What you are aiming at?")))))


(defun TRR:message-for-typist ()
  (cond
   (TRR:beginner-flag
    (insert (if TRR:japanese
		"タイピストへの道は険しいわよ。少なくとも300点をコンスタントに出すように頑張って。"
	      "The way to the typist is severe. Keep makeing 300pt every time."))
    (setq TRR:beginner-flag nil))
   ((and TRR:pass-flag (not TRR:update-flag))
    (setq TRR:typist-flag nil)
    (TRR:print-message-main)
    (setq TRR:typist-flag t))
   ((and TRR:update-flag TRR:pass-flag)
    (insert (if TRR:japanese
		"記録更新そして"
	      "You've marked a new record. And "))
    (setq TRR:typist-flag nil)
    (setq TRR:update-flag nil)
    (TRR:print-message-main)
    (setq TRR:typist-flag t))
   (TRR:update-flag (insert (if TRR:japanese
				"記録更新おめでとう！"
			      "Nice! You've marked a new record.")))
   ((> TRR:miss-type-ratio 30)
    (insert (if TRR:japanese
		"あなたには無理よ。タイピストになろうなんて当分考えないことね。"
	      "You are not up to Typist mode. Leave here for a while.")))
   ((> TRR:miss-type-ratio 20)
    (insert (if TRR:japanese
		"０点なんて恥ずかしいわね。この屈辱を胸に深く刻み込みなさい。"
	      "0pt! Aren't you ashamed?  Engrave this humiliation deeply engraved on my mind.")))
   ((> TRR:miss-type-ratio 15)
    (insert (if TRR:japanese
		"ミスがあまりにも多過ぎるわ。石橋を叩いて渡るようにタイプしなさい。"
	      "Excessively many miss types! Make assurance double sure.")))
   ((> TRR:miss-type-ratio 10)
    (insert (if TRR:japanese
		"ミスが多過ぎるわ。もっと慎重にタイプしなさい。"
	      "Too many typos. Type more carefully.")))
   ((> TRR:miss-type-ratio 6)
    (insert (if TRR:japanese
		"ミスが多いわ。もっと慎重にタイプした方がいいわよ。"
	      "Many typos. Take more care of typing.")))
   (t
    (setq TRR:typist-flag nil)
    (TRR:print-message-main)
    (setq TRR:typist-flag t))))


(provide 'trr-mesg)
;;; trr-mesg.el ends here
