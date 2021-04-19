# Domoticz Simulated Solar Battery
a dzVents LUA script to control a simulated battery for storage and consumption of (self-) generated energy

A solar battery is used to balance energy production and consumption. A battery, or 'accumulator', will dampen both peak energy production and consumption. With a battery 'after the meter', more self-generated energy will remain 'in house', avoiding the financial disadvantage in the situation where energy from the grid is more expensive than the reward for energy sent to the grid.

For details, please checkout the [Wiki](https://github.com/jakenl/domoticz_solarbattery/wiki/Home) (based on script version 0.2)

[Discussion topic](https://www.domoticz.com/forum/viewtopic.php?f=61&t=19971&sid=d140c22fef203ab0d38f86dcb2d26c16) on the Domoticz forum

## Screenshots
### Solar battery devices
![battery_dashboard](https://user-images.githubusercontent.com/16058266/115231644-16467200-a116-11eb-863b-c5eb4ff9d6e5.PNG)

### Solar battery log file
Interesting analysis: The 5kWh capacity limit is reached in many months of the year. However,in the summer months the consumption is only 2-3kWh per day, a bigger battery has no value, since also a (for instance) 20kWh battery would only be used for the same 2-3kWh for many days in a row. in the winter months the production is so low that the full mark of 5kWh is never reached.
![battery_level](https://user-images.githubusercontent.com/16058266/115231700-265e5180-a116-11eb-926a-1cd0f1709aca.PNG)
The graphs show an actual battery level over the last days and a min/avg/max level over the months and year

### Solar battery usage
![battery_usage](https://user-images.githubusercontent.com/16058266/115233723-8a821500-a118-11eb-9eec-5f629751349d.PNG)
The graph shows both consuming energy from the battery (usage1) as returning energy to the battery (return1)

### Lost solar battery energy
![lost_battery_energy](https://user-images.githubusercontent.com/16058266/115233629-6f170a00-a118-11eb-97f3-98a16a8520a6.PNG)
The graph shows both lost energy due to an empty battery (usage1) as due to a full battery (return1). (Mo/Tu the battery was empty). 24hrs ago (1 day) the battery was already full, while the solar system still produced energy.

### Lost solar battery inverter energy
![lost_inverter_energy](https://user-images.githubusercontent.com/16058266/115233422-2c553200-a118-11eb-9a9a-f97279e141bd.PNG)


