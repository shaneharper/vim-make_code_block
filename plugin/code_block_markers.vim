" vim-code_block_markers
" Author: Shane Harper <shane@shaneharper.net>

if exists("g:loaded_code_block_markers_plugin") | finish | endif
let g:loaded_code_block_markers_plugin = 1


" C/C++ block mappings ---------------------------------------------------- {{{

" Ctrl-k : insert {}s (Mnemonic: 'k'urly)
" (I wanted to use Shift-<CR> but unfortunately it's not possible to map Shift-<CR> differently to <CR> when running Vim in a terminal window.)
" Note: '{' isn't mapped because sometimes we want to have {}s on the one line.
autocmd FileType c,cpp inoremap <buffer> <c-k> <Esc>:call <SID>add_curly_brackets_and_semicolon_if_required()<CR>O
autocmd FileType c,cpp nnoremap <buffer> <c-k> :call <SID>add_curly_brackets_and_semicolon_if_required()<CR>O
autocmd FileType c,cpp vnoremap <buffer> <c-k> >`<O{<Esc>`>o}<Esc>
" XXX ^ nice to add a ';' after the '}' if line before first line of visual selection is the start of a struct/class/enum/union.
" XXX XXX ^ nice to check if selected text is already indented, if so don't indent with '>'
" XXX To do: insert #endif after #if, #ifdef, #ifndef.

" Ctrl-j : insert empty argument list and {}s for a function that takes no arguments. (Mnemonic: 'j' is beside 'k' on a Qwerty keyboard, and this is similar to Ctrl-k)
autocmd FileType c,cpp inoremap <buffer> <c-j> <Esc>A()<CR>{<CR>}<Esc>O
autocmd FileType c,cpp nnoremap <buffer> <c-j> A()<CR>{<CR>}<Esc>O
" XXX Ctrl-j after the start of a struct/class/... def'n could function as ctrl-k does and also insert the start of a constructor signature.

" jj : continue insertion past end of current block (Mnemonic: 'j' moves down in normal mode.)
autocmd FileType c,cpp inoremap <buffer> jj <Esc>]}A<CR>


function s:add_curly_brackets_and_semicolon_if_required()
    let initial_line_text = getline('.')

    execute "normal! o{\<CR>}"

    let is_a_record_definition = (initial_line_text =~# '\(\<class\>\|\<enum\>\|\<struct\>\|\<union\>\)'
                                                     \ .'[^)]*$')  " [small HACK] Filter out lines contains a ')', e.g. 'struct S* fn()' and 'if (struct S* v = fn())'
    let is_an_assignment = (initial_line_text =~# '=$')  " Assume "struct initialization", e.g. MyStruct m = { 1,3,3 };
    if is_a_record_definition || is_an_assignment
        normal! a;
    endif
endfunction

" }}}


" Vimscript block mappings ------------------------------------------------ {{{
autocmd FileType vim inoremap <buffer> <c-k> <Esc>:call <SID>insert_vim_end_of_block_keyword()<CR>O
autocmd FileType vim nnoremap <buffer> <c-k> :call <SID>insert_vim_end_of_block_keyword()<CR>O

autocmd FileType vim inoremap <buffer> <c-j> ()<Esc>:call <SID>insert_vim_end_of_block_keyword()<CR>O
autocmd FileType vim nnoremap <buffer> <c-j> A()<Esc>:call <SID>insert_vim_end_of_block_keyword()<CR>O

autocmd FileType vim inoremap <buffer> jj <Esc>:call search('\<end')<CR>o


function s:insert_vim_end_of_block_keyword()
    let block_type = substitute(substitute(getline('.'), " *", "", ""), "[ !].*", "", "")
    if block_type =~# 'catch\|finally'
        let block_type = 'try'
    endif
    execute "normal! oend".block_type
endfunction
" }}}


" Shell script block mappings --------------------------------------------- {{{
autocmd FileType sh inoremap <buffer> <c-k> <Esc>:call <SID>insert_shell_script_block_start_and_end_keywords()<CR>O
autocmd FileType sh nnoremap <buffer> <c-k> :call <SID>insert_shell_script_block_start_and_end_keywords()<CR>O

autocmd FileType sh inoremap <buffer> jj <Esc>:call <SID>move_to_end_of_shell_script_block()<CR>o


function s:insert_shell_script_block_start_and_end_keywords()
    if getline('.') =~# '^\s*if'
        if getline('.') !~# '; then'
            normal A; then
        endif
        normal ofi
    elseif getline('.') =~# '^\s*function'
        normal o{
        normal o}
    else
        if getline('.') !~# '; do'
            normal A; do
        endif
        normal odone
    endif
endfunction

function s:move_to_end_of_shell_script_block()
    call search('\<fi\|\<done\|^}')
endfunction
" }}}


" vim:set foldmethod=marker:
