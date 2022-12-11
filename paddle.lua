local love = require "love"

Paddle = {}
Paddle.__index = Paddle

function Paddle.new(x, y, width, height)
    local self = setmetatable({}, Paddle)
    self.x = x
    self.y = y
    self.startX = x
    self.startY = y
    self.width = width
    self.height = height
    self.speed = 550
    self.score = 0
    return self
end

function Paddle:draw()
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)
end

function Paddle:update(dt, player, width, height)
    if player == 1 then
        if love.keyboard.isDown("w") then
            self.y = self.y - self.speed * dt
        elseif love.keyboard.isDown("s") then
            self.y = self.y + self.speed * dt
        end
    elseif player == 2 then
        if love.keyboard.isDown("up") then
            self.y = self.y - self.speed * dt
        elseif love.keyboard.isDown("down") then
            self.y = self.y + self.speed * dt
        end
    end
    if self.y < 0 then
        self.y = 0
    elseif self.y > height - self.height then
        self.y = height - self.height
    end
end

function Paddle:reset(width, height)
    self.x = self.startX
    self.y = self.startY
end