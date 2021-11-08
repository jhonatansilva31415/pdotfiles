local M = {}

local actions = require('telescope.actions')
local action_set = require('telescope.actions.set')

require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
})

require('telescope').setup {
  extensions = {
    project = {
      base_dirs = {
        {'/storage/projects', max_depth = 2},
      },
      hidden_files = true -- default: false
    }
  }
}

-- SETUP for grepping and findind personal things
function M.edit_neovim()
  require('telescope.builtin').find_files {
    prompt = '~ Nvim ~',
    prompt_title = '~ Nvim ~',
    shorten_path = false,
    cwd = '~/.config/nvim',
  }
end

function M.grep_personal_notes()
  require('telescope.builtin').live_grep {
    prompt = '~ Personal Notes ~',
    prompt_title = '~ Personal Notes ~',
    shorten_path = false,
    cwd = '/storage/notes/notes',
    prompt_prefix="> ",
    layout_strategy='horizontal',
    layout_config={
      preview_width=0.75,
    },
  }
end

return M
