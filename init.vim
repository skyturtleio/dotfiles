" ========================================================
" vim-plug
" ========================================================
call plug#begin()
Plug 'agude/vim-eldar'
Plug 'elixir-editors/vim-elixir'
Plug 'hrsh7th/nvim-compe'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
Plug '/opt/homebrew/opt/fzf'
call plug#end()

" ========================================================
" Neovim LSP Setup
" ========================================================

" Followed the directions from this blog post:
" https://www.mitchellhanberg.com/how-to-set-up-neovim-for-elixir-development/

lua << EOF
local lspconfig = require("lspconfig")

-- Neovim doesn't support snippets out of the box, so we need to mutate the
-- capabilities we send to the language server to let them know we want snippets.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Setup our autocompletion. These configuration options are the default ones
-- copied out of the documentation.
require "compe".setup {
  enabled = true,
  autocomplete = true,
  debug = false,
  min_length = 1,
  preselect = "disabled",
  throttle_time = 80,
  source_timeout = 200,
  incomplete_delay = 400,
  max_abbr_width = 100,
  max_kind_width = 100,
  max_menu_width = 100,
  documentation = true,
  source = {
    path = true,
    buffer = true,
    calc = true,
    vsnip = true,
    nvim_lsp = true,
    nvim_lua = true,
    spell = true,
    tags = true,
    treesitter = true
  }
}

-- A callback that will get called when a buffer connects to the language server.
-- Here we create any key maps that we want to have on that buffer.
local on_attach = function(_, bufnr)
  local function map(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local map_opts = {noremap = true, silent = true}

  map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
  map("n", "gd", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
  map("n", "dt", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
  map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", map_opts)
  map("n", "gD", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
  map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", map_opts)
  map("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)

  -- These have a different style than above because I was fiddling
  -- around and never converted them. Instead of converting them
  -- now, I'm leaving them as they are for this article because this is
  -- what I actually use, and hey, it works ¯\_(ツ)_/¯.
  vim.cmd [[imap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>']]
  vim.cmd [[smap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>']]

  vim.cmd [[imap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>']]
  vim.cmd [[smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>']]
  vim.cmd [[imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>']]
  vim.cmd [[smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>']]

  vim.cmd [[inoremap <silent><expr> <C-Space> compe#complete()]]
  vim.cmd [[inoremap <silent><expr> <CR> compe#confirm('<CR>')]]
  vim.cmd [[inoremap <silent><expr> <C-e> compe#close('<C-e>')]]
  vim.cmd [[inoremap <silent><expr> <C-f> compe#scroll({ 'delta': +4 })]]
  vim.cmd [[inoremap <silent><expr> <C-d> compe#scroll({ 'delta': -4 })]]
end

require'lspconfig'.elixirls.setup{
  cmd = { "/Users/leo/lsp/elixir-ls/rel/language_server.sh" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    elixirLS = {
      -- I choose to disable dialyzer for personal reasons, but
      -- I would suggest you also disable it unless you are well
      -- aquainted with dialzyer and know how to use it.
      dialyzerEnabled = false,
      -- I also choose to turn off the auto dep fetching feature.
      -- It often get's into a weird state that requires deleting
      -- the .elixir_ls directory and restarting your editor.
      fetchDeps = false
    }
  }
}
EOF


" === Customize my status line ===========================
set statusline=%f         " Path to the file
set statusline+=\ -\      " Separator
set statusline+=%y        " Filetype of the file
set statusline+=\ -\      " Separator
set statusline+=%{FugitiveStatusline()}


" === My settings ========================================
inoremap jj <Esc>
colorscheme eldar

"set cursorline				    " highlight current line
set expandtab				      " convert tabs to spaces
set ignorecase smartcase  " search case-sensitive if it has uppercase characters
set number 	              " show line number
set scrolloff=3
set shiftwidth=2			    " how far it will indent when using >>
set showtabline=2			    " Always show tab bar at the top
set softtabstop=2
set showmatch				      " hightlight the matching bracket under cursor
set tabstop=2				
set termguicolors
set mouse=nv

let mapleader=","
nnoremap <silent> <Leader>fa :FZF<CR>
nnoremap <silent> <Leader>ff :GFiles<CR>
nnoremap <leader>n :NERDTreeFocus<CR>

" === Backups ===========================================
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set nobackup
set nowritebackup


autocmd BufEnter * :syntax sync fromstart


" ========================================================
" Nvim  Defaults

" Syntax highlighting is enabled by default
" filetype plugin indent on" is enabled by default

" 'autoindent' is enabled
" 'autoread' is enabled
" 'background' defaults to "dark" (unless set automatically by the terminal/UI)
" 'backspace' defaults to "indent,eol,start"
" 'backupdir' defaults to .,~/.local/share/nvim/backup (|xdg|)
" 'belloff' defaults to "all"
" 'compatible' is always disabled
" 'complete' excludes "i"
" 'cscopeverbose' is enabled
" 'directory' defaults to ~/.local/share/nvim/swap// (|xdg|), auto-created
" 'display' defaults to "lastline,msgsep"
" 'encoding' is UTF-8 (cf. 'fileencoding' for file-content encoding)
" 'fillchars' defaults (in effect) to "vert:│,fold:·,sep:│"
" 'formatoptions' defaults to "tcqj"
" 'fsync' is disabled
" 'history' defaults to 10000 (the maximum)
" 'hlsearch' is enabled
" 'incsearch' is enabled
" 'langnoremap' is enabled
" 'langremap' is disabled
" 'laststatus' defaults to 2 (statusline is always shown)
" 'listchars' defaults to "tab:> ,trail:-,nbsp:+"
" 'nrformats' defaults to "bin,hex"
" 'ruler' is enabled
" 'sessionoptions' includes "unix,slash", excludes "options"
" 'shortmess' includes "F", excludes "S"
" 'showcmd' is enabled
" 'sidescroll' defaults to 1
" 'smarttab' is enabled
" 'startofline' is disabled
" 'tabpagemax' defaults to 50
" 'tags' defaults to "./tags;,tags"
" 'ttimeoutlen' defaults to 50
" 'ttyfast' is always set
" 'viewoptions' includes "unix,slash"
" 'undodir' defaults to ~/.local/share/nvim/undo (|xdg|), auto-created
" 'viminfo' includes "!"
" 'wildmenu' is enabled
" 'wildoptions' defaults to "pum,tagfile"

" |man.vim| plugin is enabled, so |:Man| is available by default.
" |matchit| plugin is enabled. To disable it in your config:

