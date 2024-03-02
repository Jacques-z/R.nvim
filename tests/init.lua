-- TODO: This file should be in tests/xdg/config/nvim
-- TODO: This file should be modified to work with tests/run
--
-- This file is adapted from github.com/folke
-- This is a custom config file used in tests
local M = {}

--- Returns the root directory for the calling script, optionally appending a given subpath.
-- @param root Optional subpath to append to the root directory.
-- @return The absolute path of the root directory, with or without the appended subpath.
function M.root(root)
    -- Retrieves the source file path of the calling function, removing the initial "@" character.
    local f = debug.getinfo(1, "S").source:sub(2)
    -- Modifies the file path to get its parent's parent directory and appends a "/" and any root path provided.
    return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

--- Loads a plugin by cloning it into a specific directory if it doesn't already exist.
-- This function checks if the plugin directory exists, and if not, it clones the plugin
-- from its GitHub repository.
-- @param plugin The GitHub repository path of the plugin to be loaded (e.g., "username/plugin").
function M.load(plugin)
    -- Extracts the name of the plugin from its path.
    local name = plugin:match(".*/(.*)")
    -- Constructs the path to the plugin directory.
    local package_root = M.root(".tests/site/pack/deps/start/")
    -- Checks if the plugin directory does not exist.
    if not vim.loop.fs_stat(package_root .. name) then
        -- Notifies the user that the plugin is being installed.
        print("Installing " .. plugin)
        -- Creates the plugin directory if it doesn't exist, including parent directories as needed.
        vim.fn.mkdir(package_root, "p")
        -- Clones the plugin repository into the specified directory.
        vim.fn.system({
            "git",
            "clone",
            "--depth=1",
            "https://github.com/" .. plugin .. ".git",
            package_root .. "/" .. name,
        })
    end
end

--- Configures Neovim for testing by setting up runtime and package paths, loading essential plugins,
-- and defining custom directories for configuration, data, state, and cache.
--TODO: Replace the multiple calls to M.root with a variable
function M.setup()
    -- Resets the runtimepath to its default, ensuring a clean starting point.
    vim.cmd([[set runtimepath=$VIMRUNTIME]])

    -- Appends the project's root directory to the runtime path.
    -- The root directory is determined by the `M.root()` function.
    vim.opt.runtimepath:append(M.root())

    -- Sets the package path specifically for plugin loading, pointing to a custom directory
    -- structured for testing. This ensures that any plugins loaded during the tests do not interfere
    -- with the user's regular Neovim setup.
    vim.opt.packpath = { M.root(".tests/site") }

    -- Ensures the 'plenary.nvim' plugin is loaded
    M.load("nvim-lua/plenary.nvim")

    -- Sets custom environment variables, pointing to directories within '.tests/'.
    -- These custom paths isolate the test environment's configuration, data, state, and cache from the user's regular Neovim environment.

    vim.env.XDG_TEST_HOME = M.root(".tests")

    -- Configuration files directory for the test environment.
    vim.env.XDG_CONFIG_HOME = M.root(".tests/config")

    -- used for storing machine-local data.
    vim.env.XDG_DATA_HOME = M.root(".tests/data")

    -- used for storing state information that should persist between (automatic) restarts of the application.
    vim.env.XDG_STATE_HOME = M.root(".tests/state")

    -- used for storing non-essential data that can be regenerated by the application.
    vim.env.XDG_CACHE_HOME = M.root(".tests/cache")
end

-- Call the setup function.
M.setup()
