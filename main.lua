local fishing = require("modules.fishing")
require("yan")

function love.load()
    screen = yan:Screen()

    fishLabel = yan:Label(screen, "Fish: 0", 32, "left", "center")
    fishLabel.Position = UIVector2.new(0,10,0,10)
    fishLabel.Size = UIVector2.new(0.3,0,0.1,0)
    fishLabel.TextColor = Color.new(1,1,1,1)
end

function love.update(dt)
    fishing:Update(dt)
    yan:Update(dt)

    fishLabel.Text = "Fish: "..fishing.FishCount
end

function love.keypressed(key)
    if key == "space" then
        fishing:Fish()
    end
end

function love.draw()
    yan:Draw()
end