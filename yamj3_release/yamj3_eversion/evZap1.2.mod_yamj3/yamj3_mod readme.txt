eZap yamj3 MOD v6.0

evZap v1.2.1 & eversion3.phf is mandatory for this mod

Goals of the yamj3 Mod 
end-user have 3 modes:
- no people <==  <detailsMOVIE>movie</detailsMOVIE>
- people with max poster  <==  <detailsMOVIE>movie_people</detailsMOVIE>
- people with adjusted poster <==  <detailsMOVIE>movie_people</detailsMOVIE> and <people_max_poster>false</people_max_poster>
- people list with dynamic poster <==  <detailsMOVIE>movie_people_list</detailsMOVIE>
(adjust <detailsMOVIE> in settings.xml) 

installation rules: 

unzip the package directly at the root of the evZap skin 
1 - on the eversion side 
Modify the esettings.xml  yamj3 parameter to match with your config 
 
                <yamj3coreurl>http://192.168.1.8:8888/yamj3/</yamj3coreurl>       // adjust yamj3 address
                <yamj3librarypaths>T:\video\Film\</yamj3librarypaths>                      // where is stored your movies :  generally the library path in 
                <yamj3playerpaths>file:///opt/sybhttpd/localhost.drives/NETWORK_SHARE/SYNO/</yamj3playerpaths>          // path to access movies from PCH  
                <yamj3chunksize>24</yamj3chunksize>   // number of item perpage setted in yamj3 used by &perpage parameter 

equivalent library.xml used by yamjv2
 
<libraries>
  <library>
    <path>T:\video\Film</path>
    <playerpath>file:///opt/sybhttpd/localhost.drives/NETWORK_SHARE/SYNO/video/Film</playerpath>
    <exclude name="sample,tmp/,temp/,RECYCLER/,RECYCLE.BIN/"/>
    <description></description>
    <prebuf></prebuf>
    <scrapeLibrary>true</scrapeLibrary>
  </library>
</libraries>
 



the people mod have the following implementation :
- add a new value in the load.eskin file ==> <movie default="movie">movie,movie_people,movie_people_list</movie>

change /evZap1.2.mod-yamj3/settings.xml
- add a new value in the settings.xml file for <detailsMOVIE>   ==> <detailsMOVIE>movie_people_list</detailsMOVIE>
- add a new parameter in the settings.xml file which allow to choose 2 implementations ==> <people_max_poster>true</people_max_poster> or false
if true ==> display 8 posters (1 director, 1 writer, 6 actors) with a large frame which is called via INFO or EQUAL button 
if false ==> adjust the number of poster to the plot size, according with the rules of the skin
- add people index with fanart and biography	==>	<indexPEOPLE>people.poster.fanart.bio2</indexPEOPLE>  
- add a userlist1 to userlist7 for various entries  ==> already done 
		<userlist>Genres</userlist>
		<userlist2>Certification</userlist2>
		<userlist3>Year</userlist3>
		<userlist4>Ratings</userlist4>
		<userlist5>Set</userlist5>
		<userlist6>Title</userlist6>
		<userlist7>People</userlist7>
- add person_list-x in the people.control ==> already done but mandatory to implement people feature 
		<personlist-a>lastname-a</personlist-a> 
		<personlist-b>lastname-b</personlist-b>
		<personlist-c>lastname-c</personlist-c>
		<personlist-d>lastname-d</personlist-d>
		<personlist-e>lastname-e</personlist-e>
		<personlist-f>lastname-f</personlist-f>
		<personlist-g>lastname-g</personlist-g>
		<personlist-h>lastname-h</personlist-h>
		<personlist-i>lastname-i</personlist-i>
		<personlist-j>lastname-j</personlist-j>
		<personlist-k>lastname-k</personlist-k>
		<personlist-l>lastname-l</personlist-l>
		<personlist-m>lastname-m</personlist-m>
		<personlist-n>lastname-n</personlist-n>
		<personlist-o>lastname-o</personlist-o>
		<personlist-p>lastname-p</personlist-p>
		<personlist-q>lastname-q</personlist-q>
		<personlist-r>lastname-r</personlist-r>
		<personlist-s>lastname-s</personlist-s>
		<personlist-t>lastname-t</personlist-t>
		<personlist-u>lastname-u</personlist-u>
		<personlist-v>lastname-v</personlist-v>
		<personlist-w>lastname-w</personlist-w>
		<personlist-x>lastname-x</personlist-x>
		<personlist-y>lastname-y</personlist-y>
		<personlist-z>lastname-z</personlist-z>
- set homelist and menu 
		<homelist>Other,People,Library</homelist>
		<menulist>Other,Genres,Title,Year,Set,Ratings,Certification</menulist>

- change city code 
	<units>c</units>  <!-- c,f celsius, farenheit --> 
	<!-- Weather city code. To find out goto http://edg3.co.uk/snippets/weather-location-codes/  -->
	<!-- Examples: GMXX0087 = Munich, GMXX0007 = Berlin, USNY0996 = New York -->
	<citycode>606889</citycode>  <!-- this one is for home menu weather data -->
	<citycode1>606889</citycode1>   <!-- peynier -->
	<citycode2>575609</citycode2>   <!-- aix -->
	<citycode3>610264</citycode3>   <!-- marseille -->

- set people.control  ==> already done in the package, mandatory for people feature 
<control>

<insert>
<info>personlist-a</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-b</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-c</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-d</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-e</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-f</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-g</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-h</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-i</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>
</insert>

<insert>	
<info>personlist-j</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>
</insert>

<insert>	
<info>personlist-k</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-l</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>
</insert>

<insert>
<info>personlist-m</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-n</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-o</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-p</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-q</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-r</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-s</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-t</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-u</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-v</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-w</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

<insert>
<info>personlist-x</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>
<info>personlist-y</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>	
</insert>

<insert>	
<info>personlist-z</info>
<action>PRELOAD</action>
<file>people.poster.fanart.bio2</file>
<data>index</data>		
</insert>

</control>

- adjust home.control  ==> already done in the package 
<control>
	<!--<insert>
		<info>homelist</info>
	</insert>-->
    <item>
        <name>New</name>
        <action>SWITCH</action>
        <title>[:%new,upper:]</title>
        <originaltitle>new</originaltitle>
        <data>Other_New_1</data>
    </item>
<!--	<item>
        <name>All</name>
        <action>SWITCH</action>
        <title>[:%all,upper:]</title>
        <originaltitle>all</originaltitle>
        <data>Other_All_1</data> 
    </item> -->
	<item>
        <name>Movies</name>
        <action>SWITCH</action>
        <title>[:%movies,upper:]</title>
        <originaltitle>movies</originaltitle>
        <data>Other_Movies_1</data>
    </item>
	<item>
        <name>Non Vus</name>
        <action>SWITCH</action>
        <title>[:%unwatched,upper:]</title>
        <originaltitle>unwatched</originaltitle>
		<file>infowall</file>
        <data>Other_Unwatched_1</data> 
    </item>
	<item>
        <name>New-TV</name>
        <action>SWITCH</action>
        <title>[:%new-tv,upper:]</title>
        <originaltitle>new-tv</originaltitle>
        <data>Other_New-TV_1</data>
    </item>	
	<item>
        <name>TV shows</name>
        <action>SWITCH</action>
        <title>[:%tv-shows,upper:]</title>
        <originaltitle>tv-shows</originaltitle>
		<file>infowall</file>
        <data>Other_TV Shows_1</data>
    </item> 
	<item>
        <name>HD</name>
        <action>SWITCH</action>
        <title>[:%hd,upper:]</title>
        <originaltitle>hd</originaltitle>
		<file>wallfull2row</file>
        <data>Other_HD_1</data>
    </item>
    <item>
        <name>3D</name>
        <action>SWITCH</action>
        <title>[:%3d,upper:]</title>
        <originaltitle>3D</originaltitle>
		<file>wallfull2row</file>
        <data>Other_3D_1</data>
    </item>
	
	<insert>
        <name>Genres</name>
		<info>userlist</info>
        <title>[:%genre,upper:]</title>
        <originaltitle>genres</originaltitle>
		<action>PRELOAD</action>
	    <file>wallfull_genre</file>
	    <data>index</data>        
	</insert>
	<insert>
        <name>Certification</name>
		<info>userlist2</info>
        <title>[:%certification:]</title>
        <originaltitle>certification</originaltitle>
		<action>PRELOAD</action>
	    <file>wallfull_certification</file>
	    <data>index</data>        
	</insert>
	<insert>
        <name>Year</name>
		<info>userlist3</info>
        <title>[:%year:]</title>
        <originaltitle>year</originaltitle>
		<action>PRELOAD</action>
		<file>wallfull_year</file>
	    <data>index</data>        
	</insert> 	
	<insert>
        <name>Ratings</name>
		<info>userlist4</info>
        <title>[:%rating:]</title>
        <originaltitle>rating</originaltitle>
		<action>PRELOAD</action>
	    <file>wallfull_rating</file>
	    <data>index</data>        
	</insert> 
	<insert>
        <name>Set</name>
		<info>userlist5</info>
        <title>[:%set:]</title>
        <originaltitle>set</originaltitle>
		<action>PRELOAD</action>
	    <file>wallfull</file>
	    <data>Other_Sets_1</data>       
	</insert>
	<item>
		<name>People</name>
		<action>screen</action>
		<title>[:%people:]</title>
		<originaltitle>people</originaltitle>
		<file>thescreen.people</file>
	</item> 
	<insert>
        <name>title</name>
		<info>userlist6</info>
        <title>[:%title:]</title>
        <originaltitle>title</originaltitle>
		<action>PRELOAD</action>
	    <file>wallfull_title</file>
	    <data>index</data>
	</insert>
	<item>
        <name>Trailers</name>
		<action>SWITCH</action>
		<title>[:%trailers,upper:]</title>
        <originaltitle>trailers</originaltitle>
		<data>eskin://[:#indexTrailers,lower:]</data>
		<feed>http://trailers.lundman.net</feed>
	</item>	
	<item>
        <name>Weather</name>
		<action>SCREEN</action>
		<title>[:%weather,upper:]</title>
        <originaltitle>weather</originaltitle>
		<file>weather</file>
	</item>	

	<!--<insert>
		<info>playrom</info>
	</insert>	
	<item>
        <name>Apps</name>
		<action>apps</action>
		<title>[:%apps,upper:]</title>
        <originaltitle>apps</originaltitle>
	</item>-->

	<item>
        <name>Exit</name>
		<action>exit</action>
		<title>[:%exit:]</title>
        <originaltitle>exit</originaltitle>
	</item>
</control>



