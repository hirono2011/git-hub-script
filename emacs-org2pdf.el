;;emacsのorg-modeからPDFファイルを作成するEmacs-Lispスクリプトです。個人用なので、いくつか設定を変えないと使えないと思います。最低限パスの変更は必要です。
;;h-org2tex-processingはtexファイルを作るだけです。h-org2pdf-processingでPDFファイルまで作成します。むろんTexがコンパイルできる環境が必要です。

;;2008-10-30
(defun h-tex-preamble ()
  (interactive)
  (save-excursion
  (beginning-of-buffer)
  (let* (flag
		(sp (point))
		(ep (progn
			  (if (setq flag (re-search-forward 
							  (regexp-quote "\\begin{document}") nil t))
				  (progn (previous-line)
						 (end-of-line)
						 (point))
			  ()))))
	(if (null flag)
		(message "search error!")
	(progn
	  (delete-region sp ep)
;;プリアンブルの読み込み
	  (insert-file "/home/u9x/h-lisp/tex-preamble.tex")
	  (message "done."))))))

;;2008-11-02
(defun h-gtlt2escape ()
  (interactive)
  (save-excursion
  (let ((begin
		 (re-search-forward (regexp-quote "\\begin{document}")))
		(end
		 (re-search-forward (regexp-quote "\\end{document}"))))
	(save-restriction
	  (narrow-to-region begin end)
	  (goto-char begin)
	  (while (re-search-forward  "\\(\\\\.+{.+\\)\\(<\\)\\(.+\\)\\(>\\)\\(.*}$\\)" nil t)
		(replace-match "\\1$\\2$\\3$\\4$\\5"))))))

(defun h-org2tex-processing ()
  "org-modeのLaTeXエクスポートの結果を処理する。"
  (interactive)
  (let* ((bname (buffer-name))
	   (sname
		(progn
		  (string-match "\\(.+\\)\\..+" bname)
		  (replace-match "\\1.tex" nil nil bname))))
	(save-excursion
	  (call-interactively 'org-export-as-latex-to-buffer))
	(switch-to-buffer "*Org LaTeX Export*")
	(save-excursion
	  (beginning-of-buffer)
	  (h-gtlt2escape)
	  (h-tex-preamble))
	(write-file sname)
	(message "Create File: %s" sname)))

;;2008-11-08
(defun h-org2pdf-processing ()
  "org-modeのLaTeXエクスポートの結果を処理する。"
  (interactive)
  (let* ((bname (buffer-name))
		 (directory default-directory)
	   (sname
		(progn
		  (string-match "\\(.+\\)\\..+" bname)
		  (replace-match "\\1.tex" nil nil bname))))
	(save-excursion
	  (call-interactively 'org-export-as-latex-to-buffer))
	(switch-to-buffer "*Org LaTeX Export*")
	(save-excursion
	  (beginning-of-buffer)
	  (h-gtlt2escape)
	  (h-tex-preamble))
	(write-file sname)
	;処理結果表示用のフレームを作成
	(message "Create File: %s" sname)

	(let* ((tex-file
			(expand-file-name sname directory))
		   (target-file
			(progn
			  (string-match "\\(.+\\)\\..+$" tex-file)
			  (replace-match "\\1" nil nil tex-file)))
		   (repeat 3) (flag t))
	  (while (< 0 repeat)
		(setq flag (call-process "platex" nil  "compile TeX" nil tex-file))
	;	(if (= 0 flag)
			(progn (sleep-for 1) (setq repeat (- repeat 1))))
		 ; (error "Tex compile Error!")))

	  (setq flag (call-process "dvipdfmx" nil "compile Tex" nil
							   (format "%s.dvi" target-file)))
	  (if (= 0 flag)
		  ()
		(error "dvipdfmx Error!"))

	(setq nfrm (make-frame))
	(select-frame nfrm)
	(setq cw (frame-selected-window))
	(select-window cw)
	(get-buffer-create "compile Tex")
	(set-window-buffer cw "compile Tex")

	  (call-process "evince" nil nil nil (format "%s.pdf" target-file)))))


	(end-of-line)
	(setq ep (point))
	
	(kill-region sp ep))))




