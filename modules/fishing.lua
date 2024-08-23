local fishing = {}
fishing.FishCount = 0
fishing.IsFishing = false
local fishDelay = -1

local fishingChances = {
    {Type = "Biribiriuo", Chance = 60},
    {Type = "ShockedBiribiriuo", Chance = 40}
}

function fishing:Update(dt)
    if self.IsFishing then
        if love.timer.getTime() > fishDelay then
            local roll = love.math.random(0,100000) / 1000
            local fish = ""
            local total = 0
            
            for _, fishtype in ipairs(fishingChances) do
                print(fishtype.Type, fishtype.Chance)
                print(roll)
                print(fishtype.Chance + total)
                if roll < fishtype.Chance + total then
                    fish = fishtype.Type
                    break
                end

                total = total + fishtype.Chance
            end
            self.FishCount = self.FishCount + 1
            self.IsFishing = false

            self.Caught(fish)
        end
    end
end

function fishing:Fish()
    if self.IsFishing then return end
    self.IsFishing = true
    fishDelay = love.timer.getTime() + love.math.random(40, 70) / 100
end

return fishing