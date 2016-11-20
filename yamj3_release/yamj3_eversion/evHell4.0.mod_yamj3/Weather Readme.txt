Weather feed: Yahoo Weather
Icons: iconbest.com

1. Copy weather folder into your eskin/media folder

2. Copy weather.eskin to your eskin/code folder

3. Copy

	<!-- Date language (EN, DE; default = EN) -->
	<datelang>EN</datelang>
	<!-- Temperature unit: C or F (°C/°F; affects also other units like mph, etc.)  -->
	<units>C</units>
	<!-- Weather city code. Go to http://edg3.co.uk/snippets/weather-location-codes/ to find out. -->
	<!-- Examples: GMXX0087 = Munich, USNY0996 = New York -->
	<citycode>GMXX0087</citycode>

   into settings.xml/settings-default.xml file.
   Change the values as you like. City codes can be found eg. at: http://edg3.co.uk/snippets/weather-location-codes/

4. To open the weather page copy

	<item>
		<action>SCREEN</action>
		<title>WEATHER</title>
		<file>weather</file>
	</item>	

   into home.control and/or menu.control file
   
Note:
If you want to use different weather images:
- images must have sqare format
- images must follow yahoo weather codes; name them forecast_1-47.png (for weather codes see 'yahoo weather codes.txt')

Original Yahoo icons: http://www.youtoart.com/html/Icon/Other/4650.html
