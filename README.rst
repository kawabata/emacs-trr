=========
emacs-trr
=========

Trr is a typing training software on GNU Emacs.


Install
=======

Download from GitHub::

  $ git clone https://github.com/kawabata/emacs-trr.git ~/.emacs-trr

Add below in your emacs config file (``~/.emacs`` or ``~/.emacs.d/init.el``)::

  (add-to-list 'load-path "~/.emacs-trr")
  (require 'trr)
  ;; (setq trr-japanese t)  ;; uncomment this to play with Japanese mode

If you're `El-Get`_ user, just add below in your emacs config file::

  (el-get-bundle kawabata/emacs-trr)


.. _El-Get: https://github.com/dimitri/el-get

Or `MELPA`_ user, just type bellow command in emacs ::

  M-x package-refresh-contents
  M-x package-install trr

.. _MELPA: https://github.com/melpa/melpa

Usage
=====

Run below to play trr::

    $ emacs -f trr


License
=======
| Copyright (C) 1996 YAMAMOTO Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
| Released under GNU Emacs General Public License
