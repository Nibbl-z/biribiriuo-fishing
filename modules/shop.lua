local shop = {}
require "yan"

local upgrades = require("modules.upgrades")

local shopItems = {
    {
        Name = "Bucket Size Increase",
        Price = 10,
        PriceIncrease = 2,
        Purchases = 0,
        OnPurchase = function ()
            upgrades.BucketSize = upgrades.BucketSize + 1
        end,
        Description = function ()
            return "Increase bucket size from "..upgrades.BucketSize.." to "..(upgrades.BucketSize + 1).."."
        end
    }
}

function shop:Init()
    self.Screen = yan:Screen()
    self.Screen.ZIndex = 2

    frame = yan:Frame(self.Screen)
    frame.Position = UIVector2.new(0.5,0,0.5,0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Size = UIVector2.new(0.7, 0, 0.7, 0)
    frame.CornerRoundness = 16
    frame.Color = Color.new(0.2, 0.2, 0.2, 1)
    frame.Padding = UIVector2.new(0, 5, 0, 5)
    
    for i, shopItem in ipairs(shopItems) do
        local itemContainer = yan:Frame(self.Screen)
        itemContainer.Color = Color.new(0,0,0,0.5)
        itemContainer.Position = UIVector2.new(0, 0, 0.2 * (i - 1), 10 * (i - 1))
        itemContainer.Size = UIVector2.new(1, 0, 0.2, 0)
        itemContainer.CornerRoundness = 11
        itemContainer.Padding = UIVector2.new(0, 5, 0, 5)
        itemContainer:SetParent(frame)

        itemContainer.ZIndex = 2
        
        local nameLabel = yan:Label(self.Screen, shopItem.Name, 24, "left", "center")
        nameLabel.Size = UIVector2.new(0.5,0,0.7,0)
        nameLabel.TextColor = Color.new(1,1,1,1)
        nameLabel:SetParent(itemContainer)
        nameLabel.ZIndex = 3
        
        local descriptionLabel = yan:Label(self.Screen, shopItem:Description(), 15, "left", "center")
        descriptionLabel.Size = UIVector2.new(0.5,0,0.3,0)
        descriptionLabel.Position = UIVector2.new(0,0,0.7,0)
        descriptionLabel.TextColor = Color.new(0.7,0.7,0.7,1)
        descriptionLabel:SetParent(itemContainer)
        descriptionLabel.ZIndex = 3
        
        local buyButton = yan:TextButton(self.Screen, shopItem.Price + (shopItem.PriceIncrease * shopItem.Purchases).." Coins", 32, "center", "center")
        buyButton.Size = UIVector2.new(0.5,-10,1,0)
        buyButton.Color = Color.new(83/255, 208/255, 93/255)
        buyButton.Position = UIVector2.new(1,0,0,0)
        buyButton.AnchorPoint = Vector2.new(1,0)
        buyButton.TextColor = Color.new(1,1,1,1)
        buyButton:SetParent(itemContainer)
        buyButton.ZIndex = 3

        buyButton.MouseEnter = function () buyButton.Color = Color.new(41/255, 105/255, 46/255) end
        buyButton.MouseLeave = function () buyButton.Color = Color.new(83/255, 208/255, 93/255) end
    end
end

return shop