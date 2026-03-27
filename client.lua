-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local showMarker = false
local markerPos = vec3(0,0,0)
local markerTimer = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("cds", function()
    TriggerServerEvent("ryze_cds:Check", "cds")
end)

RegisterCommand("cds3", function()
    TriggerServerEvent("ryze_cds:Check", "cds3")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("ryze_cds:Start")
AddEventHandler("ryze_cds:Start", function(mode)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local x = math.floor(coords.x * 100) / 100
    local y = math.floor(coords.y * 100) / 100
    local z = math.floor(coords.z * 100) / 100

    local cdsText = ""
    if mode == "cds3" then
        cdsText = string.format("vec3(%.2f,%.2f,%.2f)", x, y, z)
    else
        cdsText = string.format("%.2f,%.2f,%.2f", x, y, z)
    end
    
    print("^2[" .. string.upper(mode) .. "] ^7" .. cdsText)
    TriggerEvent("Notify", "verde", "Coordenadas: " .. cdsText, 5000)
    
    markerPos = coords
    markerTimer = GetGameTimer() + 15000
    showMarker = true
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD DRAW MARKER & ADJUST
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local time = 1000
        if showMarker then
            if GetGameTimer() < markerTimer then
                time = 5
                DrawMarker(28, markerPos.x, markerPos.y, markerPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 255, 0, 0, 200, false, false, 2, nil, nil, false)

                -- Get Relative Vectors
                local ped = PlayerPedId()
                local heading = GetEntityHeading(ped)
                local rotation = (heading * math.pi) / 180.0
                local forward = vec3(-math.sin(rotation), math.cos(rotation), 0.0)
                local right = vec3(math.cos(rotation), math.sin(rotation), 0.0)

                -- Adjust Z (Height)
                if IsDisabledControlPressed(0, 10) then -- PageUp
                    markerPos = vec3(markerPos.x, markerPos.y, markerPos.z + 0.01)
                    markerTimer = GetGameTimer() + 5000
                end

                if IsDisabledControlPressed(0, 11) then -- PageDown
                    markerPos = vec3(markerPos.x, markerPos.y, markerPos.z - 0.01)
                    markerTimer = GetGameTimer() + 5000
                end

                -- Adjust X (Left/Right)
                DisableControlAction(0, 174, true)
                if IsDisabledControlPressed(0, 174) then -- Arrow Left
                    markerPos = markerPos - right * 0.01
                    markerTimer = GetGameTimer() + 5000
                end

                DisableControlAction(0, 175, true)
                if IsDisabledControlPressed(0, 175) then -- Arrow Right
                    markerPos = markerPos + right * 0.01
                    markerTimer = GetGameTimer() + 5000
                end

                -- Adjust Y (Forward/Backward)
                DisableControlAction(0, 172, true)
                if IsDisabledControlPressed(0, 172) then -- Arrow Up
                    markerPos = markerPos + forward * 0.01
                    markerTimer = GetGameTimer() + 5000
                end

                DisableControlAction(0, 173, true)
                if IsDisabledControlPressed(0, 173) then -- Arrow Down
                    markerPos = markerPos - forward * 0.01
                    markerTimer = GetGameTimer() + 5000
                end

                -- Print Current
                if IsDisabledControlJustPressed(0, 38) then -- E 
                    local x = math.floor(markerPos.x * 100) / 100
                    local y = math.floor(markerPos.y * 100) / 100
                    local z = math.floor(markerPos.z * 100) / 100
                    local cdsText = string.format("vec3(%.2f,%.2f,%.2f)", x, y, z)
                    print("^2[CDS ADJUSTED] ^7" .. cdsText)
                    TriggerEvent("Notify", "verde", "Coordenada final: " .. cdsText, 5000)
                end
            else
                showMarker = false
            end
        end
        Wait(time)
    end
end)
