if not table.maxn then
	function table.maxn(Table)
		local Number = 0
		for Index,_ in pairs(Table) do
			local Next = tonumber(Index)
			if Next and Next > Number then
				Number = Next
			end
		end
		return Number
	end
end

if not _G.async then
	function _G.async(func)
		if func then
			Citizen.CreateThreadNow(func)
		else
			return setmetatable({ wait = function(self)
				local rets = Citizen.Await(self.p)
				return table.unpack(rets,1,table.maxn(rets))
			end, p = promise.new() },{ __call = function(self,...)
				self.r = {...}
				self.p:resolve(self.r)
			end })
		end
	end
end

if not _G.module then
	function _G.module(Resource,patchs)
		if not patchs then
			patchs = Resource
			Resource = "vrp"
		end
		local code = LoadResourceFile(Resource,patchs..".lua")
		if code then
			local floats = load(code,Resource.."/"..patchs..".lua","bt",_G)
			if floats then
				local resAccept,resUlts = xpcall(floats,debug.traceback)
				if resAccept then
					return resUlts
				end
			end
		end
	end
end

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("ryze_cds:Check")
AddEventHandler("ryze_cds:Check", function(mode)
    local source = source
    local Passport = vRP.Passport(source)
    
    -- Verifica se o jogador tem o grupo "Admin" ou "Developer"
    if vRP.HasGroup(Passport, "Admin") or vRP.HasGroup(Passport, "Developer") then
        TriggerClientEvent("ryze_cds:Start", source, mode)
    else
        TriggerClientEvent("Notify", source, "vermelho", "Você não tem permissão para usar este comando.", 5000)
    end
end)
