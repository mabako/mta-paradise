--[[
runcode by Javier "jbeta" Beta
  obtained from http://code.google.com/p/mtasa-resources/

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local rootElement = getRootElement()

function outputConsoleR(message, toElement)
	if toElement == false or getElementType(toElement) == "console" then
		outputServerLog(message)
	else
		toElement = toElement or rootElement
		outputConsole(message, toElement)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end

function outputChatBoxR(message, toElement)
	if toElement == false or getElementType(toElement) == "console" then
		outputServerLog(message)
	else
		toElement = toElement or rootElement
		outputChatBox(message, toElement, 250, 200, 200)
		if toElement == rootElement then
			outputServerLog(message)
		end
	end
end

-- dump the element tree
function map(element, outputTo, level)
	level = level or 0
	element = element or getRootElement()
	local indent = string.rep('  ', level)
	local eType = getElementType(element)
	local eID = getElementID(element)
	local eChildren = getElementChildren(element)
	
	local tagStart = '<'..eType
	if eID then
		tagStart = tagStart..' id="'..eID..'"'
	end
	for dataField, dataValue in pairs(getAllElementData(element)) do
		tagStart = tagStart..' '..dataField..'="'..tostring(dataValue)..'"'
	end
	
	if #eChildren < 1 then
		outputConsoleR(indent..tagStart..'"/>', outputTo)
	else
		outputConsoleR(indent..tagStart..'">', outputTo)
		for k, child in ipairs(eChildren) do
			map(child, outputTo, level+1)
		end
		outputConsoleR(indent..'</'..eType..'>', outputTo)
	end
end
