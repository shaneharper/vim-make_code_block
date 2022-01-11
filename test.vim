" Run this from a shell:
"  vim -u test.vim

let s:cpoptions_save = &cpoptions
set cpoptions&vim

set noswapfile
set noexpandtab
set shiftwidth=0

let s:failed_test_log = ""

try

function s:test(tests)
    for [test_name, buffer_text, normal_mode_command, expected_buffer_text] in a:tests
        call setline(1, split(buffer_text, "\n"))
        execute 'normal G'.normal_mode_command.(normal_mode_command[0] !=? 'V' ? '<CURSOR>' : '')  | " (Assume that except where a visual mode mapping was used that a:normal_mode_command will put vim in insert mode - we then insert '<CURSOR>'.)
        if expected_buffer_text !=# getline(1, "$")
            let s:failed_test_log .= test_name." (".&filetype.") test failed.\nBuffer:\n".join(getline(1,"$"),"\n")."\n\n"
        endif
        normal ggdG
    endfor
endfunction

function s:echomsg_multiline(msg)
    for line in split(a:msg, "\n")
        echomsg empty(line) ? ' ' : line  | " echomsg '' doesn't output a blank line. To get a blank line we output a space.
    endfor
endfunction


source plugin/code_block_markers.vim

set filetype=c  " {{{1
set cindent
call s:test([
        \ ['function_without_arguments',
        \   'void no_args',
        \   "\<c-j>",
        \   ['void no_args()', '{', "\t<CURSOR>", '}']
        \ ],
        \ ['function_without_arguments - insert mode',
        \   'void no_args',
        \   "i\<c-j>",
        \   ['void no_args()', '{', "\t<CURSOR>", '}']
        \ ],
        \ ['make_block_of_visual_selection',
        \   'doit();',
        \   "V\<c-k>",
        \   ['{', "\<tab>doit();", '}']
        \ ]])
set nocindent
" }}}1

set filetype=cmake  " {{{1
call s:test([
        \ ['function',
        \   'function(f a',
        \   "\<c-j>",
        \   ['function(f a)', '<CURSOR>', 'endfunction()']
        \ ],
        \ ['if',
        \   'if (0',
        \   "\<c-j>",
        \   ['if (0)', '<CURSOR>', 'endif()']
        \ ],
        \ ['else',
        \   "if(0)\nelse()",
        \   "\<c-k>",
        \   ['if(0)', 'else()', '<CURSOR>', 'endif()']
        \ ],
        \ ['elseif',
        \   "if(0)\nelseif(1",
        \   "\<c-j>",
        \   ['if(0)', 'elseif(1)', '<CURSOR>', 'endif()']
        \ ],
        \ ['macro',
        \   'macro(my_macro)',
        \   "\<c-k>",
        \   ['macro(my_macro)', '<CURSOR>', 'endmacro()']
        \ ],
        \ ['while',
        \   'while (1)',
        \   "\<c-k>",
        \   ['while (1)', '<CURSOR>', 'endwhile()']
        \ ]])
" }}}1

set filetype=cpp  " {{{1
set cindent
call s:test([
        \ ['add_closing_bracket',
        \   'void f(int a',
        \   "\<c-j>",
        \   ['void f(int a)', '{', "\t<CURSOR>", '}']
        \ ],
        \ ['add_closing_bracket__opening_bracket_is_on_a_different_line',
        \   "void f(int a\nint b",
        \   "\<c-j>",
        \   ['void f(int a', 'int b)', '{', "\t<CURSOR>", '}']
        \ ],
        \ ['struct',
        \   'struct S',
        \   "\<c-k>",
        \   ['struct S', '{', "\t<CURSOR>", '};']
        \ ],
        \ ['struct - insert mode',
        \   'struct S',
        \   "i\<c-k>",
        \   ['struct S', '{', "\t<CURSOR>", '};']
        \ ]])
set nocindent
" }}}1

set filetype=cs  " (c-sharp)  {{{1
call s:test([
        \ ['struct',
        \   'struct S',
        \   "\<c-k>",
        \   ['struct S', '{', '<CURSOR>', '}']
        \ ],
        \ ['#region',
        \   '#region X',
        \   "\<c-k>",
        \   ['#region X', '<CURSOR>', '#endregion']
        \ ]])
" }}}1

set filetype=dosbatch  " {{{1
call s:test([
        \ ['if',
        \   'IF ERRORLEVEL 1',
        \   "\<c-k>",
        \   ['IF ERRORLEVEL 1 (', '<CURSOR>', ')']
        \ ],
        \ ['for',
        \   'FOR /F "delims=" %%a IN (''dir /b *.bat'') DO',
        \   "\<c-k>",
        \   ['FOR /F "delims=" %%a IN (''dir /b *.bat'') DO (', '<CURSOR>', ')']
        \ ]])
" }}}1

set filetype=sh  " {{{1
" See: filetype=zsh
call s:test([
        \ ['if',
        \   'if [ -d dir ]',
        \   "\<c-k>",
        \   ['if [ -d dir ]; then', '<CURSOR>', 'fi']
        \ ],
        \ ['if2',
        \   'if [ -d dir ];  then',
        \   "\<c-k>",
        \   ['if [ -d dir ];  then', '<CURSOR>', 'fi']
        \ ],
        \ ['if__add_then_fi',
        \   'if [ -d dir ];',
        \   "\<c-k>",
        \   ['if [ -d dir ]; then', '<CURSOR>', 'fi']
        \ ],
        \ ['if__add_semicolon_then_fi',
        \   'if [ -d dir ]',
        \   "\<c-k>",
        \   ['if [ -d dir ]; then', '<CURSOR>', 'fi']
        \ ]])
" XXX    \ ['if__add_closing_square_bracket',
"        \   'if [ -d dir',
"        \   "\<c-k>",
"        \   ['if [ -d dir ]; then', '<CURSOR>', 'fi']
"        \ ], " XXX Also add test: Add "]]" to match "[[".

call s:test([
        \ ['for',
        \   "#!/bin/sh\nfor i in hello world;  do",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'for i in hello world;  do', '<CURSOR>', 'done']
        \ ],
        \ ['case',
        \   "#!/bin/sh\ncase $v in",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'case $v in', '<CURSOR>', 'esac']
        \ ],
        \ ['function',
        \   "#!/bin/sh\nfunction f",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'function f', '{', '<CURSOR>', '}']
        \ ],
        \ ['function_name_followed_by_brackets',
        \   "#!/bin/sh\nmyfunction()",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'myfunction()', '{', '<CURSOR>', '}']
        \ ]])
" }}}1

set filetype=vim  " {{{1
call s:test([
        \ ['slash_doesnt_always_indicate_a_continuation_line',
        \   'for e in f("\n")',
        \   "\<c-k>",
        \   ['for e in f("\n")', '<CURSOR>', 'endfor']
        \ ],
        \ ['augroup',
        \   'augroup my_group',
        \   "\<c-k>",
        \   ['augroup my_group', '<CURSOR>', 'augroup END']
        \ ],
        \ ['redir',
        \   'redir => o',
        \   "\<c-k>",
        \   ['redir => o', '<CURSOR>', 'redir END']
        \ ]])
" }}}1

set filetype=zsh  " {{{1
" See: filetype=sh
call s:test([
        \ ['if',
        \   'if [ -d dir ]',
        \   "\<c-k>",
        \   ['if [ -d dir ]; then', '<CURSOR>', 'fi']
        \ ]])
" }}}1

call s:echomsg_multiline(empty(s:failed_test_log) ? "Ok." : s:failed_test_log)

quitall!

catch
    echomsg v:exception
endtry


let &cpoptions = s:cpoptions_save

" vim:set foldmethod=marker:
