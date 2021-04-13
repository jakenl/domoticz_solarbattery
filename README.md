# Domoticz Simulated Solar Battery
a dzVents LUA script to control a simulated battery for storage and consumption of (self-) generated energy

A solar battery is used to balance energy production and consumption. A battery, or 'accumulator', will dampen both peak energy production and consumption. With a battery 'after the meter', more self-generated energy will remain 'in house', avoiding the financial disadvantage in the situation where energy from the grid is more expensive than the reward for energy sent to the grid.

For details, please checkout the [Wiki](https://github.com/jakenl/domoticz_solarbattery/wiki/Home)

[Discussion topic](https://www.domoticz.com/forum/viewtopic.php?f=61&t=19971&sid=d140c22fef203ab0d38f86dcb2d26c16) on the Domoticz forum

## Screenshots
### Solar battery devices
![devices](https://user-images.githubusercontent.com/16058266/113413398-e7609a00-93ba-11eb-8399-5ba66eaea13d.JPG)

### Solar battery log file
Interesting analysis: The 5kWh capacity can be seen many months in the year. However,in the summer months the consumption is only 2-3kWh per day, a bigger battery has no value, since also a 20kWh battery would only be used for the same 2-3kWh for many days in a row. in the winter months the production is so low that the full mark is never reached.
![SolarBattery](https://user-images.githubusercontent.com/16058266/113411981-6fdd3b80-93b7-11eb-9ee9-2101f5e86430.JPG)

### Solar battery usage
The new virtual P1-meter is only used for 2 (not very energy productive) days. Therefore the simulated inverter power of 1000W is not visible as a flat line at 1000W during peak moments. 
![SolarBatteryUsage](https://user-images.githubusercontent.com/16058266/113412143-d2363c00-93b7-11eb-8bd6-6ae93dd24833.JPG)

### Lost solar energy
![LostEnergy](https://user-images.githubusercontent.com/16058266/113412186-e7ab6600-93b7-11eb-8006-456eed20006a.JPG)
