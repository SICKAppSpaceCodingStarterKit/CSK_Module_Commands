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
commands_Model.functionName = 'CSK_Commands.commandPrint' -- Name of functin to execute like 'CSK_ModuleName.FunctionName'
commands_Model.parameterConfig = {}
commands_Model.parameterConfig.type = {}
commands_Model.parameterConfig.boolValues = {}
commands_Model.parameterConfig.numberValues = {}
commands_Model.parameterConfig.stringValues = {}

for i = 1, 4 do
  table.insert(commands_Model.parameterConfig.type, 'String')
  table.insert(commands_Model.parameterConfig.boolValues, false)
  table.insert(commands_Model.parameterConfig.numberValues, 1)
  table.insert(commands_Model.parameterConfig.stringValues, 'Value')
end
commands_Model.parameterAmount = 0

-- Parameters to be saved permanently if wanted
commands_Model.parameters = {}
--commands_Model.parameters.paramA = 'paramA' -- Short docu of variable
--commands_Model.parameters.paramB = 123 -- Short docu of variable

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************


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
  local suc = Script.isServedAsFunction(functionName)
  if suc then
    if param1 ~= nil and param2 ~= nil and param3 ~= nil and param4 ~= nil then
      Script.callFunction(functionName, param1, param2, param3, param4)
    elseif param1 ~= nil and param2 ~= nil and param3 ~= nil then
      Script.callFunction(functionName, param1, param2, param3)
    elseif param1 ~= nil and param2 ~= nil then
      Script.callFunction(functionName, param1, param2)
    elseif param1 ~= nil then
      Script.callFunction(functionName, param1)
    else
      Script.callFunction(functionName)
    end
  else
    _G.logger:info(nameOfModule .. ": Not able to call function '" .. tostring(functionName) .. "'")
  end
end
commands_Model.callFunction = callFunction

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return commands_Model
