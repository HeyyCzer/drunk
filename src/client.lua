local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

src = {}
Tunnel.bindInterface(GetCurrentResourceName(), src)
vSERVER = Tunnel.getInterface(GetCurrentResourceName())
InventoryS = Tunnel.getInterface("inventory")

RegisterNetEvent("drunk:start", function()
	CreateThread(function()
        while LocalPlayer.state.Drunked > 0 do
            StartScreenEffect("RaceTurbo",0,true)
            StartScreenEffect("DrugsTrevorClownsFight",0,true)
            Wait(30000)
        end
    end)

    CreateThread(function()
        while LocalPlayer.state.Drunked > 0 do
            Wait(1000)
        end
		StopScreenEffect("RaceTurbo")
		StopScreenEffect("DrugsTrevorClownsFight")
    end)
end)

local coords = {
	{ x = 2741.33, y = 4418.14, z = 47.74, h = 14.18 },
	{ x = -1135.34, y = 2683.61, z = 18.5, h = 138.9 },
}

local anims = {
	{
		dict = "get_up@directional@movement@from_seated@drunk",
		name = "getup_r_0",
		offset = -1300,
	},
	{
		dict = "switch@trevor@drunk_howling",
		name = "exit",
		offset = -2000,
	}
}


RegisterNetEvent("drunk:superDrunk", function()
	DoScreenFadeOut(2000)
	Wait(2000)

	local ped = PlayerPedId()
	local coord = coords[math.random(#coords)]
	FreezeEntityPosition(ped, true)
	SetEntityCoords(ped, coord.x, coord.y, coord.z)
	SetEntityHeading(ped, coord.h)

	while not HasCollisionLoadedAroundEntity(ped) do
		Wait(1000)
	end

	FreezeEntityPosition(ped, false)
	
	for k, v in ipairs(anims) do
		while not HasAnimDictLoaded(v.dict) do
			RequestAnimDict(v.dict)
			Wait(10)
		end
	end

	Wait(1000)
	DoScreenFadeIn(4000)

	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	local nextCoord = GetObjectOffsetFromCoords(coord.x, coord.y, coord.z, coord.h, 0.0, 5.0, 0.5)
	SetCamCoord(cam, nextCoord.x, nextCoord.y, nextCoord.z)
	PointCamAtEntity(cam, ped, 0.0, 0.0, 0.5)
	SetCamFov(cam, 25.0)
	RenderScriptCams(true, false, 0, false, false)

	for k, v in ipairs(anims) do
		TaskPlayAnim(ped, v.dict, v.name, 8.0, 0.0, -1, 9, 1.0, 0, 0, 0)
		Wait(GetAnimDuration(v.dict, v.name) * 1000 + (v.offset or 0))
	end
	DoScreenFadeOut(1000)
	Wait(1000)
	ClearPedTasksImmediately(ped)

	RenderScriptCams(false, false, 0, false, false)
	DestroyCam(cam)

	DoScreenFadeIn(1000)
end)


function src.DropItem(coords, item, amount)
	InventoryS.DropServer(coords, item, amount)
end