# Domoticz Simulated Solar Battery
a dzVents LUA script to control a simulated battery for storage and consumption of (self-) generated energy

A solar battery is used to balance energy production and consumption. A battery, or 'accumulator', will dampen both peak energy production and consumption. With a battery 'after the meter', more self-generated energy will remain 'in house', avoiding the financial disadvantage in the situation where energy from the grid is more expensive than the reward for energy sent to the grid.

For details, please checkout the [Wiki](https://github.com/jakenl/domoticz_solarbattery/wiki/Home) (based on script version 0.2)

[Discussion topic](https://www.domoticz.com/forum/viewtopic.php?f=61&t=19971&sid=d140c22fef203ab0d38f86dcb2d26c16) on the Domoticz forum

## Screenshots
### Solar battery devices
![battery_dashboard](https://user-images.githubusercontent.com/16058266/115231644-16467200-a116-11eb-863b-c5eb4ff9d6e5.PNG)

### Solar battery log file
Interesting analysis: The 5kWh capacity can be seen many months in the year. However,in the summer months the consumption is only 2-3kWh per day, a bigger battery has no value, since also a 20kWh battery would only be used for the same 2-3kWh for many days in a row. in the winter months the production is so low that the full mark of 5kWh is never reached.
![battery_level](https://user-images.githubusercontent.com/16058266/115231700-265e5180-a116-11eb-926a-1cd0f1709aca.PNG)

### Solar battery usage
The new virtual P1-meter is only used for 2 (not very energy productive) days. Therefore the simulated inverter power of 1200W is not visible as a flat line at 1200W during peak moments. 
![battery_usage](https://user-images.githubusercontent.com/16058266/115231744-35dd9a80-a116-11eb-8764-0c65a344c932.PNG)

### Lost solar energy
![lost_battery_energy](https://user-images.githubusercontent.com/16058266/115231770-3f670280-a116-11eb-9ea4-c61a68578cea.PNG)

### Lost inverter energy!
[lost_inverter_energy](https://user-images.githubusercontent.com/16058266/115231843-5574c300-a116-11eb-93da-4e219b7e4561.PNG)
