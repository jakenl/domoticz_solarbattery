# Domoticz Simulated Solar Battery
LUA script to control a simulated battery for storage and consumption of (self-) generated energy

A solar battery is used to balance energy production and consumption. A battery, or 'accumulator', will dampen both peak energy production and consumption. With a battery 'after the meter', more self-generated energy will remain 'in house', avoiding the financial disadvantage in the situation where energy from the grid is more expensive than the reward for energy sent to the grid.

**Principle of the script**
- Compare new meter values with previous values and calculate the difference
- Add or subtract this difference to/from the solar battery.
- When the solar battery is at max capacity or is empty, no more solar energy can be stored or used. This is lost energy

**Script features**
- Free choice of the capacity of the solar battery. How does a larger or smaller setup perform in your household? After initial creation of the domoticz variable, this is easily changed through the GUI of domoticz.
- Free choice of inverter power that is connected to the battery. When for instance a 2000W inverter is simulated and a 3000W applicance is used, the battery will only deliver 2000W, the remaining 1000W will come from the grid. This 1000W from the grid will be registered as 'lost energy'.
- Multiple simulated batteries are possible by creating unique devices for each copy of the LUA script
- Both a P1-meter or 2 separate energy meters (for production and consumption) in Domoticz can be used with this script.
- Measuring of energy losses due to an empty battery can be turned on and off.

**Device log analysis**

Some analysis can be done straight from the produced graphs by Domoticz, for other analysis it is better to export the results to a spreadsheet program instead. For a better insight, it is recommended to only start analysing after some months, ideally after a full year of running the script.

- The Solar Battery log will show how often the battery reaches it maximum capacity. Equally important are also the times when the battery is not emptied over a 24hr period and the times where there is not enough energy generated to reach the maximum capacity. A big battery will prevent some losses when multiple days need to be covered by a low energy production. However, this is very costly in purchasing such a battery and the benefits might be limited to just a few days a year
- The energy consumption from the battery is the financial benefit. For the chosen capacity and inverter power, the log will tell the amount of energy that was avoided from the grid. Battery investment can be compared to the savings in buying/selling energy from/to the grid
- Lost energy can be monitored. By comparing this data in a spreadsheet with the battery usage, it can be seen whether an upgrade in battery capacity or inverter power will be useful.

**Prerequisities**
- An existing energy meter in Domoticz. This may be a P1-meter or 2 seperate energy meters for consumption from the grid and production to the grid.

**3 virtual devices need to be added**
- a custom sensor that only displays the current value of the solar battery: important to see min, avg and max values over the days
- a P1-meter that shows within 1 device power and energy usage of the solar battery in both directions
- an electricity meter that shows the lost power and energy due to a full and empty battery

**2 Domoticz user variables need to be added**
- The capacity of the the simulated battey
- The maximum power of the simulated inverter for the battery 

**Script**
- Download the script
- Place the script in the folder: \domoticz\scripts\dzVents\scripts

**Solar battery devices**
![devices](https://user-images.githubusercontent.com/16058266/113413398-e7609a00-93ba-11eb-8399-5ba66eaea13d.JPG)

**Solar battery log file**

Interesting analysis: The 5kWh capacity can be seen many months in the year. However,in the summer months the consumption is only 2-3kWh per day, a bigger battery has no value, since also a 20kWh battery would only be used for the same 2-3kWh for many days in a row. in the winter months the production is so low that the full mark is never reached.
![SolarBattery](https://user-images.githubusercontent.com/16058266/113411981-6fdd3b80-93b7-11eb-9ee9-2101f5e86430.JPG)

**Solar battery usage**

The new virtual P1-meter is only used for 2 (not very energy productive) days. Therefore the simulated inverter power of 1000W is not visible as a flat line at 1000W during peak moments. 
![SolarBatteryUsage](https://user-images.githubusercontent.com/16058266/113412143-d2363c00-93b7-11eb-8bd6-6ae93dd24833.JPG)

**Lost solar energy**
![LostEnergy](https://user-images.githubusercontent.com/16058266/113412186-e7ab6600-93b7-11eb-8006-456eed20006a.JPG)
