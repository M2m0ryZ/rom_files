FunctionChangeScene = class("FunctionChangeScene")

function FunctionChangeScene.Me()
	if nil == FunctionChangeScene.me then
		FunctionChangeScene.me = FunctionChangeScene.new()
	end
	return FunctionChangeScene.me
end

function FunctionChangeScene:ctor()
end

function FunctionChangeScene:Reset()
end

function FunctionChangeScene:TryPreLoadResources()
	Game.GOLuaPoolManager:ClearAllPools()
	-- 1.??????????????????????????????
	-- FunctionPreload.Me():PreloadJobs()
	-- 2.NPC
	FunctionPreload.Me():SceneNpcs(Game.Myself:GetPosition(),33)
end

function FunctionChangeScene:TryLoadScene(data)
	self.sceneProxy = SceneProxy.Instance
	EventManager.Me():DispatchEvent(ServiceEvent.PlayerMapChange,data.mapID)
	local mapInfo = self:PrepareData(data)
	local sameScene = self.sceneProxy:IsCurrentScene(data)
	local currentSceneLoaded = self.sceneProxy.currentScene ~= nil and self.sceneProxy.currentScene.loaded or false
	if(sameScene) then
		--????????????
		if(currentSceneLoaded) then
			self:LoadSameLoadedScene(data)
		else
			--??????????????????????????????????????????A??????????????????????????????B?????????????????????A?????????????????????B??????????????????
			local lastNeedLoad = SceneProxy.Instance:GetLastNeedLoad()
			if(lastNeedLoad) then
				SceneProxy.Instance:RemoveNeedLoad(2)
			end
			return
		end
	else
		--????????????
		self:WaitForLoad(data)
	end
	self:StartLoadScene()
end

function FunctionChangeScene:PrepareData(data)
	LogUtility.InfoFormat("????????????map: {0} ,raidID: {1}",data.mapID,data.dmapID)
	local mapInfo = SceneProxy.Instance:GetMapInfo(data.mapID)
	if(mapInfo==nil) then
		error("???????????????id:"..data.mapID.."?????????")
	end
	return mapInfo
end

function FunctionChangeScene:SetRaidID(raidID,playSceneAnim,mapInfo,isSameScene)
	-- Player.Me.handleRaid = true
	-- if(isSameScene==false) then
	-- 	Player.Me.playSceneAnimation = (playSceneAnim == 1)
	-- end
	FunctionDungen.Me():Shutdown()
	if(raidID>0) then
	-- 	Player.Me.activeRaidID = raidID
	-- 	Player.Me.playMode = Player.PlayMode.Raid
	-- 	print(string.format("<color=red>call FunctionDungen Launch %s</color>", tostring(raidID) ) )
		FunctionDungen.Me():Launch(raidID)
	else
	-- 	print(string.format("<color=red>call FunctionDungen Shutdown</color>"))
	-- 	Player.Me.activeRaidID = SceneRaid.INVALID_ID
	-- 	if(mapInfo.PVPmap==1) then
	-- 		Player.Me.playMode = Player.PlayMode.PVP
	-- 	else
	-- 		Player.Me.playMode = Player.PlayMode.PVE
	-- 	end
	end
end

function FunctionChangeScene:LoadSameLoadedScene(data)
	LogUtility.InfoFormat("????????????{0}?????????????????????????????????????????????????????????????????????",data.mapID)
	self:ClearScene()
	local sceneInfo = SceneProxy.Instance.currentScene
	if(sceneInfo) then
		sceneInfo.mapNameZH = data.mapName
	end
	Game.MapManager:SetMapName(data)
	ServicePlayerProxy.Instance:CallChangeMap("", 0, 0, 0, data.mapID)
	-- self:ChangeSceneAddMode()
	MyselfProxy.Instance:ResetMyPos(data.pos.x,data.pos.y,data.pos.z)
	--?????????????????????
	Game.AreaTrigger_ExitPoint:Shutdown()
	Game.AreaTrigger_ExitPoint:SetInvisibleEPs(data.invisiblexit)
	Game.AreaTrigger_ExitPoint:Launch()
	GameFacade.Instance:sendNotification(LoadSceneEvent.FinishLoad)
	EventManager.Me():PassEvent(LoadSceneEvent.FinishLoadScene,sceneInfo)
	GameFacade.Instance:sendNotification(MiniMapEvent.ExitPointReInit)
end

function FunctionChangeScene:StartLoadScene()
	if(SceneProxy.Instance:CanLoad()) then
		self:CacheReceiveNet(true)
		--??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
		FunctionBGMCmd.Me():Reset()
		self:ClearScene(true)
		SceneProxy.Instance:StartLoadFirst()
		EventManager.Me():PassEvent(LoadSceneEvent.BeginLoadScene)
		local data = SceneProxy.Instance.currentScene
		Game.MapManager:SetCurrentMap(data.serverData, true)
		local sameScene = self.sceneProxy:IsCurrentScene(data)
		local currentSceneLoaded = self.sceneProxy.currentScene ~= nil and self.sceneProxy.currentScene.loaded or false
		self:SetRaidID(data.dungeonMapId,data.preview,Table_Map[data.mapID],sameScene and currentSceneLoaded)
		return true
	end
	return false
end

function FunctionChangeScene:WaitForLoad(data)
	LogUtility.InfoFormat("??????????????????:{0} {1}",data.mapID,data.mapName)
	FunctionCheck.Me():SetSyncMove(FunctionCheck.CannotSyncMoveReason.LoadingScene,false)
	FunctionMapEnd.Me():Reset()
	SceneProxy.Instance:AddLoadingScene(data)
	MyselfProxy.Instance:ResetMyBornPos(data.pos.x,data.pos.y,data.pos.z)
end

function FunctionChangeScene:LoadedScene(data)
	if(data) then
		LogUtility.InfoFormat("{0} {1} ??????????????????",data.mapID,data.mapName)
		self:TryPreLoadResources()
		local sceneQueue = SceneProxy.Instance:FinishLoadScene(data)
		self:EnterScene()
		if(sceneQueue == nil or #sceneQueue ==0) then
			self:AllFinishLoad(data)
		else
			GameFacade.Instance:sendNotification(LoadingSceneView.ServerReceiveLoaded)
			self:StartLoadScene()
			-- if(not self:LoadNext()) then
			-- 	FunctionCheck.Me():SetSyncMove(FunctionCheck.CannotSyncMoveReason.LoadingScene,true)
			-- 	Player.Me:TryPlaySceneAnimation()
			-- end
		end
	end
end

function FunctionChangeScene:EnterScene()
	SceneProxy.Instance:EnterScene()
	SceneProxy.Instance.sceneLoader:SetAllowSceneActivation()
end

function FunctionChangeScene:AllFinishLoad(sceneInfo)
	LogUtility.Info(string.format("send change map: %d", sceneInfo.mapID))
	LogUtility.Info(string.format("TotalFinishLoad raid: %s", tostring(sceneInfo.dmapID)))
	if nil ~= sceneInfo.dmapID and 0 < sceneInfo.dmapID then
		local rotationOffsetY = Table_MapRaid[sceneInfo.dmapID].CameraAdj
		LogUtility.Info(string.format("TotalFinishLoad rotationOffsetY: %s", tostring(rotationOffsetY)))
		if nil ~= rotationOffsetY and 0 ~= rotationOffsetY then
			local cameraController = CameraController.Instance
			if nil ~= cameraController then
				cameraController.cameraRotationEulerOffset = Vector3(0, rotationOffsetY, 0)
				cameraController:ApplyCurrentInfo()
			end
		end
	end
	FunctionCheck.Me():SetSyncMove(FunctionCheck.CannotSyncMoveReason.LoadingScene,true)
	ServicePlayerProxy.Instance:CallChangeMap("", 0, 0, 0, sceneInfo.mapID)
	GameFacade.Instance:sendNotification(UIEvent.ShowUI,{viewname = "MainView"})
	GameFacade.Instance:sendNotification(LoadSceneEvent.FinishLoad)
	FunctionDungen.Me():HandleSceneLoaded()
	FunctionMapEnd.Me():TempSetDurationToTimeLine()

	-- ????????????????????????
	FunctionActivity.Me():UpdateNowMapTraceInfo()
	-- ?????????????????????????????? begin
	self:CacheReceiveNet(false)
	-- ?????????????????????????????? end
	EventManager.Me():PassEvent(LoadSceneEvent.FinishLoadScene,sceneInfo)
	AssetManager.Me():TryUnLoadAllUnused()
	Game.MapManager:Launch()

	MyLuaSrv.ClearLuaMapAsset();
end

function FunctionChangeScene:CacheReceiveNet(v)
	NetProtocol.CachingSomeReceives = v
	if(not v) then
		NetProtocol.CallCachedReceives()
	end
end

function FunctionChangeScene:GC()
	LuaGC.CallLuaGC()
	ResourceManager.Instance:GC()
	GameObjPool.Instance:ClearAll()
end

function FunctionChangeScene:ClearScene(loadOtherScene)
	-- print("remove me.."..MyselfProxy.Instance.myself.id)
	if(loadOtherScene)then
		GameFacade.Instance:sendNotification(SceneUserEvent.SceneRemoveRoles,{MyselfProxy.Instance.myself})
		
		FunctionCameraEffect.Me():Shutdown()
		FunctionCameraAdditiveEffect.Me():Shutdown()

		FunctionMapEnd.Me():BeginIgnoreAreaTrigger()
	end
	SceneObjectProxy.ClearAll()

	-- ??????Gvg????????????
	GvgProxy.Instance:ClearRuleGuildInfos()
end