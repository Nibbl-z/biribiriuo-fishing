local inventory = {}
local fishes = require("modules.fishes")
inventory.Inventory = {}

function inventory:Load()
    for fish, _ in pairs(fishes) do
        self.Inventory[fish] = 0
    end
end

function inventory:GetCount()
    local count = 0
    
    for k, v in pairs(self.Inventory) do
        count = count + v
    end
    
    return count
end

return inventory