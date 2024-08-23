local fishing = require("modules.fishing")
local utils = require("yan.utils")
require("yan")

local sprites = {
    Platform = love.graphics.newImage("/img/platform.png"),
    YanIdle = love.graphics.newImage("/img/yan_idle.png"),
    YanPrepare = love.graphics.newImage("/img/yan_prepare.png"),
    YanFishing = love.graphics.newImage("/img/yan_fishing.png"),
    YanCatch = love.graphics.newImage("/img/yan_catch.png"),

    Biribiriuo = love.graphics.newImage("/img/fish/biribiriuo.png")
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
            yan:NewTween(currentFish, yan:TweenInfo(0.5, EasingStyle.QuadInOut), {YPos = 700}):Play()
        end
    }
}

function StartDelay(name)
    delays[name].Active = true
    delays[name].StartTime = love.timer.getTime()
end

function love.load()
    screen = yan:Screen()
    
    fishLabel = yan:Label(screen, "Fish: 0", 32, "left", "center")
    fishLabel.Position = UIVector2.new(0,10,0,10)
    fishLabel.Size = UIVector2.new(0.3,0,0.1,0)
    fishLabel.TextColor = Color.new(1,1,1,1)
end


function fishing.Caught()
    fishingState = "CAUGHT"
    
    currentFish.Type = "Biribiriuo"
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

    fishLabel.Text = "Fish: "..fishing.FishCount

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