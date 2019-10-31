CURSOR LINE CURRENT WINDOW
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

The 'cursorline' setting makes it easy to locate the cursor position. However,
when there are split windows, each one shows its cursor line, and the only
indication of the currently active window is the different 'statusline'
highlighting (with hl-StatusLine vs. hl-StatusLineNC).

This plugin avoids the clutter of multiple highlighted screen lines with split
windows by disabling the 'cursorline' setting for all but the current window.
Unlike a simplistic solution with a few autocmds, this plugin still allows for
exceptions like disabling the cursorline for a particular window or making it
permanent for (another) window.

### SEE ALSO

- The RelativeNumberCurrentWindow plugin ([vimscript #4461](http://www.vim.org/scripts/script.php?script_id=4461)) enables the
  'relativenumber' setting only for the current window.

### RELATED WORKS

The basic idea is outlined in the Vim Tips Wiki:
    http://vim.wikia.com/wiki/Highlight_current_line
- cursorline\_current.vim ([vimscript #5740](http://www.vim.org/scripts/script.php?script_id=5740)) enables cursorline only in the
  current window and when not in insert mode.

USAGE
------------------------------------------------------------------------------

    Globally enable 'cursorline' in your vimrc via
        :set cursorline
    After sourcing this plugin, 'cursorline' will only be active for the current
    window. So with multiple split windows, only one of them, the one where the
    cursor is in, will have the 'cursorline'.

    Disable cursorline for the current window via:
        :setlocal nocursorline
    This will persist even after moving away and back to the window.

    Disable cursorline globally via:
        :set nocursorline
    As soon as you enter a window, its line highlighting will vanish.

    For some kind of files it is helpful to keep the line highlighting active,
    e.g. to serve as a ruler. You can keep the highlighting for a particular
    window by setting a window-local variable:
        :let w:persistent_cursorline = 1

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-CursorLineCurrentWindow
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim CursorLineCurrentWindow*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-CursorLineCurrentWindow/issues or email
(address below).

HISTORY
------------------------------------------------------------------------------

##### 1.00    18-Aug-2012
- First published version.

##### 0.10    23-Aug-2011
- Allow persistent cursorlines via w:persistent\_cursorline.

##### 0.01    09-May-2006
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2012-2019 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
