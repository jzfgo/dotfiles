-- Prose word count for the statusline.
--
-- vim.fn.wordcount() counts the buffer verbatim, so in markdown the YAML
-- frontmatter, the heading markers and the contents of fenced code blocks all
-- inflate the number (a small test file scored 22 against the 11 words a human
-- would count). Treesitter's markdown grammar keeps prose in `inline` nodes,
-- which minus_metadata/plus_metadata (frontmatter) and fenced_code_block never
-- contain, so querying for those nodes drops the markup without any regex.
--
-- Two deliberate fallbacks to wordcount():
--   * visual mode -- the treesitter walk covers the whole buffer, and a
--     selection is nearly always prose anyway, so visual_words is fine there
--   * no markdown parser -- better a slightly-off count than an empty block

local M = {}

local FILETYPES = { markdown = true, mdx = true }

-- NvChad drives the statusline with `%!`, so this runs on every redraw --
-- which includes every keystroke, since the cursor module moves with you.
-- Walking every inline node that often measured 4.7ms/keystroke on a 44k-word
-- document, so the count is memoized on changedtick and, when the buffer is
-- actively changing, recomputed at most every THROTTLE_MS. A count that lags a
-- fifth of a second behind the keyboard is invisible; the input lag was not.
local cache = {}
local THROTTLE_MS = 200
local THROTTLE_NS = THROTTLE_MS * 1e6
local redraw_queued = false

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  callback = function(args)
    cache[args.buf] = nil
  end,
})

local query

local function prose_words(buf)
  local hit = cache[buf]
  local tick = vim.b[buf].changedtick
  -- hrtime, not uv.now(): the latter is loop time, frozen within an iteration
  local now = vim.uv.hrtime()

  if hit and hit.tick == tick then
    return hit.count
  end

  if hit and now - hit.at < THROTTLE_NS then
    -- Serving a stale count. Nothing guarantees another redraw once typing
    -- stops, so queue one for when the window closes or the number would
    -- simply stay wrong until the cursor next moves.
    if not redraw_queued then
      redraw_queued = true
      vim.defer_fn(function()
        redraw_queued = false
        vim.cmd.redrawstatus()
      end, THROTTLE_MS)
    end
    return hit.count
  end

  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then
    return nil
  end

  if not query then
    query = vim.treesitter.query.parse("markdown", "(inline) @i")
  end

  local count = 0
  for _, node in query:iter_captures(parser:parse()[1]:root(), buf) do
    for _ in vim.treesitter.get_node_text(node, buf):gmatch "%S+" do
      count = count + 1
    end
  end

  cache[buf] = { tick = tick, count = count, at = now }
  return count
end

-- NvChad statusline module: renders a block in the minimal theme's style
M.statusline = function()
  local utils = require "nvchad.stl.utils"

  -- wordcount() takes no buffer argument and always reads the current buffer,
  -- so an inactive split's statusline would report the active buffer's count
  if not utils.is_activewin() then
    return ""
  end

  local buf = utils.stbufnr()
  if not FILETYPES[vim.bo[buf].filetype] then
    return ""
  end

  local wc = vim.fn.wordcount()
  local count = wc.visual_words or prose_words(buf) or wc.words

  local sep = utils.separators[require("nvconfig").ui.statusline.separator_style] or utils.separators.block

  return "%#St_Pos_sep#" .. sep.left .. "%#St_Pos_txt# " .. count .. "w %#St_sep_r#" .. sep.right .. " %#ST_EmptySpace#"
end

return M
