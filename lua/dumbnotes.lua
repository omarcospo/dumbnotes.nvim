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
    local path
    if input == true or input ~= "" then
      if ext then
        path = vim.fn.expand(opts.notes_path .. "/" .. input .. "." .. opts.notes_format)
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      else
        path = vim.fn.expand(opts.notes_path .. "/" .. input)
        if vim.fn.filereadable(path) == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        else
          print("Invalid note: " .. path)
        end
      end
    else
      print("Invalid note.")
    end
  end

  local function open_note(prompt_bufnr, opts)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    open(selection[1], false, opts)
  end

  local function delete_note(prompt_bufnr, opts)
    local selection = action_state.get_selected_entry()
    local file_path = vim.fn.expand(opts.notes_path .. "/" .. selection[1])
    actions.close(prompt_bufnr)
    if vim.fn.filereadable(file_path) == 1 then
      local confirm = vim.fn.confirm("Delete note: " .. file_path .. "?", "&Yes\n&No")
      if confirm == 1 then
        local ok, err = os.remove(file_path)
        if not ok then
          print("Error deleting note: " .. err)
        else
          print("Deleted note: " .. file_path)
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
    if ok then
      open(input, true, opts)
    else
      print("Error creating note: " .. input)
    end
  end

  require("telescope.builtin").find_files({
    prompt_title = "Notes",
    cwd = opts.notes_path,
    find_command = function()
      if opts.find_recursively == true then
        opts.find_recursively = {}
      else
        opts.find_recursively = { "-d", "1" }
      end
      return { "fd", "--extension", opts.notes_format, unpack(opts.find_recursively) }
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
