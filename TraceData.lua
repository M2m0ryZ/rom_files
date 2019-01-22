TraceData = class("TraceData")

TraceDataType = {
	TraceDataType_ItemTrace = 1,
	TraceDataType_SealTrace = 2,
}

function TraceData:update(type,id,stepType,traceTitle,map,pos,traceInfo,params,process,whetherTrace,thumb,icon,thumbBg,titleBg,foreBg,progressBg)
	-- body
	self.id = id or 0 --??????id ??????????????????????????????id???
	self.orderId = id
	self.map = map
	self.type = type -- ???????????????itemTr sealTr and so on???
	self.pos = pos  -- ??????
	self.traceInfo = traceInfo or ""  --????????????
	self.params = params or {}    -- ????????????
	self.questDataStepType = stepType  -- ???????????????visit kill and so on???
	self.process = process --  ????????????
	self.traceTitle = traceTitle or "default title"  --??????????????????
	self.whetherTrace = whetherTrace--????????????
	self.npc = 0     --??????npc
	self.thumb = thumb 
	self.icon = icon
	self.thumbBg = thumbBg
	self.titleBg = titleBg
	self.foreBg = foreBg
	self.progressBg = progressBg
	-- printGreen(	self.id,	self.orderId,	self.map,	self.type,	self.pos,	self.traceInfo,	self.params,	self.questDataStepType,	self.process,	self.traceTitle,	self.whetherTrace,	self.npc)
end

function TraceData:setIfShowAppearAnm( b )
	-- body
	
end

function TraceData:getProcessInfo( )
	-- body
end

function TraceData:UpdateByTraceData( traceData )
	-- body
	self:update(traceData.type,traceData.id,traceData.questDataStepType,
			traceData.traceTitle,traceData.map,traceData.pos,traceData.traceInfo,traceData.params,
			traceData.process,traceData.whetherTrace,traceData.thumb,traceData.icon,traceData.thumbBg,traceData.titleBg,traceData.foreBg,traceData.progressBg)
end

function TraceData:cloneSelf(  )
	-- body
	local data = TraceData.new()
	data.id = self.id --??????id ??????????????????????????????id???
	data.orderId = self.id
	data.map = self.map  --??????
	data.type = self.type -- ???????????????itemTr sealTr and so on???
	data.pos = self.pos  -- ??????
	data.traceInfo = self.traceInfo  --????????????
	data.params = self.params   -- ????????????
	data.questDataStepType = self.stepType  -- ???????????????visit kill and so on???
	data.process = self.process --  ????????????
	data.traceTitle = self.traceTitle  --??????????????????
	data.whetherTrace = self.whetherTrace   --????????????
	data.npc = 0     --??????npc	
end

function TraceData:parseTranceInfo()
	-- body
	local result = self.traceInfo
	return result
end