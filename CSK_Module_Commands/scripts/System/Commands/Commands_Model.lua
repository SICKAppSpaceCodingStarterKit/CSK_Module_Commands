---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_Commands'

local commands_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
commands_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
commands_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
commands_Model.parametersName = 'CSK_Commands_Parameter' -- name of parameter dataset to be used for this module
commands_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the Commands_Model interface and give access
-- to the Commands_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setCommands_ModelHandle = require('System/Commands/Commands_Controller')
setCommands_ModelHandle(commands_Model)

--Loading helper functions if needed
commands_Model.helperFuncs = require('System/Commands/helper/funcs')

-- Create parameters / instances for this module
commands_Model.log = '' -- Stored log messages
commands_Model.mode = 'Function' -- What mode to use: 'Function' to call or 'Event' to notify

commands_Model.functionName = 'CSK_Commands.print' -- Name of functin to execute like
commands_Model.eventName = 'CSK_Commands.OnNewEvent' -- Name of event to notify

commands_Model.parameterAmount = 0 -- Amount of parameters for event / function call
commands_Model.selectedParameter = '' -- Parameter of command / event to edit

commands_Model.selectedCommand = '' -- Selected command in UI to edit

commands_Model.tempType = 'String' -- Temp setup of parameter type
commands_Model.tempValue = 'ABC' -- Temp setup of parameter value

-- Configuration of parameter
commands_Model.tempParameters = {}
-- Internally will look like this:
--[[
local parameter = {}
parameter.type = 'String'
parameter.value = 'ABC'
table.insert(commands_Model.tempParameters, parameter)
-- commands_Model.tempParameters[1].type
-- commands_Model.tempParameters[1].value
]]

commands_Model.styleForUI = 'None' -- Optional parameter to set UI style
commands_Model.version = Engine.getCurrentAppVersion() -- Version of module

-- Parameters to be saved permanently if wanted
commands_Model.parameters = {}
commands_Model.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations

commands_Model.parameters.commands = {} -- Commands to run
-- Internally will look like this:
--[[
local command = {}
command.type = 'Function' or 'Event'
command.name = 'CSK_Commands.OnNewEvent'

command.parameters = {}
commands_Model.parameters.commands[1].parameters[1].type = 'String'
commands_Model.parameters.commands[1].parameters[1].value = 'ABC'

table.insert(commands_Model.parameters.commands, command)
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  commands_Model.styleForUI = theme
  Script.notifyEvent("Commands_OnNewStatusCSKStyle", commands_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

local function getLog(log)
  commands_Model.log = log
  Script.notifyEvent("Commands_OnNewLog", commands_Model.log)
end
local regSuc = Script.register('CSK_Logger.OnNewCompleteLogfile', getLog)

--- Function to call served function and optionally set function parameters
---@param functionName string Name of function to call
---@param param1 auto? Optional parameter1
---@param param2 auto? Optional parameter1
---@param param3 auto? Optional parameter1
---@param param4 auto? Optional parameter1
local function callFunction(functionName, param1, param2, param3, param4)
  --local suc = Script.isServedAsFunction(functionName)  -- Not sure if needed in future
  local suc
  if param1 ~= nil and param2 ~= nil and param3 ~= nil and param4 ~= nil then
    suc = Script.callFunction(functionName, param1, param2, param3, param4)
  elseif param1 ~= nil and param2 ~= nil and param3 ~= nil then
    suc = Script.callFunction(functionName, param1, param2, param3)
  elseif param1 ~= nil and param2 ~= nil then
    suc = Script.callFunction(functionName, param1, param2)
  elseif param1 ~= nil then
    suc = Script.callFunction(functionName, param1)
  else
    suc = Script.callFunction(functionName)
  end
  if not suc then
    _G.logger:warning(nameOfModule .. ": No success to call '" .. tostring(functionName) .. "'")
  end
end
commands_Model.callFunction = callFunction

--- Function to notify event and optionally set function parameters
---@param eventName string Name of event to notify
---@param param1 auto? Optional parameter1
---@param param2 auto? Optional parameter1
---@param param3 auto? Optional parameter1
---@param param4 auto? Optional parameter1
local function notifyEvent(eventName, param1, param2, param3, param4)
  local suc = Script.isServedAsEvent(eventName)
  if not suc then
    Script.serveEvent(eventName, eventName, 'auto:?, auto:?, auto:?, auto:?')
  end

  if param1 ~= nil and param2 ~= nil and param3 ~= nil and param4 ~= nil then
    Script.notifyEvent(eventName, param1, param2, param3, param4)
  elseif param1 ~= nil and param2 ~= nil and param3 ~= nil then
    Script.notifyEvent(eventName, param1, param2, param3)
  elseif param1 ~= nil and param2 ~= nil then
    Script.notifyEvent(eventName, param1, param2)
  elseif param1 ~= nil then
    Script.notifyEvent(eventName, param1)
  else
    Script.notifyEvent(eventName)
  end
end
commands_Model.notifyEvent = notifyEvent

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return commands_Model
