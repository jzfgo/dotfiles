-- Pins Mason's registry to a snapshot at least MIN_AGE_DAYS old, matching
-- the supply-chain rules in ~/.npmrc (min-release-age) and ~/pyproject.toml
-- (uv exclude-newer). Mason installs the exact versions its registry pins,
-- so delaying the registry is the only way to delay the packages — pip has
-- no minimum-age setting, and npm's would otherwise just make installs fail.
--
-- registry() is read synchronously at startup from a state file; refresh()
-- updates that file in the background at most once a day. A new pin takes
-- effect on the next nvim start.

local M = {}

local MIN_AGE_DAYS = 7
local REFRESH_INTERVAL = 24 * 60 * 60
local REGISTRY = "github:mason-org/mason-registry"
local STATE_FILE = vim.fn.stdpath "state" .. "/mason-registry-pin.json"
local RELEASES_URL = "https://api.github.com/repos/mason-org/mason-registry/releases?per_page=100"

local function read_state()
  local f = io.open(STATE_FILE, "r")
  if not f then
    return nil
  end
  local ok, state = pcall(vim.json.decode, f:read "*a")
  f:close()
  return ok and state or nil
end

-- "2026-08-09T12:34:56Z" -> epoch. Interpreted through os.time's local-time
-- lens, same as utc_now(), so the timezone offsets cancel out.
local function parse_utc(iso)
  local y, mo, d, h, mi, s = iso:match "^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)"
  if not y then
    return nil
  end
  return os.time { year = y, month = mo, day = d, hour = h, min = mi, sec = s }
end

local function utc_now()
  return os.time(os.date "!*t")
end

--- Registry spec for mason.setup(): the pinned snapshot when known,
--- otherwise the floating registry (first run, or unreadable state file).
function M.registry()
  local state = read_state()
  if state and state.tag then
    return REGISTRY .. "@" .. state.tag
  end
  return REGISTRY
end

--- Refresh the pin in the background. No-op if checked within the last day;
--- on any failure the state file is left alone and we retry next startup.
function M.refresh()
  local state = read_state()
  if state and state.checked_at and os.time() - state.checked_at < REFRESH_INTERVAL then
    return
  end
  vim.system(
    { "curl", "-fsSL", "--max-time", "15", RELEASES_URL },
    { text = true },
    function(out)
      if out.code ~= 0 or not out.stdout then
        return
      end
      local ok, releases = pcall(vim.json.decode, out.stdout)
      if not ok or type(releases) ~= "table" then
        return
      end
      local cutoff = utc_now() - MIN_AGE_DAYS * 24 * 60 * 60
      for _, rel in ipairs(releases) do -- newest first
        local published = rel.published_at and parse_utc(rel.published_at)
        if published and published <= cutoff and not rel.draft and not rel.prerelease then
          local f = io.open(STATE_FILE, "w")
          if f then
            f:write(vim.json.encode { tag = rel.tag_name, checked_at = os.time() })
            f:close()
          end
          return
        end
      end
    end
  )
end

return M
