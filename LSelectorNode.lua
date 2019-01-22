--????????????,?????????.????????????????????????failure???
autoImport("LParentNode")
LSelectorNode = class('LSelectorNode',LParentNode)

function LSelectorNode:Update()
	local node
	local state
	for i=1,#self.childrenNodes do
		node = self.childrenNodes [i];
		state = node:Update()
		-- if (state == TaskState.Inactive) then
		-- 	continue;
		-- print("selector",state)
		if (state ~= TaskState.Failure) then
			return state
		end
	end
	return TaskState.Failure;
end