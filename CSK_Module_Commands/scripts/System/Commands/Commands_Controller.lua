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

-- Script.serveEvent("CSK_Commands.OnNewEvent", "Commands_OnNewEvent")
Script.serveEvent("CSK_Commands.OnNewStatusLoadParameterOnReboot", "Commands_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_Commands.OnPersistentDataModuleAvailable", "Commands_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_Commands.OnNewParameterName", "Commands_OnNewParameterName")
Script.serveEvent("CSK_Commands.OnDataLoadedOnReboot", "Commands_OnDataLoadedOnReboot")

Script.serveEvent('CSK_Commands.OnUserLevelOperatorActive', 'Commands_OnUserLevelOperatorActive')
Script.serveEvent('CSK_Commands.OnUserLevelMaintenanceActive', 'Commands_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_Commands.OnUserLevelServiceActive', 'Commands_OnUserLevelServiceActive')
Script.serveEvent('CSK_Commands.OnUserLevelAdminActive', 'Commands_OnUserLevelAdminActive')

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

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

  -- Script.notifyEvent("Commands_OnNewEvent", false)

  Script.notifyEvent("Commands_OnNewStatusLoadParameterOnReboot", commands_Model.parameterLoadOnReboot)
  Script.notifyEvent("Commands_OnPersistentDataModuleAvailable", commands_Model.persistentModuleAvailable)
  Script.notifyEvent("Commands_OnNewParameterName", commands_Model.parametersName)
  -- ...
end
Timer.register(tmrCommands, "OnExpired", handleOnExpiredTmrCommands)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrCommands:start()
  return ''
end
Script.serveFunction("CSK_Commands.pageCalled", pageCalled)

--[[
local function setSomething(value)
  _G.logger:info(nameOfModule .. ": Set new value = " .. value)
  commands_Model.varA = value
end
Script.serveFunction("CSK_Commands.setSomething", setSomething)
]]

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  commands_Model.parametersName = name
end
Script.serveFunction("CSK_Commands.setParameterName", setParameterName)

local function sendParameters()
  if commands_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(commands_Model.helperFuncs.convertTable2Container(commands_Model.parameters), commands_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, commands_Model.parametersName, commands_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send Commands parameters with name '" .. commands_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
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
      -- ...
      -- ...

      CSK_Commands.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_Commands.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  commands_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_Commands.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

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
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setCommands_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

