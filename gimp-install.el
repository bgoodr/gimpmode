;;; gimp-install.el --- $Id: gimp-install.el,v 1.8 2008-08-03 22:03:07 sharik Exp $
;; Copyright (C) 2008 Niels Giesen.

;; Author: Niels Giesen <nielsforkgiesen@gmailspooncom, but please
;; replace the kitchen utensils with a dot before hitting "Send">
;; Keywords: processes, multimedia, extensions, tools, gimp, scheme
;; Homepage: http://niels.kicks-ass.org/gimpmode

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.
(defun gimp-install-message ()
  (switch-to-buffer
   "*GIMP Installation Help*")
  (let (buffer-read-only)
    (erase-buffer)
    (insert
     (format "
Installation of Gimp Mode almost completed, just one more step: 

Place your cursor after the following line (done!) and press C-x C-e.

%S

;; Uncomment following line to globally use `gimp-selector':
;; \(global-set-key \"\\C-cg\" 'gimp-selector)

You should add the above stanzas to your load
file (\"~/.emacs\"), so that they will be evaluated on next start-up.

Now you can run the GIMP with `M-x run-gimp'.
Alternatively, connect to GIMP server with `M-x gimp-cl-connect'.

Type `M-x gimp-help' for help.

For more information consult the file README."
	     `(load ,(concat gmd "gimp-init.el"))))
    (goto-char (point-min))
    (forward-list 2))
  (setq buffer-read-only t))

(defun gimp-install (&optional to-dir)
  (interactive)
  (let* ((gmd (file-name-directory
	       (or load-file-name buffer-file-name)))
	 (gimp-dir
	  (or to-dir
	      (expand-file-name 
	       (read-directory-name
		"Please enter config directory for the GIMP: "
		(if (eq window-system 'w32) 
		    (format "C:/Documents and Settings/%s/%s"
			    user-login-name
			    ".gimp-2.4/")
		  "~/.gimp-2.4/")))))
	 (gimp-emacs-dir (expand-file-name (concat gimp-dir "/emacs/")))
	 (emacs-interaction.scm "emacs-interaction.scm")
	 (emacs-interaction.scm-target
	  (expand-file-name 
	   (mapconcat 'identity
		      (list gimp-dir
			    "scripts"
			    emacs-interaction.scm)
		      "/")))

;; 	 (fud.scm "fud.scm")
;; 	 (fud.scm-target
;; 	  (expand-file-name 
;; 	   (mapconcat 'identity
;; 		      (list gimp-dir
;; 			    "scripts"
;; 			    fud.scm)
;; 		      "/")))

	 (gimp-init-file (concat gmd "gimp-init.el")))
    (unless (file-exists-p gimp-emacs-dir)
      (message "Making directory %s for communication emacs<->gimp..."
	       gimp-emacs-dir
	       (make-directory gimp-emacs-dir)))

    (message "Installing %s..." emacs-interaction.scm-target)
    (let (done
	  (funs (if (fboundp 'make-symbolic-link)
		    '(make-symbolic-link copy-file)
		  '(copy-file))))
      (dolist (fun '(make-symbolic-link copy-file))
	(unless done
	  (condition-case err
	      (progn
		(apply fun
		       (list
			(expand-file-name
			 (concat gmd emacs-interaction.scm))
			emacs-interaction.scm-target
			t))
		(setq done t))
	    (error (message "%s" (error-message-string err)))))))

;    (message "Installing %s..." fud.scm-target)
;;     (let (done
;; 	  (funs (if (fboundp 'make-symbolic-link)
;; 		    '(make-symbolic-link copy-file)
;; 		  '(copy-file))))
;;       (dolist (fun '(make-symbolic-link copy-file))
;; 	(unless done
;; 	  (condition-case err
;; 	      (progn
;; 		(apply fun
;; 		       (list
;; 			(expand-file-name
;; 			 (concat gmd fud.scm))
;; 			fud.scm-target
;; 			t))
;; 		(setq done t))
;; 	    (error (message "%s" (error-message-string err)))))))

    (progn
      (find-file-literally (concat gmd "gimp-vars.el"))
      (erase-buffer)
      (insert ";;This file was autogenerated by gimp-install, do not modify")
      (print 
       `(defcustom gimp-dir (expand-file-name ,gimp-dir)
	  "User configuration directory for the GIMP.

the GIMP puts its caches here.  Retrieve it by evaluating the variable
`gimp-dir' in GIMP script-fu console.

It is advised to run `gimp-install.el' to change this variable and
stuff depending on it."
	  :group 'gimp-directories
	  :type 'string) 
       (current-buffer))
      (save-buffer)
      (kill-buffer (current-buffer)))

    (load gimp-init-file)
    (byte-compile-file 
     (concat gmd "fud.el"))
    (byte-compile-file 
     (concat gmd "gimp-mode.el"))
    (byte-compile-file 
     (concat gmd "related/scheme-complete.el"))
    (byte-compile-file 
     (concat gmd "related/snippet.el"))
    (gimp-install-message)))

(gimp-install)

;; (provide 'gimp-install)