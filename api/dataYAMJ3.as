// Eversion, the flash interface for YAMJ on the Syabas Embedded Players
// Copyright (C) 2012  Bryan Socha, aka Accident
// Copyright (C) 2015  Diodato

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import com.syabas.as2.common.JSONUtil;
import com.designvox.tranniec.JSON;

import ev.Common;
import ev.Background;
import tools.Data;
import tools.StringUtil;
import mx.xpath.XPathAPI;
import mx.utils.Delegate;

class api.dataYAMJ3 {
	// state stuff
	private var fn:Object = null;

	// artwork vars
	private var artsize:Array=null;

	// index vars
	private var indexTypeTemp:String=null;
	private var indexName:String=null
	private var indexOriginalName=null;
	private var baseIndex:String;
	private var indexCategory:String;
	private var currentChunk:Number=null;
	private var yamj3Id:Number=null;
	private var infoProcessing:Boolean=null;

	// parse data
	private var parseDataField:String=null;;
	private var parseDataTitleArr:Object=null;
	private var parseDataHowmany:Number=null;

	private var getDetailsCount:Number=null;
	private var tmpJsonData=null;
	private var tmpJsonDataPerson=null;
	private var tmpJsonDataPerson2=null;
	private var tmpJsonDataPersonSeries=null;
	
	private var alphabetic:String="abcdefghijklmnopqrstuvwxyz";
	
	
// constructor
	function dataYAMJ3() {
		trace("dataYAMJ3 function dataYAMJ3");
		this.fn = {
			onCheckForYAMJ3:Delegate.create(this, this.onCheckForYAMJ3),
			onParseData:Delegate.create(this, this.onParseData),
			onGetYAMJ3genresIndexData:Delegate.create(this, this.onGetYAMJ3genresIndexData),
			onGetIndex_getDetails:Delegate.create(this, this.onGetIndex_getDetails),
			onGetIndex_getDetailsSeriesInfo:Delegate.create(this, this.onGetIndex_getDetailsSeriesInfo),
			onGetIndexPerson:Delegate.create(this, this.onGetIndexPerson),
			onGetDetailsSeasons:Delegate.create(this, this.onGetDetailsSeasons),
			onGetDetailsGenresFiles:Delegate.create(this, this.onGetDetailsGenresFiles),
			onGetDetailsPeople:Delegate.create(this, this.onGetDetailsPeople),
			onGetDetailsSeasons2:Delegate.create(this, this.onGetDetailsSeasons2),
			onEpisodesSeason:Delegate.create(this, this.onEpisodesSeason),
			onEpisodesEpisodes:Delegate.create(this, this.onEpisodesEpisodes),
		/*** added for new entries **/	
			onGetYAMJ3personIndexData:Delegate.create(this, this.onGetYAMJ3personIndexData),
			onGetYAMJ3setIndexData:Delegate.create(this, this.onGetYAMJ3setIndexData),
			onGetYAMJ3yearIndexData:Delegate.create(this, this.onGetYAMJ3yearIndexData),
			onGetYAMJ3titleIndexData:Delegate.create(this, this.onGetYAMJ3titleIndexData),
			onGetYAMJ3certificationIndexData:Delegate.create(this, this.onGetYAMJ3certificationIndexData),
			onGetYAMJ3ratingsIndexData:Delegate.create(this, this.onGetYAMJ3ratingsIndexData),
			onGetPerson_getDetails:Delegate.create(this, this.onGetPerson_getDetails),
			onGetDetailsPersonFiles2:Delegate.create(this, this.onGetDetailsPersonFiles2),
			onGetPersonPeople:Delegate.create(this, this.onGetPersonPeople)
		};
		this.artsize=new Array("SMALL","MEDIUM","LARGE","ORIGINAL");
	}

	public function cleanup():Void {
		trace("dataYAMJ3 function cleanup");
		delete this.fn;
		this.fn=null;
		this.reload();
	}

	public function reload():Void {
		trace("dataYAMJ3 function reload");
		this.indexTypeTemp=null;
		this.indexName=null;
		this.indexOriginalName=null;
		this.baseIndex=null;
		this.indexCategory=null;
		this.currentChunk=0;
		this.yamj3Id=null;
		this.infoProcessing=null;
		this.parseDataField=null;;
		this.parseDataTitleArr=null;
		this.parseDataHowmany=null;
		this.getDetailsCount=null;
		this.tmpJsonData=null;
		this.tmpJsonDataPerson=null;
		this.tmpJsonDataPerson2=null;
		this.tmpJsonDataPersonSeries=null;
		System.security.allowDomain('*');
	}

	// TODO onHTTP... to avoid 30s timeout when server not responding
	private function getDataYAMJ3(url:String, passthroughCallback:Function, passthroughData:Object, callBack:Function):Void {
		trace("dataYAMJ3 function getDataYAMJ3");
    	var jsonData:Object = null;
        var php_process:LoadVars = new LoadVars();
		trace("getDataYAMJ3: "+url);
		php_process.onData = Delegate.create( this, function(src:String) {
			if (src == undefined) {
               	trace("Error loading content.");
               	callBack(false, null, passthroughCallback, passthroughData);
            }
			else {
			//	trace ("getDataYAMJ3 JSONUtil.parseJSON(src) " + src);
            	this.jsonData = JSONUtil.parseJSON(src);
               	callBack(true, this.jsonData, passthroughCallback, passthroughData);
			}
			return;
		} );
        
        php_process.load(url);
	}

	// we don't use 'ping' but 'system/info' to get the artwork/photo paths
	public function checkForYAMJ3(callBack:Function):Void {
		trace("dataYAMJ3 function checkForYAMJ3");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];

		trace("In checkForYAMJ3, yamj3coreurl: "+yamj3coreurl);
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack(false);
		else
			getDataYAMJ3(yamj3coreurl+"system/info.json", callBack, null, this.fn.onCheckForYAMJ3);
	}
	
	private function onCheckForYAMJ3(success:Boolean, jsonData:Object, callBack:Function) {
		trace("dataYAMJ3 function onCheckForYAMJ3");
		if(success) {
			trace("onCheckForYAMJ3 success");
			//nullify the yamjdatapath
			Common.evSettings.yamjdatapath="";
			// url path to all artwork files
			Common.yamj3artworkurl=jsonData["baseArtworkUrl"];
			Common.yamj3photourl=jsonData["basePhotoUrl"];
			callBack(true);
		}
		else {
			trace("onCheckForYAMJ3 fail");
			callBack(false);
		}
	}
	
// ****************************** CATEGORIES *****************************

	public function getCat(callBack:Function):Void {
		trace("dataYAMJ3 function getCat");
		var arr:Array;
		var i:Number;
		
		// prep the global
		delete Common.indexes;
		Common.indexes=new Array();

		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"Other_All_1", file:"Other_All_1", title:"All", originaltitle:"All"};
		arr[i++]={action:"SWITCH", data:"Other_New_1", file:"Other_New_1", title:"New", originaltitle:"New"};
		arr[i++]={action:"SWITCH", data:"Other_New-TV_1", file:"Other_New-TV_1", title:"New-TV", originaltitle:"New-TV"};
		arr[i++]={action:"SWITCH", data:"Other_New-Movies_1", file:"Other_New-Movies_1", title:"New-Movies", originaltitle:"New-Movies"};
		arr[i++]={action:"SWITCH", data:"Other_Movies_1", file:"Other_Movies_1", title:"Movies", originaltitle:"Movies"};
	/*	arr[i++]={action:"SWITCH", data:"Other_Extras_1", file:"Other_Extras_1", title:"Extras", originaltitle:"Extras"}; */
		arr[i++]={action:"SWITCH", data:"Other_TV Shows_1", file:"Other_TV Shows_1", title:"TV Shows", originaltitle:"TV Shows"};
		arr[i++]={action:"SWITCH", data:"Other_3D_1", file:"Other_3D_1", title:"3D", originaltitle:"3D"};
		arr[i++]={action:"SWITCH", data:"Other_HD_1", file:"Other_HD_1", title:"HD", originaltitle:"HD"};
	/*	arr[i++]={action:"SWITCH", data:"Other_Top250_1", file:"Other_Top250_1", title:"Top250", originaltitle:"Top250"}; */
		arr[i++]={action:"SWITCH", data:"Other_Unwatched_1", file:"Other_Unwatched_1", title:"Unwatched", originaltitle:"Unwatched"};
	/*	arr[i++]={action:"SWITCH", data:"Other_Rating-1_1", file:"Other_Rating-1_1", title:"Rating-1", originaltitle:"Rating-1"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-2_1", file:"Other_Rating-2_1", title:"Rating-2", originaltitle:"Rating-2"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-3_1", file:"Other_Rating-3_1", title:"Rating-3", originaltitle:"Rating-3"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-4_1", file:"Other_Rating-4_1", title:"Rating-4", originaltitle:"Rating-4"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-5_1", file:"Other_Rating-5_1", title:"Rating-5", originaltitle:"Rating-5"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-6_1", file:"Other_Rating-6_1", title:"Rating-6", originaltitle:"Rating-6"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-7_1", file:"Other_Rating-7_1", title:"Rating-7", originaltitle:"Rating-7"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-8_1", file:"Other_Rating-8_1", title:"Rating-8", originaltitle:"Rating-8"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-9_1", file:"Other_Rating-9_1", title:"Rating-9", originaltitle:"Rating-9"};
		arr[i++]={action:"SWITCH", data:"Other_Rating-10_1", file:"Other_Rating-10_1", title:"Rating-10", originaltitle:"Rating-10"};*/
		trace("dataYAMJ3 create indexes other");
		Common.indexes["other"]=arr;
		delete arr;
/*		
		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"YAMJ3", file:"YAMJ3", title:"Genres", originaltitle:"Genres"};
		Common.indexes["genres"]=arr;
		delete arr;
*/

/*
		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"Year_1920-29_1", file:"Year_1920-29_1", title:"1920-29", originaltitle:"1920-29"};
		arr[i++]={action:"SWITCH", data:"Year_1930-39_1", file:"Year_1930-39_1", title:"1930-39", originaltitle:"1930-39"};
		arr[i++]={action:"SWITCH", data:"Year_1940-49_1", file:"Year_1940-49_1", title:"1940-49", originaltitle:"1940-49"};
		arr[i++]={action:"SWITCH", data:"Year_1950-59_1", file:"Year_1950-59_1", title:"1950-59", originaltitle:"1950-59"};
		arr[i++]={action:"SWITCH", data:"Year_1960-69_1", file:"Year_1960-69_1", title:"1960-69", originaltitle:"1960-69"};
		arr[i++]={action:"SWITCH", data:"Year_1970-79_1", file:"Year_1970-79_1", title:"1970-79", originaltitle:"1970-79"};
		arr[i++]={action:"SWITCH", data:"Year_1980-89_1", file:"Year_1980-89_1", title:"1980-89", originaltitle:"1980-89"};
		arr[i++]={action:"SWITCH", data:"Year_1990-99_1", file:"Year_1990-99_1", title:"1990-99", originaltitle:"1990-99"};
		arr[i++]={action:"SWITCH", data:"Year_2000-09_1", file:"Year_2000-09_1", title:"2000-09", originaltitle:"2000-09"};
		arr[i++]={action:"SWITCH", data:"Year_2010-14_1", file:"Year_2010-14_1", title:"2010-14", originaltitle:"2010-14"};
		arr[i++]={action:"SWITCH", data:"Year_Last Year_1", file:"Year_Last Year_1", title:"Last Year", originaltitle:"Last Year"};
		arr[i++]={action:"SWITCH", data:"Year_This Year_1", file:"Year_This Year_1", title:"This Year", originaltitle:"This Year"};
		Common.indexes["year"]=arr;
		delete arr;
*/
/*
		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"YAMJ3", file:"YAMJ3", title:"Library", originaltitle:"Library"};
		Common.indexes["library"]=arr;
		delete arr;
*/
		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"YAMJ3", file:"YAMJ3", title:"Set", originaltitle:"Set"};
		Common.indexes["set"]=arr;
		delete arr;
/*
		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"Ratings_1.0.0-1.0.9_1", file:"Ratings_1.0.0-1.0.9_1", title:"1.0.0-1.0.9", originaltitle:"1.0.0-1.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_2.0.0-2.0.9_1", file:"Ratings_2.0.0-2.0.9_1", title:"2.0.0-2.0.9", originaltitle:"2.0.0-2.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_3.0.0-3.0.9_1", file:"Ratings_3.0.0-3.0.9_1", title:"3.0.0-3.0.9", originaltitle:"3.0.0-3.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_4.0.0-4.0.9_1", file:"Ratings_4.0.0-4.0.9_1", title:"4.0.0-4.0.9", originaltitle:"4.0.0-4.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_5.0.0-5.0.9_1", file:"Ratings_5.0.0-5.0.9_1", title:"5.0.0-5.0.9", originaltitle:"5.0.0-5.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_6.0.0-6.0.9_1", file:"Ratings_6.0.0-6.0.9_1", title:"6.0.0-6.0.9", originaltitle:"6.0.0-6.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_7.0.0-7.0.9_1", file:"Ratings_7.0.0-7.0.9_1", title:"7.0.0-7.0.9", originaltitle:"7.0.0-7.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_8.0.0-8.0.9_1", file:"Ratings_8.0.0-8.0.9_1", title:"8.0.0-8.0.9", originaltitle:"8.0.0-8.0.9"};
		arr[i++]={action:"SWITCH", data:"Ratings_9.0.0-9.0.9_1", file:"Ratings_9.0.0-9.0.9_1", title:"9.0.0-9.0.9", originaltitle:"9.0.0-9.0.9"};
		Common.indexes["ratings"]=arr;
		delete arr;
*/

/*********   New sequence added   *************/
		/************** Genres *************/
		arr = new Array();
		i = 0;
		arr[i++]={action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "Genres", originaltitle: "Genres"};
		trace("dataYAMJ3 create indexes genres");
        Common.indexes["genres"]=arr;
		delete arr;
		
		/************** ratings *************/
		arr = new Array();
		i = 0;
		arr[i++] = {action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "Ratings", originaltitle: "Ratings"};
		trace("dataYAMJ3 create indexes ratings");
		Common.indexes["ratings"]=arr;
		delete arr;	
		
		/************** certification *************/
		arr = new Array();
		i = 0;
		arr[i++] = {action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "Certification", originaltitle: "Certification"};
		trace("dataYAMJ3 create indexes certification");
        Common.indexes["certification"]=arr;
		delete arr;

		/************** title *************/
		arr = new Array();
		i = 0;
		arr[i++] = {action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "Title", originaltitle: "Title"};
		trace("dataYAMJ3 create indexes title");
        Common.indexes["title"]=arr;
		delete arr;
		
		
		/************** year *************/
		arr = new Array();
		i = 0;
		arr[i++] = {action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "Year", originaltitle: "Year"};
		trace("dataYAMJ3 create indexes year");
        Common.indexes["year"]=arr;
		delete arr;
		
		
		/************** set *************/
		arr = new Array();
		i = 0;
		arr[i++] = {action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "Set", originaltitle: "Set"};
		trace("dataYAMJ3 create indexes set");
		Common.indexes["set"]=arr;
		delete arr;
		
		
		/************** person *************/
		arr = new Array();
		i = 0;
		arr[i++] = {action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "Person", originaltitle: "Person"};
		trace("dataYAMJ3 create indexes person");
        Common.indexes["person"]=arr;
		delete arr;
		
		/************** lastname-x *************/
	for(var k=0;k<alphabetic.length;k++) {
		var current_alpha = alphabetic.substr(k,1);
		arr = new Array();
		arr[0] = {action: "SWITCH", data: "YAMJ3", file: "YAMJ3", title: "lastname-"+current_alpha, originaltitle: "lastname-"+current_alpha};
		trace("dataYAMJ3 create indexes lastname-" + current_alpha);
        Common.indexes["lastname-"+current_alpha]=arr;
		delete arr;
	}
			
/***** end new sequence added */		
		
		
			// prepare the homelist
			var homedata:Array=new Array();
			var homelist:Array=new Array();
			homelist=Common.esSettings.homelist.split(",");
			for(var i=0;i<homelist.length;i++) {
				trace(".. adding "+homelist[i]+" to home");

				if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
					homedata=homedata.concat(Common.indexes[homelist[i].toLowerCase()]);
					//trace("... success");
				} // else trace("... didn't exist");
			}

			// send it off (if we have something)
			if(homedata.length>0) {
				Common.indexes["homelist"]=homedata;
			}

			// cleaner
			delete homedata;
			delete homelist;

			// prepare the menulist
			homelist=new Array();
			homedata=new Array();
			homelist=Common.esSettings.menulist.split(",");

			for(var i=0;i<homelist.length;i++) {
				trace(".. adding "+homelist[i]+" to menu");

				if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
					homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
				}
			}

			// send it off (if we have something)
			if(homedata.length>0) {
				Common.indexes["menulist"]=homedata;
			}
			
			if(Common.esSettings.userlist!=undefined &&  Common.esSettings.userlist!=null) {
				// prepare the userlist
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings.userlist.split(",");

				for(var i=0;i<homelist.length;i++) {
					trace(".. adding "+homelist[i]+" to userlist");
					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
						trace(".. adding "+homelist[i]+" to userlist");
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
					}
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist"]=homedata;
				}
			}

			if(Common.esSettings.userlist2!=undefined &&  Common.esSettings.userlist2!=null) {
				// prepare the userlist
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings.userlist2.split(",");

				for(var i=0;i<homelist.length;i++) {

					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
						trace(".. adding "+homelist[i]+" to userlist2");
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist2"]=homedata;
				}
			}

			if(Common.esSettings.userlist3!=undefined &&  Common.esSettings.userlist3!=null) {
				// prepare the userlist
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings.userlist3.split(",");

				for(var i=0;i<homelist.length;i++) {
					//trace(".. adding "+homelist[i]+" to user");

					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
						trace(".. adding "+homelist[i]+" to userlist3");
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist3"]=homedata;
				}
			}

			if(Common.esSettings.userlist4!=undefined &&  Common.esSettings.userlist4!=null) {
				// prepare the userlist
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings.userlist4.split(",");

				for(var i=0;i<homelist.length;i++) {
					//trace(".. adding "+homelist[i]+" to user");

					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
						trace(".. adding "+homelist[i]+" to userlist4");
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist4"]=homedata;
				}
			}
			
			if(Common.esSettings.userlist5!=undefined &&  Common.esSettings.userlist5!=null) {
				// prepare the userlist
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings.userlist5.split(",");

				for(var i=0;i<homelist.length;i++) {
					//trace(".. adding "+homelist[i]+" to user");

					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
						trace(".. adding "+homelist[i]+" to userlist5");
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist5"]=homedata;
				}
			}
			
			if(Common.esSettings.userlist6!=undefined &&  Common.esSettings.userlist6!=null) {
				// prepare the userlist
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings.userlist6.split(",");

				for(var i=0;i<homelist.length;i++) {
					//trace(".. adding "+homelist[i]+" to user");

					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
						trace(".. adding "+homelist[i]+" to userlist6");
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist6"]=homedata;
				}
			}
			
			if(Common.esSettings.userlist7!=undefined &&  Common.esSettings.userlist7!=null) {
				// prepare the userlist
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings.userlist7.split(",");

				for(var i=0;i<homelist.length;i++) {
					//trace(".. adding "+homelist[i]+" to user");

					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
						trace(".. adding "+homelist[i]+" to userlist7");
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist7"]=homedata;
				}
			}
			
 /**************** add personlist to display person by alphabetical name 
		for(var i=0;i<alphabetic.length;i++) {
			var current_alpha = alphabetic.substr(i,1);
			if(Common.esSettings["personlist-" + current_alpha]!=undefined &&  Common.esSettings["personlist-" + current_alpha]!=null) {
				// prepare the personlist
				trace(".. prepare personlist-"+current_alpha+" for person");
				homelist=new Array();
				homedata=new Array();
				homelist=Common.esSettings["personlist-" + current_alpha].split(",");

				for(var j=0;j<homelist.length;j++) {
					trace(".. adding "+homelist[j]+" to person");

					if(Common.indexes[homelist[j].toLowerCase()]!= undefined) {
						homedata.push({action:"catlist", arraydata:homelist[j].toLowerCase(), title:Common.evPrompts[homelist[j].toLowerCase()],originaltitle:homelist[j].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["personlist-" + current_alpha]=homedata;
					trace(".. set personlist-"+current_alpha+" in Common indexes");
				}
			}
		}
*************/				
			callBack();

			// cleaner
			delete homedata;
			delete homelist;
	}

	private function originaltitle_fix(testname:String) {
	trace("dataYAMJ3 function originaltitle_fix : " +testname);
		var originalName="UNKNOWN";

		testname=testname.toLowerCase();
		
		//if(testname.indexOf("other") != -1) {
		//	originalName="other";
		//} else
		if(testname.indexOf("genre") != -1) {
			originalName="genre";
		} else if(testname.indexOf("title") != -1) {
			originalName="title";
		} else if(testname.indexOf("certification") != -1) {
			originalName="certification";
		} else if(testname.indexOf("year") != -1) {
			originalName="year";
		} else if(testname.indexOf("library") != -1) {
			originalName="library";
		} else if(testname.indexOf("cast") != -1) {
			originalName="cast";
		} else if(testname.indexOf("director") != -1) {
			originalName="director";
		} else if(testname.indexOf("country") != -1) {
			originalName="country";
		} else if(testname.indexOf("set") != -1) {
			originalName="set";
		} else if(testname.indexOf("award") != -1) {
			originalName="award";
		} else if(testname.indexOf("person") != -1) {
			originalName="person";
		} else if(testname.indexOf("ratings") != -1) {
			originalName="ratings";
		}
	
		return(originalName);
	}

/******** added sequence for new entries like genres *********/
	
	/******* person ********/ 	/******* lastname ********/ 

	

	public function getYAMJ3personIndexData(callBack:Function,Index:String, page) {
		trace("dataYAMJ3 function getYAMJ3personIndexData");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		this.currentChunk = page;
		trace("In getYAMJ3personIndexData with Index" + Index);
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			{callBack("ERROR","getYAMJ3personIndexData: yamj3coreurl undefined or null",null);}
		else
			{	
				if(Index==null || Index==undefined)
					{getDataYAMJ3(yamj3coreurl + "api/index/person.json?sortdir=ASC&dataitems=biography,birthName,artwork&artwork=photo&artworksortdir=DESC&sortby=name&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize + "&max=2500" , callBack, null, this.fn.onGetYAMJ3personIndexData);}
				else
			{
				trace("getYAMJ3personIndexData prepare getDataYAMJ3 with index: " +Index)
				getDataYAMJ3(yamj3coreurl + "api/index/person.json?sortdir=ASC&dataitems=filmography_inside,biography,birthName,artwork&artwork=photo&artworksortdir=DESC&search="+ Index + "&field=last_name&mode=START&sortby=last_name&page="+this.currentChunk+"&perpage=" + ev.Common.evSettings.yamj3chunksize + "&max=2500" , callBack, null, this.fn.onGetYAMJ3personIndexData);
			}
				
			}
	}
	private function onGetYAMJ3personIndexData(success:Boolean, jsonData:Object, callBack:Function) 
	{
		trace("dataYAMJ3 function onGetYAMJ3personIndexData");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				trace ("onGetYAMJ3personIndexData len: " + len)
				for(var i:Number=0;i<len;i++){	
					var birthday_split:Array = jsonData["results"][i]["birthDay"].split("-");
					var tmp_photo:String = jsonData.basePhotoUrl + jsonData["results"][i]["artwork"][0]["filename"];
					 if (jsonData["results"][i]["artwork"][0]["filename"] == undefined || jsonData["results"][i]["artwork"][0]["filename"] == null)
						{tmp_photo = "undefined"}
					trace ("onGetYAMJ3personIndexData results[" + i+ "][name]: " + jsonData["results"][i]["name"])
					var tmp_filmography:String = "";
					var tmp_filmography_len:Number=jsonData["results"][i]["filmography"].length
					for(var j:Number=0;j<tmp_filmography_len;j++){	
						tmp_filmography += jsonData["results"][i]["filmography"][j]["title"] + " (" + jsonData["results"][i]["filmography"][j]["year"] + ")";  
						if (jsonData["results"][i]["filmography"][j]["role"]) 
							{tmp_filmography += " - " + jsonData["results"][i]["filmography"][j]["role"];}
						else {tmp_filmography += " - " + jsonData["results"][i]["filmography"][j]["job"];}
						tmp_filmography += "\n"
						}
					
				//	trace ("onGetYAMJ3personIndexData results[" + i+ "][filmography]: "+ jsonData["results"][i]["filmography"][0]["title"])
					addto.push(
								{action: "SWITCH",
								data: "Person_" + jsonData["results"][i]["id"] + "::" + jsonData["results"][i]["name"] + "_1",
								file: "Person_" + jsonData["results"][i]["id"] + "::" + jsonData["results"][i]["name"] + "_1",
								title: jsonData["results"][i]["name"],
								originaltitle: jsonData["results"][i]["name"],
								photo: tmp_photo,
								birthday: jsonData["results"][i]["birthDay"],
								birthplace: jsonData["results"][i]["birthPlace"],
								biography: jsonData["results"][i]["biography"],
								year: birthday_split[0],
								birthname: jsonData["results"][i]["birthName"],
								filmography: tmp_filmography}
							); 
				}
			callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 onGetYAMJ3PersonIndexData DB access error code: "+jsonData["status"]["message"]+" for 'Person' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 onGetYAMJ3PersonIndexData DB access for \'Person\' error", null);
	}
	
	/******* set ********/ 
	
	public function getYAMJ3setIndexData(callBack:Function) {
		trace("dataYAMJ3 function getYAMJ3setIndexData");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		trace("In getYAMJ3setIndexData");
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack("ERROR","getYAMJ3setIndexData: yamj3coreurl undefined or null",null);
		else
			getDataYAMJ3(yamj3coreurl + "api/boxset/list.json?&sortby=name&sortdir=ASC&dataitems=artwork&artwork=poster", callBack, null, this.fn.onGetYAMJ3setIndexData);
	}
	
	private function onGetYAMJ3setIndexData(success:Boolean, jsonData:Object, callBack:Function) {
		trace("dataYAMJ3 function onGetYAMJ3setIndexData");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				for(var i:Number=0;i<len;i++)			
					addto.push(
								{action: "SWITCH",
								data: "Set_" + jsonData["results"][i]["id"] + "::" + jsonData["results"][i]["name"] + "_1",
								file: "Set_" + jsonData["results"][i]["id"] + "::" + jsonData["results"][i]["name"] + "_1",
								title: jsonData["results"][i]["name"],
								originaltitle: jsonData["results"][i]["name"],
								poster: jsonData.baseArtworkUrl + jsonData["results"][i]["artwork"]["POSTER"][0]["filename"]}
							);       
				callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 onGetYAMJ3setIndexData DB access error code: "+jsonData["status"]["message"]+"for 'Set' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 onGetYAMJ3setIndexData DB access for \'Set\' error", null);
	}
	
	/******* year ********/ 
	
	public function getYAMJ3yearIndexData(callBack:Function) {
		trace("dataYAMJ3 function getYAMJ3yearIndexData");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		trace("In getYAMJ3yearIndexData");
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack("ERROR","getYAMJ3yearIndexData: yamj3coreurl undefined or null",null);
		else
			getDataYAMJ3(yamj3coreurl + "api/video/decades/list.json?type=movie,series", callBack, null, this.fn.onGetYAMJ3yearIndexData);
	}
	private function onGetYAMJ3yearIndexData(success:Boolean, jsonData:Object, callBack:Function) {
		trace("dataYAMJ3 function onGetYAMJ3yearIndexData");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				for(var i:Number=0;i<len;i++)			
					addto.push(	
								{action: "SWITCH",
								data: "Year_" + jsonData["results"][i]["decade"] + "_1",
								file: "Year_" + jsonData["results"][i]["decade"] + "_1",
								title: jsonData["results"][i]["decade"],
								originaltitle: jsonData["results"][i]["decade"]}
                    
							); 
				callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 onGetYAMJ3yearIndexData DB access error code: "+jsonData["status"]["message"]+"for 'Year' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 onGetYAMJ3yearIndexData DB access for \'Year\' error", null);
	} 
	
	/******* title ********/ 
	
	public function getYAMJ3titleIndexData(callBack:Function) {
		trace("dataYAMJ3 function getYAMJ3titleIndexData");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		trace("In getYAMJ3titleIndexData");
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack("ERROR","getYAMJ3titleIndexData: yamj3coreurl undefined or null",null);
		else
			this.getDataYAMJ3(yamj3coreurl + "api/alphabetical/list.json?type=movie,series", callBack, null, this.fn.onGetYAMJ3titleIndexData);
	}
	
	private function onGetYAMJ3titleIndexData(success:Boolean, jsonData:Object, callBack:Function) {
		trace("dataYAMJ3 function onGetYAMJ3titleIndexData");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				for(var i:Number=0;i<len;i++)			
					addto.push(
								{action: "SWITCH",
								data: "Title_" + jsonData["results"][i]["name"] + "_1",
								file: "Title_" + jsonData["results"][i]["name"] + "_1",
								title: jsonData["results"][i]["name"],
								originaltitle: jsonData["results"][i]["name"]}
							); 
				callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 onGetYAMJ3titleIndexData DB access error code: "+jsonData["status"]["message"]+"for 'Title' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 onGetYAMJ3titleIndexData DB access for \'Title\' error", null);
	}
		

	/******* ratings ********/ 
	
	public function getYAMJ3ratingsIndexData(callBack:Function) {
		trace("dataYAMJ3 function getYAMJ3ratingsIndexData");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		trace("In getYAMJ3ratingsIndexData");
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack("ERROR","getYAMJ3ratingsIndexData: yamj3coreurl undefined or null",null);
		else
			getDataYAMJ3(yamj3coreurl + "api/ratings/list.json?type=movie,series&source=combined", callBack, null, this.fn.onGetYAMJ3ratingsIndexData);
	}
	
	private function onGetYAMJ3ratingsIndexData(success:Boolean, jsonData:Object, callBack:Function) {
		trace("dataYAMJ3 function onGetYAMJ3ratingsIndexData");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				for(var i:Number=0;i<len;i++)			
					addto.push(
								{action: "SWITCH",
								data: "Ratings_" + jsonData["results"][i]["rating"] + "_1",
								file: "Ratings_" + jsonData["results"][i]["rating"] + "_1",
								title: jsonData["results"][i]["rating"],
								originaltitle: jsonData["results"][i]["rating"]}
							); 
				callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 onGetYAMJ3ratingsIndexData DB access error code: "+jsonData["status"]["message"]+"for 'Ratings' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 onGetYAMJ3ratingsIndexData DB access for \'Ratings\' error", null);
	}
	
	/******* genres ********/ 
	
	public function getYAMJ3genresIndexData(callBack:Function) {
		trace("dataYAMJ3 function getYAMJ3genresIndexData");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		trace("In getYAMJ3genresIndexData");
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack("ERROR","getYAMJ3genresIndexData: yamj3coreurl undefined or null",null);
		else
			getDataYAMJ3(yamj3coreurl + "api/genres/list.json", callBack, null, this.fn.onGetYAMJ3genresIndexData);
		}
	
	private function onGetYAMJ3genresIndexData(success:Boolean, jsonData:Object, callBack:Function) {
		trace("dataYAMJ3 function onGetYAMJ3genresIndexData");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				for(var i:Number=0;i<len;i++)			
					addto.push(
								{action: "SWITCH",
								data: "Genres_" + jsonData["results"][i]["name"] + "_1",
								file: "Genres_" + jsonData["results"][i]["name"] + "_1",
								title: jsonData["results"][i]["name"],
								originaltitle: jsonData["results"][i]["name"]}	
							); 
				callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 onGetYAMJ3genresIndexData DB access error code: "+jsonData["status"]["message"]+"for 'Genres' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 onGetYAMJ3genresIndexData DB access for \'Genres\' error", null);
	}

	/******* certification ********/ 
	
	public function getYAMJ3certificationIndexData(callBack:Function) {
		trace("dataYAMJ3 function getYAMJ3certificationIndexData");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		trace("In getYAMJ3certificationIndexData");
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack("ERROR","getYAMJ3certificationIndexData: yamj3coreurl undefined or null",null);
		else
			getDataYAMJ3(yamj3coreurl + "api/certifications/list.json?&type=movie,series&sortby=certificate&sortdir=ASC", callBack, null, this.fn.onGetYAMJ3certificationIndexData);
	}
	
	private function onGetYAMJ3certificationIndexData(success:Boolean, jsonData:Object, callBack:Function) {
		trace("dataYAMJ3 function onGetYAMJ3certificationIndexData");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				for(var i:Number=0;i<len;i++)			
					addto.push(
							{action: "SWITCH",
								data: "Certification_" + jsonData["results"][i]["country"] + " " + jsonData["results"][i]["certificate"] + "::" + jsonData["results"][i]["id"] + "_1",
								file: "Certification_" + jsonData["results"][i]["country"] + " " + jsonData["results"][i]["certificate"] + "::" + jsonData["results"][i]["i"] + "_1",
								title: jsonData["results"][i]["country"] + "::" + jsonData["results"][i]["certificate"],
								originaltitle: jsonData["results"][i]["country"] + "::" + jsonData["results"][i]["certificate"],
								certification: jsonData["results"][i]["certificate"],
								flagcertification: jsonData["results"][i]["countryCode"]			
								}
							); 
				callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 onGetYAMJ3certificationIndexData DB access error code: "+jsonData["status"]["message"]+"for 'Certification' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 onGetYAMJ3certificationIndexData DB access for \'Certification\' error", null);
	}


/************end new sequence for news entries **************/


	
	// Load/get information about an index
	public function getIndexInfo(url:String, callBack:Function):Void {
		trace("dataYAMJ3 function getIndexInfo url: "+url);

		if(url != null) {
			// figure out the temp types we need to use filename to find
			var tmp:Array = url.split("_",4);
			this.baseIndex=tmp[0];
			this.indexCategory=tmp[1];
			var split_category:Array = tmp[1].split("::",2);
			this.indexName=tmp[1];
			this.indexOriginalName=this.indexCategory;
			this.currentChunk=int(tmp[2]);
			this.yamj3Id=int(tmp[3]);
		 // trace( "getIndexInfo url:" + url + " baseIndex: " + tmp[0] + " indexCategory: " + tmp[1] + " currentChunk: " + tmp[2] + " yamj3Id: " + tmp[3]);
		
		if (url.indexOf("Set") != -1 ) 
			{
				this.indexTypeTemp = "set";
				this.yamj3Id = split_category[0];
				this.indexName = split_category[1];
			}
			else if (url.indexOf("Other_3D") != -1 ) 
					{
						this.indexTypeTemp = "3D";
					}
			else if (url.indexOf("Other_HD") != -1 ) 
					{
						this.indexTypeTemp = "HD";
					}
			else if (url.indexOf("Other_Unwatched") != -1 ) 
					{
						this.indexTypeTemp = "UNWATCHED";
					}
			else if (url.indexOf("Other_Watched") != -1 ) 
					{
						this.indexTypeTemp = "WATCHED";
					}
			else if (url.indexOf("Other_People") != -1 ) 
					{
						this.indexTypeTemp = "PEOPLE";
					}
			else if (url.indexOf("Other_Sets") != -1 ) 
					{
						this.indexTypeTemp = "SETS";
					}		
			else if (url.indexOf("Rating-1") != -1 ) 
					{
						this.indexTypeTemp = "rating-1";
					}
			else if (url.indexOf("Rating-2") != -1 ) 
					{
						this.indexTypeTemp = "rating-2";
					}
			else if (url.indexOf("Rating-3") != -1 ) 
					{
						this.indexTypeTemp = "rating-3";
					}
			else if (url.indexOf("Rating-4") != -1 ) 
					{
						this.indexTypeTemp = "rating-4";
					}
			else if (url.indexOf("Rating-5") != -1 ) 
					{
						this.indexTypeTemp = "rating-5";
					}
			else if (url.indexOf("Rating-6") != -1 ) 
					{
						this.indexTypeTemp = "rating-6";
					}
			else if (url.indexOf("Rating-7") != -1 ) 
					{
						this.indexTypeTemp = "rating-7";
					}
			else if (url.indexOf("Rating-8") != -1 ) 
					{
						this.indexTypeTemp = "rating-8";
					}
			else if (url.indexOf("Rating-9") != -1 ) 
					{
						this.indexTypeTemp = "rating-9";
					}
			else if (url.indexOf("Rating-10") != -1 ) 
					{
						this.indexTypeTemp = "rating-10";
					}
			else if (url.indexOf("Title") != -1 ) 
					{
						this.indexTypeTemp = "title";
					}
			else if (url.indexOf("Year") != -1 ) 
					{
						this.indexTypeTemp = "year";
					}
			else if (url.indexOf("Certification") != -1 ) 
					{
						this.indexTypeTemp = "CERTIFICATION";
						this.yamj3Id = split_category[1];
						this.indexName = split_category[0];
					}
			else if (url.indexOf("Person") != -1 ) 
					{
						this.indexTypeTemp = "person";
						this.yamj3Id = split_category[0];
						this.indexName = split_category[1];
					}
			
			
		else {
			if(url.indexOf("Other_New-TV") != -1) {
				trace("dataYAMJ3 getIndexInfo NEWTV index");
				this.indexTypeTemp="NEWTV";
			} else if(url.indexOf("Other_TV") != -1 || url.indexOf("Library_TV") != -1){
				trace("dataYAMJ3 getIndexInfo TV index");
				this.indexTypeTemp="TV";
			} else if(url.indexOf("Other_Movie") != -1 || url.indexOf("Library_Movie") != -1) {
				trace("dataYAMJ3 getIndexInfo Movie index");
				this.indexTypeTemp="MOVIE";
			} else if(url.indexOf("Other_New-Movie") != -1) {
				trace("dataYAMJ3 getIndexInfo NEWMOVIE index");
				this.indexTypeTemp="NEWMOVIE";
			} else if(url.indexOf("Other_New_") != -1 || url.indexOf("Library_New") != -1) {
				trace("dataYAMJ3 getIndexInfo NEW index");
				this.indexTypeTemp="NEW";
			} else if(url.indexOf("TVSET_") != -1) {
				trace("dataYAMJ3 getIndexInfo TVSET index");
				this.indexTypeTemp="TVSET";
			} else if(url.indexOf("Person_") != -1 || url.indexOf("Writer_") != -1 || url.indexOf("Director_") != -1 || url.indexOf("Cast_") != -1) {
				trace("dataYAMJ3 getIndexInfo PEOPLE index");
				this.indexTypeTemp="PEOPLE";
			} else {
				trace("dataYAMJ3 getIndexInfo generic INDEX or possible unknown rename");
				this.indexTypeTemp="INDEX";
			}
		}
		//	this.indexName=this.indexCategory;
		//  callBack(null, "getIndexInfo url:" + url + " baseIndex: " + tmp[0] + " indexCategory: " + tmp[1] + " currentChunk: " + tmp[2] + " yamj3Id: " + tmp[3]);
			trace( "YAMJ3 getIndexInfo url:" + url + " baseIndex: " + this.baseIndex + " indexCategory: " + this.indexCategory + " currentChunk: " + this.currentChunk + " yamj3Id: " + this.yamj3Id);
		
		this.infoProcessing=true;
			getIndex(callBack);
		} else {
			// return with error
			callBack(null, Common.evPrompts.enoindexfilename);
		}
	}
	
	public function getData(indexChunk:Number, callBack:Function):Void {
		trace ("dataYAMJ3 function getData indexChunk: " + indexChunk);
		this.currentChunk=indexChunk;
		this.infoProcessing=false;
		getIndex(callBack);
	}

	private function getIndex(callBack:Function):Void {
		trace ("dataYAMJ3 function getIndex");
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		var yamj3preferedtitletype = ev.Common.evSettings["yamj3preferedtitletype"];
		var title_sort:String = "title";
		
		switch(yamj3preferedtitletype) {
				case "title" :
				title_sort = "title"
				break;
				case "title_sort" :
				title_sort = "sortTitle"
				break;
				case "title_original" :
				title_sort = "originalTitle"
				break;
		}
		trace("dataYAMJ3 function getIndex yamj3preferedtitletype: " + yamj3preferedtitletype + " title_sort: " + title_sort);
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			{callBack(null, Common.evPrompts.enoindexfilename);}
			
		// specific index based on base Index
		if (this.baseIndex != "Other")
		{
			trace ("dataYAMJ3 function getIndex baseIndex: " + this.baseIndex);
			switch(this.baseIndex) {
				case "All" :
				this.getDataYAMJ3(yamj3coreurl+"api/index/video.json?type=MOVIE,SERIES&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize+"&artwork=poster,fanart&dataitems=status,plot,outline,rating,certification,award&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
				break;
				case "Genres" :
				this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&include=genre-" + this.indexCategory + "&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
				break;
				case "Ratings" :
				this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&include=rating-" + this.indexCategory + "&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
				break;
				case "Certification" :
				this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&include=certification-" + this.yamj3Id + "&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
				break;
				case "Title" :
			//	 this.getDataYAMJ3(yamj3coreurl + "api/index/person.json?sortdir=ASC&dataitems=artwork&artwork=photo&artworksortdir=DESC&search=" + this.indexCategory + "B&field=name&mode=START&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize , callBack, null, this.fn.onGetIndex_getDetails);
				this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&search=" + this.indexCategory + "&field=" + Common.evSettings.yamj3preferedtitletype + "&mode=START&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
				break;
				case "Year" :
				var __reg3 = Number(this.indexCategory) + 9; 
				this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&search=&yearStart=" + this.indexCategory + "&yearEnd=" +  __reg3 + "&field=title&mode=START&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
				break;
				case "Set" :
			//	 callBack(null, "this.indexCategory: " + this.indexCategory);
				this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&include=boxset-" + this.yamj3Id + "&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&dataitems=status,boxset,rating,certification,videosource,plot,outline,rating,certification&sortby=videoYear DESC,createTimestamp DESC&artwork=poster,fanart", callBack, null, this.fn.onGetIndex_getDetails);
				break;

				case "Person" :
			//	callBack(null, "YAMJ3 getIndex this.yamj3Id" + this.yamj3Id);
				this.getDataYAMJ3(yamj3coreurl + "api/person/" + this.yamj3Id + ".json?&dataitems=filmography_inside,artwork&artwork=photo&artworksortdir=DESC&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize, callBack, null, this.fn.onGetIndexPerson);
				break;
			default:
				break;
			}
		}
		
			// specific index
			if(this.indexTypeTemp=="TVSET") {
				trace ("function getIndex indexTypeTemp: " + this.indexTypeTemp);
				//TV SET - yamj3Id is the seriesId
				if(this.yamj3Id!=undefined || this.yamj3Id!=null)
		//			callBack(null, "getIndex this.yamj3Id:" + this.yamj3Id + " baseIndex: " + this.baseIndex + " indexCategory: " + this.indexCategory );
					getDataYAMJ3(yamj3coreurl+"api/video/seriesinfo.json?id="+this.yamj3Id+"&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize, callBack, null, this.fn.onGetIndex_getDetailsSeriesInfo);
			}
			else if(this.indexTypeTemp=="PEOPLE") {
				trace ("function getIndex indexTypeTemp: " + this.indexTypeTemp  )
				// TODO fix Person index
				// callBack(null, "Unsupported index: "+this.indexCategory);
				if(this.yamj3Id!=undefined || this.yamj3Id!=null) {
					switch(this.indexCategory) {
						default:
							// yamj3Id is person_id
							this.getDataYAMJ3(yamj3coreurl + "api/video/seriesinfo.json?id=" + this.yamj3Id + "&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize, callBack, null, this.fn.onGetIndex_getDetailsSeriesInfo);
							break;
					}
				}
			}
		
			else {
				// all other_xx
				// have the first page loaded 
				trace ("function getIndex indexCategory: " + this.indexCategory);
				switch(this.indexCategory) {
					case "All" :
						this.getDataYAMJ3(yamj3coreurl+"api/index/video.json?type=MOVIE,SERIES&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize+"&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification,award&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
			        case "Movies" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart&dataitems=status,plot,outline,rating,certification,award&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "New-Movies" :
					case "New-MOVIES" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart&dataitems=status,plot,outline,rating,certification,award&sortby=videoYear DESC,createTimestamp DESC&watched=all&include=newest-80-file", callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "New-TV" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification,award&sortby=videoYear DESC,createTimestamp DESC&watched=all&include=newest-80-file", callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "TV Shows" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "Top250" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification,award&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "New" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline,rating,certification,award&sortby=videoYear DESC,createTimestamp DESC&watched=all&include=newest-80-file", callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "3D" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart&dataitems=status,plot,outline,rating,certification,award&include=videosource-3D&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "HD" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart&dataitems=status,plot,outline,rating,certification,award&include=resolution-hd&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "Unwatched" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart&dataitems=status,plot,outline,rating,certification,award&watched=false&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "Watched" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart&dataitems=status,plot,outline,rating,certification,award&watched=true&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "Sets" :
					   this.getDataYAMJ3(yamj3coreurl + "api/boxset/list.json?&sortby=name&sortdir=DESC&dataitems=artwork&artwork=poster&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize, callBack, null, this.fn.onGetIndex_getDetails);
						break;
					case "Rating-1" :
					case "Rating-2" :
					case "Rating-3" :
					case "Rating-4" :
					case "Rating-5" :
					case "Rating-6" :
					case "Rating-7" :
					case "Rating-8" :
					case "Rating-9" :
					case "Rating-10" :
						this.getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=MOVIE,SERIES&include=" + this.indexCategory.toLowerCase() + "-combined&page=" + this.currentChunk + "&perpage=" + ev.Common.evSettings.yamj3chunksize + "&artwork=poster,fanart,banner&dataitems=status,plot,outline&sortby=" + title_sort , callBack, null, this.fn.onGetIndex_getDetails);
						break;
					default:
					// check if this is not a movie from a set formated like index::name
					//	if (this.indexCategory.indexOf("::") == -1)
					//	callBack(null, "Unsupported index: "+this.indexCategory);
						break;
					}
				} 
				return;
			
		
	}
	
	private function onGetIndex_getDetails(success:Boolean, jsonData:Object, callBack:Function, data:Object) {
		trace("dataYAMJ3 function onGetIndex_getDetails");
		if(success) {
			if(jsonData["status"]["status"] == 200)
			{
				var len:Number = jsonData["results"].length;
				this.getDetailsCount=len;
				this.tmpJsonData=jsonData;
				for(var i=0;i<len;++i) {
					getDetailsSeasons(i, callBack);
				}
			}
			else if (jsonData["status"]["status"] == 404)
				callBack(null, "YAMJ3 onGetIndex_getDetails : "+jsonData["status"]["message"]+" for " + this.indexCategory);
		}
		else
			callBack(null, "YAMJ3 onGetIndex_getDetails DB access for getIndexInfo/getData error");
	}

	private function getDetailsSeasons(passthroughData:Object, callBack:Function) {
		trace("dataYAMJ3 function getDetailsSeasons baseIndex " + this.baseIndex);
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		var i=Number(passthroughData);
		if (this.baseIndex === "Person")
		{
	//	callBack(null, "YAMJ3 getDetailsSeasons this.tmpJsonDataPerson[i]['type']" + this.tmpJsonDataPerson[i]["type"] + " this.baseIndex " + this.baseIndex);
			if (this.tmpJsonDataPerson[i]["type"] == "SERIES") 
			{
				getDataYAMJ3(yamj3coreurl + "api/video/seriesinfo.json?id=" + this.tmpJsonDataPerson[i]["seriesId"] + "&dataitems=status,plot,outline,artwork,rating,certification&artwork=all", callBack, passthroughData, this.fn.onGetDetailsSeasons);
				return;
			}
			onGetDetailsSeasons(true, null, callBack, passthroughData);
		}
		else if(this.tmpJsonData["results"][i]["videoType"] == "SERIES")
			{getDataYAMJ3(yamj3coreurl + "api/video/seriesinfo.json?id=" + this.tmpJsonData["results"][i]["id"] + "&dataitems=status,plot,outline,artwork,rating,certification&artwork=all", callBack, passthroughData, this.fn.onGetDetailsSeasons);}
		else
			{
	//	if (this.baseIndex === "Person") {	callBack(null, "YAMJ3 getDetailsSeasons this.tmpJsonDataPerson[i]['type']" + this.tmpJsonDataPerson[i]["type"] + " this.baseIndex " + this.baseIndex);}
				onGetDetailsSeasons(true, null, callBack, passthroughData);
				
			}
	}

	private function onGetDetailsSeasons(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		trace("dataYAMJ3 function onGetDetailsSeasons baseIndex " + this.baseIndex);
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		var i=Number(passthroughData);
		var yamj3preferedtitletype = ev.Common.evSettings["yamj3preferedtitletype"];
		var title_sort:String = "title";
		
		switch(yamj3preferedtitletype) {
				case "title" :
				title_sort = "title"
				break;
				case "title_sort" :
				title_sort = "sortTitle"
				break;
				case "title_original" :
				title_sort = "originalTitle"
				break;
		}
		trace("dataYAMJ3 function onGetDetailsSeasons yamj3preferedtitletype: " + yamj3preferedtitletype + " title_sort: " + title_sort);
		if(success && jsonData!=null)
		{
			if (this.baseIndex === "Person")
			{
				if (i === 0) 
				{
					var __reg7 = new Array();
					this.tmpJsonDataPersonSeries = {results: __reg7};
					this.tmpJsonDataPersonSeries[i] = jsonData["results"][0];
					trace("onGetDetailsSeasons this.tmpJsonDataPersonSeries[i].results[0].seasonList[0].sortTitle" + this.tmpJsonDataPersonSeries[i]["seasonList"][0]["sortTitle"]);
				
				//	callBack(null, "YAMJ3 onGetDetailsSeasons this.tmpJsonDataPersonSeries[i].results[0].seasonList[0].sortTitle" + this.tmpJsonDataPersonSeries[i]["seasonList"][0]["sortTitle"]);
				}
			}
			else 
			{this.tmpJsonData["results"][i]["seasonList"] = jsonData["results"][0]["seasonList"];}
		}
		if (this.baseIndex === "Person")
			{
			 //  if (this.tmpJsonDataPerson[i]["videodataId"] === "undefined" || this.tmpJsonDataPerson[i]["seriesId"] === "undefined") {return;}
			   if (this.tmpJsonDataPerson[i]["type"] === "MOVIE") 
					{
						trace ("onGetDetailsSeasons this.tmpJsonDataPerson[i].videodataId" + this.tmpJsonDataPerson[i].videodataId + " this.tmpJsonDataPerson[i].type: " + this.tmpJsonDataPerson[i].type);
					//	 callBack(null, "YAMJ3 onGetDetailsSeasons this.tmpJsonDataPerson[i].videodataId" + this.tmpJsonDataPerson[i].videodataId + " this.tmpJsonDataPerson[i].type: " + this.tmpJsonDataPerson[i].type);
						getDataYAMJ3(yamj3coreurl + "api/video/movie/" + this.tmpJsonDataPerson[i]["videodataId"]+ ".json?dataitems=status,plot,genre,files,rating,certification,studio,country,artwork,award&artwork=poster,fanart&sortby=" + title_sort , callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
						return;
					}
			   else if (this.tmpJsonDataPerson[i].type === "SERIES")
					{
						trace ( "onGetDetailsSeasons this.tmpJsonDataPerson[i].seriesId" + this.tmpJsonDataPerson[i].seriesId + " this.tmpJsonDataPerson[i].type: " + this.tmpJsonDataPerson[i].type);
					//	 callBack(null, "YAMJ3 onGetDetailsSeasons this.tmpJsonDataPerson[i].seriesId" + this.tmpJsonDataPerson[__reg2].seriesId + " this.tmpJsonDataPerson[i].type: " + this.tmpJsonDataPerson[i].type);
						getDataYAMJ3(yamj3coreurl + "api/video/series/" + this.tmpJsonDataPerson[i]["seriesId"] + ".json?dataitems=status,genre,files,rating,certification,studio,country,artwork&artwork=all&sortby=" + title_sort , callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
						return;
					}
				return;
			}
		else if(this.tmpJsonData["results"][i]["genreCount"]==0 || this.tmpJsonData["results"][i]["genreCount"]==undefined)
		{	
			trace("dataYAMJ3 function onGetDetailsSeasons this.tmpJsonData['results'][" + i + "]['videoType']" + this.tmpJsonData["results"][i]["videoType"]);
			switch(this.tmpJsonData["results"][i]["videoType"]) {
				case 'MOVIE':
					getDataYAMJ3(yamj3coreurl+"api/video/movie/"+this.tmpJsonData["results"][i]["id"]+".json?dataitems=status,genre,files,rating,studio,country,certification,award,artwork&artwork=all", callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
					break;
				case 'SERIES':
					getDataYAMJ3(yamj3coreurl+"api/video/series/"+this.tmpJsonData["results"][i]["id"]+".json?dataitems=status,genre,files,rating,certification,studio,country,artwork&artwork=all", callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
					break;
				default:
					switch (this.indexTypeTemp) {
					case 'Sets':
					getDataYAMJ3(yamj3coreurl+"api/video/movie/"+this.tmpJsonData["results"][i]["id"]+".json?dataitems=status,genre,files,rating,certification,studio,country,award,artwork&artwork=all", callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
					break;
					case 'PEOPLE':
					//	 callBack(null, "YAMJ3 onGetDetailsSeasons PEOPLE i: " + i + " this.tmpJsonData['results'][i]['id']" + this.tmpJsonData["results"][i]["id"] + " photo: " + ev.Common.yamj3photourl + this.tmpJsonData["results"][i]["artwork"][0]["filename"]);
					onGetDetailsGenresFiles(true, null, callBack, passthroughData);
					//	this.getDataYAMJ3(yamj3coreurl + "api/person/" + this.tmpJsonData["results"][i]["id"] + ".json?&dataitems=status,filmography_inside,artwork&artwork=photosortdir=DESC", callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
						break;
					default:
					onGetDetailsGenresFiles(true, null, callBack, passthroughData);
				}
			}
		}
	}
	
	private function onGetDetailsGenresFiles(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		trace("dataYAMJ3 function onGetDetailsGenresFiles");
		if(success && jsonData!=null) {
			var i=Number(passthroughData);
			if (this.baseIndex === "Person")
			{
				if (i === 0) 
				{
					var __reg7 = new Array();
					this.tmpJsonData = {totalCount: this.getDetailsCount, results: __reg7};
				}
			this.tmpJsonData["results"][i] = jsonData["result"];
			if (this.tmpJsonData["results"][i]["videoType"] === "SERIES")
			{
				this.tmpJsonData["results"][i]["seasonList"] = this.tmpJsonDataPersonSeries[i]["seasonList"] ;
			}
		//	callBack(null, "YAMJ3 reg3: " + i + " onGetDetailsGenresFiles this.tmpJsonData.results[i].seasonList[0].sortTitle" + this.tmpJsonData.results[i].seasonList[0].sortTitle );
		//	callBack(null, "YAMJ3 reg3: " + i + " onGetDetailsGenresFiles this.tmpJsonData.results[i].id" + this.tmpJsonData.results[i].id );
			}
			else {
			this.tmpJsonData["results"][i]["genreCount"]=jsonData["result"]["genreCount"];
			this.tmpJsonData["results"][i]["genres"]=jsonData["result"]["genres"];
			this.tmpJsonData["results"][i]["files"]=jsonData["result"]["files"];
			this.tmpJsonData["results"][i]["ratings"]=jsonData["result"]["ratings"];
			this.tmpJsonData["results"][i]["studios"]=jsonData["result"]["studios"];
			this.tmpJsonData["results"][i]["countries"]=jsonData["result"]["countries"];
			}
		}
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		var i=Number(passthroughData);
		if (this.baseIndex === "Person")
		{
			if (this.tmpJsonData["results"][i]["videoType"] === "MOVIE")
				{
				trace("onGetDetailsGenresFiles i: " + i + " this.tmpJsonData.results[i].id" + this.tmpJsonData["results"][i]["id"]);
					this.getDataYAMJ3(yamj3coreurl + "api/person/movie.json?id=" + this.tmpJsonData["results"][i]["id"] + "&dataitems=status,artwork", callBack, passthroughData, this.fn.onGetDetailsPeople);
					return;
				}
			else if (this.tmpJsonData["results"][i]["videoType"] === "SERIES") 
				{
				//    this.getDataYAMJ3(yamj3coreurl + "api/person/series.json?id=" + this.tmpJsonData["results"][i]["id"] + "&dataitems=status,artwork", callBack, passthroughData, this.fn.onGetDetailsPeople);
					this.onGetDetailsPeople(true, null, callBack, passthroughData);
				   return;
				}
		}
		//	callBack(null, "onGetDetailsGenresFiles reg3: " + __reg3 + " onGetDetailsGenresFiles this.tmpJsonData.results[__reg3].id" + this.tmpJsonData.results[__reg3].id);
		if (this.indexCategory === "PEOPLE") 
        {
			trace("onGetDetailsGenresFiles this.tmpJsonData.results[i].id" + this.tmpJsonData["results"][i]["id"]);
			onGetDetailsPeople(true, null, callBack, passthroughData);
			return;
		}
		else {
		trace("onGetDetailsGenresFiles this.tmpJsonData['results'][" + i + "]['videoType']" + this.tmpJsonData["results"][i]["videoType"]);
		switch(this.tmpJsonData["results"][i]["videoType"]) {
			case 'MOVIE':
				getDataYAMJ3(yamj3coreurl+"api/person/movie.json?id="+this.tmpJsonData["results"][i]["id"]+"&dataitems=status,artwork", callBack, passthroughData, this.fn.onGetDetailsPeople);
				break;
			case 'SERIES':
				getDataYAMJ3(yamj3coreurl+"api/person/series.json?id="+this.tmpJsonData["results"][i]["id"]+"&dataitems=status,artwork", callBack, passthroughData, this.fn.onGetDetailsPeople);
			//	onGetDetailsPeople(true, null, callBack, passthroughData);
				break;
			default:
				trace("onGetDetailsGenres - unhandled videoType: "+this.tmpJsonData["results"][i]["videoType"]);
				onGetDetailsPeople(true, null, callBack, passthroughData);
			}
		}
	
	}
	
	private function onGetDetailsPeople(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		trace("dataYAMJ3 function onGetDetailsPeople");
		if(success && jsonData!=null) {
			var i=Number(passthroughData);
			if (this.baseIndex === "Person")
			{	
				this.tmpJsonData["results"][i]["people"] = jsonData["results"];
				//if (i === this.getDetailsCount) {callBack(null, "YAMJ3 i: " + i + " onGetDetailsPeople this.tmpJsonData.results[i].people[0].id " + this.tmpJsonData["results"][i]["people"][0]["id"] + "  this.tmpJsonData.results[i].id: " +  this.tmpJsonData["results"][i]["id"]);}
			}
			else {this.tmpJsonData["results"][i]["people"]=jsonData["results"];}
			
		}
		--this.getDetailsCount;
		if(this.getDetailsCount==0)
			onGetIndex(success, callBack);
	}
	
	private function onGetIndex(success:Boolean, callBack:Function):Void {
		trace("dataYAMJ3 function onGetIndex");
		if(success) {
			if(this.infoProcessing) {
				var total=int(this.tmpJsonData["totalCount"]);
				var count=Common.evSettings.yamj3chunksize;
				var pages=Math.ceil(total/count);
				trace("onGetIndex if id: " + this.tmpJsonData["results"][0]["id"] + " Name: " +  this.indexName + " temp : " + this.indexTypeTemp +  " page: " + pages + " total: " + total +  " originalname : " + this.indexOriginalName); 

				callBack(
					this.tmpJsonData["results"],
					this.indexName,
					this.indexTypeTemp,
					pages,
					total,
					this.indexOriginalName);
			}
			else
				{trace("onGetIndex else: " + this.tmpJsonData["results"][0]["id"] + " Name: " +  this.indexName + " temp : " + this.indexTypeTemp +  " page: " + pages + " total: " + total +  " originalname : " + this.indexOriginalName); 
				callBack(this.tmpJsonData["results"],this.currentChunk);}
		}
		else
			callBack(null, "YAMJ3 DB access for GetIndexInfo/GetData error");
	}
	
	private function onGetIndex_getDetailsSeriesInfo(success:Boolean, jsonData:Object, callBack:Function, data:Object) {
		trace("dataYAMJ3 function onGetIndex_getDetailsSeriesInfo");
		if(success) {
			if(jsonData["status"]["status"] == 200){
				if (this.indexCategory === "Sets") 
					{
						var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
						var a_sets:Array = new Array();
						var len_sets = jsonData["results"].length;
						this.tmpJsonData = {totalCount: len_sets, results: a_sets};
						this.getDetailsCount = len_sets;
						for(var i=0;i<len_sets;++i) {
							getDataYAMJ3(yamj3coreurl + "api/index/video.json?type=movie&watched=all&include=boxset-" + jsonData["results"][i]["id"] + "&dataitems=status,artwork&artwork=poster" , callBack, i, this.fn.onGetDetailsSeasons2);
						}
					}
				else if (this.baseIndex === "Person")		
					{
						var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
						var a_person:Array = new Array();
						var len_person:Number = jsonData["results"][0]["seasonList"].length;
						this.tmpJsonData = {totalCount: len_person, results: a_person};
						this.getDetailsCount = len_person;
						for(var i=0;i<len_person;++i) {
							getDataYAMJ3(yamj3coreurl + "api/video/season/" + jsonData["results"][0]["seasonList"][i]["seasonId"] + ".json?dataitems=status,artwork,plot,outline,files&artwork=all", callBack, i, this.fn.onGetDetailsSeasons2);	
						}
					}
			else
			{
				var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
				var a:Array = new Array();
				var len:Number = jsonData["results"][0]["seasonList"].length;
				this.tmpJsonData = {totalCount:len , results:a};
				this.getDetailsCount=len;
				for(var i=0;i<len;++i) {
					getDataYAMJ3(yamj3coreurl + "api/video/season/" + jsonData["results"][0]["seasonList"][i]["seasonId"] + ".json?dataitems=status,artwork,plot,outline,files&artwork=all", callBack, i, this.fn.onGetDetailsSeasons2);
					}
			}
		}
		else {callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+"for getIndexInfo/getData");}
		return;
		}
		callBack(null, "YAMJ3 DB access for getIndexInfo/getData error");
	}
	
	private function onGetDetailsSeasons2(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		trace("dataYAMJ3 function onGetDetailsSeasons2");
		if(success && jsonData!=null) {
			var i=Number(passthroughData);
			var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
			this.tmpJsonData["results"][i]=jsonData["result"];
			getDataYAMJ3(yamj3coreurl+"api/person/season.json?id="+this.tmpJsonData["results"][i]["id"]+"&dataitems=status,artwork", callBack, passthroughData, this.fn.onGetDetailsPeople);
			//	onGetDetailsPeople(true, null, callBack, passthroughData);
				break;
		}
		--this.getDetailsCount;
		if(this.getDetailsCount==0)
			onGetIndex(success, callBack);
	}

	
	private function onGetIndexPerson(success:Boolean, jsonData:Object, callBack:Function, data:Object) {
		trace("dataYAMJ3 function onGetIndexPerson");
		if(success) {
			if(jsonData["status"]["status"] == 200)
			{
				this.tmpJsonDataPerson2 = jsonData;
                this.tmpJsonDataPerson2["results"] = new Array();
                this.tmpJsonDataPerson2["results"][0] = jsonData["result"];
				this.indexName = jsonData["result"]["name"];
				this.indexOriginalName = jsonData["result"]["name"];
			//	callBack(null, "YAMJ3 DB onGetIndexPerson sucess");
			//	this.onGetDetailsPersonFiles(success, this.tmpJsonData, callBack, passthroughData);
				onGetPerson_getDetails(success, this.tmpJsonDataPerson2, callBack, data);
			}
			else {callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+" for getIndexInfo/getData");}
			return;
		}
		else
			callBack(null, "YAMJ3 DB access for getIndexInfo/getData error");
	}
/************** New sequence for Person ********************/

	private function onGetPerson_getDetails(success:Boolean, jsonData:Object, callBack:Function, data:Object) 
    {   
				trace("dataYAMJ3 function onGetPerson_getDetails");
				this.tmpJsonDataPerson = this.tmpJsonDataPerson2["results"][0]["filmography"];
				var len:Number = this.tmpJsonDataPerson.length;
				this.getDetailsCount = len;

			//	 callBack(null, "YAMJ3 DB onGetPerson_getDetails len: " + len);
               for(var i=0;i<len;++i) 
                {
					this.getDetailsSeasons(i, callBack);

                }
            
         //  callBack(null, "YAMJ3 DB onGetPerson_getDetails return len: " + len);
            return;
      
    }
	
	private function onGetDetailsPersonFiles(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) 
    { 
		trace("dataYAMJ3 function onGetDetailsPersonFiles");
		var len:Number = int(passthroughData);
        var yamj3coreurl:String = ev.Common.evSettings.yamj3coreurl;
		var len_bis:Number = int(passthroughData);
	//	this.tmpJsonDataPerson = new Array();
      //  this.tmpJsonDataPerson = JsonData.results[0].filmography;
       // var __reg4 = this.tmpJsonDataPerson.length;
		//this.getDetailsCount = __reg4;
		//callBack(null, "YAMJ3 DB onGetDetailsPersonFiles this.tmpJsonDataPerson[__reg1].videodataId:" + this.tmpJsonDataPerson[__reg1].videodataId + "  __reg1 :" + __reg1 + " passthroughData: " + passthroughData);
                  if (this.tmpJsonDataPerson[len_bis]["type"] === "MOVIE") 
					{
				//	callBack(null, "YAMJ3 DB onGetDetailsPersonFiles this.tmpJsonDataPerson[__reg1].videodataId:" + this.tmpJsonDataPerson[__reg1].videodataId + "  __reg1 :" + __reg1);
						this.getDataYAMJ3(yamj3coreurl+ "api/video/movie/" + this.tmpJsonDataPerson[len_bis]["videodataId"] + ".json?dataitems=status,genre,files,rating,certification,studio,country,plot,outline,artwork,award&artwork=all", callBack, len_bis, this.fn.onGetDetailsPersonFiles2);
				return;
					}
				else {this.onGetDetailsPeople(true, null, callBack, passthroughData);}
    }
	
	private function onGetDetailsPersonFiles2(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) 
    {
		trace("dataYAMJ3 function onGetDetailsPersonFiles2");
	
        if (success && jsonData != null ) 
        {
			trace ('as  onGetDetailsPersonFiles2');
            var len = Number(passthroughData);
		//	callBack(null, "onGetDetailsPersonFiles2 success: " + success + " jsonData != null" + " jsonData.result.title" + jsonData.result.title  + " jsonData.result.id" + jsonData.result.id + " __reg3: " + __reg3);
			this.tmpJsonData["results"][len]=jsonData["result"];
			this.tmpJsonData["results"][len]["genreCount"]=jsonData["result"]["genreCount"];
			this.tmpJsonData["results"][len]["genres"]=jsonData["result"]["genres"];
			this.tmpJsonData["results"][len]["files"]=jsonData["result"]["files"];
			this.tmpJsonData["results"][len]["ratings"]=jsonData["result"]["ratings"];
			this.tmpJsonData["results"][len]["studios"]=jsonData["result"]["studios"];
			this.tmpJsonData["results"][len]["id"]=jsonData["result"]["id"];
			this.tmpJsonData["results"][len]["videoType"]=jsonData["result"]["videoType"];
        }
        var yamj3coreurl:String = ev.Common.evSettings.yamj3coreurl;
		len = Number(passthroughData);
		switch(this.tmpJsonData["results"][len]["videoType"]) {
			case 'MOVIE':
				getDataYAMJ3(yamj3coreurl + "api/person/movie.json?id=" + this.tmpJsonData["results"][len]["id"] + "&dataitems=status,artwork", callBack, passthroughData, this.fn.onGetPersonPeople);
				break;
			case 'SERIES':
				onGetDetailsPeople(true, null, callBack, passthroughData);
				break;
		}
        this.onGetDetailsPeople(true, null, callBack, passthroughData);
    }
	private function onGetPersonPeople(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) 
    {
		trace("dataYAMJ3 function onGetPersonPeople")
        if (success && jsonData != null) 
        {
            var len:Number = Number(passthroughData);
            this.tmpJsonData["results"][len]["people"] = jsonData["results"];
		//	callBack(null, "onGetPersonPeople reg2: " + __reg2 + " onGetPersonPeople this.tmpJsonData.results[__reg2].people[0].id" + this.tmpJsonData.results[__reg2].people[0].id + " this.getDetailsCount" + this.getDetailsCount);
       //  this.onGetIndex_ForPerson(success, callBack);
		 //return;
		}
        --this.getDetailsCount;
        if (this.getDetailsCount == 0) 
        {
		//	callBack(null, "onGetPersonPeople getDetailsCount == 0: ");
        
            this.onGetIndex_ForPerson(success, callBack);
		//	return;
        }
    }

	private function onGetIndex_ForPerson(success:Boolean, callBack:Function) 
    {
		trace("dataYAMJ3 function onGetIndex_ForPerson");
		if(success) {
			if(this.infoProcessing) {
				var total=int(this.tmpJsonData["totalCount"]);
				var count=Common.evSettings.yamj3chunksize;
				var pages=Math.ceil(total/count);
				callBack(
					this.tmpJsonData["results"],
					this.indexName,
					this.indexTypeTemp,
					pages,
					total,
					this.indexOriginalName);
			}
			else 
            {
			//		 callBack(null, "onGetIndex_ForPerson else id: " + this.tmpJsonData.results[0].id + " indexName: " +  this.indexName + " temp : " + this.indexTypeTemp +  " reg4: " + __reg4 + " reg2: " + __reg2 +  " indexoriginalname : " + this.indexOriginalName);  
                callBack(this.tmpJsonData.results, this.currentChunk);
			//	return;
            }
            return;
        }
        callBack(null, "YAMJ3 DB onGetIndex_ForPerson access for GetIndexInfo/GetData error");
    }
	
/*********** end new new sequence for person **************/

// ****************************** EPISODES *****************************
	public function episodes(titleArr:Object, callBack:Function) {
		trace("dataYAMJ3 function episodes");
		// first load the fanart
		var seasonId:Number;
		if(titleArr["videoType"]=="SERIES")
			seasonId=titleArr["seasonList"][0]["seasonId"];
		else
			seasonId=titleArr["seasonId"];
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		getDataYAMJ3(yamj3coreurl+"api/video/season/"+seasonId+".json?dataitems=status,artwork,files&artwork=all", callBack, seasonId, this.fn.onEpisodesSeason);
	}
	
	private function onEpisodesSeason(success:Boolean, jsonData:Object, callBack:Function, seasonId:Number) {
		trace("dataYAMJ3 function onEpisodesSeason");
		if(success) {
			if(jsonData["status"]["status"] == 200)
			{
				var artwork_files:Array = new Array();;
				artwork_files[0] = jsonData["result"]["artwork"];
				artwork_files[1] = jsonData["result"]["files"];
				var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
				getDataYAMJ3(yamj3coreurl+"api/video/episodes.json?seasonid="+seasonId+"&dataitems=status,artwork,outline,plot", callBack, artwork_files, this.fn.onEpisodesEpisodes);
			}
			else
				callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+"for episodes");
		}
		else
			callBack(null, "YAMJ3 DB access for episodes error");
	}

	private function onEpisodesEpisodes(success:Boolean, jsonData:Object, callBack:Function, artwork_files:Object) {
		trace("dataYAMJ3 function onEpisodesEpisodes");
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				// insert fanart and filename into each episode
				var len:Number=jsonData["results"].length;
				for(var i=0;i<len;++i)
				{
					jsonData["results"][i]["artwork"]=artwork_files[0];
					jsonData["results"][i]["filename"]=artwork_files[1][i];
				}
				callBack(null, null, jsonData["results"]);
			}
			else
				callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+"for episodes");
		}
		else
			callBack(null, "YAMJ3 DB access for episodes error");
	}

	public function episodeswithset(titleArr:Object, tvset:Object, callBack:Function) {
		
		trace("dataYAMJ3 function episodeswithset");
		var seasonId:Number=titleArr["seasonId"];
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		getDataYAMJ3(yamj3coreurl+"api/video/season/"+seasonId+".json?dataitems=status,artwork,files&artwork=all", callBack, seasonId, this.fn.onEpisodesSeason);
	}

// ****************************** PEOPLE *****************************
	public function people(titleArr:Object, callBack:Function) {
		trace("dataYAMJ3 function people");
		callBack(null, null, titleArr["people"]);
	}

// ************************** data processing ******************************

	public function process_data(field:String,titleArr,howmany:Number):String {
		trace("dataYAMJ3 function process_data");
		return(this.fn.onParseData(field, titleArr, howmany));
	}

	private function onParseData(field:String,titleArr:Object,howmany:Number):String {
		trace("dataYAMJ3 function onParseData");
		
		var itemResult:String=null;
		// make sure we're good to contine
		if(titleArr != null) {
			// process the request
		trace("####Field: "+field.toLowerCase());
			switch(field.toLowerCase()) {
				case 'basefilename':
					itemResult=titleArr["files"][0]["fileName"];
					break;
				case 'filedate':
					itemResult=titleArr["files"][0]["fileDate"];
					break;
				case 'showstatus':
					itemResult=titleArr["status"];
					break;
				case 'releasedate':
					itemResult=titleArr["releaseDate"];
					break;
				case 'sorttitle':
					itemResult=titleArr["sortTitle"];
					break;
				case 'originaltitle':
					itemResult=titleArr["originalTitle"];
					break;
				case 'title':
					itemResult=titleArr["title"];
					break;
				case 'fulltitle':
				case 'fulltitlenoyear':
					itemResult=titleArr["title"];
					if(titleArr["videoType"]=="SERIES" && titleArr["seasonList"].length==1)
						itemResult+=" Season "+titleArr["seasonList"][0].season;
					else if(titleArr["videoType"]=="SEASON")
						itemResult+=" Season "+titleArr["season"];
					break;
				case 'smarttitle':
					if(titleArr["videoType"]=="SERIES" && titleArr["seasonList"].length==1)
						itemResult="Season "+titleArr["seasonList"][0].season;
					else if(titleArr["videoType"]=="SEASON")
						itemResult="Season "+titleArr["season"];
					else
						itemResult=titleArr["title"];
					break;
				case 'fullseason':
					if(titleArr["videoType"]=="SERIES" && titleArr["seasonList"].length==1)
						itemResult="Season "+titleArr["seasonList"][0].season;
					else if(titleArr["videoType"]=="SEASON")
						itemResult="Season "+titleArr["season"];
					break;
				case 'season':
					if(titleArr["videoType"]=="SERIES" && titleArr["seasonList"].length==1)
						itemResult=titleArr["seasonList"][0].season;
					else if(titleArr["videoType"]=="SEASON")
						itemResult=titleArr["season"];
					break;
				case 'thumbnail':
				case 'smartthumbnail':
				case 'poster':
				case 'smartposter':
				case 'smartposter1large':
				case 'smartposter1small':
				case 'poster1small':
				case 'poster1large':
					itemResult=Common.yamj3artworkurl+titleArr["artwork"]["POSTER"][0]["filename"];
					break;
				case 'fanart':
				case 'fanart1large':
				case 'smartfanart1large':
				case 'smartfanart1.large':
					itemResult=Common.yamj3artworkurl+titleArr["artwork"]["FANART"][0]["filename"];
					break;
				case 'banner':
				case 'banner1medium':
				case 'banner1small':
				case 'smartbanner1small':
					itemResult=Common.yamj3artworkurl+titleArr["artwork"]["BANNER"][0]["filename"];
					break;
				case 'videoimage':
				case 'videoimageurl':
					itemResult=Common.yamj3artworkurl+titleArr["videoimage"];
					break;
				case 'mtype':
					switch(titleArr["videoType"])
					{
//					itemResult="MOVIESET";
//					itemResult="TVSET";
						case "SERIES":
							if(titleArr["seasonList"]!=undefined && titleArr["seasonList"].length > 1)
								itemResult="TVSET";
							else
								itemResult="TV";
							break;
						case "SEASON":
							itemResult="TV";
							break;
						case "MOVIE":
							itemResult="MOVIE"
							break;
						default:
							itemResult="MOVIE";
					}
					break;
				case 'epcount':
				trace("******* epcount");
					itemResult="0";
					break;
				case 'episode':
					itemResult=titleArr["episode"]
					break;
				case 'aired':
					itemResult=titleArr["firstAired"];
					break;
				case 'file':
					itemResult="";
					switch(titleArr["videoType"])
					{
//					itemResult="MOVIESET";
//					itemResult="TVSET";
						case "SERIES":
							if(titleArr["seasonList"]!=undefined && titleArr["seasonList"].length > 1)
								itemResult="TVSET_"+titleArr["title"]+"_1_"+titleArr["seriesId"];
							break;
					}
					break;
				case 'setorder':
					itemResult="NONE";
					break;
				case 'watched':
					itemResult="false";
					if(titleArr["watched"]==true) itemResult="true";
					break;
				case 'action':    // figure out the dex action
					itemResult="detail";
					switch(titleArr["videoType"])
					{
//					itemResult="MOVIESET";
//					itemResult="TVSET";
						case "SERIES":
							if(titleArr["seasonList"]!=undefined && titleArr["seasonList"].length > 1)
								itemResult="index";
					}
					break;
				case 'genres':
					{	
						var count:Number=int(titleArr["genreCount"]);
						var a=new Array();
						var j:Number = 0;
						for(var i=0;i<count;++i)
							{
								a.push(titleArr["genres"][i]["name"]);
								++j;
								if (j == howmany) break;
							}
						itemResult=a.join(", ");
						delete a;
					}
					break;
				case 'actors':
					if(titleArr["people"]!=undefined || titleArr["people"]!=null)
					{
						var count:Number=titleArr["people"].length;
						if (howmany != undefined)
							{if (count > howmany) {count = howmany;}}
						var a=new Array();
						var j:Number = 0;
						for(var i=0;i<count;++i)
							{
							if(titleArr["people"][i]["job"]=="ACTOR")
								{ 
									a.push(titleArr["people"][i]["name"]);
									++j;
									if (j == howmany) break;
								}
							}
						itemResult=a.join(", ");
						delete a;
					}
					else
						itemResult="";
					break;
				case 'writers':
					if(titleArr["people"]!=undefined || titleArr["people"]!=null)
					{
						var count:Number=titleArr["people"].length;
						var a=new Array();
						var j:Number = 0;
						for(var i=0;i<count;++i)
							{
							if(titleArr["people"][i]["job"]=="WRITER")
								{ 
									a.push(titleArr["people"][i]["name"]);
									++j;
									if (j == howmany) break;
								}
							}
						itemResult=a.join(", ");
						delete a;
					}
					else
						itemResult="";
					break;
				case 'directors':
					trace("YAMJ3 onParseData directors")
					if(titleArr["people"]!=undefined || titleArr["people"]!=null)
					{
						var count:Number=titleArr["people"].length;
						var a=new Array();
						var j:Number = 0;
						for(var i=0;i<count;++i)
							{
							if(titleArr["people"][i]["job"]=="DIRECTOR")
								{ 
									a.push(titleArr["people"][i]["name"]);
									++j;
									if (j == howmany) break;
								}
							}
						itemResult=a.join(", ");
						trace ("YAMJ3 onParseData directors " + a)
						delete a;
					}
					else
						itemResult="";
					break;
				case 'smartoutline':
					// is it for an episode?
					if(titleArr["episodeId"]>0)
						itemResult=titleArr["plot"];
					else
						itemResult=titleArr["outline"];
					break;
				case 'outline':
					itemResult=titleArr["outline"];
					break;
				case 'plot':
				case 'smartplot':
					itemResult=titleArr["plot"];
					break;
				case 'scoreyamj':
					itemResult="";
					if(titleArr["ratings"][0].rating!=undefined)
					{
						var score:Number=Math.round(int(titleArr["ratings"][0].rating)/10)*10;
						itemResult=score.toString();
					}
					break;
				case 'score10':
				case 'score':
					itemResult="";
					if(titleArr["ratings"][0].rating!=undefined)
					{
						var score:Number=int(titleArr["ratings"][0].rating)/10;
						itemResult=score.toString();
					}
					break;
				case 'rating':
					itemResult="";
					if(titleArr["ratings"][0].rating!=undefined)
					{
						var score:Number=Math.round((int(titleArr["ratings"][0].rating)*10)/10);
						itemResult=score.toString();
					}
					break;
				case 'score5':
					itemResult="";
					if(titleArr["ratings"][0].rating!=undefined)
					{
						var score:Number=Math.round((int(titleArr["ratings"][0].rating)/20)*10)/10;
						itemResult=score.toString();
					}
					break;
				case 'top250':
					itemResult="-1";
					break;
				case 'runtime':
					itemResult="";
					itemResult=titleArr["files"][0].runtime;
					break;
				case 'year':
					itemResult="UNKNOWN";
					itemResult=titleArr["videoYear"];
					break;
				case 'fps':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].fps!=undefined)
						itemResult=titleArr["files"][0].fps;
					break;
				case 'videosource':
				case 'videoSource':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].videoSource!=undefined)
						itemResult=titleArr["files"][0].videoSource;
					break;
				case 'container':
				case 'flagcontainer':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].container!=undefined) {
						itemResult=titleArr["files"][0].container.toUpperCase();
						if(check.indexOf("MATROSKA") != -1) {
							itemResult="mkv";
						} else if(check.indexOf("QUICKTIME") != -1) {
							itemResult="mov";
						} else if(check.indexOf("DVD") != -1) {
							itemResult="dvd";
						} else if(check.indexOf("WEB") != -1) {
							itemResult="web-dl";
						} else if(check.indexOf("FLV") != -1) {
							itemResult="flash";
						}
					}
					break;
				case 'smartcontainer':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].container!=undefined) {
						itemResult=titleArr["files"][0].container.toUpperCase();
						if(itemResult.indexOf("HD2DVD") != -1) {
							itemResult="hd2dvd";
						} else if(itemResult.indexOf("ASF") != -1) {
							itemResult="asf";
						} else if(itemResult.indexOf("AVI") != -1) {
							itemResult="avi";
						} else if(itemResult.indexOf("BIN") != -1) {
							itemResult="bin";
						} else if(itemResult.indexOf("DAT") != -1) {
							itemResult="dat";
						} else if(itemResult.indexOf("IMG") != -1) {
							itemResult="img";
						} else if(itemResult.indexOf("DIVX") != -1) {
							itemResult="divx";
						} else if(itemResult.indexOf("DVD") != -1) {
							itemResult="dvd";
						} else if(itemResult.indexOf("ISO") != -1) {
							itemResult="iso";
						} else if(itemResult.indexOf("BDMV") != -1 || itemResult.indexOf("BDAV") != -1 || itemResult.indexOf("BLURAY") != -1 || itemResult.indexOf("BLU-RAY") != -1 || itemResult.indexOf("BDMV") != -1 || itemResult.indexOf("BDMV") != -1) {
							itemResult="bluray";
						} else if(itemResult.indexOf("M1V") != -1) {
							itemResult="m1v";
						} else if(itemResult.indexOf("M2P") != -1) {
							itemResult="m2p";
						} else if(itemResult.indexOf("M2TS") != -1) {
							itemResult="m2ts";
						} else if(itemResult.indexOf("M2T") != -1) {
							itemResult="m2t";
						} else if(itemResult.indexOf("M2V") != -1) {
							itemResult="m2v";
						} else if(itemResult.indexOf("M4V") != -1) {
							itemResult="m4v";
						} else if(itemResult.indexOf("MDF") != -1) {
							itemResult="mdf";
						} else if(itemResult.indexOf("MKV") != -1 || itemResult.indexOf("MATROSKA") != -1) {
							itemResult="mkv";
						} else if(itemResult.indexOf("MOV") != -1) {
							itemResult="mov";
						} else if(itemResult.indexOf("MP4") != -1 || itemResult.indexOf("MPEG-4") != -1) {
							itemResult="mp4";
						} else if(itemResult.indexOf("MPG") != -1 || itemResult.indexOf("PS") != -1) {
							itemResult="mpg";
						} else if(itemResult.indexOf("MTS") != -1) {
							itemResult="mts";
						} else if(itemResult.indexOf("NRG") != -1) {
							itemResult="nrg";
						} else if(itemResult.indexOf("QT") != -1) {
							itemResult="qt";
						} else if(itemResult.indexOf("RAR") != -1) {
							itemResult="rar";
						} else if(itemResult.indexOf("FLV") != -1) {
							itemResult="flv";
						} else if(itemResult.indexOf("RM") != -1) {
							itemResult="rm";
						} else if(itemResult.indexOf("RMP4") != -1) {
							itemResult="rmp4";
						} else if(itemResult.indexOf("TS") != -1) {
							itemResult="ts";
						} else if(itemResult.indexOf("TP") != -1) {
							itemResult="tp";
						} else if(itemResult.indexOf("TRP") != -1) {
							itemResult="trp";
						} else if(itemResult.indexOf("VOB") != -1) {
							itemResult="vob";
						} else if(itemResult.indexOf("WMV") != -1 || itemResult.indexOf("WINDOWS MEDIA") != -1) {
							itemResult="wmv";
						}
					}
					break;
				case 'flagvideocodec':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].codec!=undefined) {
						itemResult=titleArr["files"][0].codec.toUpperCase();
						var split:Array=itemResult.split("/");
						var check:String=StringUtil.remove(split[0],"-");
						if(check.indexOf("DIVX") != -1 || check.indexOf("3VIX") != -1) {
							itemResult="divx";
						} else if(check.indexOf("XVID") != -1) {
							itemResult="xvid";
						} else if(check.indexOf("MPEG1") != -1) {
							itemResult="mpeg1video";
						} else if(check.indexOf("MPEG2") != -1) { // must be after theora
							itemResult="mpeg2video";
						} else if(check.indexOf("MPEG4") != -1 || check.indexOf("AVC") != -1) {
							itemResult="mpeg4video";
						} else if(check.indexOf("H263") != -1) {
							itemResult="h263";
						} else if(check.indexOf("H262") != -1) {
							itemResult="h262";
						} else if(check.indexOf("DVR") != -1) {
							itemResult="asf";
						} else if(check.indexOf("THEORA") != -1) {
							itemResult="oggtheora";
						} else if(check.indexOf("OGG") != -1) { // must be after theora
							itemResult="ogg";
						} else if(check.indexOf("REAL") != -1) {
							itemResult="real";
						} else if(check.indexOf("MICROSOFT") != -1) {
							itemResult="wmv";
						} else if(check.indexOf("VC1") != -1) {
							itemResult="wvc1";
						} else {
							itemResult="UNKNOWN";
						}
					}
					break;
				case 'videocodec':
				case 'smartvideocodec':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].codecFormat!=undefined) {
						itemResult=titleArr["files"][0].codecFormat.toUpperCase();
						trace("video codec OLD "+itemResult);
						if(itemResult.indexOf("AVC") != -1) {
							itemResult="AVC";
						} else if(itemResult.indexOf("XVID") != -1) {
							itemResult="XVID";
						} else if(itemResult.indexOf("DIVX") != -1) {
							itemResult="DIVX";
						}else if(itemResult.indexOf("VC-1") != -1) {
							itemResult="VC1";
						}else if(itemResult.indexOf("H.264") != -1) {
							itemResult="H264";
						}else if(itemResult.indexOf("MPEG") != -1) {
							itemResult="MPEG";
						}else if(itemResult.indexOf("MICROSOFT") != -1) {
							itemResult="VC1";
						} else {
							if(itemResult.length>6) {
								itemResult="UNKNOWN";
							} else {
								itemResult=itemResult.toUpperCase();
							}
						}
					}
					break;
				case 'flagaudiocodec':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].audioCodecs[0].codecFormat!=undefined) {
						var check:String=titleArr["files"][0].audioCodecs[0].codecFormat.toUpperCase();
						if(check.indexOf("MP3") != -1) {
							itemResult="mp3";
						} else if(check.indexOf("AAC") != -1) {
							itemResult="aac";
						} else if(check.indexOf("FLAC") != -1) {
							itemResult="flac";
						} else if(check.indexOf("EAC3") != -1 || check.indexOf("EC3") != -1 || check.indexOf("AC3+") != -1) {
							itemResult="dolbydigitalplus";
						} else if(check.indexOf("AC-3") != -1) { // must be below AC3+
							itemResult="dolbydigital";
						} else if(check.indexOf("DTSHD") != -1) {  // must be above DTS
							itemResult="dtsma";
						} else if(check.indexOf("DTS") != -1) {
							itemResult="dts";
						} else if(check.indexOf("TRUEHD") != -1) {
							itemResult="truehd";
						} else if(check.indexOf("ORBIS") != -1) {
							itemResult="vorbis";
						} else if(check.indexOf("PCM") != -1) {
							itemResult="pcm";
						} else if(check.indexOf("WMA") != -1 || check.indexOf("MICROSOFT") != -1) {
							itemResult="wmapro";
						} else {
							itemResult="UNKNOWN";
						}
					}
					break;
				case 'audioCodec':
				case 'audiocodec':
				case 'smartaudiocodec':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].audioCodecs[0].codecFormat!=undefined)
					{
						itemResult=titleArr["files"][0].audioCodecs[0].codecFormat.toUpperCase();
						// TODO conversion from YAMJ3 needed
						if(itemResult.indexOf("AC-3") != -1) {
							itemResult="AC3";
						}// else if(check.indexOf("MPEG AUDIO") != -1) {
						//	itemResult="MP2";
						//}
					}
					break;
				case 'audioChannels':
				case 'audiochannels':
				case 'flagchannels':
				case 'smartchannels':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].audioCodecs[0].channels!=undefined)
						itemResult=titleArr["files"][0].audioCodecs[0].channels;
					break;
				case 'subtitles':
					itemResult="NO";
					if(titleArr["files"][0].subtitles!=undefined)
						// return languageCode which is 2 letter
						itemResult=titleArr["files"][0].subtitles[0].languageCode.toUpperCase();
						// itemResult=languageFullTo2Letters(titleArr["files"][0].subtitles[0].language.toUpperCase());
					break;
				case 'languagecode':
				case 'language':
				case 'country':
					itemResult="UNKNOWN";
					if(titleArr["countries"][0]["countryCode"]!=undefined);
						itemResult=titleArr["countries"][0]["countryCode"].toUpperCase();
					//	languageFullTo2Letters(titleArr["files"][0].audioCodecs[0].language.toUpperCase());
					break;
				case 'aspect':
				case 'aspectyamj':
				case 'smartaspect':
				case 'flagaspect':
				case 'flagratio': // legacy from manual typo
					itemResult="UNKNOWN";
					if(titleArr["files"][0].aspectRatio==undefined)
						return;
					var aspect:String=titleArr["files"][0].aspectRatio;
					var asparts:Array=aspect.split(":");
					var asp:Number=Number(asparts[0]);
					//trace("aspect: "+aspect+" asparts: "+asparts[0]+" asp: "+asp);
					if(aspect.length!=6) {
						if(asp > 2.710) {
							itemResult="2.76";
						} else if(asp > 2.625) {
							itemResult="2.66";
						} else if(asp > 2.570) {
							itemResult="2.59";
						} else if(asp > 2.485) {
							itemResult="2.55";
						} else if(asp > 2.415) {
							itemResult="2.42";
						} else if(asp > 2.405) {
							itemResult="2.41";
						} else if(asp > 2.395) {
							itemResult="2.40";
						} else if(asp > 2.370) {
							itemResult="2.39";
						} else if(asp > 2.275) {
							itemResult="2.35";
						} else if(asp > 2.100) {
							itemResult="2.20";
						} else if(asp > 1.925) {
							itemResult="2.00";
						} else if(asp > 1.815) {
							itemResult="1.85";
						} else if(asp > 1.765) {
							itemResult="1.78";
						} else if(asp > 1.705) {
							itemResult="1.75";
						} else if(asp > 1.610) {
							itemResult="1.66";
						} else if(asp > 1.530) {
							itemResult="1.56";
						} else if(asp > 1.465) {
							itemResult="1.50";
						} else if(asp > 1.400) {
							itemResult="1.43";
						} else if(asp > 1.350) {
							itemResult="1.37";
						} else {
							itemResult="1.33";
						}
					} else {
						itemResult=asp.toString();
						if(itemResult.length<4) itemResult=itemResult+"0";
					}
					if(field=="smartaspect") {
						itemResult=itemResult+":1";
					} else if(field=="aspectyamj"){
						itemResult=StringUtil.remove(itemResult,".");
					}
					break;
				case 'videoOutput':
				case 'videooutput':
				case 'resolution':
				case 'flagresolution':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].width==undefined) return;
					if(titleArr["files"][0].height==undefined) return;
					var resx:Number=int(titleArr["files"][0].width);
					var resy:Number=int(titleArr["files"][0].height);
					// adjust for 3d
					if(resx>2559) { // SBS
						resx=resx/2;
					} else if((resx>1919 && resy>1080) || (resx>1279 && resy>1080)) { // TB
						resy=resy/2;
					}

					if(resx>1919) {
						itemResult="1080";
					} else if(resx>1279) {
						itemResult="720";
					} else if(resy>720) {
						itemResult="1080";
					} else if(resy>576) {
						itemResult="720";
					} else if(resy>540) {
						itemResult="576";
					} else if(resy>480) {
						itemResult="540";
					} else if(resy>360) {
						itemResult="480";
					} else if(resy>240) {
						itemResult="360";
					} else itemResult="240";
					break;
				case 'smartres':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].width==undefined) return;
					if(titleArr["files"][0].height==undefined) return;
					var resx:Number=int(titleArr["files"][0].width);
					var resy:Number=int(titleArr["files"][0].height);
					//trace("original: "+resolution+" resx: "+resx+" resy: "+resy);
					if(resx>3849) {
						itemResult="3D1080";
					} else if(resx>2559) {
						itemResult="3D720";
					} else if(resx>1919 && resy>1080) {
						itemResult="3D1080";
					} else if(resx>1919 || resy==1080) {
						itemResult="HD1080";
					} else if(resx>1279 && resy>1080) {  // prevents false 3d720 when 720
						itemResult="3D720";
					}  else if(resx>1279 || resy==720) {
						itemResult="HD720";
					} else if(resy>719) {
						itemResult="HD4:3";
					} else itemResult="SD";
					break;
				case 'flagcertification':
				case 'certification':
					itemResult="UNKNOWN";
					trace("[certifications][0].certificate: " + titleArr["certifications"][0].certificate)
					if(titleArr["certifications"][0].certificate!=undefined)
					{
						itemResult=titleArr["certifications"][0].countryCode + " " + titleArr["certifications"][0].certificate;
					}
					break;
				case 'isextras':
					itemResult="NO";
					if(titleArr["files"][0].extra!=undefined && titleArr["files"][0].extra)
						itemResult="YES";
					break;
				case 'company':
					itemResult="UNKNOWN";
					if(titleArr["studios"][0].name!=undefined)
						itemResult=titleArr["studios"][0].name;
					break;
				case 'filesize':
				case 'fileSize':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].fileSize!=undefined)
						itemResult=titleArr["files"][0].fileSize;
					break;
				default:
					if(StringUtil.beginsWith(field, "multi-")) {
						itemResult=multi_vars(field,titleArr);
					} else if(StringUtil.beginsWith(field, "person") || field == "photo") { 
							// allow using [:photo:] anytime
							// process person variable 
						itemResult=person_vars(field,titleArr);
					} else {
						trace("************* "+field);
						itemResult="UNKNOWN";
					}
			}
		}
		trace("===> dataYAMJ3 getData "+field+" result: "+itemResult);
		return(itemResult);
	}
	
	private function multi_vars(field,titleArr) {
// multi-/movie/cast/actor-1-/actor
// multi-/movie/directors/director-1-/director
// multi-/movie/codecs/audio/codec-1-/codec-langugageFull
// multi-/movie/codecs/audio/codec-1-/codec
// multi-/movie/codecs/audio/codec-1-/codec-channels
// multi-/movie/codecs/audio-1-/audio-count
// multi-/movie/subtitles/subtitle-1-/subtitle-langugageFull  /* new */
// multi-/movie/countries/land-1-/land
// multi-/movie/award/event/award-1-/award
// multi-/movie/genres/genre-1-/genre
		trace("dataYAMJ3 function  multi_vars multi processing: "+field);

		var itemResult;
		var what:Array=field.split("-");
		if(what.length<4 || what.length>5) {
			trace("not enough elements");
			return("UNKNOWN");
		}
		var type:Array=what[1].split("/");
		what[3]=String(what[3]).substr(1).toUpperCase(); // remove the leading '/'
		
		trace("looking for: "+what[1]);
		switch(type[2].toUpperCase()) {
			case 'CAST':
			case 'DIRECTORS':
				var which:Number=int(what[2]);
				var a:Array=new Array();
				var len:Number=titleArr["people"].length;
				switch(what[3]) {
					case 'ACTOR':
					case 'DIRECTOR':
					case 'WRITER':
						for(var i=0;i<len;++i)
							if(titleArr["people"][i]["job"]==what[3])
								a.push(titleArr["people"][i]["name"]);
						itemResult = a[which-1];
						delete a;
						return(itemResult);
						break;
				}
				break;
			case 'COUNTRIES':
				var which:Number=int(what[2]);
				var a:Array=new Array();
				var len:Number=titleArr["countries"].length;
				trace("YAMJ3 multi countries which:" + which + " what(3):" + what[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
				switch(what[3].toUpperCase()) {
					case 'LAND':
						for(var i=0;i<len;++i) 
						{
							a.push(titleArr["countries"][i]["countryCode"]);
						}
						itemResult = a[which-1];
						delete a;
						return(itemResult);
						break;
					case 'COUNTRIES':
						switch(what[4].toUpperCase()) {
							case 'COUNT':
								itemResult = titleArr["countries"].length;
								return(itemResult);
								break;
							case 'LAND':
								for(var i=0;i<len;++i) 
								{
									a.push(titleArr["countries"][i]["country"]);
								}
								itemResult = a[which-1];
								delete a;
								return(itemResult);
								break;
						}	
				}
				break;
			case 'GENRES':
				var which:Number=int(what[2]);
				var a:Array=new Array();
				var len:Number=titleArr["genres"].length;
				trace("YAMJ3 multi genres which:" + which + " what(3):" + what[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
				switch(what[3].toUpperCase()) {
					case 'GENRE':
						for(var i=0;i<len;++i) 
						{
							a.push(titleArr["genres"][i]["name"]);
						}
						itemResult = a[which-1];
						delete a;
						return(itemResult);
						break;
					case 'GENRE':
						switch(what[4].toUpperCase()) {
							case 'COUNT':
								itemResult = titleArr["genres"].length;
								return(itemResult);
								break;
							case 'GENRE':
								for(var i=0;i<len;++i) 
								{
									a.push(titleArr["genres"][i]["name"]);
								}
								itemResult = a[which-1];
								delete a;
								return(itemResult);
								break;
						}	
				}
				break;
			case 'CODECS':
				switch(type[3].toUpperCase()) {
					case 'AUDIO':
						var which:Number = int(what[2])-1;
						trace("YAMJ3 multi codecs audio which:" + which + " type[3]:" + type[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
						switch(what[4].toUpperCase()) {
							case 'CHANNELS':
								itemResult = titleArr["files"][0].audioCodecs[which].channels;
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'LANGUAGEFULL':
							case 'LANGUGAGEFULL': // evZap skin typo
								trace("YAMJ3 multi codecs LANGUGAGEFULL which:" + which + " what(3):" + what[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
						
								itemResult = titleArr["files"][0].audioCodecs[which].languageCode.toUpperCase();
							//	itemResult=languageFullTo2Letters(itemResult);
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'COUNT':
								var count:Number = titleArr["files"][0].audioCodecs.length;
								if(count != undefined) {
									itemResult = count;
									return(itemResult);
								}
								break;
							default:
								trace("YAMJ3 multi codecs default audio is codec")
								// codec type
								itemResult = titleArr["files"][0].audioCodecs[which].codecFormat.toUpperCase();
								// TODO conversion from YAMJ3 needed
								if(itemResult.indexOf("AC-3") != -1) {
									itemResult="AC3";
								} else if(itemResult.indexOf("MPEG AUDIO") != -1) {
									itemResult="MP2";
								} 
								if(itemResult!=undefined) {
									return(itemResult);
								}
								break;
						}
						break;
					case 'VIDEO':
						var which:Number = int(what[2])-1;
						trace("YAMJ3 multi codecs video which:" + which + " type[3]:" + type[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
						switch(what[4].toUpperCase()) {
							case 'PROFILE':
								itemResult = titleArr["files"][which].codecProfile;
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'BITRATE':
								trace("YAMJ3 multi codecs LANGUGAGEFULL which:" + which + " what(3):" + what[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
								itemResult = titleArr["files"][which].bitrate;
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'COUNT':
								var count:Number = titleArr["files"].length;
								if(count != undefined) {
									itemResult = count;
									return(itemResult);
								}
								break;
							case 'CODEC':
								itemResult = titleArr["files"][which].codec;
								if(itemResult!=undefined)
									return(itemResult);
								break;
							default:
								// codecformat type
								itemResult = titleArr["files"][which].codecFormat.toUpperCase();
								if(itemResult!=undefined) {
									return(itemResult);
								}
								break;
						}
						break;
				}
				break;
			/*  new subtitules  */
			case 'SUBTITLES':
			case 'SUBS':
				trace("YAMJ3 multi subtitles which:" + which + " what(3):" + what[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
				switch(type[3].toUpperCase()) {
					case 'SUBS':
					case 'SUBTITLE':
						var which:Number = int(what[2])-1;
						trace("YAMJ3 multi subtitle which:" + which + " type(3):" + type[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
						switch(what[4].toUpperCase()) {
							case 'SUBTITLE':
							case 'LANGUAGEFULL':
							case 'LANGUGAGEFULL': // evZap skin typo
								itemResult = titleArr["files"][0].subtitles[which].languageCode.toUpperCase();
								if(itemResult!=undefined)
									return(itemResult);
								break;
							default:
								// subtitle type 
								itemResult = titleArr["files"][0].subtitles[which].languageCode.toUpperCase();
								if(itemResult!=undefined) {
									return(itemResult);
								}
								break;
						}
				}
				switch(what[4].toUpperCase()) {
					case 'COUNT':
							trace("YAMJ3 multi subtitles count which:" + which + " type(3):" + type[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
							itemResult = titleArr["files"][0]["subtitles"].length;
							if(itemResult!=undefined) {
									return(itemResult);
								}
						break;
				}
				break;
			case 'AWARD':
			case 'AWARDS':
					var check:Boolean=false;
				if(field.indexOf("@")!=-1)
					{
					//	trace ("awards with indexOf")
						check=true;
						// @name, @event,@category
						var award_field:String=type[3].substr(type[3].indexOf("@")+1,(type[3].indexOf("=")-type[3].indexOf("@")-1));
						var award_field_name=type[3].substr(type[3].indexOf("=")+2,(type[3].indexOf("']")- type[3].indexOf("=") - 2));
						
						type[2] = type[3].substr(0,type[3].indexOf("["));
						trace("award_field: " + award_field + " award_field_name: " + award_field_name + " type[2]: " +type[2] + " check: " + check)
					}
					var which:Number = int(what[2])-1;
					trace("YAMJ3 multi awards which:" + which + " type[3]:" + type[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
					switch(what[4].toUpperCase()) {
					case 'COUNT':
							trace("YAMJ3 multi awards count which:" + which + " type(3):" + type[3].toUpperCase() + " what(4): " + what[4].toUpperCase())
							itemResult = titleArr["awards"].length;
							if(itemResult!=undefined) {
									return(itemResult);
								}
						break;
					}
					switch(type[3].toUpperCase()) {
					case 'EVENT':
						var which:Number = int(what[2])-1;
						trace("what[3]:" + what[3] + " what[4]:" +what[4])
						var tmpwhat:Array=what[3].split("-");
						var award_what=String(tmpwhat[2]);
						
						// trace("AWARD case EVENT award_what:" +award_what + " type[2]: " +type[2] + " check: " + check);
						
						switch(what[4].toUpperCase()) {
							case 'YEAR':
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].year;}
									else {}
								else {itemResult = titleArr["awards"][which].year;}
								
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'NOMINATED':
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].nominated;}
									else {}
								else {itemResult = titleArr["awards"][which].nominated;}
								
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'WON':
							
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].won;}
									else {}
								else {itemResult = titleArr["awards"][which].won;}
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'CATEGORY':
							
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].category;}
									else {}
								else {itemResult = titleArr["awards"][which].category;}
								
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'COUNT':
							
								// trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{var count:Number = titleArr["awards"][which].length;}
									else {}
								else {var count:Number = titleArr["awards"][which].length;}
								
								if(count != undefined) {
									itemResult = count;
									return(itemResult);
								}
								break;
							default:
								// award type
								// trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check +" event:" + titleArr["awards"][which].event );
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].event;}
									else {}
								else {itemResult = titleArr["awards"][which].event;}
								
								if(itemResult!=undefined) {
									return(itemResult);
								}
								break;
						}
					}
					switch(type[2].toUpperCase()) {
					case 'EVENT':
						var which:Number = int(what[2])-1;
						trace("what[3]:" + what[3] + " what[4]:" +what[4])
						var tmpwhat:Array=what[3].split("-");
						var award_what=String(tmpwhat[2]);
						
						// trace("AWARD case EVENT award_what:" +award_what + " type[2]: " +type[2] + " check: " + check);
						
						switch(what[4].toUpperCase()) {
							case 'YEAR':
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].year;}
									else {}
								else {itemResult = titleArr["awards"][which].year;}
								
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'NOMINATED':
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].nominated;}
									else {}
								else {itemResult = titleArr["awards"][which].nominated;}
								
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'WON':
							
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].won;}
									else {}
								else {itemResult = titleArr["awards"][which].won;}
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'CATEGORY':
							
							//	trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].category;}
									else {}
								else {itemResult = titleArr["awards"][which].category;}
								
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'COUNT':
							
								// trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check);
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{var count:Number = titleArr["awards"][which].length;}
									else {}
								else {var count:Number = titleArr["awards"][which].length;}
								
								if(count != undefined) {
									itemResult = count;
									return(itemResult);
								}
								break;
							default:
								// award type
								// trace("AWARD case EVENT case what[4]:" +what[4].toUpperCase() + " which:" + which + " type[2]: " +type[2].toUpperCase() + " check: " + check +" event:" + titleArr["awards"][which].event );
								if (check)
									if (award_field_name.toUpperCase() == titleArr["awards"][which].event.toUpperCase()) 
										{itemResult = titleArr["awards"][which].event;}
									else {}
								else {itemResult = titleArr["awards"][which].event;}
								
								if(itemResult!=undefined) {
									return(itemResult);
								}
								break;
						}
						break;
					case 'VIDEO':
						break;
				}
				break;
		}
		return("UNKNOWN");
		
	}
	
	private function person_vars(field,titleArr) {
		trace("dataYAMJ3 function person_vars processing: "+field);
		if(field == "photo") {field = "person@photo"}
		if(field.indexOf("@")!=-1)
		{
			// person@job, person@name
			var person:Array=field.split("@");
			switch(person[1]) {
				case 'name':
					return(titleArr["name"]);
				case 'job':
					return(titleArr["job"]);
				case 'character':
					return(titleArr["role"]);
				case 'photo':
					return(Common.yamj3photourl+titleArr["artwork"][0]["filename"]);
				case 'index':
					return(titleArr["id"]);
				case 'year':
					var year_only:String = titleArr.birthDay.split("-");
					return (year_only[0]);
					return(titleArr["name"]);
				case 'birthplace':
					return(titleArr["birthPlace"]);
				case 'birthday':
					return(titleArr["birthDay"]);
				case 'biography':
					return(titleArr["biography"]);
				case 'birthname':
					return(titleArr["birthName"]);
				default:
					return("UNKNOWN");
			}
		}
		var person:Array=field.split("-");
		if(person.length<3 || person.length>4) {
			trace("not enough elements");
			return("UNKNOWN");
		}

		trace("looking for: "+person[1]);
		var which:Number=int(person[2]);
		var job:String=String(person[1]).toUpperCase();
		
		var a:Array=new Array();
		var len:Number=titleArr["people"].length;
		if(person.length==4)
		{
			switch(person[3]) {
				case 'name':
					for(var i=0;i<len;++i)
						if(titleArr["people"][i]["job"]==job)
							a.push(titleArr["people"][i]["name"]);
					break;
				case 'character':
					for(var i=0;i<len;++i)
						if(titleArr["people"][i]["job"]==job)
							a.push(titleArr["people"][i]["role"]);
					break;
				case 'photo':
					for(var i=0;i<len;++i)
						if(titleArr["people"][i]["job"]==job)
							a.push(Common.yamj3photourl+titleArr["people"][i]["artwork"][0]["filename"]);
					break;
			}
		}
		var itemResult = a[which-1];
		delete a;

		return(itemResult);
	}

	private function languageFullTo2Letters(lang:String):String { // TODO complete
		trace ("dataYAMJ3 function languageFullTo2Letters lang: " + lang);
		switch(lang) {
			case 'ENGLISH':
			case 'FRENCH':
			case 'FRANCAIS':
			case 'ITALIAN':
			case 'JAPANESE':
			case 'DANISH':
			case 'NORWEGIAN':
			case 'FINNISH':
			case 'RUSSIAN':
			case 'HEBREW':
			case 'HUNGARIAN':
				return(lang.substring(0,2));
			case 'CHINESE':
				return ("ZH");
			case 'GERMAN':
				return("DE");
			case 'SPANISH':
				return("ES");
			case 'POLISH':
				return("PL");
			case 'PORTOGUESE':
				return("PT");
			case 'SWEDISH':
				return("SE");
			case 'TURKISH':
				return("TR");
			case 'ANGLAIS':
				return("EN");
		}
		return "UNKNOWN";
	}
}











