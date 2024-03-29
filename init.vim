" ========================================================
" vim-plug
" ========================================================
call plug#begin()

" colorscheme
Plug 'agude/vim-eldar'

" Elixir filetype support
"Plug 'elixir-editors/vim-elixir'

" From the documentation on nvim-lspconfig
Plug 'hrsh7th/nvim-compe'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

" Fuzzy finding
Plug 'junegunn/fzf.vim'


"Plug 'neovim/nvim-lspconfig'
"Plug 'preservim/nerdtree'
"Plug 'tpope/vim-fugitive'
"Plug 'tpope/vim-surround'
"Plug 'wlangstroth/vim-racket'
"Plug '/opt/homebrew/opt/fzf'
call plug#end()


" ========================================================
" Neovim LSP Setup
" ========================================================

" Followed the directions from this blog post:
" https://www.mitchellhanberg.com/how-to-set-up-neovim-for-elixir-development/

lua << EOF


---------- Keybindings-and-completion --------------------
-- Reference: https://github.com/neovim/nvim-lspconfig#Keybindings-and-completion

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
--  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end


---------- Autocompletion ------------------------------

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
    nvim_lsp = true,
    buffer = true,
    calc = true,
    vsnip = true,
    nvim_lua = true,
    spell = true,
    tags = true,
    treesitter = true
  }
}


local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

--This line is important for auto-import
vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })
vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })


------ Elixir-LS LSP Setup and Configuration

-- Neovim doesn't support snippets out of the box, so we need to mutate the
-- capabilities we send to the language server to let them know we want snippets.
-- This code is from the blog post and not the documentation
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require'lspconfig'.elixirls.setup{
  cmd = { "/Users/leo/lsp/elixir-ls/rel/language_server.sh" },
  capabilities = capabilities,
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
    },
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

require'lspconfig'.racket_langserver.setup{
  on_attach = on_attach,
  filetypes = { "racket", "scheme" }
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
set showmatch				      " Highlight the matching bracket under cursor
set tabstop=2				
set termguicolors
set hidden                " Switch buffers even if file is not saved
set rnu
set mouse=nv

let mapleader=","
nnoremap <space>c :clo<CR>
nnoremap <space>z <C-z>
nnoremap <Leader>bp :bprevious<CR>
nnoremap <space>nh :noh<CR>

" Easier split navigations
" Source https://thoughtbot.com/blog/vim-splits-move-faster-and-more-naturally
" Comment out lspconfig that conflicts with <C-K>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" FZF
nnoremap <Leader>ff :FZF<CR>
nnoremap <Leader>fg :GFiles<CR>
nnoremap <Leader>fb :Buffers<CR>
nnoremap <Leader>fl :Lines<CR>

" vim-fugitive
nnoremap <Leader>gac :Gwrite<CR>
nnoremap <Leader>gaa :Git add -A<CR>
nnoremap <Leader>gcc :Git commit<CR>
nnoremap <Leader>gcm :Git commit -m<CR>

" NERDTree - think `show` and `close`
nnoremap <leader>nt :NERDTreeToggle<CR>
let g:NERDTreeShowLineNumbers=1

" === Backups ===========================================
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set nobackup
set nowritebackup


autocmd BufEnter * :syntax sync fromstart
au BufReadPost *.rkt,*.rktl set filetype=racket

