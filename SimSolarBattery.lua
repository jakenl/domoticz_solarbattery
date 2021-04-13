--version 0.1 02-04-2021: dzVents version of solar battery script
--version 0.1.1	03-04-2021: fix left behind variable and avoidance of power level > max inverter power level, due to rounding of calculation
--version 0.1.2 05-04-2021: changed a check for latest data storage from seconds to milliseconds to accommodate meters that update every second
--version 0.1.3 05-04-2021: Added a check to avoid big deviations in calculation when inverter power level is small while having
--	also a small script interval. Added more debug logging
--version 0.1.4b 10-04-2021: Description text fix + little preparation for future release
--version 0.1.5 11-04-2021: Lost energy due to battery and due to inverter size are now split and only combined during device update

--version 0.2	13-04-2021: BREAKING CHANGE: 	-- 'Lost Energy' 'Electric + Instant + Counter' device need to be replaced by a 'P1-meter' device
												-- New 'P1-meter' device needs to be added to trace losses in limited battery inverter

--To be created virtual devices in the hardware section of Domoticz:
	local solarBattery_name = 'Virtual Solar Battery'				-- (1) Virtual 'Custom Sensor' device name for the 'Virtual Solar Battery'. Change axis label to kWh
	local batteryUsage_name = 'Virtual Solar Battery Usage'			-- (2) Virtual 'P1-meter' device name for monitoring storage in and consumption from the solar battery
	local lostEnergy_name	 = 'Lost Solar Energy'					-- (3) Virtual 'Electric Instant + Counter' device name for the 'Lost Solar Energy'
	local lostBattery_name = 'Lost Solar Battery Energy'			-- (3) Virtual 'P1-meter' device name for the 'Lost Solar Battery Energy'
	local lostInverter_name = 'Lost Solar Battery Inverter Energy'	-- (3) Virtual 'P1-meter' device name for the 'Lost Solar Battery Inverter Energy'
	
--To be created User Variable in the Setup - More Options - User Variable section:
	local battery_capacity_name = 'SolarBatteryCapacity'			-- (4) User Variable name for the 'Solar Battery Capacity'. Type 'Integer'. Value in Wh (4kWh battery = '4000')
	local battery_inverter_power_name = 'SolarBatteryInverterCap'	-- (5) User variable name for the 'Solar Battery Inverter Power'. Type 'Integer'. Value in W

--Energy meter(s) management
	--name the device(s) used for counting energy from/to the grid
	--when a P1 meter is used for both 'from' and 'to' the grid, fill in this name for both lines! Else, fill in the name for both requested devices
	--Device name for consumed energy FROM the grid:
	local consumedEnergyMeter_name = 'Electricity'
	--Device name for delivered energy TO the grid:
	local returnedEnergyMeter_name = 'Electricity'
	--decide if energy consumption with an empty battery counts as 'lost energy'
	local emptyBatteryIsLostEnergy = 1 --(1 =  yes, 0 = no)
	--decide if energy losses due to limited inverter power count with a full/empty battery
	local emptyFullBatteryCountLostInverterEnergy = 1 --(1 = yes, 0 = no)
	--Interval of running the Script
	local scriptInterval = 60 --(seconds. Minimum interval depends on update frequency of P1-meter. 0 = P1-meter update frequency)


-- 1 trigger for P1 meter with both consumption and production meter integrated. Otherwise 2 meters
	if (consumedEnergyMeter_name == returnedEnergyMeter_name) then
	 	meterName = consumedEnergyMeter_name
	else
		meterName = consumedEnergyMeter_name ..', '.. returnedEnergyMeter_name
	end


return {
	active = true,
	on = {
		devices = {
	--timer based devices
	--sensor based devices
		meterName,
	--setting devices
	--actuator devices
		}
--	timer = {'every minute'}},
	},
	data = {
		returnedEnergy = {initial=nil, history = true, maxItems = 1},
		consumedEnergy = {initial= nil, history = true, maxItems = 1}
	},
	logging = {
	level = domoticz.LOG_DEBUG, --domoticz.LOG_INFO, domoticz.LOG_MODULE_EXEC_INFO, domoticz.LOG_DEBUG or domoticz.LOG_ERROR
	marker = "Hey solar battery"
	},

	execute = function(domoticz, device)

---error checking functions ---

--check whether devices exist by veryfing their name
	if domoticz.utils.deviceExists(solarBattery_name) == false then
		domoticz.log('necessary device '.. solarBattery_name ..'	doesnt exist. Script will end. Please add the device to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif domoticz.utils.deviceExists(batteryUsage_name) == false then
		domoticz.log('necessary device '.. batteryUsage_name ..'	doesnt exist. Script will end. Please add the device to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif domoticz.utils.deviceExists(lostEnergy_name) == false then
		domoticz.log('necessary device '.. lostEnergy_name ..'	doesnt exist. Script will end. Please add the device to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif domoticz.utils.deviceExists(lostBattery_name) == false then
		domoticz.log('necessary device '.. lostBattery_name ..'	doesnt exist. Script will end. Please add the device to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif domoticz.utils.deviceExists(lostInverter_name) == false then
		domoticz.log('necessary device '.. lostInverter_name ..'	doesnt exist. Script will end. Please add the device to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif domoticz.utils.variableExists(battery_capacity_name) == false then
		domoticz.log('User variable '.. battery_capacity_name ..' doesnt exist. Script will end. Please add the user variable to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif domoticz.utils.variableExists(battery_inverter_power_name) == false then
		domoticz.log('User variable '.. battery_inverter_power_name ..' doesnt exist. Script will end. Please add the user variable to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	end

--Devices exists, now define devices/variable within Domoticz:
	local solarBattery = domoticz.devices(solarBattery_name)
	local batteryUsage = domoticz.devices(batteryUsage_name)
	local lostEnergy = domoticz.devices(lostEnergy_name)
	local lostBattery = domoticz.devices(lostBattery_name)
	local lostInverter = domoticz.devices(lostInverter_name)
	local consumedEnergyMeter = domoticz.devices(consumedEnergyMeter_name)
	local returnedEnergyMeter = domoticz.devices(returnedEnergyMeter_name)
	local battery_capacity = domoticz.variables(battery_capacity_name)
	local battery_inverter_power = domoticz.variables(battery_inverter_power_name)

--Define script variables
	local oldConsumedEnergyMeter
	local oldReturnedEnergyMeter
	local newConsumedEnergyMeter
	local newReturnedEnergyMeter
	local energyBalance
	local solarBatteryValue
	local newSolarBatteryValue
	--local newLostEnergy
	local newLostEnergyFull
	local newLostEnergyEmpty
	local batteryUsedEnergy
	local batteryProdEnergy
	local batteryUsedWatt
	local batteryProdWatt
	local batter
	local deltaTime
	local maxBbatteryInverterEnergy -- battery inverter power x (time since last time the script was ran / 3600) in Wh
	local inverterLostEnergy -- lost energy to or from the grid due to limitation in battery capacity and/or battery inverter power
	local inverterLostEnergyProd
	local inverterLostEnergyUsed
	local inverterLostEnergyProdFull
	local inverterLostEnergyUsedEmpty
	local inverterLostProdWatt
	local inverterLostUsedWatt
	local _ = domoticz.utils._

--check if new created virtual devices are the right type
	if (solarBattery.deviceType ~= 'General' and solarBattery.deviceSubType ~= "Custom Sensor") then
		domoticz.log('created device '.. solarBattery_name ..'	is not of the type Custom Sensor. Script will end. Please add the correct device(type) to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif (batteryUsage.deviceType ~= 'P1 Smart Meter' and batteryUsage.deviceSubType ~= "Energy") then
		domoticz.log('created device '.. batteryUsage_name ..'	is not of the type P1-meter. Script will end. Please add the correct device(type) to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif (lostEnergy.deviceType ~= 'General' and lostEnergy.deviceSubType ~= "kWh") then
		domoticz.log('created device '.. lostEnergy_name ..'	is not of the type RFXMeter. Script will end. Please add the correct device(type) to Domoticz', domoticz.LOG_ERROR)
		goto endScript
	elseif (lostBattery_name.deviceType ~= 'P1 Smart Meter' and lostBattery.deviceSubType ~= "Energy") then
		domoticz.log('created device '.. lostBattery_name ..'	is not of the type P1-meter. Script will end. Please add the correct device(type) to Domoticz', domoticz.LOG_ERROR)
	elseif (lostInverter.deviceType ~= 'P1 Smart Meter' and lostInverter.deviceSubType ~= "Energy") then
		domoticz.log('created device '.. lostEnergy_name ..'	is not of the type P1-meter. Script will end. Please add the correct device(type) to Domoticz', domoticz.LOG_ERROR)
	end

--check if variables are the right type and contain a good value
	if battery_capacity.type ~= domoticz.INTEGER then
		domoticz.log('User variable '.. battery_capacity_name ..' is not of the type INTEGER. Script will end. Please change the user variable to the type INTEGER and put a positive number in there', domoticz.LOG_ERROR)
	goto endScript
	elseif (battery_capacity.value == nil or battery_capacity.value < 0) then
		domoticz.log('Solar battery capacity wrong or <0. Now set at 2000(Wh)', domoticz.LOG_ERROR)
		battery_capacity.set(2000)
	end

	if battery_inverter_power.type ~= domoticz.INTEGER then
		domoticz.log('User variable '.. battery_inverter_power_name ..' is not of the type INTEGER. Script will end. Please change the user variable to the type INTEGER and put a positive number in there', domoticz.LOG_ERROR)
		goto endScript
	elseif (battery_inverter_power.value == nil or battery_capacity.value < 0) then
		domoticz.log('Solar battery inverter capacity wrong or <0. Now set at 4000(W)', domoticz.LOG_ERROR)
		battery_inverter_power.set(4000)
	end
	
	if (emptyBatteryIsLostEnergy == nil or (emptyBatteryIsLostEnergy ~= 0 and emptyBatteryIsLostEnergy ~= 1 )) then
		emptyBatteryIsLostEnergy = 1
		domoticz.log('internal variable emptyBatteryIsLostEnergy does not contain a value of 0 or 1. Script will use value 1 and count lost energy at an empty battery')
	end
	
	if (emptyFullBatteryCountLostInverterEnergy == nil or (emptyFullBatteryCountLostInverterEnergy ~= 0 and emptyFullBatteryCountLostInverterEnergy ~= 1)) then
		emptyFullBatteryCountLostInverterEnergy = 1
		domoticz.log('internal variable emptyFullBatteryCountLostInverterEnergy does not contain a value of 0 or 1. Script will use a value of 1 and count lost inverter energy at empty or full battery')
	end

--check if persistent data exist and is a number. The new 'zero' value will be updated further down the script
	if (domoticz.data.consumedEnergy.size == 0 or
		_.isNumber(domoticz.data.consumedEnergy.getLatest().data)==false or
		domoticz.data.consumedEnergy.getLatest().data < 0) then
		domoticz.data.consumedEnergy.add(0)
		domoticz.log('dzVents variable consumedEnergy was empty or did not contain a number. Now set as 0',domoticz.LOG_DEBUG)
	end
	if (domoticz.data.returnedEnergy.size == 0 or
		_.isNumber(domoticz.data.returnedEnergy.getLatest().data)==false or
		domoticz.data.returnedEnergy.getLatest().data < 0) then
		domoticz.data.returnedEnergy.add(0)
		domoticz.log('dzVents variable returnedEnergy was empty or did not contain a number. Now set as 0',domoticz.LOG_DEBUG)
	end

--give a new virtual devices a start load of 0 kWh and 0 W
	if solarBattery.sValue == nil then
		solarBattery.updateCustomSensor(0)
		domoticz.log('solar battery value is nil en will be updated to 0',domoticz.LOG_DEBUG)
	end
	if (batteryUsage.usage1 == nil or batteryUsage.return1 == nil) then batteryUsage.updateP1(0,0,0,0,0,0) end
	if lostEnergy.WhTotal == nil then lostEnergy.updateElectricity(0,0) end
	if (lostBattery.usage1 == nil or lostBattery.return1 == nil) then lostBattery.updateP1(0,0,0,0,0,0) end
	if (lostInverter.usage1 == nil or lostInverter.return1 == nil) then lostInverter.updateP1(0,0,0,0,0,0) end
	
--Check if scriptInterval value is valid
	if (_.isNumber(scriptInterval) == false or scriptInterval < 0) then
		domoticz.log('value for scriptInterval is invalid (not a number, or < 0). Script will use P1 update frequency (scriptInterval = 0)',domoticz.LOG_ERROR)
		scriptInterval = 0
	end

--Check if inverter power level in relation to script interval and the fact that the minimum energy count is 1Wh, is in balance
	--(example: inverter power = 1800 @ scriptInterval of 1 second = 0,5 Wh.
	--At 20 seconds ((3600/1800) x (100/10)) = 10Wh +/-0.5Wh(minimum counter value))
	-- 10 +/-0.5 is a 10% deviation
	local maxDev = 10 --percent
	if (3600 / battery_inverter_power.value) * (100 / maxDev) > scriptInterval then
		scriptInterval = _.round ((3600 / battery_inverter_power.value) * (100 / maxDev), 3)
		domoticz.log('scriptInterval value increased to ' .. scriptInterval .. ' seconds to have a maximum deviation of ' .. maxDev .. ' percent', domoticz.LOG_DEBUG)
	end
---end of error checking functions ---

	--check if the script should continue, based on given scriptInterval timer
	--check timestamp from persistent data

	deltaTime = (domoticz.data.consumedEnergy.getLatest().time.millisecondsAgo)/1000
	if (deltaTime < scriptInterval) then
		domoticz.log("script trigger interval < than set value for scriptInterval (".. scriptInterval .. ")",domoticz.LOG_DEBUG)
		goto endScript
	end


	---calculate new energy values
	--check if device is a P1 meter
	domoticz.log('energymeter type = '.. consumedEnergyMeter.deviceType, domoticz.LOG_DEBUG)
	if consumedEnergyMeter.deviceType == 'P1 Smart Meter' then
		newConsumedEnergyMeter = consumedEnergyMeter.usage1 + consumedEnergyMeter.usage2
		newReturnedEnergyMeter = returnedEnergyMeter.return1 + returnedEnergyMeter.return2
		--batteryProdWatt = consumedEnergyMeter.usage
		--batteryUsedWatt = consumedEnergyMeter.usageDelivered
		domoticz.log('P1 meter: usage and return values will be used', domoticz.LOG_DEBUG)
	else -- other meter than P1 Smart Meter
		newConsumedEnergyMeter = consumedEnergyMeter.WhTotal
		newReturnedEnergyMeter = returnedEnergyMeter.WhTotal
		domoticz.log('General Energy meters for consumption and returned: WhTotal will be used per meter', domoticz.LOG_DEBUG)
	end

	---load previous energy values for consumption and returnedEnergy
	oldReturnedEnergyMeter = domoticz.data.returnedEnergy.getLatest().data
	oldConsumedEnergyMeter = domoticz.data.consumedEnergy.getLatest().data


	---check if the dzVents variable is new and if so, fill it with the current meter value
	if oldConsumedEnergyMeter == 0 then
		domoticz.data.consumedEnergy.add(newConsumedEnergyMeter)
	end
	if oldReturnedEnergyMeter == 0 then
		domoticz.data.returnedEnergy.add(newReturnedEnergyMeter)
		goto endScript
	end

	if (oldConsumedEnergyMeter == 0 or oldReturnedEnergyMeter == 0) then
		domoticz.log('Script is gathering the value for the consumed / produced energy meter for the 1st time. Script will end and be continued at the next interval', domoticz.LOG_DEBUG)
		goto endScript
	end
	
	---check for error when new value < old value
	if newConsumedEnergyMeter < oldConsumedEnergyMeter then
		domoticz.log('New value of consumed enery meter ('.. newConsumedEnergyMeter ..' Wh < previous value of '.. oldConsumedEnergyMeter..' Wh. Script will not continue',domoticz.LOG_ERROR)
		goto endScript
	elseif newReturnedEnergyMeter < newReturnedEnergyMeter then
		domoticz.log('New value of returned enery meter ('.. newReturnedEnergyMeter ..' Wh < previous value of '.. oldReturnedEnergyMeter..' Wh. Script will not continue',domoticz.LOG_ERROR)
		goto endScript
	end

	---calculate max. Wh that the battery inverter can handle (both directions)
	maxBbatteryInverterEnergy = battery_inverter_power.value * (domoticz.data.consumedEnergy.getLatest().time.millisecondsAgo / 3600000)
	domoticz.log('maxBbatteryInverterEnergy = '..battery_inverter_power.value .. ' x (' ..
	domoticz.data.consumedEnergy.getLatest().time.secondsAgo .. ' / 3600) = ' .. _.round (maxBbatteryInverterEnergy, 1) .. ' Wh',domoticz.LOG_DEBUG)

	---calculate the energy balance by: return - consumption
	--a negative value means consumption
	--a positive value means return
	energyBalance = (newReturnedEnergyMeter - oldReturnedEnergyMeter) - (newConsumedEnergyMeter - oldConsumedEnergyMeter)
	domoticz.log('Energy balance = '..energyBalance..' Wh (negative = consumption)',domoticz.LOG_DEBUG)

	if energyBalance > maxBbatteryInverterEnergy then
		inverterLostEnergy = energyBalance - maxBbatteryInverterEnergy
		inverterLostEnergyProd = energyBalance - maxBbatteryInverterEnergy
		inverterLostEnergyUsed = 0
		domoticz.log('Positive energybalance above max inverter capacity. inverterLostEnergy = '.. energyBalance  ..' - ' ..maxBbatteryInverterEnergy .. ' = ' .. inverterLostEnergy, domoticz.LOG_DEBUG)
		energyBalance = maxBbatteryInverterEnergy
		batteryProdWatt = battery_inverter_power.value
		batteryUsedWatt = 0
	elseif energyBalance < (-1 * maxBbatteryInverterEnergy) then -- more consumption than inverter can deliver
		inverterLostEnergy = (-1 * energyBalance ) - maxBbatteryInverterEnergy
		inverterLostEnergyUsed = (-1 * energyBalance ) - maxBbatteryInverterEnergy
		inverterLostEnergyProd = 0
		domoticz.log('Negative Energybalance below max inverter capacity. inverterLostEnergy = '.. -1 *energyBalance ..' - ' ..maxBbatteryInverterEnergy .. ' = ' .. inverterLostEnergy, domoticz.LOG_DEBUG)
		energyBalance = -1 * maxBbatteryInverterEnergy
		batteryUsedWatt = battery_inverter_power.value
		batteryProdWatt = 0
	else
		inverterLostEnergy = 0
		inverterLostEnergyProd = 0
		inverterLostEnergyUsed = 0
		inverterLostEnergyProd = 0
		domoticz.log('Energy balance within capacity of battery inverter', domoticz.LOG_DEBUG)
	end

---check the effect of the energy balance on the solar battery
	solarBatteryValue = solarBattery.sValue * 1000 -- custom sensor registers in kWh, while internal calculations are done in Wh
	newSolarBatteryValue = solarBatteryValue + energyBalance
	domoticz.log('solar battery value = '..solarBatteryValue ..' Wh, battery capacity is '..battery_capacity.value ..' Wh, new solar battery value = '..newSolarBatteryValue, domoticz.LOG_DEBUG)

--initial variable values:
	batteryProdEnergy = 0
	batteryUsedEnergy = 0
	newLostEnergyEmpty = 0
	newLostEnergyFull = 0
	inverterLostEnergyProdFull = 0
	inverterLostEnergyUsedEmpty = 0

--decide what the new state of the battery will be
	if newSolarBatteryValue > battery_capacity.value then --more energy produced than fits in battery
		--newLostEnergy = newSolarBatteryValue - battery_capacity.value --count all energy that goes above the set capacity level
		newLostEnergyFull = newSolarBatteryValue - battery_capacity.value --count all energy that goes above the set capacity level

		--update battery level with max value
		newSolarBatteryValue = battery_capacity.value
		--check if the battery is not already full
		if solarBatteryValue < battery_capacity.value then
			batteryProdEnergy = battery_capacity.value - solarBatteryValue
		end
		if emptyFullBatteryCountLostInverterEnergy == 0 then --battery is already full without lost inverter energy
			inverterLostProdWatt = 0
		else
			inverterLostEnergyProdFull = inverterLostEnergyProd
			inverterLostEnergyProd = 0  -- reset value to zero, because 'ProdFull' is used instead
		end
	elseif newSolarBatteryValue < 0 then --more energy consumed than available in battery
		--check if the battery is not already empty
		if solarBatteryValue > 0 then
			--first calculate the battery-used value (old value - 0)
			batteryUsedEnergy = solarBatteryValue
		end
		if emptyBatteryIsLostEnergy == 1 then -- also count lost energy due to empty battery
			--newLostEnergy = newSolarBatteryValue * -1 --(newSolarBatteryValue is negative, but it needs to be added UP to the counter)
			newLostEnergyEmpty = newSolarBatteryValue * -1 --(newSolarBatteryValue is negative, but it needs to be added UP to the counter)
		else
			--newLostEnergy = 0
		end
		if emptyFullBatteryCountLostInverterEnergy == 0 then --battery is already empty without lost inverter energy, don't count (1 = count)
			inverterLostUsedWatt = 0
		else
			inverterLostEnergyUsedEmpty = inverterLostEnergyUsed
			inverterLostEnergyUsed = 0 -- reset value to zero, because 'UsedEmpty' is used instead
		end
		--update battery level to zero
		newSolarBatteryValue = 0
	else --new battery within bandwith of chosen battery capacity
		--check if energy from battery is consumed
		if energyBalance > 0 then
			batteryProdEnergy = energyBalance
		elseif energyBalance < 0 then
			--negative value means consumption
			batteryUsedEnergy = energyBalance*-1 --(energyBalance is negative, but it needs to be added UP to the counter)
		else
			--either no energy used or energy is returned
		end
		--newLostEnergy = 0
	end

	domoticz.log('battery Used Energy = '..batteryUsedEnergy .. 'Wh',domoticz.LOG_DEBUG)
	domoticz.log('battery Prod Energy = '..batteryProdEnergy .. 'Wh',domoticz.LOG_DEBUG)
	domoticz.log('battery Lost Energy empty = '..newLostEnergyEmpty .. 'Wh',domoticz.LOG_DEBUG)
	domoticz.log('battery Lost Energy full = '..newLostEnergyFull .. 'Wh',domoticz.LOG_DEBUG)
	domoticz.log('inverter Lost Energy production = '..inverterLostEnergyProd .. 'Wh',domoticz.LOG_DEBUG)
	domoticz.log('inverter Lost Energy production when battery is full = '..inverterLostEnergyProdFull .. 'Wh',domoticz.LOG_DEBUG)
	domoticz.log('inverter Lost Energy usage = '..inverterLostEnergyUsed .. 'Wh',domoticz.LOG_DEBUG)
	domoticz.log('inverter Lost Energy usage when battery is full = '..inverterLostEnergyUsedEmpty .. 'Wh',domoticz.LOG_DEBUG)
	
--calculate battery power, based on battery energy
	if batteryUsedWatt == nil then batteryUsedWatt = _.round (batteryUsedEnergy * (3600/deltaTime), 0) end
	if batteryProdWatt == nil then batteryProdWatt = _.round (batteryProdEnergy * (3600/deltaTime), 0) end

--calculate lost energy power, based on lost energy
	if lostEnergyWatt == nil then lostEnergyWatt =  _.round ((newLostEnergyFull + newLostEnergyEmpty) * (3600/deltaTime), 0) end
	
--calculate lost inverter power, based on lost inverter energy
	if inverterLostEnergyUsedEmpty == nil then inverterLostEnergyUsedEmpty = 0 end
	if inverterLostEnergyProdFull == nil then inverterLostEnergyProdFull = 0 end
	if inverterLostUsedWatt == nil then inverterLostUsedWatt = _.round ((inverterLostEnergyUsed + inverterLostEnergyUsedEmpty) * (3600/deltaTime), 0) end
	if inverterLostProdWatt == nil then inverterLostProdWatt = _.round ((inverterLostEnergyProd + inverterLostEnergyProdFull)* (3600/deltaTime), 0) end


---update devices
	--update battery level with new value
	solarBattery.updateCustomSensor(_.round(newSolarBatteryValue / 1000,3))
	--update battery usage with new value
	batteryUsage.updateP1(batteryUsage.usage1 + batteryUsedEnergy, 0, batteryUsage.return1 + batteryProdEnergy, 0, batteryUsedWatt, batteryProdWatt)
	--update lost energy with new value
	--lostEnergy.updateElectricity(_.round(newLostEnergy * (3600/deltaTime),0), _.round(lostEnergy.WhTotal + newLostEnergy + inverterLostEnergy,0))
	lostBattery.updateP1(lostBattery.usage1 + newLostEnergyEmpty, 0, lostBattery.return1 + newLostEnergyFull, 0, lostEnergyWatt, 0)
	--update lost inverter energy with new value
	lostInverter.updateP1(lostInverter.usage1 + inverterLostEnergyUsed, lostInverter.usage2 + inverterLostEnergyUsedEmpty,
		lostInverter.return1 + inverterLostEnergyProd, lostInverter.return2 + inverterLostEnergyProdFull,
		inverterLostUsedWatt, inverterLostProdWatt)

---Update dzVents variables with the new meter values
	domoticz.data.returnedEnergy.add(newReturnedEnergyMeter)
	domoticz.data.consumedEnergy.add(newConsumedEnergyMeter)
::endScript::
end
}
