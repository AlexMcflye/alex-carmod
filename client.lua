ESX                     = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

local driftMod, oldSportMod, totalNos = {}, {}, {}
local driftCd, sportCd = false, false

-- Drift Mod
Citizen.CreateThread( function()
	while true do
        local time = 1000
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(vehicle, -1) == ped then	
            time = 1
            if GetVehicleClass(vehicle) == 1 or GetVehicleClass(vehicle) == 3 or GetVehicleClass(vehicle) == 4 or GetVehicleClass(vehicle) == 5 or GetVehicleClass(vehicle) == 6 or GetVehicleClass(vehicle) == 7 then 
                local plate = GetVehicleNumberPlateText(vehicle)

                if IsControlJustReleased(0, 29) and not driftMod[plate] and not driftCd then
                    ESX.TriggerServerCallback('carmod:isChiped', function(chiped)
                        if chiped then
                            driftMod[plate] = true
                            --QBCore.Functions.Notify("Drift Modu Aktif")
                            TriggerEvent('mythic_notify:client:SendAlert', { type = 'inform', text = 'Drift Modu Aktif!'})
                        end
                    end, plate)
                    TriggerEvent("alex-carmod:driftCd")
                elseif IsControlJustReleased(0, 29) and driftMod[plate] and not driftCd then
                    driftMod[plate] = false
                    --QBCore.Functions.Notify("Drift Modu Pasif")
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Drift Modu Pasif!'})
                    TriggerEvent("alex-carmod:driftCd")
                elseif IsControlJustReleased(0, 29) and driftCd and (driftMod[plate] or driftMod[plate] == false) then
                    --QBCore.Functions.Notify("Bu Kadar Hızlı Mod Değiştiremezsin!", "error")
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Bu kadar hızlı mod değiştiremezsin!'})
                end

                if driftMod[plate] then
                    if IsControlPressed(1, 21) then
                        SetVehicleReduceGrip(vehicle, true)
                        TriggerEvent("simplecarhud:zorlahizsabitle", vehicle, true, 120)
                    elseif IsControlJustReleased(1, 21) then
                        SetVehicleReduceGrip(vehicle, false)
                        TriggerEvent("simplecarhud:zorlahizsabitle", vehicle, false)
                    end
                end
          
            end

            -- Sport Mod
            if GetVehicleClass(vehicle) == 1 or GetVehicleClass(vehicle) == 3 or GetVehicleClass(vehicle) == 4 or GetVehicleClass(vehicle) == 5 or GetVehicleClass(vehicle) == 6 or GetVehicleClass(vehicle) == 7 then 
                local plate = GetVehicleNumberPlateText(vehicle)
          
                if IsControlJustReleased(0, 60) and not sportCd then
                    ESX.TriggerServerCallback('carmod:isChiped', function(chiped, onOrOff, olddata)
                        if chiped then
                            if onOrOff == nil or onOrOff == false then
                                SportModOn(vehicle, plate)
                            else
                                SportModOff(vehicle, plate, olddata)
                            end
                        end
                    end, plate)
                    TriggerEvent("alex-carmod:sportCd")
                elseif IsControlJustReleased(1, 60) and sportCd then
                    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Bu kadar hızlı mod değiştiremezsin!'})
                end	
            end       

            -- Nos
            if IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(vehicle, -1) == ped then
                local plate = GetVehicleNumberPlateText(vehicle)
                if IsControlPressed(1, 19) and totalNos[plate] ~= nil then	
                    if totalNos[plate] > 9 then
                        totalNos[plate] = totalNos[plate] - 10
    
                        --QBCore.Functions.Notify("Kalan NOS %" ..totalNos[plate])
                        --exports['mythic_notify']:SendAlert('error', Blips[i].name.. ' Bliplerini Kapadın')
                        exports['mythic_notify']:SendAlert('inform', totalNos[plate].. ' NOS Kaldı!')
                        SetVehicleForwardSpeed(vehicle, GetEntitySpeed(vehicle)+3.0)
                        StartScreenEffect("RaceTurbo", 0, 0)
                        nitroActivado = false
                        Citizen.Wait(650)
                    end
                end
            end

        end
        Citizen.Wait(time)
	end
end)

-- Çip Takma
RegisterNetEvent("carmod:chipAddClient")
AddEventHandler("carmod:chipAddClient", function()
	local playerPed = PlayerPedId()
	
	if IsPedInAnyVehicle(playerPed, false) then
		TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Araç içinden çip takamazsın'})
		return
    end

    local coords = GetEntityCoords(playerPed)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)	
    if GetVehicleClass(vehicle) == 1 or GetVehicleClass(vehicle) == 3 or GetVehicleClass(vehicle) == 4 or GetVehicleClass(vehicle) == 5 or GetVehicleClass(vehicle) == 6 or GetVehicleClass(vehicle) == 7 then 
        local kaputkordinat = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'engine'))
        
        if #(coords - kaputkordinat) <= 2.3 then
            if DoesEntityExist(vehicle) then
                TriggerServerEvent("carmod:chipAdd", GetVehicleNumberPlateText(vehicle))
                SetVehicleDoorOpen(vehicle, 4, 0, 0)
                FreezeEntityPosition(PlayerPedId(), true)
                TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

                --QBCore.Functions.Progressbar("cip_tak", "Çip Takılıyor", 10000, false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
                exports['mythic_progbar']:Progress({
                    name = "chip",
                    duration = 10000,
                    label = 'Çip Takılıyor...',
                    useWhileDead = false,
                    canCancel = false,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = true,
                    },
                     animation = {
                     	animDict = "mini@repair",
                    	anim = "fixing_a_ped",
                     	flags = 49,
                    },
                }, function(cancelled)
                    if not cancelled then
                        TriggerEvent('mythic_notify:client:SendAlert', { type = 'success', text = 'Çip takıldı'})
                        FreezeEntityPosition(PlayerPedId(), false)
                    end
                end)
                --TriggerEvent('mythic_notify:client:SendAlert', { type = 'success', text = 'Çip takıldı'})
                    ClearPedTasksImmediately(playerPed)
                    SetVehicleDoorShut(vehicle, 4, 0)
            end
        else
            --QBCore.Functions.Notify("Çipi Takmak İçin Motara Yakın Olman Lazım")
            TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Çipi Takmak İçin Motara Yakın Olman Lazım'})
        end
    else
        --QBCore.Functions.Notify("Bu Araca Çip Takılamaz")
        TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Bu Araca Çip Takılamaz'})
    end
end)

-- Nos Takma
RegisterNetEvent("carmod:nos")
AddEventHandler("carmod:nos", function()
	local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        --QBCore.Functions.Progressbar("nos_tak", "Nos Takılıyor", 10000, false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
		exports['mythic_progbar']:Progress({
			name = "nos",
			duration = 7000,
			label = 'Nos Takılıyor...',
			useWhileDead = false,
			canCancel = false,
			controlDisables = {
				disableMovement = false,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			},
			-- animation = {
			-- 	animDict = "mp_player_inteat@burger",
			-- 	anim = "mp_player_int_eat_burger_fp",
			-- 	flags = 49,
			-- },
		}, function(cancelled)
			if not cancelled then
				TriggerEvent('mythic_notify:client:SendAlert', { type = 'success', text = 'Nos Takıldı'})
			end
		end)
            local plate = GetVehicleNumberPlateText(vehicle)
            --QBCore.Functions.Notify("Nos Takıldı")
            --TriggerEvent('mythic_notify:client:SendAlert', { type = 'success', text = 'Nos Takıldı'})
            totalNos[plate] = 100
            TriggerServerEvent("carmod:removeNos")
        else 
        --QBCore.Functions.Notify("Araç Dışında Bunu Kullanamazsın!")
        TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Araç dışında kullanamazsın'})
    end
end)

RegisterNetEvent("alex-carmod:driftCd")
AddEventHandler("alex-carmod:driftCd", function()
    driftCd = true
    Citizen.Wait(3000)
    driftCd = false
end)

RegisterNetEvent("alex-carmod:sportCd")
AddEventHandler("alex-carmod:sportCd", function()
    sportCd = true
    Citizen.Wait(3000)
    sportCd = false
end)

function SportModOn(vehicle, plate)
    local oldfInitialDriveMaxFlatVelData = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
    local oldffDriveInertiaData = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia")
    local oldfClutchChangeRateScaleUpShiftData = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift")
    local oldfClutchChangeRateScaleDownShiftData = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleDownShift")

    oldSportMod[plate] = {
        oldfInitialDriveMaxFlatVel = oldfInitialDriveMaxFlatVelData,
        oldffDriveInertia = oldfInitialDriveMaxFlatVelData,
        oldfClutchChangeRateScaleUpShift = oldfInitialDriveMaxFlatVelData,
        oldfClutchChangeRateScaleDownShift = oldfInitialDriveMaxFlatVelData,
    }
	
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel', oldfInitialDriveMaxFlatVelData + (oldfInitialDriveMaxFlatVelData / 100 * 20))
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fDriveInertia', 2.000000)
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fClutchChangeRateScaleUpShift', oldfClutchChangeRateScaleUpShiftData * 8)
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fClutchChangeRateScaleDownShift', oldfClutchChangeRateScaleDownShiftData * 8)
    TriggerServerEvent("carmod:OpenSportMod", plate, oldSportMod[plate])

    --QBCore.Functions.Notify("Sport Modu Aktif")
    TriggerEvent('mythic_notify:client:SendAlert', { type = 'success', text = 'Sport Modu Aktif!'})
end

function SportModOff(vehicle, plate, olddata)
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel', olddata.oldfInitialDriveMaxFlatVel)
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fDriveInertia', olddata.oldffDriveInertia)
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fClutchChangeRateScaleUpShift', olddata.oldfClutchChangeRateScaleUpShift)
	SetVehicleHandlingField(vehicle, 'CHandlingData', 'fClutchChangeRateScaleDownShift', olddata.oldfClutchChangeRateScaleDownShift)
    TriggerServerEvent("carmod:CloseSportMod", plate)

    --QBCore.Functions.Notify("Sport Modu Pasif")
    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Sport Modu Pasif!'})
end

--[[RegisterCommand("ciptak", function()
    TriggerEvent("carmod:chipAddClient")
end)
RegisterCommand("nostak", function()
    TriggerEvent("carmod:nos")
end)--]]