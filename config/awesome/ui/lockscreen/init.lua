local awful = require("awful")
local gfs = require('gears.filesystem')

local lock_screen = {}

local config_dir = gfs.get_configuration_dir()
package.cpath = package.cpath .. ";" .. config_dir .. "ui/lockscreen/lib/?.so;"

lock_screen.init = function()
    local pam = require("liblua_pam")
    lock_screen.authenticate = function(password)
        local success, err = pam.auth_current_user(password)
        if not success then
            print("Authentication failed:", err)
        end
        return success
    end
    require("ui.lockscreen.lockscreen")
end

return lock_screen
