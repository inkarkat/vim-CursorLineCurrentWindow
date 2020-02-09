" CursorLineCurrentWindow.vim: Only highlight the screen line of the cursor in the currently active window.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_CursorLineCurrentWindow') || (v:version < 700)
    finish
endif
let g:loaded_CursorLineCurrentWindow = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:CursorLineCurrentWindow_OptionNames')
    let g:CursorLineCurrentWindow_OptionNames = []
    for s:optionName in ['cursorline', 'cursorcolumn'] + (exists('&wincolor') ? ['wincolor'] : [])
	execute 'if ! empty(&' . s:optionName . ') | call add(g:CursorLineCurrentWindow_OptionNames, "' . s:optionName . '") | endif'
    endfor
endif


"- functions -------------------------------------------------------------------

" Note: We use both global and local optionvalues to store the states, though
" the option is window-local and only the local value effectively determines the
" visibility of the highlighting. This makes for a better value inheritance when
" splitting windows than a separate window-local variable would.

function! s:Expand( template, optionName ) abort
    return substitute(a:template, '%s', a:optionName, 'g')
endfunction
function! s:CreateFunctionsForFlag( optionName ) abort
    execute s:Expand(
    \   'function! s:OnEnter_%s()' . "\n" .
    \   '   if s:%s' . "\n" .
    \   '	if &g:%s || exists("w:persistent_%s") && w:persistent_%s' . "\n" .
    \   '	    setlocal %s' . "\n" .
    \   '	else' . "\n" .
    \   '	    setglobal %s' . "\n" .
    \   '	endif' . "\n" .
    \   '   else' . "\n" .
    \   '	setlocal no%s' . "\n" .
    \   '    endif' . "\n" .
    \   'endfunction' . "\n" .
    \   '', a:optionName)
    execute s:Expand(
    \   'function! s:OnLeave_%s()' . "\n" .
    \   '    if s:%s' . "\n" .
    \   '	if &l:%s' . "\n" .
    \   '	    if ! &g:%s' . "\n" .
    \   '		" user did :setlocal %s' . "\n" .
    \   '		set %s' . "\n" .
    \   '	    endif' . "\n" .
    \   '	else' . "\n" .
    \   '	    if &g:%s' . "\n" .
    \   '		" user did :setlocal no%s' . "\n" .
    \   '		set no%s' . "\n" .
    \   '	    else' . "\n" .
    \   '		" user did :set no%s' . "\n" .
    \   '		let s:%s = 0' . "\n" .
    \   '	    endif' . "\n" .
    \   '	endif' . "\n" .
    \   '	if exists("w:persistent_%s") && w:persistent_%s' . "\n" .
    \   '	    setglobal no%s' . "\n" .
    \   '	    setlocal %s' . "\n" .
    \   '	else' . "\n" .
    \   '	    setlocal no%s' . "\n" .
    \   '	endif' . "\n" .
    \   '    else' . "\n" .
    \   '	if &g:%s && &l:%s' . "\n" .
    \   '	    " user did :set %s' . "\n" .
    \   '	    let s:%s = 1' . "\n" .
    \   '	endif' . "\n" .
    \   '    endif' . "\n" .
    \   'endfunction' . "\n" .
    \   '', a:optionName)
endfunction
function! s:CreateFunctionsForOptionValue( optionName ) abort
    execute s:Expand(
    \   'function! s:OnEnter_%s()' . "\n" .
    \   '   if ! empty(s:%s)' . "\n" .
    \   '	if ! empty(&g:%s) || exists("w:persistent_%s") && w:persistent_%s' . "\n" .
    \   '	    let &l:%s = s:%s' . "\n" .
    \   '	else' . "\n" .
    \   '	    let &g:%s = s:%s' . "\n" .
    \   '	endif' . "\n" .
    \   '   else' . "\n" .
    \   '	setlocal %s=' . "\n" .
    \   '    endif' . "\n" .
    \   'endfunction' . "\n" .
    \   '', a:optionName)
    execute s:Expand(
    \   'function! s:OnLeave_%s()' . "\n" .
    \   '    if ! empty(s:%s)' . "\n" .
    \   '	if ! empty(&l:%s)' . "\n" .
    \   '	    if empty(&g:%s)' . "\n" .
    \   '		" user did :setlocal %s=...' . "\n" .
    \   '		let &%s = &g:%s' . "\n" .
    \   '	    endif' . "\n" .
    \   '	else' . "\n" .
    \   '	    if ! empty(&g:%s)' . "\n" .
    \   '		" user did :setlocal %s=' . "\n" .
    \   '		set %s=' . "\n" .
    \   '	    else' . "\n" .
    \   '		" user did :set %s=' . "\n" .
    \   '		let s:%s = ""' . "\n" .
    \   '	    endif' . "\n" .
    \   '	endif' . "\n" .
    \   '	if exists("w:persistent_%s") && w:persistent_%s' . "\n" .
    \   '	    setglobal %s=' . "\n" .
    \   '	    let &l:%s = s:%s' . "\n" .
    \   '	else' . "\n" .
    \   '	    setlocal %s=' . "\n" .
    \   '	endif' . "\n" .
    \   '    else' . "\n" .
    \   '	if ! empty(&g:%s) && ! empty(&l:%s)' . "\n" .
    \   '	    " user did :set %s=...' . "\n" .
    \   '	    let s:%s = &l:%s' . "\n" .
    \   '	endif' . "\n" .
    \   '    endif' . "\n" .
    \   'endfunction' . "\n" .
    \   '', a:optionName)
endfunction
function! s:CreateFunctions( optionName ) abort
    execute 'let l:isFlag = (type(&' . s:optionName . ') == type(0))'
    if l:isFlag
	call s:CreateFunctionsForFlag(s:optionName)
    else
	call s:CreateFunctionsForOptionValue(s:optionName)
    endif
endfunction
function! s:Init( optionName ) abort
    execute s:Expand('let s:%s = &g:%s', a:optionName)
endfunction
function! s:CreateAutocommands( optionName ) abort
    augroup CursorLine
	execute s:Expand(
	\   '    autocmd VimEnter,WinEnter,BufWinEnter * call <SID>OnEnter_%s()' .
	\   '', a:optionName)
	execute s:Expand(
	\   '    autocmd WinLeave                      * call <SID>OnLeave_%s()' .
	\   '', a:optionName)
    augroup END
endfunction

augroup CursorLine
    autocmd!
augroup END
for s:optionName in g:CursorLineCurrentWindow_OptionNames
    call s:CreateFunctions(s:optionName)
    call s:Init(s:optionName)
    call s:CreateAutocommands(s:optionName)
endfor
unlet! s:optionName
delfunction s:Expand
delfunction s:CreateFunctionsForFlag
delfunction s:CreateFunctionsForOptionValue
delfunction s:CreateFunctions
delfunction s:Init
delfunction s:CreateAutocommands

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
