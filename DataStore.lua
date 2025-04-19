local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Player")

local loaded = {}

game.Players.PlayerAdded:Connect(function(plr)
	local success, value = pcall(dataStore.GetAsync, dataStore, plr.UserId)
	if success == false then plr:Kick("Failed to load DataStore") return end
	local data = value or {}
	print("Loaded: ", data)
	for i, folder in game.ServerStorage.PlayerData:GetChildren() do
		local subData = data[folder.Name] or {}
		local Clone = folder:Clone()
		for i, child in Clone:GetChildren() do
			child.Value = subData[child.Name] or child.Value
		end
		Clone.Parent = plr
	end
	loaded[plr] = true
end)

game.Players.PlayerRemoving:Connect(function(plr)
	if loaded[plr] == nil then return end
	local data = {}
	for i, folder in game.ServerStorage.PlayerData:GetChildren() do
		local subData = {}
		for i, child in plr[folder.Name]:GetChildren() do
			subData[child.Name] = child.Value
		end
		data[folder.Name] = subData
	end
	local success, value = pcall(dataStore.SetAsync, dataStore, plr.UserId, data)
	print("Saved: ", data)
	loaded[plr] = nil
end)

game:BindToClose(function()
	while next(loaded) ~= nil do
		task.wait()
	end
end)

