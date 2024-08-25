local save = {}

local shop = require("modules.shop")
local fishes = require("modules.fishes")
local inventory = require("modules.inventory")
local upgrades = require("modules.upgrades")

function save:Load()
    love.filesystem.setIdentity(love.filesystem.getIdentity())
    
    local exists = love.filesystem.getInfo("save")
    if exists == nil then return end

    local saveData = love.filesystem.read("save")
    local loadedSave = loadstring(saveData)()
    
    shop.Coins = loadedSave.Coins
    
    for _, v in ipairs(shop.ShopItems) do
        v.Purchases = loadedSave.Shop[v.Name]
        upgrades[v.UpgradeName] = v.GetUpgradeValue(v.Purchases)
    end
    
    for k, v in pairs(loadedSave.Inventory) do
        print(k, v)
        print(type(v))
        inventory.Inventory[k] = tonumber(v)
    end
end

function TableToString(table, main)
    local string = "{"

    for k, v in pairs(table) do
        if type(v) ~= "table" then
            string = string.."[\""..k.."\"]".." = "..tostring(v)..","
        else
            string = string.."[\""..k.."\"]".." = "..TableToString(v, false)
        end
    end
    
    if main then
        string = string.."}"
    else
        string = string.."},"
    end
    

    return string
end

function save:Save()
    local save = {
        Coins = shop.Coins,
        Shop = {
            ["Barrel Size Increase"] = 0,
            ["Better Fishing Rod"] = 0,
            ["Luck of the Stars"] = 0,
            ["Salesman"] = 0
        },
        Inventory = {}
    }
    
    for _, v in ipairs(shop.ShopItems) do
        save.Shop[v.Name] = v.Purchases
    end
    
    for k, v in pairs(inventory.Inventory) do
        print(k, v)
        save.Inventory[k] = v
    end
    
    love.filesystem.setIdentity(love.filesystem.getIdentity())

    love.filesystem.write("save", "return "..TableToString(save, true))
end

return save