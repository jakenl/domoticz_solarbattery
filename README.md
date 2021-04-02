# domoticz_solarbattery
LUA script to control a simulated battery for storage and consumption of (self-) generated energy

A solar battery is used to balance energy production and consumption

**Principle of the script**
- Compare new meter values with previous values and calculate the difference
- Add or subtract this difference to/from the solar battery.
- When the solar battery is at max capacity or is empty, no more solar energy can be stored or used. This is lost energy

**3 devices need to be added**
- a custom sensor that only displays the current value of the solar battery: important to see min, avg and max values over the days
- a P1-meter that shows within 1 device power and energy usage of the solar battery
- an electricity meter that shows the lost power and energy due to a full and empty battery

**Solar battery log file**
Interesting analysis: in the summer months the consumption is only 2-3kWh per day, a bigger battery has no value. in the winter months the production is so low that the full mark is never reached.
![SolarBattery](https://user-images.githubusercontent.com/16058266/113411981-6fdd3b80-93b7-11eb-9ee9-2101f5e86430.JPG)

**Solar battery usage**
![SolarBatteryUsage](https://user-images.githubusercontent.com/16058266/113412143-d2363c00-93b7-11eb-8bd6-6ae93dd24833.JPG)

**Lost solar energy**
![LostEnergy](https://user-images.githubusercontent.com/16058266/113412186-e7ab6600-93b7-11eb-8006-456eed20006a.JPG)
