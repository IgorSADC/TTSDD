--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
APIAttribute = 'DDAPI'
spells = {}
displayString = {}

function onLoad()
    --[[ print('onLoad!') --]]
    originalXML = UI.getXml()

    UI.setAttribute(APIAttribute,'active' , true)

    UI.setAttribute('final_result', 'active', false)
    UI.setAttribute('searching_list', 'active', true)

    -- WebRequest.get('https://www.dnd5eapi.co/api/spells', 
    -- function(ri)
    --     spells = JSON.decode(ri.text)['results']
    --     print(spells)
    --     for key, value in pairs(spells) do
    --         print(spells[key]["name"])
    --     end
    -- end)

end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
end

function onScriptingButtonDown(index, player_color)
    local attr = UI.getAttribute(APIAttribute, 'active') == 'True'
    if attr then
        print("entrou")
        UI.setAttribute(APIAttribute,'active' , false )
        return
    end

    UI.setAttribute(APIAttribute,'active' , true)
    
end

function onSubmitToAPI(player, value, id)
    UI.setAttribute('final_result', 'active', true)
    UI.setAttribute('searching_list', 'active', false)
    print(value)

    makeConnection(value)
end

function makeConnection(value)
    if value == "" then return end
    
    value = string.gsub(value, " ", "-")
    local req = 'spells/' .. value
 
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
            thingToDisplay = thingToDisplay .. "----------" .. string.upper(key) .. "----------" .. "\n" .. getStringFromValue(value) .. "\n"
        end
    end

    UI.setAttribute('magic_description', 'text', thingToDisplay)
end

function getStringFromValue(valueToDesc)
    if(type(valueToDesc) ~= "table") then return "   " .. tostring(valueToDesc) end
    desc = "   "
    for key, value in pairs(valueToDesc) do
        desc = desc .. getStringFromValue(value)

        -- if type(value) == "table" then 
        --     print(value)
        --     return getStringFromValue(value)
        -- else
        --     desc = desc .. value
        -- end

    end
    return desc
end


function onResearch(player, value, id)

end

