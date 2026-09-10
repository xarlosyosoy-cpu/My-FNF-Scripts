-- V2.3.1 (correcciones de sintaxis y mejoras)
-- script made by camlikeskirby (Username on a lot of sites)
-- Now this script is only in one song while the CharacterLoader.lua does all the character setting stuff

-- Easily Editable:
local modNames = {'Character Select', '1My Character Pack'}
local blockedCharacters = {'bf-pixel', 'bf-pixel-opponent', 'darnell-blazin', 'nene', 'pico-blazin', 'pico-speaker', 'senpai', 'senpai-angry', 'spirit', 'gf'}
local blockedCharactersGF = {'nene', 'pico-speaker', 'gf-pixel'}

-- Easily Editable: For psych forks with different folder locations
local assetsSharedCharactersFolder = 'assets/shared/characters' -- Base Game Character Location
local modsFolder = 'mods'

-- Settings
local BaseCharacters = getModSetting('baCh', 'Character Select')
local BaseCharactersGF = getModSetting('baChgf', 'Character Select')
local ModCharacters = getModSetting('moCh', 'Character Select')
local LoadCharacterswithC = getModSetting('lcwC', 'Character Select')
local PreloadCharacters = getModSetting('pload', 'Character Select')
local PreloadCharactersGF = getModSetting('ploadgf', 'Character Select')
local AnyGF = getModSetting('gfunlocked', 'Character Select')
local isMobile = buildTarget == 'android' or buildTarget == 'ios' or buildTarget == 'unknown'

-- Don't touch unless you know what your doing!!
local mobileOffset = 1
-- BF and GF vars combined
local bAndGChars = {{}, {}}
local savebforgf = {'',''}
local bAndGCharacterNumber = {"0", "2"}
local bAndGNums = {1, 1}
local pages = {1,1}
local bfOrGf = 1

local CharFolder = {}
local thing = false
local folders = ''

runHaxeCode([[import backend.Mods; setVar('modFolders', Mods.parseList().enabled);]])
local enabledModFolders = getVar('modFolders') or {}

function onCreatePost()
    if not isMobile then mobileOffset = 0 end
    setProperty('camHUD.alpha', 0)
    setProperty('dad.alpha', 0)

    folders = directoryFileList('mods')
    cameraSetTarget("boyfriend")
    setProperty('gf.alpha', 0.3)

    makeLuaText("charName", "", 0, 970, 450)
    setTextSize("charName", 30)
    setObjectCamera("charName","other")
    addLuaText("charName")

    local c = ''
    if LoadCharacterswithC and not isMobile then
        c = ' Press C to load in the character.'
    elseif isMobile then
        c = ' Press up and down hitboxes/buttons to accept.'
    end
    makeLuaText("controlsTxt", 'Use G and B to switch between the player and partner.'..c, 0, -1, 700)
    setProperty('controlsTxt.borderSize', 1.25)
    setObjectCamera('controlsTxt','other')
    addLuaText("controlsTxt")

    initSaveData('autoCharacterSelect')

    savebforgf[1] = getDataFromSave('autoCharacterSelect', 'bf', 'bf')
    savebforgf[2] = getDataFromSave('autoCharacterSelect', 'gf', 'gf')

    runHaxeCode([[
        createCallback('checkAnimation', function(text:String, character:String) {
            if (character == 'b') {
                return boyfriend.animation.getByName(text) != null;
            } else if (character == 'g') {
                return gf.animation.getByName(text) != null;
            }
        });
    ]])

    table.insert(bAndGChars[1], savebforgf[1])
    table.insert(bAndGChars[2], savebforgf[2])

    addTheCharacters()

    triggerEvent("Change Character", "0", savebforgf[1])
    triggerEvent("Change Character", "2", savebforgf[2])
    playMusic('stayFunky', 1, true)
end

function onStartCountdown()
    gfdance = 1
    runTimer('Dance', 0.69, 0)
    if not allowCountdown then
        allowCountdown = true
        return Function_Stop
    end
    cancelTimer("Dance")
    return Function_Continue
end

function onUpdate()
    local toptext = 'PLAYER'
    local animControls = '\nD, F, J, K'
    if bfOrGf == 2 then
        toptext = 'PARTNER'
        animControls = ''
    end
    if isMobile then animControls = '' end

    setTextString("charName", toptext.. animControls.. '\n' ..bAndGNums[bfOrGf].. '/'.. #bAndGChars[bfOrGf])

    if keyJustPressed("right") then changeItem(1) end
    if keyJustPressed("down") and not keyJustPressed("up") then changeItem(5) end
    if keyJustPressed("up") and not keyJustPressed("down") then changeItem(-5) end
    if keyJustPressed("left") then changeItem(-1) end

    if bfOrGf == 1 then
        if keyboardJustPressed('D') then playAnim("boyfriend", "singLEFT", true, false, 0) end
        if keyboardJustPressed('F') then playAnim("boyfriend", "singDOWN", true, false, 0) end
        if keyboardJustPressed('J') then playAnim("boyfriend", "singUP", true, false, 0) end
        if keyboardJustPressed('K') then playAnim("boyfriend", "singRIGHT", true, false, 0) end
    end

    if keyboardJustPressed('C') and LoadCharacterswithC then
        triggerEvent("Change Character", bAndGCharacterNumber[bfOrGf], bAndGChars[bfOrGf][bAndGNums[bfOrGf]])
        if bfOrGf == 1 then
            cameraSetTarget("boyfriend")
        else
            triggerEvent('Camera Follow Pos', getMidpointX('gf') + getProperty('gf.cameraPosition[0]'), getMidpointY('gf') + getProperty('gf.cameraPosition[1]'))
        end
    end

    if keyboardJustPressed('B') or #bAndGChars[2] < bAndGNums[2] then
        if isMobile then changeItem(1) end
        bfOrGf = 1
        if isMobile then bAndGNums[2] = 1 end
        triggerEvent('Camera Follow Pos', nil, nil)
        cameraSetTarget("boyfriend")
        setProperty('gf.alpha', 0.3)
        setProperty('boyfriend.alpha', 1)
        for i = 1, #bAndGChars[1] + mobileOffset, 1 do setProperty(i..'1TEXT.visible', true) end
        for i = 1, #bAndGChars[2] + mobileOffset, 1 do setProperty(i..'2TEXT.visible', false) end
    end

    if keyboardJustPressed('G') or #bAndGChars[1] < bAndGNums[1] then
        if isMobile then changeItem(1) end
        bfOrGf = 2
        triggerEvent('Camera Follow Pos', getMidpointX('gf') + getProperty('gf.cameraPosition[0]'), getMidpointY('gf') + getProperty('gf.cameraPosition[1]'))
        setProperty('boyfriend.alpha', 0.3)
        setProperty('gf.alpha', 1)
        for i = 1, #bAndGChars[1] + mobileOffset, 1 do setProperty(i..'1TEXT.visible', false) end
        for i = 1, #bAndGChars[2] + mobileOffset, 1 do setProperty(i..'2TEXT.visible', true) end
    end

    if keyJustPressed('back') then exitSong(true) end

    if keyJustPressed('accept') or (keyJustPressed("UP") and keyJustPressed("DOWN") and isMobile) then
        playSound('confirmMenu')
        cancelTimer("Dance")
        if not thing then
            thing = true

            cameraSetTarget('boyfriend')

            if LoadCharacterswithC then
                triggerEvent("Change Character", "0", bAndGChars[1][bAndGNums[1]])
                triggerEvent("Change Character", "2", bAndGChars[2][bAndGNums[2]])
            end
            setDataFromSave('autoCharacterSelect', 'bf', bAndGChars[1][bAndGNums[1]])
            setDataFromSave('autoCharacterSelect', 'gf', bAndGChars[2][bAndGNums[2]])

            if checkAnimation('hey', 'b') then
                playAnim("boyfriend", "hey", true, false, 0)
            else
                playAnim("boyfriend", "singUP", true, false, 0)
            end

            if checkAnimation('cheer', 'g') then
                playAnim("gf", "cheer", true, false, 0)
            elseif checkAnimation('hey', 'g') then
                playAnim("gf", "hey", true, false, 0)
            else
                playAnim("gf", "singUP", true, false, 0)
            end

            runTimer('Exit', 2, 0)
            soundFadeOut(nil, 1)
            doTweenAlpha('gfalph', 'gf', 1, 1)
            doTweenAlpha('bfalph', 'boyfriend', 1, 1)
            doTweenAlpha('text', 'camOther', 0, 0.5)
        else
            exitSong(true)
        end
    end
end

function onTimerCompleted(tag)
    if tag == 'Dance' then
        playAnim("boyfriend", "idle", false, false, 0)
        playAnim("gf", "idle", false, false, 0)

        if gfdance == 1 then gfdance = 0 else gfdance = 1 end

        if gfdance == 0 then
            playAnim("gf", "danceLeft", false, false, 0)
            playAnim("boyfriend", "danceLeft", false, false, 0)
        else
            playAnim("gf", "danceRight", false, false, 0)
            playAnim("boyfriend", "danceRight", false, false, 0)
        end
    end
    if tag == 'Exit' then exitSong(true) end
end

function addTheCharacters()
    local bc = directoryFileList(assetsSharedCharactersFolder)

    if BaseCharacters then
        for i = 1, #bc, 1 do
            if not stringStartsWith(bc[i], "gf-") then table.insert(CharFolder, bc[i]) end
        end
    end

    if BaseCharactersGF then
        table.insert(bAndGChars[2], 'gf')
        for i = 1, #bc, 1 do
            if stringStartsWith(bc[i], "gf-") then table.insert(CharFolder, bc[i]) end
        end
    end

    for i = 1, #folders, 1 do
        if contains(modNames, folders[i]) and contains(enabledModFolders, folders[i]) then
            local mfc = directoryFileList(modsFolder..'/'..folders[i]..'/characters')
            for j = 1, #mfc, 1 do
                table.insert(CharFolder, mfc[j])
            end
        end
    end

    if ModCharacters then
        local mc = directoryFileList(modsFolder..'/characters')
        for i = 1, #mc, 1 do table.insert(CharFolder, mc[i]) end
    end

    for i = 1, #CharFolder, 1 do
        local wJ = string.gsub(CharFolder[i], "%.json$", "")
        if stringEndsWith(CharFolder[i], ".json") and not contains(blockedCharacters, wJ) and not contains(blockedCharactersGF, wJ) and not stringEndsWith(wJ, '-dead') then
            if not stringStartsWith(CharFolder[i], "gf-") then
                if PreloadCharacters then addCharacterToList(wJ, 'boyfriend') end
                table.insert(bAndGChars[1], wJ)
                if AnyGF and not contains(blockedCharactersGF, wJ) then table.insert(bAndGChars[2], wJ) end
            end

            if stringStartsWith(CharFolder[i], "gf-") then
                if PreloadCharactersGF then addCharacterToList(wJ, 'gf') end
                table.insert(bAndGChars[2], wJ)
            end
        end
    end
    addMenu()
end

function addMenu()
    for c = 1, #bAndGChars, 1 do
        local count = 1
        local currentY = 0
        for i = 1, #bAndGChars[c], 1 do
            if count == 1 then currentY = currentY + 70 end
            makeLuaText(i..c..'TEXT', string.sub(bAndGChars[c][i], 1, 5), screenWidth, (70 * count) - 650, currentY)
            setObjectCamera(i..c..'TEXT', "other")
            setProperty(i..c..'TEXT.borderSize', 1.25)
            setObjectOrder(i..c..'TEXT', 1)
            addLuaText(i..c..'TEXT')
            if c == 2 then setProperty(i..c..'TEXT.visible', false) end
            count = count + 1
            if count == 6 then count = 1 end
        end
        if isMobile then
            if count == 1 then currentY = currentY + 70 end
            local name = 'gf'
            if c == 2 then name = 'bf' end

            makeLuaText((#bAndGChars[c] + 1)..c..'TEXT', name..'switch', screenWidth, (70 * count) - 650, currentY)
            setObjectCamera((#bAndGChars[c] + 1)..c..'TEXT', "other")
            setProperty((#bAndGChars[c] + 1)..c..'TEXT.borderSize', 1.25)
            setObjectOrder((#bAndGChars[c] + 1)..c..'TEXT', 1)
            addLuaText((#bAndGChars[c] + 1)..c..'TEXT')
            if c == 2 then setProperty((#bAndGChars[c] + 1)..c..'TEXT.visible', false) end
            setTextColor((#bAndGChars[1] + 1)..c..'TEXT', 'red')
            setTextColor((#bAndGChars[2] + 1)..c..'TEXT', 'cyan')
        end
    end
    setTextColor('11TEXT', 'yellow')
    setTextColor('12TEXT', 'yellow')
end

function changeItem(number)
    bAndGNums[bfOrGf] = bAndGNums[bfOrGf] + number

    if bAndGNums[bfOrGf] < 1 or bAndGNums[bfOrGf] > #bAndGChars[bfOrGf] + mobileOffset then
        if number > 0 then
            bAndGNums[bfOrGf] = 1
            for i = 1, #bAndGChars[bfOrGf] + mobileOffset, 1 do setProperty(i..bfOrGf..'TEXT.y', getProperty(i..bfOrGf..'TEXT.y') + 630 * (pages[bfOrGf] - 1)) end
            pages[bfOrGf] = pages[bfOrGf] - (pages[bfOrGf] - 1)
        else
            bAndGNums[bfOrGf] = #bAndGChars[bfOrGf]
            pages[bfOrGf] = pages[bfOrGf] + 1
            for i = 1, #bAndGChars[bfOrGf] + mobileOffset, 1 do setProperty(i..bfOrGf..'TEXT.y', getProperty(i..bfOrGf..'TEXT.y') - 630 * (pages[bfOrGf] - 1)) end
        end
    end

    if bAndGNums[bfOrGf] - (45 * (pages[bfOrGf] - 1)) >= 46 then
        for i = 1, #bAndGChars[bfOrGf] + mobileOffset, 1 do setProperty(i..bfOrGf..'TEXT.y', getProperty(i..bfOrGf..'TEXT.y') - 630) end
        pages[bfOrGf] = pages[bfOrGf] + 1
    elseif bAndGNums[bfOrGf] - (45 * (pages[bfOrGf] - 1)) <= 0 then
        for i = 1, #bAndGChars[bfOrGf] + mobileOffset, 1 do setProperty(i..bfOrGf..'TEXT.y', getProperty(i..bfOrGf..'TEXT.y') + 630) end
        pages[bfOrGf] = pages[bfOrGf] - 1
    end

    if not LoadCharacterswithC then
        triggerEvent("Change Character", bAndGCharacterNumber[bfOrGf], bAndGChars[bfOrGf][bAndGNums[bfOrGf]])
        if bfOrGf == 1 then
            cameraSetTarget("boyfriend")
        else
            triggerEvent('Camera Follow Pos', getMidpointX('gf') + getProperty('gf.cameraPosition[0]'), getMidpointY('gf') + getProperty('gf.cameraPosition[1]'))
        end
    end

    for i = 1, #bAndGChars[bfOrGf] + mobileOffset, 1 do
        if bAndGNums[bfOrGf] == i and #bAndGChars[bfOrGf] >= i then
            setTextColor(i..bfOrGf..'TEXT', 'yellow')
        elseif i <= #bAndGChars[bfOrGf] then
            setTextColor(i..bfOrGf..'TEXT', 'white')
        end
    end
end

function contains(tabla, element)
    for _, value in pairs(tabla) do
        if value == element then
            return true
        end
    end
    return false
end

function onDestroy() flushSaveData('autoCharacterSelect') end
