return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>gn",
        function()
          local Snacks = require("snacks")
          Snacks.input({
            prompt = "Issue title: ",
          }, function(title)
            if not title or title == "" then
              return
            end

            Snacks.input({
              prompt = "Issue body: ",
            }, function(body)
              body = body or ""

              vim.system({
                "gh",
                "issue",
                "create",
                "--title",
                title,
                "--body",
                body,
              }, { text = true }, function(obj)
                vim.schedule(function()
                  if obj.code == 0 then
                    vim.notify("Issue created successfully")
                  else
                    vim.notify(obj.stderr, vim.log.levels.ERROR)
                  end
                end)
              end)
            end)
          end)
        end,
        desc = "Create GitHub Issue",
      },
    },
  },
}
