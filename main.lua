-- Game of Pong by Cameron McHatton
-- sliders are imported from simple-slider library by George Prosser

-- import classes
require "ball"
require "paddle"
-- import libraries
require "simple-slider"
local love = require "love"

-- screen height and width
local screenWidth, screenHeight = 800, 600

-- function that creates button objects
function newButton(text, fn) 
    return {text = text, fn = fn}
end

-- create a buttons table and add buttons to it for the main menu
local menuButtons = {}
table.insert(menuButtons, newButton("Start", function() gameState = "start" end))
table.insert(menuButtons, newButton("Read Me", function() gameState = "controls" end))
table.insert(menuButtons, newButton("Options", function() gameState = "options" end))
table.insert(menuButtons, newButton("Exit",
    function()
        buttonClickSound:play()
        -- sleep for 0.5 seconds to allow the button click sound to play
        love.timer.sleep(0.5)
        love.event.quit()
    end
))
-- back button for multiple screens
backButton = newButton("Back", function() gameState = "menu" end)

--draw centered buttons with hover effect and custom font
function drawMenuButtons()
    local buttonWidth = 250
    local buttonHeight = 75
    local buttonSpacing = 20
    local buttonX = screenWidth / 2 - buttonWidth / 2
    local buttonY = (screenHeight / 2 - (#menuButtons * (buttonHeight + buttonSpacing)) / 2) + 75
    for i, button in ipairs(menuButtons) do
        local r, g, b = 0.9, 0.9, 0.9
        if love.mouse.getX() > buttonX and love.mouse.getX() < buttonX + buttonWidth and love.mouse.getY() > buttonY and love.mouse.getY() < buttonY + buttonHeight then
            r, g, b = 0, 0, 0
            if love.mouse.isDown(1) then
                buttonClickSound:play()
                button.fn()
            end
        end
        love.graphics.setColor(r, g, b, 0.25)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(pixelFontButtons)
        love.graphics.print(button.text, buttonX + buttonWidth / 2 - love.graphics.getFont():getWidth(button.text) / 2, buttonY + buttonHeight / 2 - love.graphics.getFont():getHeight(button.text) / 2)
        buttonY = buttonY + buttonHeight + buttonSpacing
    end
    love.graphics.setColor(1, 1, 1)
end

-- draw back button with hover effect and custom font
function drawBackButton() 
    local buttonWidth = 150
    local buttonHeight = 50
    -- put button on top left of screen
    local buttonX = 20
    local buttonY = 20
    local r, g, b = 0.9, 0.9, 0.9
    if love.mouse.getX() > buttonX and love.mouse.getX() < buttonX + buttonWidth and love.mouse.getY() > buttonY and love.mouse.getY() < buttonY + buttonHeight then
        r, g, b = 0, 0, 0
        if love.mouse.isDown(1) then
            buttonClickSound:play()
            backButton.fn()
        end
    end
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(pixelFontButtons)
    love.graphics.print(backButton.text, buttonX + buttonWidth / 2 - love.graphics.getFont():getWidth(backButton.text) / 2, buttonY + buttonHeight / 2 - love.graphics.getFont():getHeight(backButton.text) / 2)
    love.graphics.setColor(1, 1, 1)
end

-- load some images, fonts, sounds, sliders, and set the window title and size
function love.load()

    background = love.graphics.newImage("sprites/pixel_sky.jpg")

    pixelFontPresents = love.graphics.newFont("fonts/04B_30__.TTF", 15)
    pixelFontButtons = love.graphics.newFont("fonts/04B_30__.TTF", 25)
    pixelFontControls = love.graphics.newFont("fonts/04B_30__.TTF", 20)
    pixelFontIntroText = love.graphics.newFont("fonts/04B_30__.TTF", 40)
    pixelFontControlsTitle = love.graphics.newFont("fonts/04B_30__.TTF", 60)
    pixelFontTitle = love.graphics.newFont("fonts/04B_30__.TTF", 100)

    buttonClickSound = love.audio.newSource("sounds/button_click.mp3", "static")
    gameMusic = love.audio.newSource("sounds/game_music.mp3", "stream")
    gameMusic:setLooping(true)
    gameOverSound = love.audio.newSource("sounds/game_over.mp3", "static")
    menuMusic = love.audio.newSource("sounds/menu_music.mp3", "stream")
    menuMusic:setLooping(true)
    paddleHitSound = love.audio.newSource("sounds/paddle_hit.ogg", "static")
    pastPaddleSound = love.audio.newSource("sounds/past_paddle.mp3", "static")
    wallHitSound = love.audio.newSource("sounds/wall_hit.ogg", "static")

    -- tables of sounds and music
    sounds = {buttonClickSound, gameOverSound, paddleHitSound, pastPaddleSound, wallHitSound}
    musics = {gameMusic, menuMusic}
    
    -- set volume of sounds and music
    for i, sound in ipairs(sounds) do
        sound:setVolume(0.75)
    end
    for i, music in ipairs(musics) do
        music:setVolume(0.5)
    end

    love.window.setTitle("Pong")
    love.window.setMode(screenWidth, screenHeight, {resizable=false, vsync=false})

    -- start the menu music upon starting the game
    menuMusic:play()

    -- sliders for options screen
    soundSlider = newSlider(screenWidth / 2, 250, 200, 150, 0, 200, function (value)
        for i, sound in ipairs(sounds) do
            sound:setVolume(value / 200)
        end
    end)
    musicSlider = newSlider(screenWidth / 2, 330, 200, 100, 0, 200, function (value)
        for i, music in ipairs(musics) do
            music:setVolume(value / 200)
        end
    end)
    playerSlider = newSlider(screenWidth / 2, 410, 200, 2, 0, 2, function (value)
        if value == 1 or value < 1 then
            paddle2.cpu = true
        else
            paddle2.cpu = false
        end
    end)
end

-- create paddles
paddle1 = Paddle.new(5, 225, 5, 80)
paddle2 = Paddle.new(790, 225, 5, 80)
-- create ball
local ball = Ball.new(400, 300, 10)

-- variables to control screen brightness
local backgroundColor = 0.9
local count = 0
local updateDelay = 0.025

-- keep track of who serves the ball. This allows the ball to go a different direction each turn
local server = 1

-- keep track of the game state and if the game is over in order to display the correct screen
gameState = "intro"
gameOver = false

-- update the screen and keep a steady frame rate
function love.update(dt)
    if gameState == "start" then
        if love.keyboard.isDown("return") then
            gameState = "play"
        end
    end
    if gameState == "intro" then
        if love.keyboard.isDown("return") then
            buttonClickSound:play()
            gameState = "menu"
        end
    end
    -- if gameState is play, then play
    if gameState == "play" then
        paddle1:update(dt, 1, screenWidth, screenHeight, ball)
        paddle2:update(dt, 2, screenWidth, screenHeight, ball)
        ball:update(dt, screenWidth, screenHeight, server, wallHitSound)
        if ball:collides(paddle1) then
            paddleHitSound:play()
            ball.angle = math.pi - ball.angle
            ball.x = paddle1.x + paddle1.width + ball.radius
            ball:setSpeed(ball.speed + 20)
            paddle1:setSpeed(paddle1.speed + 10)
            if paddle2.cpu then
                paddle2:setSpeed(paddle2.speed + 15)
            else
                paddle2:setSpeed(paddle2.speed + 10)
            end
        end
        if ball:collides(paddle2) then
            paddleHitSound:play()
            ball.angle = math.pi - ball.angle
            ball.x = paddle2.x - ball.radius
            ball:setSpeed(ball.speed + 20)
            paddle1:setSpeed(paddle1.speed + 10)
            if paddle2.cpu then
                paddle2:setSpeed(paddle2.speed + 15)
            else
                paddle2:setSpeed(paddle2.speed + 10)
            end
        end
        local gameData = ball:reset(screenWidth, screenHeight, pastPaddleSound)
        if gameData.gameState == "start" then
            if gameData.winner == 1 then
                paddle1.score = paddle1.score + 1
            else
                paddle2.score = paddle2.score + 1
            end
            if paddle1.score == 7 or paddle2.score == 7 then
                gameOverSound:play()
                gameState = "end"
            else
                gameState = "start"
            end
            paddle1:reset(screenWidth, screenHeight)
            paddle2:reset(screenWidth, screenHeight)
            server = server * -1
        end
    end
    -- if the user presses escape, reset the game and go to menu
    if love.keyboard.isDown("escape") then
        paddle1.score = 0
        paddle2.score = 0
        ball.x = screenWidth / 2
        ball.y = screenHeight / 2
        paddle1:reset(screenWidth, screenHeight)
        paddle2:reset(screenWidth, screenHeight)
        gameOver = false
        if gameState ~= "menu" then
            buttonClickSound:play()
        end
        gameState = "menu"
    end

    -- control music and screen brightness
    if gameState == "start" or gameState == "play" or gameState == "end" then
        
        menuMusic:pause()
        gameMusic:play()

        count = count + dt
        if count > updateDelay then
            if backgroundColor > 0.4 then
                backgroundColor = backgroundColor - 0.01
            end
            count = 0
        end
        if love.keyboard.isDown("escape") then
            backgroundColor = 0.4
        end
    elseif gameState == "menu" or gameState == "intro" or gameState == "controls" or gameState == "options" then

        gameMusic:pause()
        menuMusic:play()

        count = count + dt
        if count > updateDelay then
            if backgroundColor < 0.9 then
                backgroundColor = backgroundColor + 0.01
            end
            count = 0
        end
    end
    -- update the sliders
    if gameState == "options" then
        soundSlider:update()
        musicSlider:update()
        playerSlider:update()
    end
end

--draws all objects, background, and text. Also draws the correct screen based on the game state
function love.draw()
    local sx = love.graphics.getWidth() / background:getWidth()
    local sy = love.graphics.getHeight() / background:getHeight()
    --draw background and buttons
    love.graphics.setColor(backgroundColor, backgroundColor, backgroundColor)
    love.graphics.draw(background, 0, 0, 0, sx, sy+0.03)
    if gameState == "menu" or gameState == "intro" then
        love.graphics.setFont(pixelFontPresents)
        love.graphics.printf("Cameron McHatton presents...", 0, 50, screenWidth, "center")
        love.graphics.setFont(pixelFontTitle)
        love.graphics.printf("Pong", 0, 70, screenWidth, "center")
        if gameState == "intro" then
            love.graphics.setFont(pixelFontPresents)
            love.graphics.printf("Please visit the 'Read Me' menu before playing", 0, 300, screenWidth, "center")
            if math.floor((love.timer.getTime()) % 2) - 1 == 0 then
                love.graphics.printf("Press Enter to Continue...", 0, 350, screenWidth, "center")
            end
        end
        if gameState == "menu" then
            drawMenuButtons()
        end
    elseif gameState == "controls" then
        love.graphics.setFont(pixelFontControlsTitle)
        love.graphics.printf("Read Me", 0, 70, screenWidth, "center")
        love.graphics.setFont(pixelFontControls)
        love.graphics.printf("Player 1: W and S", 0, 200, screenWidth, "center")
        love.graphics.printf("Player 2: Up and Down", 0, 250, screenWidth, "center")
        love.graphics.printf("Press Enter to Start the Round", 0, 300, screenWidth, "center")
        love.graphics.printf("Press Escape to Return to the Menu", 0, 350, screenWidth, "center")
        love.graphics.printf("First to 7 Points Wins", 0, 400, screenWidth, "center")
        drawBackButton()

    elseif gameState == "options" then
        love.graphics.setFont(pixelFontControlsTitle)
        love.graphics.printf("Options", 0, 70, screenWidth, "center")

        love.graphics.setFont(pixelFontButtons)
        love.graphics.printf("Sound: " .. math.floor(soundSlider.value * 100) .. "%", 0, 210, screenWidth, "center")
        love.graphics.printf("Music: " .. math.floor(musicSlider.value * 100) .. "%", 0, 290, screenWidth, "center")

        if paddle2.cpu == false then
            love.graphics.printf("Players: 2", 0, 370, screenWidth, "center")
        else
            love.graphics.printf("Players: 1", 0, 370, screenWidth, "center")
        end
            
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1, 1, 1, 0.5)

        soundSlider:draw()
        musicSlider:draw()
        playerSlider:draw()

        drawBackButton()

    elseif gameState == "start" or gameState == "play" or gameState == "end" then
        --place line in middle of screen
        love.graphics.setColor(1, 1, 1, 0.5)
        if gameState == "start" or gameState == "play" then
            love.graphics.rectangle("fill", screenWidth / 2 - 2, 0, 2, screenHeight)
        elseif gameState == "end" then
            love.graphics.rectangle("fill", screenWidth / 2 - 2, 0, 2, 90)
            love.graphics.rectangle("fill", screenWidth / 2 - 2, 300, 2, screenHeight)
        end
        --place score and player names
        love.graphics.print(paddle1.score, screenWidth / 2 - 50, 25)
        love.graphics.print(paddle2.score, screenWidth / 2 + 30, 25)
        love.graphics.setFont(pixelFontPresents)
        if paddle2.cpu == false then
            love.graphics.printf("Player 1", 0, 5, screenWidth / 2, "center")
            love.graphics.printf("Player 2", screenWidth / 2, 5, screenWidth / 2, "center")
        else
            love.graphics.printf("Player", 0, 5, screenWidth / 2, "center")
            love.graphics.printf("CPU", screenWidth / 2, 5, screenWidth / 2, "center")
        end
        love.graphics.setFont(pixelFontButtons)
        --place paddles
        paddle1:draw()
        paddle2:draw()
        --place ball
        ball:draw()

        if gameState == "end" then
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.printf("Game Over", 0, 100, screenWidth, "center")
            if paddle1.score == 7 then
                love.graphics.printf("Player 1 Wins!", 0, 150, screenWidth, "center")
            else
                love.graphics.printf("Player 2 Wins!", 0, 150, screenWidth, "center")
            end
            love.graphics.printf("Press Enter to Play Again", 0, 200, screenWidth, "center")
            love.graphics.printf("Press Escape to Return to the Menu", 0, 250, screenWidth, "center")
            if love.keyboard.isDown("return") then
                paddle1.score = 0
                paddle2.score = 0
                gameState = "start"
            end
        end
    end
end
