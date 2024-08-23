local fishing = {}
fishing.FishCount = 0
fishing.IsFishing = false
local fishDelay = -1

function fishing:Update(dt)
    if self.IsFishing then
        if love.timer.getTime() > fishDelay then
            self.FishCount = self.FishCount + 1
            self.IsFishing = false
        end
    end
end

function fishing:Fish()
    if self.IsFishing then return end
    self.IsFishing = true
    fishDelay = love.timer.getTime() + love.math.random(40, 70) / 10
end

return fishing