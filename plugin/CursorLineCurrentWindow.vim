" CursorLineCurrentWindow.vim: Only highlight the screen line of the cursor in the currently active window.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	08-Jun-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_CursorLineCurrentWindow') || (v:version < 700)
    finish
endif
let g:loaded_CursorLineCurrentWindow = 1

"- functions -------------------------------------------------------------------

" Note: We use both global and local values of 'cursorline' to store the states,
" though 'cursorline' is window-local and only the &l:cursorline value
" effectively determines the visibility of the highlighting. This makes for a
" better value inheritance when splitting windows than a separate window-local
" variable would.

function! s:GetGlobal( optionName ) abort
    execute 'return &g:' . a:optionName
endfunction
function! s:GetLocal( optionName ) abort
    execute 'return &l:' . a:optionName
endfunction
function! s:SetGlobal( optionName, value ) abort
    execute 'let &g:' . a:optionName . ' = a:value'
endfunction
function! s:Set( optionName, value ) abort
    execute 'let &' . a:optionName . ' = a:value'
endfunction
function! s:SetLocal( optionName, value ) abort
    execute 'let &l:' . a:optionName . ' = a:value'
endfunction
function! s:GetPersistent( optionName ) abort
    let l:varName = 'w:persistent_' . a:optionName
    if exists(l:varName)
	execute 'return' l:varName
    else
	return 0
    endif
endfunction
function! s:CursorLineOnEnter()
    if ! empty(s:store['cursorline'])
	if ! empty(s:GetGlobal('cursorline')) || ! empty(s:GetPersistent('cursorline'))
	    call s:SetLocal('cursorline', s:store['cursorline'])
	else
	    call s:SetGlobal('cursorline', s:store['cursorline'])
	endif
    else
	let l:offValue = (type(s:store['cursorline']) == type(0) ? 0 : '')
	call s:SetLocal('cursorline', l:offValue)
    endif
endfunction
function! s:CursorLineOnLeave()
    if ! empty(s:store['cursorline'])
	if ! empty(s:GetLocal('cursorline'))
	    if empty(s:GetGlobal('cursorline'))
		" user did :setlocal cursorline
		call s:Set('cursorline', s:GetLocal('cursorline'))
	    endif
	else
	    if ! empty(s:GetGlobal('cursorline'))
		" user did :setlocal nocursorline
		call s:Set('cursorline', s:GetLocal('cursorline'))
		set nocursorline
	    else
		" user did :set nocursorline
		let s:store['cursorline'] = s:GetLocal('cursorline')
	    endif
	endif

	let l:offValue = (type(s:store['cursorline']) == type(0) ? 0 : '')
	let l:persistentValue = s:GetPersistent('cursorline')
	if ! empty(l:persistentValue)
	    call s:SetGlobal('cursorline', l:offValue)
	    call s:SetLocal('cursorline', l:persistentValue)
	else
	    call s:SetLocal('cursorline', l:offValue)
	endif
    else
	if ! empty(s:GetGlobal('cursorline')) && ! empty(s:GetLocal('cursorline'))
	    " user did :set cursorline
	    let s:store['cursorline'] = s:GetLocal('cursorline')
	endif
    endif
endfunction


"- autocmds --------------------------------------------------------------------

let s:store = {'cursorline': &g:cursorline}
augroup CursorLine
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * call <SID>CursorLineOnEnter()
    autocmd WinLeave                      * call <SID>CursorLineOnLeave()
augroup END

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
