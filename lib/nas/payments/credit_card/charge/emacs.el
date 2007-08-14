;;; $Id: emacs.el 159 2004-06-11 14:04:25Z nas $

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "make -C /usr/local/lib/site_ruby/nas/payment/credit_card/charge"))

;;; end of emacs.el
