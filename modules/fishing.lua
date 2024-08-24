local fishing = {}
fishing.FishCount = 0
fishing.IsFishing = false
local fishDelay = -1
local upgrades = require("modules.upgrades")
local rarities = {
    Common = {
        "Biribiriuo", "Shocked Biribiriuo"
    },
    
    Uncommon = {
        "Pausegill", "Quicknibble", "Threefish"
    }
}

local fishingChances = {
    {Type = "Common", Chance = 60},
    {Type = "Uncommon", Chance = 40},
}

function fishing:RollFish()
    local roll = love.math.random(0,100000) / 1000

    if roll < upgrades.MinimumLuck then fishing:RollFish() return end

    local fish = ""
    local total = 0
    
    for _, fishtype in ipairs(fishingChances) do
        if roll < fishtype.Chance + total then
            fish = rarities[fishtype.Type][love.math.random(#rarities[fishtype.Type])]
            break
        end

        total = total + fishtype.Chance
    end
    self.FishCount = self.FishCount + 1
    self.IsFishing = false

    self.Caught(fish)
end

function fishing:Update(dt)
    if self.IsFishing then
        if love.timer.getTime() > fishDelay then
            fishing:RollFish()
        end
    end
end

function fishing:Fish()
    if self.IsFishing then return end
    self.IsFishing = true
    fishDelay = love.timer.getTime() + love.math.random(40, 70) / upgrades.FishingSpeed
end

return fishing