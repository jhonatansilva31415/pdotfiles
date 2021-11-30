;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun jhon/display-startup-time ()
    (message "Emacs loaded in %s with %d garbage collections."
            (format "%.2f seconds"
                    (float-time
                        (time-subtract after-init-time before-init-time)))
            gcs-done))

(add-hook 'emacs-startup-hook #'jhon/display-startup-time)

(setq make-backup-files nil)
(setq create-lockfiles nil)

(defvar jhon/default-font-size 120)
(defvar jhon/default-variable-font-size 120)

;; Make frame transparency overridable
(defvar jhon/frame-transparency '(90 . 90))

(set-face-attribute 'default nil :font "JetBrains Mono" :height jhon/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :height jhon/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "JetBrains Mono" :height jhon/default-variable-font-size :weight 'regular)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                        ("org" . "https://orgmode.org/elpa/")
                        ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
(package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
    (package-install 'use-package))

(require 'use-package)
  (setq use-package-always-ensure t)

(use-package auto-package-update
:custom
(auto-package-update-interval 7)
(auto-package-update-prompt-before-update t)
(auto-package-update-hide-results t)
:config
(auto-package-update-maybe)
(auto-package-update-at-time "09:00"))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
    `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

  (scroll-bar-mode -1)        ; Disable visible scrollbar
  (tool-bar-mode -1)          ; Disable the toolbar
  (tooltip-mode -1)           ; Disable tooltips
  (set-fringe-mode 10)        ; Give some breathing room

  (menu-bar-mode -1)            ; Disable the menu bar

  ;; Set up the visible bell
  (setq visible-bell t)

  (column-number-mode)
  (global-display-line-numbers-mode t)
  (setq display-line-numbers 'relative)

  (set-window-margins nil 0)

  (setq right-divider-width 0
        bottom-divider-width 0)

  (load-theme 'wombat)

  ;; Make ESC quit prompts
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)

  ;; Set frame transparency
  (set-frame-parameter (selected-frame) 'alpha jhon/frame-transparency)
  (add-to-list 'default-frame-alist `(alpha . ,jhon/frame-transparency))
  (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
(add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package emojify
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#E8DCCA")
  (show-paren-mode 1))

(use-package doom-themes
    :init
    (load-theme 'doom-one t)
    (global-hl-line-mode +1)
    :custom
    (doom-themes-visual-bell-config)
    ;; Enable custom neotree theme (all-the-icons must be installed!)
    (doom-themes-neotree-config)
    (doom-themes-org-config)
)

(custom-set-faces
 `(fringe ((t (:background nil)))))

(use-package all-the-icons)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

(use-package avy
  :commands (avy-goto-char avy-goto-word-0 avy-goto-line))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; unmap f1 - will use for global mode
(global-set-key (kbd "<f1>") nil)

(use-package general
  :after evil
  :config
  (general-create-definer jhon/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "<f1>"
    )

  (general-create-definer jhon/normal-keys
    :keymaps '(normal)
    :prefix "")
)

(use-package hydra
    :defer t
)

(jhon/leader-keys
  "." '(find-file :which-key "Find Files")
  "a"  '(hydra-agenda-menu/body :which-key "Agenda")
  "b"  '(hydra-bookmarks-menu/body :which-key "Bookmark")
  "c"  '(org-capture :which-key "Quick Capture")
  "d"  '(hydra-dap-menu/body :which-key "Bookmark")
  "e"  '(neotree-toggle :which-key "Neotree explorer")
  "f"  '(hydra-files-menu/body :which-key "Files")
  "l"  '(hydra-lsp-menu/body :which-key "LSP")
  "o"  '(hydra-org-menu/body :which-key "Org")
  "p"  '(hydra-perspective-menu/body :which-key "Perspective")
  "r"  '(:ignore t :which-key "Roam")
  "s"  '(hydra-search-menu/body :which-key "Search")
  "t"  '(hydra-text-scale/body :which-key "Text scale")
  "w"  '(hydra-windows-menu/body :which-key "Windows")
)

(defhydra hydra-agenda-menu (:hint nil)
  "
^Agenda^
^^^^^^^^----------------------------------------------------------------------------------------
_a_: Agenda
_t_: Change status
_l_: Agenda list
                     ^^                     ^^                             ^^
"
  ("a" org-agenda :exit t)
  ("t" org-todo :exit t)
  ("l" org-agenda-list :exit t)
  ("q" nil "quit" :color blue)
)

(defhydra hydra-dap-menu (:hint nil :color red)
  "
^DAP^               ^Interact^        ^Delete^                        ^Hydra
^^^^^^^^----------------------------------------------------------------------------------------
_d_: Debug last     _n_:  Next        _xx_: Delete all                _hh_: Dap hydra
_t_: Breakpoint     _r_:  Restart     _xq_: Disconnect
_m_: Message        _cc_: Continue
^^                  _cn_: Console
^^                  _e_:  Add expression

"
  ("d" dap-debug-last :color blue)
  ("t" dap-breakpoint-toggle :color blue)
  ("m" dap-breakpoint-log-message)
  ("n" dap-next)
  ("r" dap-debug-restart)
  ("cc" dap-ui-continue)
  ("cn" dap-ui-repl :color blue)
  ("xq" dap-disconnect :color blue)
  ("xx" dap-delete-all-sessions)
  ("e" dap-ui-expressions-add)

  ("hh" dap-hydra)

  ("q" nil "quit" :color blue)
)

(defhydra hydra-files-menu (:hint nil :color red)
  "
^Local^                           ^Common files
^^^^^^^^----------------------------------------------------------------------------------------
_f_: file in dir                  _de_: Go to Emacs.org
_g_: rg dir                       _dt_: Go to Tasks.org
_p_: find preview
_b_: buffer
_c_: themes
^^

"
  ("f" consult-find :exit t)
  ("g" consult-ripgrep :exit t)
  ("p" jhon/find-file-preview :exit t)
  ("b" consult-buffer :exit t)
  ("c" consult-theme)

  ("de" (lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/Emacs.org"))) :exit t)
  ("dt" (lambda () (interactive) (find-file (expand-file-name "/storage/org/todo/Tasks.org"))) :exit t)

  ("q" nil "quit" :color blue)
)

(jhon/leader-keys
  "SPC"  '(consult-line :which-key "consult-line")
)

(defun jhon/avy-goto-char-timer-highlight()
  (interactive)
  (let ((current-prefix-arg t)) (evil-avy-goto-char-timer))
)

(jhon/normal-keys
  "gs" '(jhon/avy-goto-char-timer-highlight :which-key "jump to char with highlight")
  "s" '(avy-goto-char-timer :which-key "char")
)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t)
 )

(defun jhon/org-file-jump-to-heading (org-file heading-title)
  (interactive)
  (find-file (expand-file-name org-file))
  (goto-char (point-min))
  (search-forward (concat "* " heading-title))
  (org-overview)
  (org-reveal)
  (org-show-subtree)
  (forward-line))

(defun jhon/org-file-show-headings (org-file)
  (interactive)
  (find-file (expand-file-name org-file))
  (counsel-org-goto)
  (org-overview)
  (org-reveal)
  (org-show-subtree)
  (forward-line))

(defhydra hydra-perspective-menu (:hint nil)
  "
^Perspective^         ^Buffer^                 ^State^                        ^Delete
^^^^^^^^----------------------------------------------------------------------------------------
_p_: Go to persp     _a_: Add to buffer       _ss_: State save               _xt_: Kill this
_n_:  Next            _b_: Choose which buffer _sl_: State load               _xo_: Kill others
_fb_: Search          ^^                       ^^                             ^^
                      ^^                       ^^                             ^^
"
  ("p" persp-switch :exit t)
  ("fb" switch-to-buffer :exit t)
  ("n" persp-next :exit t)
  ("a" persp-add-buffer)
  ("b" persp-set-buffer)
  ("xt" persp-kill)
  ("xo" persp-kill-others)
  ("ss" persp-state-save :exit t)
  ("sl" persp-state-load :exit t)
  ("q" nil "quit" :color blue)
)

(defhydra hydra-org-menu (:hint nil)
  "
^Code^
^^^^^^^^----------------------------------------------------------------------------------------
_cb_: Compile Block
_cc_: Compile elisp

"
  ("cb" org-ctrl-c-ctrl-c :exit t)
  ("cc" eval-last-sexp :exit t)
  ("q" nil "quit" :color blue)
)

(defhydra hydra-lsp-menu (:hint nil)
  "
^Diagnostics^              ^Python^
^^^^^^^^----------------------------------------------------------------------------------------
_i_: Show diagnostics      _ve_: Pyenv
_a_: Show code actions
                           ^^
"
  ("i" flycheck-list-errors :exit t)
  ("a" lsp-ui-sideline-apply-code-actions :exit t)
  ("ve" pyvenv-workon :exit t)
  ("q" nil "quit" :color blue)
)

(defhydra hydra-bookmarks-menu (:hint nil)
  "
^Bookmarks^
^^^^^^^^----------------------------------------------------------------------------------------
_s_: Set bookmark
_b_: Consult bookmark
_x_: Delete bookmark
                         ^^
"
  ("b" consult-bookmark :exit t)
  ("s" bookmark-set :exit t)
  ("x" bookmark-delete :exit t)
  ("q" nil "quit" :color blue)
)

(defhydra hydra-windows-menu (:hint nil :color red)
  "
^Windows^
^^^^^^^^----------------------------------------------------------------------------------------
_r_: Split right
_b_: Split bellow
_d_: Delete window
_s_: Shrink
_e_: Enlarge
_w_: Recenter
                         ^^
"

  ("w" recenter :exit t)
  ("d" delete-window :exit t)
  ("l" evil-window-right :exit t)
  ("h" evil-window-left :exit t)
  ("k" evil-window-up :exit t)
  ("j" evil-window-down :exit t)

  ("r" evil-window-vsplit :color blue)
  ("b" evil-window-split :color blue)

  ("s" shrink-window-horizontally)
  ("e" enlarge-window-horizontally)

  ("q" nil "quit" :color blue)
)

(defhydra hydra-search-menu (:hint nil)
  "
^Bookmarks^
^^^^^^^^----------------------------------------------------------------------------------------
_n_: Search my org roam notes
_p_: Search /storage/projects
                         ^^
"
  ("n" jhon/org-roam-rg-search :exit t)
  ("p" jhon/search-projects :exit t)
  ("q" nil "quit" :color blue)
)

;; blank line
  (setq outline-blank-line t)

  (defun jhon/org-mode-setup ()
    (org-indent-mode)
    (variable-pitch-mode 1)
    (visual-line-mode 1))

  (use-package org
    :pin org
    :commands (org-capture org-agenda)
    :hook (org-mode . jhon/org-mode-setup)
    :config
    (setq org-ellipsis " ▾")
    (setq org-src-fontify-natively t)
    ;org-agenda
    (setq org-agenda-start-with-log-mode t)
    (setq org-log-done 'time)
    (setq org-log-into-drawer t)


    (setq org-agenda-files
    '("/storage/org/todo/Tasks.org"
     "/storage/org/todo/Bills.org"
     "/storage/org/todo/Birthdays.org"
     "/storage/org/journal/Habits.org"))

    (require 'org-habit)
    (add-to-list 'org-modules 'org-habit)
    (setq org-habit-graph-column 60)

    (setq org-todo-keywords
  '((sequence "TODO(t)" "NEXT(n)" "PROCESS(pr)" "|" "DONE(d!)")
    (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

      (setq org-todo-keyword-faces
          '(
            ("TODO" . org-warning) ("NEXT" . "yellow")
            ("PLAN" . "orange") ("WAIT" . "yellow")
            ("CANC" . "red") ("READY" . "green")
            ("ACTIVE" . "green") ("HOLD" . "red")
            ("BACKLOG" . "gray") ("PROCESS" . "yellow")
           )
      )

    (setq org-agenda-custom-commands
          '(("d" "Dashboard"
             ((agenda "" ((org-deadline-warning-days 7)))
              (todo "NEXT"
                    ((org-agenda-overriding-header "Next Tasks")))
              (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

            ("n" "Next Tasks"
             ((todo "NEXT"
                    ((org-agenda-overriding-header "Next Tasks")))))
            )
    )

    (setq org-capture-templates
      '(
          ("t" "Tasks / Projects")
          ("tt" "Task" entry (file+olp "/storage/org/todo/Tasks.org" "Inbox")
              "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

          ("j" "Journal")
          ("jj" "Journal" entry
          (file+olp+datetree "/storage/org/journal/Journal.org")
          "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
          ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
          :clock-in :clock-resume
          :empty-lines 1)
       )
    )

)

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●"))
)
(with-eval-after-load 'org-faces
  (set-face-attribute 'org-document-title nil :font "JetBrains Mono" :weight 'bold :height 1.3)
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.0)
                  (org-level-6 . 1.0)
                  (org-level-7 . 1.0)
                  (org-level-8 . 1.0)))
    (set-face-attribute (car face) nil :font "JetBrains Mono" :weight 'medium :height (cdr face)))
)

;; Make sure org-indent face is available
(require 'org-indent)

;; Ensure that anything that should be fixed-pitch in Org files appears that way
;;(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
;;(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
;;(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;; Get rid of the background on column views
(set-face-attribute 'org-column nil :background nil)
(set-face-attribute 'org-column-title nil :background nil)

(defun jhon/org-mode-visual-fill ()
  (setq visual-fill-column-width 140
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . jhon/org-mode-visual-fill)
  )

(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
        (python . t)
      )
    )
  (push '("conf-unix" . conf-unix) org-src-lang-modes)
)

;; Automatically tangle our Emacs.org config file when we save it
(defun jhon/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'jhon/org-babel-tangle-config)))

(defun my-org-confirm-babel-evaluate (lang body)
  (not (member lang '("python" "typescript"))))

(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

(use-package org-roam
   :ensure t
   :init
   (setq org-roam-v2-ack t)
   :custom
   org-roam-directory "/storage/roam"
   org-roam-completion-everywhere

   (org-roam-capture-templates
    '(("d" "default" plain
        "%?"
        :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
        :unnarrowed t)

      ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
       :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: Project")
       :unnarrowed t)

      ))
   :bind (:map org-mode-map ("C-M-i" . completion-at-point))
   :config
   (org-roam-setup)
   (require 'org-roam-dailies) ;; Ensure the keymap is available
   (org-roam-db-autosync-mode)
 )


(defun org-roam-node-insert-immediate (arg &rest args)
(interactive "P")
(let ((args (cons arg args))
      (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                '(:immediate-finish t)))))
  (apply #'org-roam-node-insert args)))


(jhon/leader-keys
 "rb"  'org-roam-buffer-toggle
 "rf"  'org-roam-node-find
 "ri"  'org-roam-node-insert-immediate
 "rz"  'font-lock-mode
 "rd"  'org-roam-dailies-capture-today
 "ro"  'org-open-at-point
)

(require 'org-roam-node)

(setq read-process-output-max (* 1024 1024))

(defun jhon/org-roam-rg-search ()
  "Search org-roam directory using consult-ripgrep. With live-preview."
  (interactive)
  (let ((consult-ripgrep-command "rg --multiline --null --ignore-case --type org --line-buffered --color=always --max-columns=500 --no-heading --line-number . -e ARG OPTS"))
    (consult-ripgrep "/storage/roam")))

(defun jhon/search-projects()
  (interactive)
  (let ((consult-ripgrep-command "rg --multiline --null --ignore-case --type org --line-buffered --color=always --max-columns=500 --no-heading --line-number . -e ARG OPTS"))
    (consult-ripgrep "/storage/projects")))

(defun jhon/org-roam-export-all ()
  "Re-exports all Org-roam files to Hugo markdown."
  (interactive)
  (dolist (f (org-roam--list-all-files))
    (with-current-buffer (find-file f)
      (when (s-contains? "SETUPFILE" (buffer-string))
        (org-hugo-export-wim-to-md)))))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package ox-hugo
  :ensure t            ;Auto-install the package from Melpa (optional)
  :after ox)

;; Enable vertico
(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-f" . vertico-exit)
              :map minibuffer-local-map
              ("M-h" . backward-kill-word))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode)
  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; Optionally use the `orderless' completion style. See
;; `+orderless-dispatch' in the Consult wiki for an advanced Orderless style
;; dispatcher. Additionally enable `partial-completion' for file path
;; expansion. `partial-completion' is important for wildcard support.
;; Multiple files can be opened at once with `find-file' if you enter a
;; wildcard. You may also give the `initials' completion style a try.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; Alternatively try `consult-completing-read-multiple'.
  (defun crm-indicator (args)
    (cons (concat "[CRM] " (car args)) (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

;; Example configuration for Consult
(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI. You may want to also
  ;; enable `consult-preview-at-point-mode` in Embark Collect buffers.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Optionally replace `completing-read-multiple' with an enhanced version.
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-recent-file consult--source-project-recent-file consult--source-bookmark
   :preview-key (kbd "M-."))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;;;; 4. locate-dominating-file
  (setq consult-project-root-function (lambda () (locate-dominating-file "." ".git")))
  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  :custom
  (completion-in-region-function #'consult-completion-in-region)
)

(use-package consult-dir
  :ensure t)

;;(setq-default highlight-indentation-mode nil)
(setq-default tab-width 2)
(setq-default evil-shift-width tab-width)
(setq-default indent-tabs-mode nil)
  ; clean white spaces
(use-package ws-butler
  :hook ((text-mode . ws-butler-mode)
         (prog-mode . ws-butler-mode)))

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package json-mode)

(use-package docker
  :commands docker)

(use-package dockerfile-mode)

(defun jhon/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . jhon/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

;; was too much information
(use-package lsp-ui
 :hook (typescript-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package dap-mode
  :custom
  (dap-auto-configure-features '(sessions locals tooltip))
  :config
  (dap-ui-mode 1)
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed
)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2)
)

(use-package apheleia
  :config
  (apheleia-global-mode +1))

(use-package prettier-js
  ;; :hook ((js2-mode . prettier-js-mode)
  ;;        (typescript-mode . prettier-js-mode))
  :config
  (setq prettier-js-show-errors nil))

(use-package flycheck)

(use-package python-mode
  :ensure t
  :hook
  (python-mode . lsp-deferred)
  (python-mode . pyvenv-mode)
  (python-mode . blacken-mode)
  (python-mode . flycheck-mode)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  ;; (python-shell-interpreter "python3")
  ;; (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python)
 )

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

(use-package pyvenv
  :ensure t
  :init
  (setenv "WORKON_HOME" "~/.pyenv/versions")
  (pyvenv-mode 1)
)

(use-package blacken
  :init
  (setq-default blacken-fast-unsafe t)
  (setq-default blacken-line-length 80)
  (blacken-mode 1)
 )

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package origami)

(use-package restclient)

(use-package neotree
  :init
  (require 'neotree)
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  (setq neo-smart-open t)
  )
(provide 'init-neotree)

(defun jhon/find-file-preview ()
  "Search org-roam directory using consult-ripgrep. With live-preview."
  (interactive)
  (let ((consult-ripgrep-command "rg --multiline --null --ignore-case --type org --line-buffered --color=always --max-columns=500 --no-heading --line-number . -e ARG OPTS"))
    (consult-ripgrep)))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (setq vterm-max-scrollback 10000))

(use-package elfeed
  :commands elfeed
  :config
  (setq elfeed-feeds
    '(
      "https://www.reddit.com/r/emacs/.rss"
      "https://www.reddit.com/r/OrgRoam/.rss"
     )
  )
)

(defun dw/org-start-presentation ()
  (interactive)
  (org-tree-slide-mode 1)
  (setq text-scale-mode-amount 3)
  (text-scale-mode 1))

(defun dw/org-end-presentation ()
  (interactive)
  (text-scale-mode 0)
  (org-tree-slide-mode 0))

(use-package org-tree-slide
  :defer t
  :after org
  :commands org-tree-slide-mode
  :config
  (evil-define-key 'normal org-tree-slide-mode-map
    (kbd "q") 'dw/org-end-presentation
    (kbd "C-l") 'org-tree-slide-move-next-tree
    (kbd "C-h") 'org-tree-slide-move-previous-tree)
  (setq org-tree-slide-slide-in-effect nil
        org-tree-slide-activate-message "Presentation started."
        org-tree-slide-deactivate-message "Presentation ended."
        org-tree-slide-header t))

(use-package org-pomodoro
  :ensure t
  :commands (org-pomodoro)
  :config
    (setq alert-user-configuration (quote (:category . "org-pomodoro")))
)

(use-package perspective
  :ensure t
  :init
  (persp-mode)
  :config
  (persp-state-load "~/.emacs.d/persp")
)
