local rootElement = getRootElement()
local _set, _get = set, get
function runString (commandstring, outputTo, source)
	local sourceName
	if source then
		sourceName = getPlayerName(source)
	else
		sourceName = "Console"
	end
	outputChatBoxR(sourceName.." executed command: "..commandstring, outputTo)
	
	-- wrap a few custom variables
	source = source
	p = getPlayerFromName
	c = function(p) return getPedOccupiedVehicle(p) or getPedContactElement(p) end
	vehicle = c(source)
	car = c(source)
	res = getResourceFromName
	rr = getResourceRootElement
	settingsSet = _set
	settingsGet = _get
	set = setElementData
	get = getElementData
	
	local notReturned
	--First we test with return
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		notReturned = true
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		outputChatBoxR("Error: "..errorMsg, outputTo)
		return
	end
	--Finally, lets execute our function
	results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		outputChatBoxR("Error: "..results[2], outputTo)
		return
	end
	if not notReturned then
		local resultsString = ""
		local first = true
		for i = 2, #results do
			if first then
				first = false
			else
				resultsString = resultsString..", "
			end
			local resultType = type(results[i])
			if isElement(results[i]) then
				resultType = "element:"..getElementType(results[i])
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		outputChatBoxR("Command results: "..resultsString, outputTo)
	elseif not errorMsg then
		outputChatBoxR("Command executed!", outputTo)
	end
end

-- silent run command
addCommandHandler("srun",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		return runString(commandstring, player, player)
	end
)

-- clientside run command
addCommandHandler("crun",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		if player then
			return triggerClientEvent(player, "doCrun", rootElement, commandstring)
		else
			return runString(commandstring, false, false)
		end
	end
)
