-- GitHub Copilot Chat configuration for LazyVim
-- All keymaps under <leader>a (AI)

local prompts = {
  BetterNamings = "Please provide better names for the following variables and functions.",
  Concise = "Please rewrite the following text to make it more concise.",
  -- CreateAPost = [["Please provide documentation for the following code to post it in social media, like LinkedIn.
  --                 Make it deep, well explained, easy to understand, fun and engaging."]],
  Documentation = "Please provide documentation for the following code.",
  DocumentationForGithub = "Please provide documentation for the following code ready for GitHub using markdown.",
  Explain = "Please explain how the following code works.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  --[[   JsDocs = "Please provide JSDocs for the following code.", ]]
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Summarize = "Please summarize the following text.",
  -- SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  -- SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  TranslateToEnglish = [["Please translate the following markdown content to English.
                      Maintain the exact same structure, formatting, headings, lists, code blocks, links,
                      and any other markdown elements. Only translate the text content, keeping all markdown 
                      syntax unchanged."]],
  Wording = "Please improve the grammar and wording of the following text.",
  TranslateCodeToEnglish = [["Please translate all comments, print statements, variable names, function names, and any 
              other text in the following code to English. Maintain the original logic and structure, ensure the translations are clear 
              and idiomatic, and follow standard English naming conventions (camelCase, snake_case, etc. as appropriate for the language)."]],
  ConventionalCommit = [["Generate a Conventional Commit message for the following code changes using the format
                    'type(scope): description'. Choose the appropriate type (feat, fix, docs, refactor, etc.) and write a clear, concise description."]],
}

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    cmd = "CopilotChat",
    opts = {
      prompts = prompts,
      system_prompt = [[
Hi, I'm juanQnav. You are my personal assistant. Act as a professional, approachable, and direct AI assistant who helps me grow professionally.

- When explaining technical concepts, provide practical examples and enough context to make them easy to understand.
- Structure your answers clearly, using sections, lists, or steps when necessary.
- Be pragmatic and direct; avoid unnecessary fluff, but keep a friendly tone.
- When providing code, write comments in English and briefly explain what each part does if applicable.
- Focus on responses that help me learn and apply knowledge professionally.

Your goal is to make every answer useful, clear, and aligned with my style: professional, approachable, and pragmatic.
]],
      model = "claude-sonnet-4.5",
      answer_header = "🤖 juanQnav assistant> ",
      auto_insert_mode = true,
      window = {
        layout = "horizontal",
        width = 0.8,
        height = 0.6,
      },
      mappings = {
        complete = {
          insert = "<Tab>",
        },
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-l>",
          insert = "<C-l>",
        },
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        toggle_sticky = {
          normal = "grr",
        },
        clear_stickies = {
          normal = "grx",
        },
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        jump_to_diff = {
          normal = "gj",
        },
        quickfix_answers = {
          normal = "gqa",
        },
        quickfix_diffs = {
          normal = "gqd",
        },
        yank_diff = {
          normal = "gy",
          register = '"',
        },
        show_diff = {
          normal = "gd",
          full_diff = false,
        },
        show_info = {
          normal = "gi",
        },
        show_context = {
          normal = "gc",
        },
        show_help = {
          normal = "gh",
        },
      },
    },
    keys = {
      -- Toggle Copilot Chat
      {
        "<leader>aa",
        function()
          local chat = require("CopilotChat")
          chat.toggle()
        end,
        desc = "Toggle Copilot Chat",
        mode = { "n", "v" },
      },
      -- Quick question
      {
        "<leader>aq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input)
          end
        end,
        desc = "Quick question",
        mode = { "n", "v" },
      },
      -- Select from available prompts (alphabetically sorted)
      {
        "<leader>ap",
        function()
          local sorted_prompts = vim.tbl_keys(prompts)
          table.sort(sorted_prompts)
          vim.ui.select(sorted_prompts, {
            prompt = "Select a prompt:",
          }, function(choice)
            if choice then
              vim.cmd("CopilotChat" .. choice)
            end
          end)
        end,
        desc = "Select prompt",
        mode = { "n", "v" },
      },
      -- Show help
      {
        "<leader>ah",
        ":CopilotChatHelp<cr>",
        desc = "Show help",
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      -- Visual configuration for chat buffer
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = false
          vim.opt_local.signcolumn = "no"
        end,
      })

      chat.setup(opts)
    end,
  },
  -- Integration with blink.cmp
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        providers = {
          path = {
            enabled = function()
              return vim.bo.filetype ~= "copilot-chat"
            end,
          },
        },
      },
    },
  },
}
