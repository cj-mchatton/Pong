--Needs
-- game over
-- sound effects
-- music
-- inscrease speed of ball?
-- change fonts
require "paddle"
require "ball"
local love = require "love"

--Pong game using love2d
local screenWidth, screenHeight = 800, 600

-- main menu
function newButton(text, fn) 
    return {text = text, fn = fn}
end

local buttons = {}
table.insert(buttons, newButton("Start", function() gameState = "start" end))
table.insert(buttons, newButton("Controls", function() gameState = "controls" end))
table.insert(buttons, newButton("Exit", function() love.event.quit() end))
backButton = newButton("Back", function() gameState = "menu" end)

--draw centered buttons with hover effect
function drawMenuButtons()
    local buttonWidth = 200
    local buttonHeight = 50
    local buttonSpacing = 10
    local buttonX = screenWidth / 2 - buttonWidth / 2
    local buttonY = screenHeight / 2 - (#buttons * (buttonHeight + buttonSpacing)) / 2
    for i, button in ipairs(buttons) do
        local r, g, b = 0.9, 0.9, 0.9
        if love.mouse.getX() > buttonX and love.mouse.getX() < buttonX + buttonWidth and love.mouse.getY() > buttonY and love.mouse.getY() < buttonY + buttonHeight then
            r, g, b = 0, 0, 0
            if love.mouse.isDown(1) then
                button.fn()
            end
        end
        love.graphics.setColor(r, g, b, 0.25)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(button.text, buttonX + buttonWidth / 2 - love.graphics.getFont():getWidth(button.text) / 2, buttonY + buttonHeight / 2 - love.graphics.getFont():getHeight(button.text) / 2)
        buttonY = buttonY + buttonHeight + buttonSpacing
    end
    love.graphics.setColor(1, 1, 1)
end

function drawBackButton() 
    local buttonWidth = 100
    local buttonHeight = 50
    -- put button on top left of screen
    local buttonX = 20
    local buttonY = 20
    local r, g, b = 0.9, 0.9, 0.9
    if love.mouse.getX() > buttonX and love.mouse.getX() < buttonX + buttonWidth and love.mouse.getY() > buttonY and love.mouse.getY() < buttonY + buttonHeight then
        r, g, b = 0.8, 0.8, 0.8
        if love.mouse.isDown(1) then
            backButton.fn()
        end
    end
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(backButton.text, buttonX + buttonWidth / 2 - love.graphics.getFont():getWidth(backButton.text) / 2, buttonY + buttonHeight / 2 - love.graphics.getFont():getHeight(backButton.text) / 2)
    love.graphics.setColor(1, 1, 1)
end

--Set up window
function love.load()
    background = love.graphics.newImage("sprites/pixelsky.jpg")
    love.window.setTitle("Pong")
    love.window.setMode(screenWidth, screenHeight, {resizable=false, vsync=false})
end

--Create paddles
local paddle1, paddle2
paddle1 = Paddle.new(5, 225, 5, 80)
paddle2 = Paddle.new(790, 225, 5, 80)
local ball = Ball.new(400, 300, 10)

local server = 1

gameState = "menu"

--Update function--updates all objects
function love.update(dt)
    if gameState == "controls" then
        if love.keyboard.isDown("escape") then
            gameState = "menu"
        end
    end
    if gameState == "start" then
        if love.keyboard.isDown("return") then
            gameState = "play"
        end
    end
    if gameState == "play" then
        paddle1:update(dt, 1, screenWidth, screenHeight)
        paddle2:update(dt, 2, screenWidth, screenHeight)
        ball:update(dt, screenWidth, screenHeight, server)
        if ball:collides(paddle1) then
            ball.angle = math.pi - ball.angle
            ball.x = paddle1.x + paddle1.width + ball.radius
        end
        if ball:collides(paddle2) then
            ball.angle = math.pi - ball.angle
            ball.x = paddle2.x - ball.radius
        end
        local gameData = ball:reset(screenWidth, screenHeight)
        if gameData.gameState == "start" then
            if gameData.winner == 1 then
                paddle1.score = paddle1.score + 1
            else
                paddle2.score = paddle2.score + 1
            end
            paddle1:reset(screenWidth, screenHeight)
            paddle2:reset(screenWidth, screenHeight)
            server = server * -1
            gameState = "start"
        end
    end
end

--draws all objects, background, and text
function love.draw()
    if gameState == "menu" or gameState == "controls" then
        love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
        local sx = love.graphics.getWidth() / background:getWidth()
        local sy = love.graphics.getHeight() / background:getHeight()
        --draw background and buttons
        love.graphics.draw(background, 0, 0, 0, sx, sy+0.03)
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.setFont(love.graphics.newFont(30))
        love.graphics.printf("Pong", 0, 100, screenWidth, "center")
        love.graphics.setFont(love.graphics.newFont(20))
        if gameState == "menu" then
            drawMenuButtons()
        elseif gameState == "controls" then
            love.graphics.printf("Controls", 0, 200, screenWidth, "center")
            love.graphics.printf("Player 1: W and S", 0, 250, screenWidth, "center")
            love.graphics.printf("Player 2: Up and Down", 0, 300, screenWidth, "center")
            love.graphics.printf("Press Enter to Start the Round", 0, 350, screenWidth, "center")
            love.graphics.printf("Press Escape to Return to the Menu", 0, 400, screenWidth, "center")
            drawBackButton()
        end
    elseif gameState == "start" or gameState == "play" then
        --set background color
        love.graphics.setBackgroundColor(0.125, 0.368, 0.149)
        --place line in middle of screen
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle("fill", screenWidth / 2 - 2, 0, 2, screenHeight)
        --place score
        love.graphics.print(paddle1.score, screenWidth / 2 - 50, 10)
        love.graphics.print(paddle2.score, screenWidth / 2 + 30, 10)
        --place paddles
        paddle1:draw()
        paddle2:draw()
        --place ball
        ball:draw()
    end
end
