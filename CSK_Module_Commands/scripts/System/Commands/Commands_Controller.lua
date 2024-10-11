---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the Commands_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_Commands'

-- Timer to update UI via events after page was loaded
local tmrCommands = Timer.create()
tmrCommands:setExpirationTime(300)
tmrCommands:setPeriodic(false)

-- Reference to global handle
local commands_Model

-- ************************ UI Events Start ********************************

Script.serveEvent('CSK_Commands.OnNewStatusModuleVersion', 'Commands_OnNewStatusModuleVersion')
Script.serveEvent('CSK_Commands.OnNewStatusCSKStyle', 'Commands_OnNewStatusCSKStyle')
Script.serveEvent('CSK_Commands.OnNewStatusModuleIsActive', 'Commands_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_Commands.OnNewStatusMode', 'Commands_OnNewStatusMode')
Script.serveEvent('CSK_Commands.OnNewStatusEventName', 'Commands_OnNewStatusEventName')

Script.serveEvent('CSK_Commands.OnNewFunctionName', 'Commands_OnNewFunctionName')
Script.serveEvent('CSK_Commands.OnNewStatusParameterAmount', 'Commands_OnNewStatusParameterAmount')
Script.serveEvent('CSK_Commands.OnNewStatusSelectedParameter', 'Commands_OnNewStatusSelectedParameter')

Script.serveEvent('CSK_Commands.OnNewStatusParameterList', 'Commands_OnNewStatusParameterList')

Script.serveEvent('CSK_Commands.OnNewStatusParameterType', 'Commands_OnNewStatusParameterType')

Script.serveEvent('CSK_Commands.OnNewStatusBoolParameterValue', 'Commands_OnNewStatusBoolParameterValue')
Script.serveEvent('CSK_Commands.OnNewStatusStringParameterValue', 'Commands_OnNewStatusStringParameterValue')
Script.serveEvent('CSK_Commands.OnNewStatusNumberParameterValue', 'Commands_OnNewStatusNumberParameterValue')

Script.serveEvent('CSK_Commands.OnNewStatusCommandList', 'Commands_OnNewStatusCommandList')

Script.serveEvent('CSK_Commands.OnNewLog', 'Commands_OnNewLog')

Script.serveEvent('CSK_Commands.OnNewStatusFlowConfigPriority', 'Commands_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_Commands.OnNewStatusLoadParameterOnReboot", "Commands_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_Commands.OnPersistentDataModuleAvailable", "Commands_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_Commands.OnNewParameterName", "Commands_OnNewParameterName")
Script.serveEvent("CSK_Commands.OnDataLoadedOnReboot", "Commands_OnDataLoadedOnReboot")

Script.serveEvent('CSK_Commands.OnUserLevelOperatorActive', 'Commands_OnUserLevelOperatorActive')
Script.serveEvent('CSK_Commands.OnUserLevelMaintenanceActive', 'Commands_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_Commands.OnUserLevelServiceActive', 'Commands_OnUserLevelServiceActive')
Script.serveEvent('CSK_Commands.OnUserLevelAdminActive', 'Commands_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("Commands_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("Commands_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("Commands_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("Commands_OnUserLevelAdminActive", status)
end

--- Function to get access to the commands_Model object
---@param handle handle Handle of commands_Model object
local function setCommands_Model_Handle(handle)
  commands_Model = handle
  if commands_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if commands_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("Commands_OnUserLevelAdminActive", true)
    Script.notifyEvent("Commands_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("Commands_OnUserLevelServiceActive", true)
    Script.notifyEvent("Commands_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrCommands()

  updateUserLevel()

  Script.notifyEvent("Commands_OnNewStatusModuleVersion", 'v' .. commands_Model.version)
  Script.notifyEvent("Commands_OnNewStatusCSKStyle", commands_Model.styleForUI)
  Script.notifyEvent("Commands_OnNewStatusModuleIsActive", _G.availableAPIs.specific)

  Script.notifyEvent("Commands_OnNewStatusMode", commands_Model.mode)
  Script.notifyEvent("Commands_OnNewStatusEventName", commands_Model.eventName)
  Script.notifyEvent("Commands_OnNewFunctionName", commands_Model.functionName)
  Script.notifyEvent("Commands_OnNewStatusParameterAmount", commands_Model.parameterAmount)
  Script.notifyEvent("Commands_OnNewStatusParameterList", commands_Model.helperFuncs.createStringListBySize(commands_Model.parameterAmount))
  Script.notifyEvent("Commands_OnNewStatusSelectedParameter", tostring(commands_Model.selectedParameter))

  Script.notifyEvent("Commands_OnNewStatusParameterType", commands_Model.tempType)

  if commands_Model.tempType == 'String' then
    Script.notifyEvent("Commands_OnNewStatusStringParameterValue", commands_Model.tempValue)
  elseif commands_Model.tempType == 'Number' then
    Script.notifyEvent("Commands_OnNewStatusNumberParameterValue", commands_Model.tempValue)
  elseif commands_Model.tempType == 'Bool' then
    Script.notifyEvent("Commands_OnNewStatusBoolParameterValue", commands_Model.tempValue)
  end

  Script.notifyEvent("Commands_OnNewStatusCommandList", commands_Model.helperFuncs.createJsonListCommands(commands_Model.parameters.commands, commands_Model.selectedCommand)) -- commands_Model.commandList

  Script.notifyEvent("Commands_OnNewLog", commands_Model.log)

  --Script.notifyEvent("Commands_OnNewStatusFlowConfigPriority", commands_Model.parameters.flowConfigPriority)
  Script.notifyEvent("Commands_OnNewStatusLoadParameterOnReboot", commands_Model.parameterLoadOnReboot)
  Script.notifyEvent("Commands_OnPersistentDataModuleAvailable", commands_Model.persistentModuleAvailable)
  Script.notifyEvent("Commands_OnNewParameterName", commands_Model.parametersName)
end
Timer.register(tmrCommands, "OnExpired", handleOnExpiredTmrCommands)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrCommands:start()
  return ''
end
Script.serveFunction("CSK_Commands.pageCalled", pageCalled)

local function setMode(mode)
  _G.logger:fine(nameOfModule .. ": Set mode: " .. tostring(mode))
  commands_Model.mode = mode
  Script.notifyEvent("Commands_OnNewStatusMode", commands_Model.mode)
end
Script.serveFunction('CSK_Commands.setMode', setMode)

local function setFunctionName(functionName)
  _G.logger:fine(nameOfModule .. ": Set function name: " .. tostring(functionName))
  commands_Model.functionName = functionName
end
Script.serveFunction('CSK_Commands.setFunctionName', setFunctionName)

local function setEventName(name)
  _G.logger:fine(nameOfModule .. ": Set event name: " .. tostring(name))
  commands_Model.eventName = name
end
Script.serveFunction('CSK_Commands.setEventName', setEventName)

local function setSelectedParameter(selection)
  _G.logger:fine(nameOfModule .. ": Select parameter: " .. tostring(selection))
  commands_Model.selectedParameter = selection
  if selection ~= 0 then
    commands_Model.tempType = commands_Model.tempParameters[commands_Model.selectedParameter].type
    commands_Model.tempValue = commands_Model.tempParameters[commands_Model.selectedParameter].value
  end

  handleOnExpiredTmrCommands()
end
Script.serveFunction('CSK_Commands.setSelectedParameter', setSelectedParameter)

local function setParameterAmount(amount)
  _G.logger:fine(nameOfModule .. ": Set parameter amount: " .. tostring(amount))
  commands_Model.parameterAmount = amount
  Script.notifyEvent("Commands_OnNewStatusParameterList", commands_Model.helperFuncs.createStringListBySize(commands_Model.parameterAmount))

  if commands_Model.parameterAmount > #commands_Model.tempParameters then
    while commands_Model.parameterAmount > #commands_Model.tempParameters do
      local tempParam = {}
      tempParam.type = 'String'
      tempParam.value = 'ABC'
      table.insert(commands_Model.tempParameters, tempParam)
    end
  else
    while #commands_Model.tempParameters > commands_Model.parameterAmount  do
      local tempParam = {}
      tempParam.type = 'String'
      tempParam.value = 'ABC'
      table.remove(commands_Model.tempParameters, #commands_Model.tempParameters)
    end
  end
  setSelectedParameter(amount)
end
Script.serveFunction('CSK_Commands.setParameterAmount', setParameterAmount)

local function callFunctionViaUI()
  if commands_Model.parameterAmount == 0 then
    commands_Model.callFunction(commands_Model.functionName)
  elseif commands_Model.parameterAmount == 1 then
    commands_Model.callFunction(commands_Model.functionName, commands_Model.tempParameters[1].value)
  elseif commands_Model.parameterAmount == 2 then
    commands_Model.callFunction(commands_Model.functionName, commands_Model.tempParameters[1].value, commands_Model.tempParameters[2].value)
  elseif commands_Model.parameterAmount == 3 then
    commands_Model.callFunction(commands_Model.functionName, commands_Model.tempParameters[1].value, commands_Model.tempParameters[2].value, commands_Model.tempParameters[3].value)
  elseif commands_Model.parameterAmount == 4 then
    commands_Model.callFunction(commands_Model.functionName, commands_Model.tempParameters[1].value, commands_Model.tempParameters[2].value, commands_Model.tempParameters[3].value, commands_Model.tempParameters[4].value)
  end
end
Script.serveFunction('CSK_Commands.callFunctionViaUI', callFunctionViaUI)

local function notifyEventViaUI()
  if commands_Model.parameterAmount == 0 then
    commands_Model.notifyEvent(commands_Model.eventName)
  elseif commands_Model.parameterAmount == 1 then
    commands_Model.notifyEvent(commands_Model.eventName, commands_Model.tempParameters[1].value)
  elseif commands_Model.parameterAmount == 2 then
    commands_Model.notifyEvent(commands_Model.eventName, commands_Model.tempParameters[1].value, commands_Model.tempParameters[2].value)
  elseif commands_Model.parameterAmount == 3 then
    commands_Model.notifyEvent(commands_Model.eventName, commands_Model.tempParameters[1].value, commands_Model.tempParameters[2].value, commands_Model.tempParameters[3].value)
  elseif commands_Model.parameterAmount == 4 then
    commands_Model.notifyEvent(commands_Model.eventName, commands_Model.tempParameters[1].value, commands_Model.tempParameters[2].value, commands_Model.tempParameters[3].value, commands_Model.tempParameters[4].value)
  end
end
Script.serveFunction('CSK_Commands.notifyEventViaUI', notifyEventViaUI)

local function commandPrint(content)
  if not content then
    print('')
  else
    print(content)
  end
end
Script.serveFunction('CSK_Commands.print', commandPrint)

local function commandSleep(time)
  Script.sleep(time)
end
Script.serveFunction('CSK_Commands.sleep', commandSleep)

local function setParameterType(paramType)
  _G.logger:fine(nameOfModule .. ": Set parameter type: " .. tostring(paramType))
  commands_Model.tempType = paramType
  if commands_Model.tempParameters[commands_Model.selectedParameter] then
    commands_Model.tempParameters[commands_Model.selectedParameter].type = paramType

    if paramType == 'String' then
      commands_Model.tempParameters[commands_Model.selectedParameter].value = 'ABC'
    elseif paramType == 'Number' then
      commands_Model.tempParameters[commands_Model.selectedParameter].value = 123
    elseif paramType == 'Bool' then
      commands_Model.tempParameters[commands_Model.selectedParameter].value = false
    end
    commands_Model.tempValue = commands_Model.tempParameters[commands_Model.selectedParameter].value
  else
    if paramType == 'String' then
      commands_Model.tempValue = 'ABC'
    elseif paramType == 'Number' then
      commands_Model.tempValue = 123
    elseif paramType == 'Bool' then
      commands_Model.tempValue = false
    end

  end
  handleOnExpiredTmrCommands()
end
Script.serveFunction('CSK_Commands.setParameterType', setParameterType)

local function setParameterValue(paramValue)
  _G.logger:fine(nameOfModule .. ": Set parameter value: " .. tostring(paramValue))
  commands_Model.tempValue = paramValue
  if commands_Model.tempParameters[commands_Model.selectedParameter] then
    commands_Model.tempParameters[commands_Model.selectedParameter].value = paramValue
  end
  handleOnExpiredTmrCommands()
end
Script.serveFunction('CSK_Commands.setParameterValue', setParameterValue)

--- Function to check if selection in UIs DynamicTable can find related pattern
---@param selection string Full text of selection
---@param pattern string Pattern to search for
---@param findEnd bool Find end after pattern
---@return string? Success if pattern was found or even postfix after pattern till next quotation marks if findEnd was set to TRUE
local function checkSelection(selection, pattern, findEnd)
  if selection ~= "" then
    local _, pos = string.find(selection, pattern)
    if pos == nil then
      return nil
    else
      if findEnd then
        pos = tonumber(pos)
        local endPos = string.find(selection, '"', pos+1)
        if endPos then
          local tempSelection = string.sub(selection, pos+1, endPos-1)
          if tempSelection ~= nil and tempSelection ~= '-' then
            return tempSelection
          end
        else
          return nil
        end
      else
        return 'true'
      end
    end
  end
  return nil
end

local function selectCommandViaUI(selection)
  local tempSelection = checkSelection(selection, '"DTC_ID":"', true)

  if tempSelection then
    local isSelected = checkSelection(selection, '"selected":true', false)
    if isSelected then
      _G.logger:fine(nameOfModule .. ": Selected ID " .. tostring(tempSelection))
      commands_Model.selectedCommand = tonumber(tempSelection)

      commands_Model.mode = commands_Model.parameters.commands[commands_Model.selectedCommand]['type']
      if commands_Model.mode == 'Function' then
        commands_Model.functionName = commands_Model.parameters.commands[commands_Model.selectedCommand]['name']
      else
        commands_Model.eventName = commands_Model.parameters.commands[commands_Model.selectedCommand]['name']
      end

      if #commands_Model.parameters.commands[commands_Model.selectedCommand]['parameters'] ~= 0 then
        commands_Model.parameterAmount = #commands_Model.parameters.commands[commands_Model.selectedCommand]['parameters']
        commands_Model.selectedParameter = 1
        commands_Model.tempParameters = commands_Model.helperFuncs.copyParameterContent(commands_Model.parameters.commands[commands_Model.selectedCommand]['parameters'])

        commands_Model.tempType = commands_Model.tempParameters[commands_Model.selectedParameter].type
        commands_Model.tempValue = commands_Model.tempParameters[commands_Model.selectedParameter].value
      else
        commands_Model.parameterAmount = 0
        commands_Model.selectedParameter = ''
        commands_Model.tempParameters = {}
      end
    else
      commands_Model.selectedCommand = ''
    end
    handleOnExpiredTmrCommands()
  end
end
Script.serveFunction('CSK_Commands.selectCommandViaUI', selectCommandViaUI)

local function addCommandViaUI()
  local command = {}
  command.type = commands_Model.mode
  if command.type == 'Function' then
    _G.logger:fine(nameOfModule .. ": Add function command: " .. tostring(commands_Model.functionName))
    command.name = commands_Model.functionName
  else
    _G.logger:fine(nameOfModule .. ": Add event command: " .. tostring(commands_Model.eventName))
    command.name = commands_Model.eventName
  end
  command.parameters = commands_Model.helperFuncs.copyParameterContent(commands_Model.tempParameters)

  table.insert(commands_Model.parameters.commands, command)
  handleOnExpiredTmrCommands()
end
Script.serveFunction('CSK_Commands.addCommandViaUI', addCommandViaUI)

local function removeCommandViaUI()
  if commands_Model.selectedCommand ~= '' then
    if commands_Model.parameters.commands[commands_Model.selectedCommand] then
      _G.logger:fine(nameOfModule .. ": Remove command: " .. tostring(commands_Model.selectedCommand))
      table.remove(commands_Model.parameters.commands, commands_Model.selectedCommand)
    end
  end
  handleOnExpiredTmrCommands()
end
Script.serveFunction('CSK_Commands.removeCommandViaUI', removeCommandViaUI)

local function runCommands()
  for key, value in pairs(commands_Model.parameters.commands) do
    local paramAmount = #commands_Model.parameters.commands[key]['parameters']

    if commands_Model.parameters.commands[key]['type'] == 'Function' then
      if paramAmount == 0 then
        commands_Model.callFunction(commands_Model.parameters.commands[key]['name'])
      elseif paramAmount == 1 then
        commands_Model.callFunction(commands_Model.parameters.commands[key]['name'], commands_Model.parameters.commands[key]['parameters'][1]['value'])
      elseif paramAmount == 2 then
        commands_Model.callFunction(commands_Model.parameters.commands[key]['name'], commands_Model.parameters.commands[key]['parameters'][1]['value'], commands_Model.parameters.commands[key]['parameters'][2]['value'])
      elseif paramAmount == 3 then
        commands_Model.callFunction(commands_Model.parameters.commands[key]['name'], commands_Model.parameters.commands[key]['parameters'][1]['value'], commands_Model.parameters.commands[key]['parameters'][2]['value'], commands_Model.parameters.commands[key]['parameters'][3]['value'])
      elseif paramAmount == 4 then
        commands_Model.callFunction(commands_Model.parameters.commands[key]['name'], commands_Model.parameters.commands[key]['parameters'][1]['value'], commands_Model.parameters.commands[key]['parameters'][2]['value'], commands_Model.parameters.commands[key]['parameters'][3]['value'], commands_Model.parameters.commands[key]['parameters'][4]['value'])
      end
    elseif commands_Model.parameters.commands[key]['type'] == 'Event' then
      if paramAmount == 0 then
         commands_Model.notifyEvent(commands_Model.eventName)
       elseif paramAmount == 1 then
         commands_Model.notifyEvent(commands_Model.eventName, commands_Model.parameters.commands[key]['parameters'][1]['value'])
       elseif paramAmount == 2 then
         commands_Model.notifyEvent(commands_Model.eventName, commands_Model.parameters.commands[key]['parameters'][1]['value'], commands_Model.parameters.commands[key]['parameters'][2]['value'])
       elseif paramAmount == 3 then
         commands_Model.notifyEvent(commands_Model.eventName, commands_Model.parameters.commands[key]['parameters'][1]['value'], commands_Model.parameters.commands[key]['parameters'][2]['value'], commands_Model.parameters.commands[key]['parameters'][3]['value'])
       elseif paramAmount == 4 then
         commands_Model.notifyEvent(commands_Model.eventName, commands_Model.parameters.commands[key]['parameters'][1]['value'], commands_Model.parameters.commands[key]['parameters'][2]['value'], commands_Model.parameters.commands[key]['parameters'][3]['value'], commands_Model.parameters.commands[key]['parameters'][4]['value'])
       end
    end
  end
end
Script.serveFunction('CSK_Commands.runCommands', runCommands)

local function getStatusModuleActive()
  return _G.availableAPIs.specific
end
Script.serveFunction('CSK_Commands.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  -- Not needed so far
  --for key, value in pairs(commands_Model.parameters.registeredEvents) do
  --  deleteRegistration(key)
  --end
end
Script.serveFunction('CSK_Commands.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  commands_Model.parametersName = name
end
Script.serveFunction("CSK_Commands.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if commands_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(commands_Model.helperFuncs.convertTable2Container(commands_Model.parameters), commands_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, commands_Model.parametersName, commands_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send Commands parameters with name '" .. commands_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_Commands.sendParameters", sendParameters)

local function loadParameters()
  if commands_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(commands_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      commands_Model.parameters = commands_Model.helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data, place this here:
      runCommands()

      CSK_Commands.pageCalled()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_Commands.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  commands_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("Commands_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_Commands.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  commands_Model.parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("Commands_OnNewStatusFlowConfigPriority", commands_Model.parameters.flowConfigPriority)
end
Script.serveFunction('CSK_Commands.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.specific then
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      commands_Model.persistentModuleAvailable = false
    else

      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

      if parameterName then
        commands_Model.parametersName = parameterName
        commands_Model.parameterLoadOnReboot = loadOnReboot
      end

      if commands_Model.parameterLoadOnReboot then
        loadParameters()
      end
      Script.notifyEvent('Commands_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  -- Nothing to do so far
  --if _G.availableAPIs.default and _G.availableAPIs.specific then
  --  pageCalled()
  --end
end
Script.serveFunction('CSK_Commands.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setCommands_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

