# cmp-github

## Requirements

- `neovim >= 0.6`
- `gh` cli

## Installation

### Packer
```lua
use({
  "hrsh7th/nvim-cmp",
  requires = {
    { 
      "richardmarbach/cmp-github" 
      requires = "nvim-lua/plenary.nvim"
    },
  },
})


require('cmp').setup({
  sources = {
    { name = "github" },
  },
})

```


### Vim-Plug
```vim
Plug "nvim-lua/plenary.nvim"
Plug "hrsh7th/nvim-cmp"
Plug "richardmarbach/cmp-github" 

lua << EOF
require('cmp').setup({
  sources = {
    { name = "github" },
  },
})
EOF
```

## Usage

The completion source is only enabeld for `gitcommit` filetypes. Typing `issue: ` or `#` triggers the completion of issues.
