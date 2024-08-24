local shop = {}
require "yan"

shop.Coins = 0
local upgrades = require("modules.upgrades")

shop.ShopItems = {
    {
        Name = "Barrel Size Increase",
        Price = 10,
        PriceIncrease = 2,
        Purchases = 0,
        OnPurchase = function ()
            upgrades.BucketSize = upgrades.BucketSize + 1
        end,
        UpgradeName = "BucketSize",
        GetUpgradeValue = function (purchases)
            return 5 + purchases
        end,
        Description = function ()
            return "Increase barrel size from "..upgrades.BucketSize.." to "..(upgrades.BucketSize + 1).."."
        end
    },
    
    {
        Name = "Better Fishing Rod",
        Price = 15,
        PriceIncrease = 5,
        Purchases = 0,
        OnPurchase = function ()
            upgrades.FishingSpeed = upgrades.FishingSpeed + 5
        end,
        UpgradeName = "FishingSpeed",
        GetUpgradeValue = function (purchases)
            return 20 + purchases * 5
        end,
        Description = function ()
            return "Decrease the time it takes to catch fish by 5%"
        end
    },

    {
        Name = "Luck of the Stars",
        Price = 20,
        PriceIncrease = 5,
        Purchases = 0,
        OnPurchase = function ()
            upgrades.MinimumLuck = upgrades.MinimumLuck + 5
        end,
        UpgradeName = "MinimumLuck",
        GetUpgradeValue = function (purchases)
            return 0 + purchases * 5
        end,
        Description = function ()
            return "Increase the chances of rarer fish by 5%"
        end
    },
    
    {
        Name = "Salesman",
        Price = 20,
        PriceIncrease = 10,
        Purchases = 0,
        OnPurchase = function ()
            upgrades.CoinMultiplier = upgrades.CoinMultiplier + 0.2
        end,
        UpgradeName = "CoinMultiplier",
        GetUpgradeValue = function (purchases)
            return 1 + purchases * 0.2
        end,
        Description = function ()
            return "Increase coin sell multiplier from "..upgrades.CoinMultiplier.."x to "..(upgrades.CoinMultiplier + 0.2).."x"
        end
    }
}

local clickSfx = love.audio.newSource("/sfx/click.wav", "static")

function shop:Init()
    self.Screen = yan:Screen()
    self.Screen.ZIndex = 2
    self.Screen.Enabled = false

    frame = yan:Frame(self.Screen)
    frame.Position = UIVector2.new(0.5,0,0.5,0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Size = UIVector2.new(0.7, 0, 0.7, 0)
    frame.CornerRoundness = 16
    frame.Color = Color.new(0.2, 0.2, 0.2, 1)
    frame.Padding = UIVector2.new(0,5,0,5)
    
    for i, shopItem in ipairs(self.ShopItems) do
        local itemContainer = yan:Frame(self.Screen)
        itemContainer.Color = Color.new(0,0,0,0.5)
        itemContainer.Position = UIVector2.new(0, 0, 0.2 * (i - 1), 10 * (i - 1))
        itemContainer.Size = UIVector2.new(1, 0, 0.2, 0)
        itemContainer.CornerRoundness = 11
        itemContainer.Padding = UIVector2.new(0,10,0,10)
        itemContainer:SetParent(frame)

        itemContainer.ZIndex = 2
        
        local nameLabel = yan:Label(self.Screen, shopItem.Name, 24, "left", "top", "/W95FA.otf")
        nameLabel.Size = UIVector2.new(0.5,0,0.7,0)
        nameLabel.TextColor = Color.new(1,1,1,1)
        nameLabel:SetParent(itemContainer)
        nameLabel.ZIndex = 3
        
        local descriptionLabel = yan:Label(self.Screen, shopItem:Description(), 15, "left", "bottom", "/W95FA.otf")
        descriptionLabel.Size = UIVector2.new(0.5,0,0.3,0)
        descriptionLabel.Position = UIVector2.new(0,0,0.7,0)
        descriptionLabel.TextColor = Color.new(0.7,0.7,0.7,1)
        descriptionLabel:SetParent(itemContainer)
        descriptionLabel.ZIndex = 3
        
        local buyButton = yan:TextButton(self.Screen, shopItem.Price + (shopItem.PriceIncrease * shopItem.Purchases).." Coins", 32, "center", "center", "/W95FA.otf")
        buyButton.Size = UIVector2.new(0.5,-10,1,0)
        buyButton.Color = Color.new(83/255, 208/255, 93/255)
        buyButton.Position = UIVector2.new(1,0,0,0)
        buyButton.AnchorPoint = Vector2.new(1,0)
        buyButton.TextColor = Color.new(1,1,1,1)
        buyButton:SetParent(itemContainer)
        buyButton.ZIndex = 3
        
        buyButton.MouseEnter = function () buyButton.Color = Color.new(41/255, 105/255, 46/255) end
        buyButton.MouseLeave = function () buyButton.Color = Color.new(83/255, 208/255, 93/255) end
        buyButton.MouseDown = function ()
            local price = shopItem.Price + (shopItem.PriceIncrease * shopItem.Purchases)
            
            if shop.Coins >= price then
                clickSfx:play()
                shop.Coins = shop.Coins - price
                shopItem.OnPurchase()
                shopItem.Purchases = shopItem.Purchases + 1
                
                descriptionLabel.Text = shopItem:Description()
                buyButton.Text = shopItem.Price + (shopItem.PriceIncrease * shopItem.Purchases).." Coins"
            end
        end
    end
end

return shop