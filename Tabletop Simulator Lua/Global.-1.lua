--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
APIAttribute = 'DDAPI'
spells = {}
displayString = {}
currentLetters = 0

searchField = "spells"

currentSpellsSubset = {}
function onLoad()
    --[[ print('onLoad!') --]]
    initialize()
    

end

function initialize()
    originalXML = UI.getXml()

    UI.setAttribute(APIAttribute,'active' , true)

    UI.setAttribute('final_result', 'active', false)
    UI.setAttribute('searching_list', 'active', true)

    WebRequest.get('https://www.dnd5eapi.co/api/' .. searchField, 
    function(ri)
        spells = JSON.decode(ri.text)['results']

    end)
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
end

function onScriptingButtonDown(index, player_color)
    local attr = UI.getAttribute(APIAttribute, 'active') == 'True'
    if attr then
        UI.setAttribute(APIAttribute,'active' , false )
        return
    end

    UI.setAttribute(APIAttribute,'active' , true)
    
end

function onSubmitToAPI(player, value, id)
    UI.setAttribute('final_result', 'active', true)
    UI.setAttribute('searching_list', 'active', false)

    makeConnection(id)
end

function makeConnection(value)
    if value == "" then return end
    
    value = string.gsub(value, " ", "-")
    local req = searchField ..'/' .. value
 
    local desc = ""
    WebRequest.get('https://www.dnd5eapi.co/api/'..req, 
    function (ri)
    if ri.response_code == 404 then
        print("ERROR")
        UI.setAttribute('magic_description', 'text', "No magic named " .. value)
        return
    end

    currentMagic = JSON.decode(ri.text)
    overrideToggles(currentMagic)
    UI.setAttribute('magic_description', 'text', "Please select inputs on the left panel")
     end)
end

function overrideToggles(baseTable)
    local optionsString = ""
    for key, _ in pairs(baseTable) do
        optionsString = optionsString .. '<Toggle onValueChanged = "Global/printID" id="' .. key .. '">' .. key .. "</Toggle>"
        displayString[key] = ''
    end
    UI.setXml(string.gsub(originalXML, "$options_toggles", optionsString))
end

function printID(player, value, id)
    if value == 'True' then
        displayString[id] = currentMagic[id]
    else
        displayString[id] = ''
    end
    
    UpdateDisplay()
end

function UpdateDisplay()
    local thingToDisplay = ""
    for key, value in pairs(displayString) do
        if(value ~= '') then
            thingToDisplay = thingToDisplay .. "----------" .. string.upper(key) .. "----------" .. "\n" .. getStringFromValueWithKey(value) .. "\n"
        end
    end

    UI.setAttribute('magic_description', 'text', thingToDisplay)
end

function getStringFromValue(valueToDesc)
    if(type(valueToDesc) ~= "table") then return "   " .. tostring(valueToDesc) end
    desc = "   "
    for key, value in pairs(valueToDesc) do
        desc = desc .. getStringFromValueWithKey(value)

        -- if type(value) == "table" then 
        --     print(value)
        --     return getStringFromValue(value)
        -- else
        --     desc = desc .. value
        -- end

    end
    return desc
end
function getStringFromValueWithKey(valueToDesc)
    if(type(valueToDesc) ~= "table") then 
        print(valueToDesc)
        return "   " .. tostring(valueToDesc)
     end
    desc = "   "
    for key, value in pairs(valueToDesc) do
        desc = desc .. "---" .. key .. "--- \n      " 
        desc = desc .. getStringFromValueWithKey(value) .. "\n   "

        -- if type(value) == "table" then 
        --     print(value)
        --     return getStringFromValue(value)
        -- else
        --     desc = desc .. value
        -- end

    end
    return desc
end

-- THIS IS A VERY SIMPLE SEARCH ENGINE. I DON'T WANT TO SPEND TOO MUCH TIME HERE
function onResearch(player, value, id)
    print(value)
    if(value == "") then 
        -- Empty box
        UI.setAttribute('final_result', 'active', true)
        UI.setAttribute('searching_list', 'active', false)
        currentLetters = 0
        return
    end
    UI.setAttribute('final_result', 'active', false)
    UI.setAttribute('searching_list', 'active', true)

    if(string.len(value) < 3) then return end
    if(string.len(value) == 3 or string.len(value) < currentLetters) then 
        currentSpellsSubset = spells 
    end
    currentLetters = string.len(value)
    SelectSubset(value)
    -- print(getStringFromValue(currentSpellsSubset))
    
end

function SelectSubset(value)
    local new_subset = {}
    
    local text_to_display = ""
    for k, spell in pairs(currentSpellsSubset) do
        local lower_name = string.lower(spell['name'])
        if string.find(lower_name, value) ~= nil then
            -- print(spell)
            new_subset[k] = spell
            text_to_display = text_to_display .. '<Button onClick= "onSubmitToAPI" id= "' .. lower_name .. '"> ' .. lower_name .. "</Button>"
        end
    end
    currentSpellsSubset = new_subset
    
    local currentAttributes = UI.getAttribute('magic_name', 'onClick')
    UI.setXml(string.gsub(originalXML, "$new_row", text_to_display))
    UI.setAttribute('magic_name', 'text', value)
end


