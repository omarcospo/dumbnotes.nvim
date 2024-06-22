local dumbnotes = {}
local opts = {}

dumbnotes.config = {
  notes_format = "md",
  notes_path = "~/Notes",
  find_recursively = false,
  mappings = {
    new_note_key = "<C-n>",
    delete_note_key = "<C-d>",
  },
}

dumbnotes.setup = function(user_opts)
  _G.dumbnotes = dumbnotes
  opts = vim.tbl_deep_extend("force", dumbnotes.config, user_opts or {})
  vim.api.nvim_create_user_command("DumbNotes", function()
    dumbnotes.list_notes(opts)
  end, {})
  vim.api.nvim_create_user_command("DumbNotesGrep", function()
    dumbnotes.search_notes(opts)
  end, {})
end

function dumbnotes.list_notes(opts)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function open(input, ext, opts)
    if input or input ~= "" then
      local path = vim.fn.expand(opts.notes_path .. "/" .. input .. (ext and ("." .. opts.notes_format) or ""))
      if ext or vim.fn.filereadable(path) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      else
        print("Invalid note: " .. path)
      end
    else
      print("Invalid note.")
    end
  end

  local function open_note(prompt_bufnr, opts)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    open(selection.value, false, opts)
  end

  local function delete_note(prompt_bufnr, opts)
    local selection = action_state.get_selected_entry()
    local file_path = vim.fn.expand(opts.notes_path .. "/" .. selection.value)
    actions.close(prompt_bufnr)
    if vim.fn.filereadable(file_path) == 1 then
      local confirm = vim.fn.confirm("Delete note: " .. file_path .. "?", "&Yes\n&No")
      if confirm == 1 then
        local ok, err = os.remove(file_path)
        if ok then
          print("Deleted note: " .. file_path)
        else
          print("Error deleting note: " .. err)
        end
      else
        print("Deletion cancelled.")
      end
    else
      print("Note not found: " .. file_path)
    end
  end

  local function new_note_prompt(prompt_bufnr, opts)
    actions.close(prompt_bufnr)
    local ok, input = pcall(function()
      return vim.fn.input({ prompt = "Note title: " })
    end)
    if ok and input ~= "" then
      open(input, true, opts)
    else
      print("Error creating note: " .. (input or "Invalid input"))
    end
  end

  require("telescope.builtin").find_files({
    prompt_title = "Notes",
    cwd = opts.notes_path,
    find_command = function()
      return { "fd", "--extension", opts.notes_format, opts.find_recursively and "" or "-d 1" }
    end,
    attach_mappings = function(prompt_bufnr, map)
      map({ "i", "n" }, "<CR>", function()
        open_note(prompt_bufnr, opts)
      end)
      map({ "i", "n" }, opts.mappings.delete_note_key, function()
        delete_note(prompt_bufnr, opts)
      end)
      map({ "i", "n" }, opts.mappings.new_note_key, function()
        new_note_prompt(prompt_bufnr, opts)
      end)
      return true
    end,
  })
end

function dumbnotes.search_notes(opts)
  require("telescope.builtin").live_grep({
    prompt_title = "Search Notes",
    cwd = opts.notes_path,
    glob_pattern = "*." .. opts.notes_format,
  })
end

return dumbnotes
