local love = require "love"

Ball = {}
Ball.__index = Ball

function Ball.new(x, y, radius)
    local self = setmetatable({}, Ball)
    self.x = x
    self.y = y
    self.radius = radius
    self.speed = 600
    self.angle = (4 * math.pi / 3) * math.random(1, 2)
    return self
end

function Ball:draw()
    love.graphics.setColor(0.874, 1, 0.31)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Ball:update(dt, width, height, serve)
    if serve == 1 then
        self.x = self.x + self.speed * math.cos(self.angle) * dt
    elseif serve == -1 then
        self.x = self.x - self.speed * math.cos(self.angle) * dt
    end
    self.y = self.y + self.speed * math.sin(self.angle) * dt
    if self.y < 0 then
        self.y = 0
        self.angle = -self.angle
    elseif self.y > height then
        self.y = height
        self.angle = -self.angle
    end
end

function Ball:collides(paddle)
    if self.x - self.radius > paddle.x + paddle.width or self.x + self.radius < paddle.x then
        return false
    end
    if self.y - self.radius > paddle.y + paddle.height or self.y + self.radius < paddle.y then
        return false
    end
    return true
end

function Ball:reset(width, height)
    local data = {gameState = "play", winner = 0}
    if self.x < 0 or self.x > width then
        if self.x < 0 then
            data.winner = 2
        else
            data.winner = 1
        end
        self.x = width / 2
        self.y = height / 2
        self.angle = (4 * math.pi / 3) * math.random(1, 2)
        data.gameState = "start"
    end
    return data
end
