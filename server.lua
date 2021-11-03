ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local IsSportModOn = {}
local oldSportModData = {}
local isChiped = {}

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    exports.ghmattimysql:execute('SELECT plate FROM owned_vehicles WHERE chip = @chip', { 
        ['@chip'] = 1
    }, function(result)
        if #result > 0 then
            for i=1, #result do
                isChiped[result[i].plate] = true
            end
        end
    end)
end)

ESX.RegisterServerCallback('carmod:isChiped', function(source, cb, plate)
    cb(isChiped[plate], IsSportModOn[plate], oldSportModData[plate])
end)

RegisterServerEvent('carmod:OpenSportMod')
AddEventHandler('carmod:OpenSportMod', function(plate, data)
    IsSportModOn[plate] = true
    oldSportModData[plate] = data
end)

RegisterServerEvent('carmod:CloseSportMod')
AddEventHandler('carmod:CloseSportMod', function(plate)
    IsSportModOn[plate] = nil
end)

ESX.RegisterUsableItem('tunner_chip', function(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('carmod:chipAddClient', source)
    
end)

ESX.RegisterUsableItem('aracnos', function(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('carmod:nos', source)
   
end)

RegisterServerEvent('carmod:removeNos')
AddEventHandler('carmod:removeNos', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        --xPlayer.Functions.RemoveItem('dolu_nos', 1, xPlayer.Functions.GetItemByName("dolu_nos").slot)
        xPlayer.removeInventoryItem('aracnos', 1)
    end
end)

--[[RegisterServerEvent('carmod:chipAdd')
AddEventHandler('carmod:chipAdd', function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        --xPlayer.Functions.RemoveItem('tunner_chip', 1, xPlayer.Functions.GetItemByName("tunner_chip").slot)
        xPlayer.removeInventoryItem('tunner_chip', 1)
        isChiped[plate] = true
        exports.ghmattimysql:execute("UPDATE owned_vehicles SET chip = @chip WHERE plate = @plate", {
            ['@plate'] = plate,
            ['@chip'] = 1 
        })
    end
end)--]]

RegisterServerEvent('carmod:chipAdd')
AddEventHandler('carmod:chipAdd', function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        --xPlayer.Functions.RemoveItem('tunner_chip', 1, xPlayer.Functions.GetItemByName("tunner_chip").slot)
        xPlayer.removeInventoryItem('tunner_chip', 1)
        isChiped[plate] = true
        exports.ghmattimysql:execute("UPDATE owned_vehicles SET chip = @chip WHERE plate = @plate", {
            ['@plate'] = plate,
            ['@chip'] = 1 
        })
    end
end)

RegisterServerEvent('carmod:chipRemove')
AddEventHandler('carmod:chipRemove', function(plate)
    if IsSportModOn[plate] then
        IsSportModOn[plate] = nil
    end
    isChiped[plate] = nil
    exports.ghmattimysql:execute("UPDATE owned_vehicles SET chip = @chip WHERE plate = @plate", {
        ['@plate'] = plate,
        ['@chip'] = 0
    })
end)
