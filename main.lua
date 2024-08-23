local fishing = require("modules.fishing")
local utils = require("yan.utils")
local fishes = require("modules.fishes")
local shop = require("modules.shop")
local upgrades = require("modules.upgrades")

require("yan")

local sprites = {
    Platform = love.graphics.newImage("/img/platform.png"),
    YanIdle = love.graphics.newImage("/img/yan_idle.png"),
    YanPrepare = love.graphics.newImage("/img/yan_prepare.png"),
    YanFishing = love.graphics.newImage("/img/yan_fishing.png"),
    YanCatch = love.graphics.newImage("/img/yan_catch.png"),

    BarrelEmpty = love.graphics.newImage("/img/bucket_empty.png"),
    BarrelFull = love.graphics.newImage("/img/bucket_full.png"),

    StarSmall = love.graphics.newImage("/img/star_small.png"),
    StarSmallFlash = love.graphics.newImage("/img/star_small_flash.png"),
    StarBig = love.graphics.newImage("/img/star_big.png"),
    StarBigFlash = love.graphics.newImage("/img/star_big_flash.png"),

    Biribiriuo = love.graphics.newImage("/img/fish/biribiriuo.png"),
    ["Shocked Biribiriuo"] = love.graphics.newImage("/img/fish/shocked_biribiriuo.png"),
    Pausegill = love.graphics.newImage("/img/fish/pausegill.png"),
    Quicknibble = love.graphics.newImage("/img/fish/quicknibble.png"),
    Threefish = love.graphics.newImage("/img/fish/threefish.png"),
}

local fishingState = "IDLE"
local currentFish = {Type = "", YPos = 700}

local inventory = {}

function GetInventoryCount()
    local count = 0

    for k, v in pairs(inventory) do
        count = count + v
    end

    return count
end

local delays = {
    ["Uncatch"] = {
        Delay = 1,
        StartTime = 0,
        Active = false,
        Function = function ()
            fishingState = "IDLE"
            statusLabel.Text = ""
            yan:NewTween(currentFish, yan:TweenInfo(0.5, EasingStyle.QuadInOut), {YPos = 700}):Play()
        end
    },

    ["ResetSell"] = {
        Delay = 2,
        StartTime = 0,
        Active = false,
        Function = function ()
            statusLabel.Text = ""
        end
    }
}

local stars = {}

function StartDelay(name)
    delays[name].Active = true
    delays[name].StartTime = love.timer.getTime()
end

function love.load()
    shop:Init()
    for i = 1, 20 do
        local x = love.math.random(0,100)
        local y = love.math.random(0,73)
        local t = love.math.random(1, 2)
        table.insert(stars, {x = x, y = y, t = t})
    end

    for fish, _ in pairs(fishes) do
        inventory[fish] = 0
    end
    
    screen = yan:Screen()
    
    coinsLabel = yan:Label(screen, "Coins: 0", 32, "left", "top")
    coinsLabel.Position = UIVector2.new(0,10,0,10)
    coinsLabel.Size = UIVector2.new(0.3,0,0.1,0)
    coinsLabel.TextColor = Color.new(1,1,1,1)
    
    sellBtn = yan:TextButton(screen, "Sell", 32, "center", "center")
    sellBtn.Position = UIVector2.new(1,-10,0,10)
    sellBtn.Size = UIVector2.new(0.2,0,0.1,0)
    sellBtn.AnchorPoint = Vector2.new(1,0)

    shopBtn = yan:TextButton(screen, "Shop", 32, "center", "center")
    shopBtn.Position = UIVector2.new(1,-10,0.1,20)
    shopBtn.Size = UIVector2.new(0.2,0,0.1,0)
    shopBtn.AnchorPoint = Vector2.new(1,0)
    
    statusLabel = yan:Label(screen, "", 20, "left", "bottom")
    statusLabel.Position = UIVector2.new(0, 10, 1, -10)
    statusLabel.AnchorPoint = Vector2.new(0, 1)
    statusLabel.Size = UIVector2.new(1,0,0.1,0)
    statusLabel.TextColor = Color.new(1,1,1,1)
    
    sellBtn.MouseDown = function ()
        local totalValue = 0

        for fish, value in pairs(inventory) do
            shop.Coins = shop.Coins + fishes[fish] * inventory[fish]
            totalValue = totalValue + fishes[fish] * inventory[fish]
            inventory[fish] = 0
        end
        
        statusLabel.Text = "Sold all fish for "..totalValue.." coins!"
        StartDelay("ResetSell")
    end
    
    shopBtn.MouseDown = function ()
        shop.Screen.Enabled = not shop.Screen.Enabled
    end
end


function fishing.Caught(fishType)
    fishingState = "CAUGHT"
    
    inventory[fishType] = inventory[fishType] + 1
    currentFish.Type = fishType
    statusLabel.Text = "Caught a "..fishType.."!"
    
    if GetInventoryCount() >= upgrades.BucketSize then
        statusLabel.Text = statusLabel.Text.." Also, your barrel is full, press sell to sell your fish!"
    end
    yan:NewTween(currentFish, yan:TweenInfo(0.5, EasingStyle.QuadInOut), {YPos = 200}):Play()

    StartDelay("Uncatch")
end

function love.update(dt)
    for k, v in pairs(delays) do
        if v.Active then
            if love.timer.getTime() > v.StartTime + v.Delay then
                v.Function()
                v.Active = false
            end
        end
    end
    
    fishing:Update(dt)
    yan:Update(dt)
    
    coinsLabel.Text = "Coins: "..tostring(shop.Coins)

    for _, v in pairs(sprites) do
        v:setFilter("nearest", "nearest")
    end
end

function love.keypressed(key)
    if key == "space" and fishingState == "IDLE" then
        if GetInventoryCount() >= upgrades.BucketSize then return end
        
        fishingState = "PREPARE"
    end
end

function love.keyreleased(key)
    if key == "space" and fishingState == "PREPARE" then
        fishingState = "FISHING"
        fishing:Fish()
    end
end

function love.draw()
    for _, star in ipairs(stars) do
        if love.math.random(1,200) == 1 then
            love.graphics.draw(star.t == 1 and sprites.StarSmallFlash or sprites.StarBigFlash, star.x * 8, star.y * 8, 0, 8, 8)
        else
            love.graphics.draw(star.t == 1 and sprites.StarSmall or sprites.StarBig, star.x * 8, star.y * 8, 0, 8, 8)
        end
    end
    
    love.graphics.draw(sprites.Platform, 0, 0, 0, 8, 8)
    
    if GetInventoryCount() >= upgrades.BucketSize then 
        love.graphics.draw(sprites.BarrelFull, 0, 0, 0, 8, 8)
    else
        love.graphics.draw(sprites.BarrelEmpty, 0, 0, 0, 8, 8)
    end

    if fishingState == "IDLE" then
        love.graphics.draw(sprites.YanIdle, 0, 0, 0, 8, 8)
    elseif fishingState == "PREPARE" then
        love.graphics.draw(sprites.YanPrepare, 0, 0, 0, 8, 8)
    elseif fishingState == "FISHING" then
        love.graphics.draw(sprites.YanFishing, 0, 0, 0, 8, 8)
    elseif fishingState == "CAUGHT" then
        love.graphics.draw(sprites.YanCatch, 0, 0, 0, 8, 8)
    end
    
    if currentFish.Type ~= "" then
        love.graphics.draw(sprites[currentFish.Type], 350, currentFish.YPos, 0, 8, 8)
    end

    yan:Draw()
end