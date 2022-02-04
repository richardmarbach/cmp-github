# github-cmp


## Requirements

Requires that the `gh` cli is installed.

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


### Plug
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

The completion source is only enabeld for `gitcommit` filetypes. Typing `Issue: ` triggers the completion of issues.
