local fishing = require("modules.fishing")
local utils = require("yan.utils")
local fishes = require("modules.fishes")

local coins = 0

require("yan")

local sprites = {
    Platform = love.graphics.newImage("/img/platform.png"),
    YanIdle = love.graphics.newImage("/img/yan_idle.png"),
    YanPrepare = love.graphics.newImage("/img/yan_prepare.png"),
    YanFishing = love.graphics.newImage("/img/yan_fishing.png"),
    YanCatch = love.graphics.newImage("/img/yan_catch.png"),

    Biribiriuo = love.graphics.newImage("/img/fish/biribiriuo.png"),
    ShockedBiribiriuo = love.graphics.newImage("/img/fish/shocked_biribiriuo.png"),
    Pausegill = love.graphics.newImage("/img/fish/pausegill.png"),
    Quicknibble = love.graphics.newImage("/img/fish/quicknibble.png"),
    Threefish = love.graphics.newImage("/img/fish/threefish.png"),
}

local fishingState = "IDLE"
local currentFish = {Type = "", YPos = 700}

local inventory = {}

local delays = {
    ["Uncatch"] = {
        Delay = 1,
        StartTime = 0,
        Active = false,
        Function = function ()
            fishingState = "IDLE"
            yan:NewTween(currentFish, yan:TweenInfo(0.5, EasingStyle.QuadInOut), {YPos = 700}):Play()
        end
    }
}

function StartDelay(name)
    delays[name].Active = true
    delays[name].StartTime = love.timer.getTime()
end

function love.load()
    for fish, _ in pairs(fishes) do
        inventory[fish] = 0
    end
    
    screen = yan:Screen()
    
    coinsLabel = yan:Label(screen, "Coins: 0", 32, "left", "center")
    coinsLabel.Position = UIVector2.new(0,10,0,10)
    coinsLabel.Size = UIVector2.new(0.3,0,0.1,0)
    coinsLabel.TextColor = Color.new(1,1,1,1)

    sellBtn = yan:TextButton(screen, "Sell", 32, "center", "center")
    sellBtn.Position = UIVector2.new(1,-10,0,10)
    sellBtn.Size = UIVector2.new(0.2,0,0.1,0)
    sellBtn.AnchorPoint = Vector2.new(1,0)
    
    sellBtn.MouseDown = function ()
        for fish, value in pairs(inventory) do
            coins = coins + value
            inventory[fish] = 0
        end
    end
end


function fishing.Caught(fishType)
    fishingState = "CAUGHT"
    
    inventory[fishType] = inventory[fishType] + fishes[fishType]
    currentFish.Type = fishType
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
    
    coinsLabel.Text = "Coins: "..tostring(coins)

    for _, v in pairs(sprites) do
        v:setFilter("nearest", "nearest")
    end
end

function love.keypressed(key)
    if key == "space" and fishing.IsFishing == false then
        fishingState = "PREPARE"
    end
end

function love.keyreleased(key)
    if key == "space" then
        fishingState = "FISHING"
        fishing:Fish()
    end
end

function love.draw()
    love.graphics.draw(sprites.Platform, 0, 0, 0, 8, 8)
    
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