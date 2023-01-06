local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local vRP = Proxy.getInterface("vRP")
local vINVENTORY = Proxy.getInterface("inventory")

src = {}
Tunnel.bindInterface(GetCurrentResourceName(), src)
vCLIENT = Tunnel.getInterface(GetCurrentResourceName())

exports("increase", function(Passport, Points)
	local source = vRP.Source(Passport)
	local currentPoints = (Player(source).state.Drunked or 0)

	local coords = GetEntityCoords(GetPlayerPed(source))	

	local newPoints = currentPoints + Points

	Player(source).state.Drunked = newPoints
	Player(source).state.DrunkTimer = os.time()

	if newPoints == 3 then
		TriggerClientEvent("drunk:start", source)
	elseif newPoints == 11 then
		TriggerClientEvent("Notify", source, "amarelo", "Cuidado! É melhor parar de beber ou você perderá o controle.", 15000)
	elseif newPoints >= 12 then
		Player(source).state.Drunked = 1
		TriggerClientEvent("drunk:superDrunk", source)

		print("^4[DRUNK] ^0O jogador ^4" .. Passport .. " ^0bebeu demais e foi parar no meio do nada.")

		local items = takeRandomItems(Passport, source, coords)
		if items ~= "Nenhum" then
			TriggerClientEvent("Notify",source,"aviso","Parece que você esqueceu seu(s) <b>" .. items .. "</b> em algum lugar... Talvez onde você estava?")
		end

		PerformHttpRequest("https://canary.discord.com/api/webhooks/1054599075267354704/OhD-P8gF4w0nROV6Huk3fR8ZUaxgJoYnlPx8BGrLQVUSOAg7pFCZIdVGEMfHtzt3fkhi", function(err, text, headers)
			if err ~= 204 then
				print(json.encode(text))
			end
		end, "POST", json.encode({
			embeds = {
				{
					description = "O jogador **" .. Passport .. "** bebeu demais e foi parar no meio do nada!",
					fields = {
						{
							name = "Itens perdidos",
							value = "```\n" .. items .. "\n```"
						}
					},
					color = 3042892
				}
			}
		}), {["Content-Type"] = "application/json"})
	end
end)


function takeRandomItems(Passport, source, coords)
	coords = { x = coords.x, y = coords.y, z = coords.z - 0.5 }	

	local lost = {}
	local inventory = vRP.Inventory(Passport)
	for k, v in pairs(inventory) do
		local chance = math.random(100)
		if chance < 10 then
			local amount = math.random(v.amount)
			vRP.TakeItem(Passport, v.item, amount)
			vCLIENT.DropItem(source, coords, v.item, amount)

			local split = splitString(v["item"], "-")
			table.insert(lost, v.amount .. "x " .. itemName(split[1]))
		end
	end

	if #lost == 0 then
		return "Nenhum"
	end
	return table.concat(lost, ", ")
end

Citizen.CreateThread(function()
	while true do
		for _, pSource in pairs(GetPlayers()) do
			pSource = tonumber(pSource)

			local s = Player(pSource).state
			local points = s.Drunked or 0
			if points > 0 then
				if s.DrunkTimer < os.time() - 60 then
					Player(pSource).state.Drunked = points - 1
					Player(pSource).state.DrunkTimer = os.time()
				end
			elseif points < 0 then
				Player(pSource).state.Drunked = 0
			end
		end
		Wait(15 * 1000)
	end
end)
