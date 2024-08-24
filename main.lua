local fishing = require("modules.fishing")
local utils = require("yan.utils")
local fishes = require("modules.fishes")
local shop = require("modules.shop")
local upgrades = require("modules.upgrades")
local inventory = require("modules.inventory")
local save = require("modules.save")

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
    ["Plain Ol' Fish"] = love.graphics.newImage("/img/fish/plain_ol_fish.png"),
    Nibbler = love.graphics.newImage("/img/fish/nibbler.png"),
    ["Touchy Fish"] = love.graphics.newImage("/img/fish/touchy_fish.png"),
    ["King of the Pond"] = love.graphics.newImage("/img/fish/king_of_the_pond.png"),
    ["Mystery Fish"] = love.graphics.newImage("/img/fish/mystery_fish.png"),
}

local fishingState = "IDLE"
local currentFish = {Type = "", YPos = 700}

local delays = {
    ["Uncatch"] = {
        Delay = 1,
        StartTime = 0,
        Active = false,
        Function = function ()
            fishingState = "IDLE"
            statusLabel.Text = ""
            yan:NewTween(currentFish, yan:TweenInfo(1, EasingStyle.QuintIn), {YPos = 700}):Play()
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

function love.quit()
    save:Save()

    return false
end

function love.load()
    shop:Init()
    inventory:Load()
    save:Load()
    local function chooseStarPos()
        local x = love.math.random(0,100)
        local y = love.math.random(0,60)
        if utils:CheckCollision(x, y, 5, 5, 13, 35, 21, 40) then return chooseStarPos() end
        for _, star in ipairs(stars) do
            if utils:Distance(x, y, star.x, star.y) < 7 then return chooseStarPos() end
        end
        
        return x, y
    end
    
    for i = 1, 40 do
        local x, y = chooseStarPos()
        local t = love.math.random(1, 2)
        table.insert(stars, {x = x, y = y, t = t})
    end
    
    screen = yan:Screen()
    
    coinsImg = yan:Image(screen, "/img/coin.png")
    coinsImg.Position = UIVector2.new(0,8,0,8)
    coinsImg.Size = UIVector2.new(0,32,0,32)

    coinsLabel = yan:Label(screen, "0", 32, "left", "center", "/W95FA.otf")
    coinsLabel.Position = UIVector2.new(0,45,0,8)
    coinsLabel.Size = UIVector2.new(0.3,0,0,32)
    coinsLabel.TextColor = Color.new(1,1,0,1)
    
    sellBtn = yan:TextButton(screen, "Sell", 32, "center", "center", "/W95FA.otf")
    sellBtn.Position = UIVector2.new(1,-10,0,10)
    sellBtn.Size = UIVector2.new(0.2,0,0.1,0)
    sellBtn.AnchorPoint = Vector2.new(1,0)
    sellBtn.Color = Color.new(0.2,0.2,0.2,1)
    sellBtn.TextColor = Color.new(1,1,1,1)
    sellBtn.MouseEnter = function () sellBtn.Color = Color.new(0.1,0.1,0.1,1) end
    sellBtn.MouseLeave = function () sellBtn.Color = Color.new(0.2,0.2,0.2,1) end
    
    shopBtn = yan:TextButton(screen, "Shop", 32, "center", "center",  "/W95FA.otf")
    shopBtn.Position = UIVector2.new(1,-10,0.1,20)
    shopBtn.Size = UIVector2.new(0.2,0,0.1,0)
    shopBtn.AnchorPoint = Vector2.new(1,0)
    shopBtn.Color = Color.new(0.2,0.2,0.2,1)
    shopBtn.TextColor = Color.new(1,1,1,1)
    shopBtn.MouseEnter = function () shopBtn.Color = Color.new(0.1,0.1,0.1,1) end
    shopBtn.MouseLeave = function () shopBtn.Color = Color.new(0.2,0.2,0.2,1) end
    
    statusLabel = yan:Label(screen, "", 20, "left", "bottom", "/W95FA.otf")
    statusLabel.Position = UIVector2.new(0, 10, 1, -10)
    statusLabel.AnchorPoint = Vector2.new(0, 1)
    statusLabel.Size = UIVector2.new(1,0,0.1,0)
    statusLabel.TextColor = Color.new(1,1,1,1)
    
    sellBtn.MouseDown = function ()
        local totalValue = 0
        
        for fish, value in pairs(inventory.Inventory) do
            print(inventory.Inventory[fish])
            totalValue = totalValue + fishes[fish] * inventory.Inventory[fish]
            inventory.Inventory[fish] = 0
        end
        
        totalValue = math.ceil(totalValue * upgrades.CoinMultiplier)
        shop.Coins = shop.Coins + totalValue
        
        statusLabel.Text = "Sold all fish for "..totalValue.." coins!"
        StartDelay("ResetSell")
        
    end
    
    shopBtn.MouseDown = function ()
        save:Save()
        shop.Screen.Enabled = not shop.Screen.Enabled
    end
end


function fishing.Caught(fishType)
    fishingState = "CAUGHT"
    
    inventory.Inventory[fishType] = inventory.Inventory[fishType] + 1
    currentFish.Type = fishType
    statusLabel.Text = "Caught a "..fishType.."!"

    yan:NewTween(currentFish, yan:TweenInfo(1, EasingStyle.QuintOut), {YPos = 200}):Play()
    
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
    
    coinsLabel.Text = tostring(shop.Coins)
    
    for _, v in pairs(sprites) do
        v:setFilter("nearest", "nearest")
    end
end

function love.keypressed(key)
    if key == "space" and fishingState == "IDLE" then
        if inventory:GetCount() >= upgrades.BucketSize then
            statusLabel.Text = "Your barrel is full! Press sell to sell your fish!"
            StartDelay("ResetSell")
            return 
        end
        
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
    
    if inventory:GetCount() >= upgrades.BucketSize then 
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