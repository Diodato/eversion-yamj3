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
	
// constructor
	function dataYAMJ3() {
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
			onEpisodesEpisodes:Delegate.create(this, this.onEpisodesEpisodes)
		};
		this.artsize=new Array("SMALL","MEDIUM","LARGE","ORIGINAL");
	}

	public function cleanup():Void {
		delete this.fn;
		this.fn=null;
		this.reload();
	}

	public function reload():Void {
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
	}

	// TODO onHTTP... to avoid 30s timeout when server not responding
	private function getDataYAMJ3(url:String, passthroughCallback:Function, passthroughData:Object, callBack:Function):Void {
    	var jsonData:Object = null;
        var php_process:LoadVars = new LoadVars();
//trace("getDataYAMJ3: "+url);
		php_process.onData = Delegate.create( this, function(src:String) {
			if (src == undefined) {
               	trace("Error loading content.");
               	callBack(false, null, passthroughCallback, passthroughData);
            }
			else {
            	this.jsonData = JSONUtil.parseJSON(src);
               	callBack(true, this.jsonData, passthroughCallback, passthroughData);
			}
			return;
		} );
        
        php_process.load(url);
	}

	// we don't use 'ping' but 'system/info' to get the artwork/photo paths
	public function checkForYAMJ3(callBack:Function):Void {
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];

		trace("In checkForYAMJ3, yamj3coreurl: "+yamj3coreurl);
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack(false);
		else
			getDataYAMJ3(yamj3coreurl+"system/info.json", callBack, null, this.fn.onCheckForYAMJ3);
	}
	
	private function onCheckForYAMJ3(success:Boolean, jsonData:Object, callBack:Function) {
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
		var arr:Array;
		var i:Number;
		
		// prep the global
		delete Common.indexes;
		Common.indexes=new Array();

		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"Other_All_1", file:"Other_All_1", title:"All", originaltitle:"All"};
//		arr[i++]={action:"SWITCH", data:"Other_New_1", file:"Other_New_1", title:"New", originaltitle:"New"};
//		arr[i++]={action:"SWITCH", data:"Other_New-TV_1", file:"Other_New-TV_1", title:"New-TV", originaltitle:"New-TV"};
//		arr[i++]={action:"SWITCH", data:"Other_New-Movies_1", file:"Other_New-Movies_1", title:"New-Movies", originaltitle:"New-Movies"};
		arr[i++]={action:"SWITCH", data:"Other_Movies_1", file:"Other_Movies_1", title:"Movies", originaltitle:"Movies"};
//		arr[i++]={action:"SWITCH", data:"Other_Extras_1", file:"Other_Extras_1", title:"Extras", originaltitle:"Extras"};
		arr[i++]={action:"SWITCH", data:"Other_TV Shows_1", file:"Other_TV Shows_1", title:"TV Shows", originaltitle:"TV Shows"};
//		arr[i++]={action:"SWITCH", data:"Other_3D_1", file:"Other_3D_1", title:"3D", originaltitle:"3D"};
//		arr[i++]={action:"SWITCH", data:"Other_HD_1", file:"Other_HD_1", title:"HD", originaltitle:"HD"};
//		arr[i++]={action:"SWITCH", data:"Other_Top250_1", file:"Other_Top250_1", title:"Top250", originaltitle:"Top250"};
//		arr[i++]={action:"SWITCH", data:"Other_Unwatched_1", file:"Other_Unwatched_1", title:"Unwatched", originaltitle:"Unwatched"};
//		arr[i++]={action:"SWITCH", data:"Other_Rating_1", file:"Other_Rating_1", title:"Rating", originaltitle:"Rating"};
		Common.indexes["other"]=arr;
		delete arr;
		
		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"YAMJ3", file:"YAMJ3", title:"Genres", originaltitle:"Genres"};
		Common.indexes["genres"]=arr;
		delete arr;

/*		arr = new Array();
		i = 0;
		arr[i++]={action:"SWITCH", data:"Title_09_1", file:"Title_09_1", title:"09", originaltitle:"09"};
		arr[i++]={action:"SWITCH", data:"Title_A_1", file:"Title_A_1", title:"A", originaltitle:"A"};
		arr[i++]={action:"SWITCH", data:"Title_B_1", file:"Title_B_1", title:"B", originaltitle:"B"};
		arr[i++]={action:"SWITCH", data:"Title_C_1", file:"Title_C_1", title:"C", originaltitle:"C"};
		arr[i++]={action:"SWITCH", data:"Title_D_1", file:"Title_D_1", title:"D", originaltitle:"D"};
		arr[i++]={action:"SWITCH", data:"Title_E_1", file:"Title_E_1", title:"E", originaltitle:"E"};
		arr[i++]={action:"SWITCH", data:"Title_F_1", file:"Title_F_1", title:"F", originaltitle:"F"};
		arr[i++]={action:"SWITCH", data:"Title_G_1", file:"Title_G_1", title:"G", originaltitle:"G"};
		arr[i++]={action:"SWITCH", data:"Title_H_1", file:"Title_H_1", title:"H", originaltitle:"H"};
		arr[i++]={action:"SWITCH", data:"Title_I_1", file:"Title_I_1", title:"I", originaltitle:"I"};
		arr[i++]={action:"SWITCH", data:"Title_J_1", file:"Title_J_1", title:"J", originaltitle:"J"};
		arr[i++]={action:"SWITCH", data:"Title_K_1", file:"Title_K_1", title:"K", originaltitle:"K"};
		arr[i++]={action:"SWITCH", data:"Title_L_1", file:"Title_L_1", title:"L", originaltitle:"L"};
		arr[i++]={action:"SWITCH", data:"Title_M_1", file:"Title_M_1", title:"M", originaltitle:"M"};
		arr[i++]={action:"SWITCH", data:"Title_N_1", file:"Title_N_1", title:"N", originaltitle:"N"};
		arr[i++]={action:"SWITCH", data:"Title_O_1", file:"Title_O_1", title:"O", originaltitle:"O"};
		arr[i++]={action:"SWITCH", data:"Title_P_1", file:"Title_P_1", title:"P", originaltitle:"P"};
		arr[i++]={action:"SWITCH", data:"Title_Q_1", file:"Title_Q_1", title:"Q", originaltitle:"Q"};
		arr[i++]={action:"SWITCH", data:"Title_R_1", file:"Title_R_1", title:"R", originaltitle:"R"};
		arr[i++]={action:"SWITCH", data:"Title_S_1", file:"Title_S_1", title:"S", originaltitle:"S"};
		arr[i++]={action:"SWITCH", data:"Title_T_1", file:"Title_T_1", title:"T", originaltitle:"T"};
		arr[i++]={action:"SWITCH", data:"Title_U_1", file:"Title_U_1", title:"U", originaltitle:"U"};
		arr[i++]={action:"SWITCH", data:"Title_V_1", file:"Title_V_1", title:"V", originaltitle:"V"};
		arr[i++]={action:"SWITCH", data:"Title_W_1", file:"Title_W_1", title:"W", originaltitle:"W"};
		arr[i++]={action:"SWITCH", data:"Title_X_1", file:"Title_X_1", title:"X", originaltitle:"X"};
		arr[i++]={action:"SWITCH", data:"Title_Y_1", file:"Title_Y_1", title:"Y", originaltitle:"Y"};
		arr[i++]={action:"SWITCH", data:"Title_Z_1", file:"Title_Z_1", title:"Z", originaltitle:"Z"};
		Common.indexes["title"]=arr;
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
			// prepare the homelist
			var homedata:Array=new Array();
			var homelist:Array=new Array();
			homelist=Common.esSettings.homelist.split(",");
			for(var i=0;i<homelist.length;i++) {
				//trace(".. adding "+homelist[i]+" to home");

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
				//trace(".. adding "+homelist[i]+" to menu");

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
					if(Common.indexes[homelist[i].toLowerCase()]!= undefined) {
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
						homedata.push({action:"catlist", arraydata:homelist[i].toLowerCase(), title:Common.evPrompts[homelist[i].toLowerCase()],originaltitle:homelist[i].toLowerCase()});
						//trace("... success");
					} // else trace("... didn't exist");
				}

				// send it off (if we have something)
				if(homedata.length>0) {
					Common.indexes["userlist4"]=homedata;
				}
			}
			callBack();

			// cleaner
			delete homedata;
			delete homelist;
	}

	private function originaltitle_fix(testname:String) {
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

	public function getYAMJ3genresIndexData(callBack:Function) {
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];

		trace("In getYAMJ3indexData");
		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack("ERROR","yamj3coreurl undefined or null",null);
		else
			getDataYAMJ3(yamj3coreurl+"api/genres/list.json", callBack, null, this.fn.onGetYAMJ3genresIndexData);



	}

	private function onGetYAMJ3genresIndexData(success:Boolean, jsonData:Object, callBack:Function) {
		if(success) {
			if(jsonData["status"]["status"] == 200) {
				var addto:Array=new Array();
				var len:Number=jsonData["results"].length;
				for(var i:Number=0;i<len;i++)
					addto.push(
							   {action:"SWITCH",
							   data:"Genres_"+jsonData["results"][i]["name"]+"_1",
							   file:"Genres_"+jsonData["results"][i]["name"]+"_1",
							   title:jsonData["results"][i]["name"],
							   originaltitle:jsonData["results"][i]["name"]}
							   );
				callBack(null,null,addto);
			}
			else
				callBack("ERROR", "YAMJ3 DB access error code: "+jsonData["status"]["message"]+"for 'Genres' error", null);
		}
		else
			callBack("ERROR", "YAMJ3 DB access for 'Genres' error", null);
	}
	
	// Load/get information about an index
	public function getIndexInfo(url:String, callBack:Function):Void {
		trace("getIndexInfo url: "+url);

		if(url != null) {
			// figure out the temp types we need to use filename to find
			var tmp:Array = url.split("_",4);
			this.baseIndex=tmp[0];
			this.indexCategory=tmp[1];
			this.currentChunk=int(tmp[2]);
			this.yamj3Id=int(tmp[3]);
			
			if(url.indexOf("Other_New-TV") != -1) {
				trace("TV index");
				this.indexTypeTemp="NEWTV";
			} else if(url.indexOf("Other_TV") != -1 || url.indexOf("Library_TV") != -1){
				trace("TV index");
				this.indexTypeTemp="TV";
			} else if(url.indexOf("Other_Movie") != -1 || url.indexOf("Library_Movie") != -1) {
				trace("Movie index");
				this.indexTypeTemp="MOVIE";
			} else if(url.indexOf("Other_New-Movie") != -1) {
				trace("Movie index");
				this.indexTypeTemp="NEWMOVIE";
			} else if(url.indexOf("Other_New_") != -1 || url.indexOf("Library_New") != -1) {
				trace("Movie index");
				this.indexTypeTemp="NEW";
			} else if(url.indexOf("TVSET_") != -1) {
				trace("tvset index");
				this.indexTypeTemp="TVSET";
			} else if(url.indexOf("Person_") != -1 || url.indexOf("Writer_") != -1 || url.indexOf("Director_") != -1 || url.indexOf("Cast_") != -1) {
				trace("People index");
				this.indexTypeTemp="PEOPLE";
			} else {
				trace("generic index or possible unknown rename");
				this.indexTypeTemp="INDEX";
			}
			this.indexName=this.indexCategory;
			this.infoProcessing=true;
			getIndex(callBack);
		} else {
			// return with error
			callBack(null, Common.evPrompts.enoindexfilename);
		}
	}
	
	public function getData(indexChunk:Number, callBack:Function):Void {
		this.currentChunk=indexChunk;
		this.infoProcessing=false;
		getIndex(callBack);
	}

	private function getIndex(callBack:Function):Void {
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];

		if(yamj3coreurl==null || yamj3coreurl==undefined)
			callBack(null, Common.evPrompts.enoindexfilename);
			
		// specific index
		if(this.indexTypeTemp=="TVSET") {
			//TV SET - yamj3Id is the seriesId
			if(this.yamj3Id!=undefined || this.yamj3Id!=null)
				getDataYAMJ3(yamj3coreurl+"api/video/seriesinfo.json?id="+this.yamj3Id+"&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize, callBack, null, this.fn.onGetIndex_getDetailsSeriesInfo);
		} else if(this.indexTypeTemp=="PEOPLE") {
			// TODO unsupported Person index
			callBack(null, "Unsupported index: "+this.indexCategory);
/*			if(this.yamj3Id!=undefined || this.yamj3Id!=null) {
				switch(this.indexCategory) {
					default:
						// yamj3Id is person_id
						getDataYAMJ3(yamj3coreurl+"api/person/"+this.yamj3Id+"?dataitems=biography,artwork", callBack, null, this.fn.onGetIndexPerson);
						break;
				}
			}*/
		}
		else 
			// have the first page loaded
			switch(this.indexCategory) {
				case "All" :
					getDataYAMJ3(yamj3coreurl+"api/index/video.json?type=MOVIE,SERIES&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize+"&artwork=poster,fanart&dataitems=plot,outline", callBack, null, this.fn.onGetIndex_getDetails);
					break;
				case "Movies" :
					getDataYAMJ3(yamj3coreurl+"api/index/video.json?type=MOVIE&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize+"&artwork=poster,fanart&dataitems=plot,outline", callBack, null, this.fn.onGetIndex_getDetails);
					break;
				case "TV Shows" :
					getDataYAMJ3(yamj3coreurl+"api/index/video.json?type=SERIES&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize+"&artwork=poster,fanart,banner&dataitems=plot,outline", callBack, null, this.fn.onGetIndex_getDetails);
					break;
				default:
					switch(this.baseIndex) {
						case "Genres":
							// TODO bug in YAMJ3 API for SERIES genres, skip them
							//getDataYAMJ3(yamj3coreurl+"api/index/video?type=MOVIE,SERIES&include=genre-"+this.indexCategory+"&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize+"&artwork=poster,fanart,banner&dataitems=plot,outline", callBack, null, this.fn.onGetIndex_getDetails);
							getDataYAMJ3(yamj3coreurl+"api/index/video.json?type=MOVIE&include=genre-"+this.indexCategory+"&page="+this.currentChunk+"&perpage="+Common.evSettings.yamj3chunksize+"&artwork=poster,fanart,banner&dataitems=plot,outline", callBack, null, this.fn.onGetIndex_getDetails);
							break;
						default:
							callBack(null, "Unsupported index: "+this.indexCategory);
							break;
					}
					break;
			}
	}
	
	private function onGetIndex_getDetails(success:Boolean, jsonData:Object, callBack:Function, data:Object) {
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
			else
				callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+" for getIndexInfo/getData");
		}
		else
			callBack(null, "YAMJ3 DB access for getIndexInfo/getData error");
	}

	private function getDetailsSeasons(passthroughData:Object, callBack:Function) {
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		var i=Number(passthroughData);
		if(this.tmpJsonData["results"][i]["videoType"] == "SERIES")
			getDataYAMJ3(yamj3coreurl+"api/video/seriesinfo.json?id="+this.tmpJsonData["results"][i]["id"]+"&dataitems=plot,outline,artwork&artwork=all", callBack, passthroughData, this.fn.onGetDetailsSeasons);
		else
			onGetDetailsSeasons(true, null, callBack, passthroughData);
	}

	private function onGetDetailsSeasons(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		var i=Number(passthroughData);
		if(success && jsonData!=null)
			this.tmpJsonData["results"][i]["seasonList"] = jsonData["results"][0]["seasonList"];

		if(this.tmpJsonData["results"][i]["genreCount"]==0 || this.tmpJsonData["results"][i]["genreCount"]==undefined)
			switch(this.tmpJsonData["results"][i]["videoType"]) {
				case 'MOVIE':
					getDataYAMJ3(yamj3coreurl+"api/video/movie/"+this.tmpJsonData["results"][i]["id"]+".json?dataitems=genre,files,rating,studio,country", callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
					break;
				case 'SERIES':
					getDataYAMJ3(yamj3coreurl+"api/video/series/"+this.tmpJsonData["results"][i]["id"]+".json?dataitems=genre,files,rating,studio,country", callBack, passthroughData, this.fn.onGetDetailsGenresFiles);
					break;
				default:
					trace("getDetailsGenres - unhandled videoType: "+this.tmpJsonData["results"][i]["videoType"]);
					onGetDetailsGenresFiles(true, null, callBack, passthroughData);
			}
	}
	
	private function onGetDetailsGenresFiles(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		if(success && jsonData!=null) {
			var i=Number(passthroughData);
			this.tmpJsonData["results"][i]["genreCount"]=jsonData["result"]["genreCount"];
			this.tmpJsonData["results"][i]["genres"]=jsonData["result"]["genres"];
			this.tmpJsonData["results"][i]["files"]=jsonData["result"]["files"];
			this.tmpJsonData["results"][i]["ratings"]=jsonData["result"]["ratings"];
			this.tmpJsonData["results"][i]["studios"]=jsonData["result"]["studios"];
			this.tmpJsonData["results"][i]["countries"]=jsonData["result"]["countries"];
		}
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		var i=Number(passthroughData);
		switch(this.tmpJsonData["results"][i]["videoType"]) {
			case 'MOVIE':
				getDataYAMJ3(yamj3coreurl+"api/person/movie.json?id="+this.tmpJsonData["results"][i]["id"]+"&dataitems=artwork", callBack, passthroughData, this.fn.onGetDetailsPeople);
				break;
			case 'SERIES':
				getDataYAMJ3(yamj3coreurl+"api/person/series.json?id="+this.tmpJsonData["results"][i]["id"]+"&dataitems=artwork", callBack, passthroughData, this.fn.onGetDetailsPeople);
				break;
			default:
				trace("onGetDetailsGenres - unhandled videoType: "+this.tmpJsonData["results"][i]["videoType"]);
				onGetDetailsPeople(true, null, callBack, passthroughData);
		}
	
	}
	
	private function onGetDetailsPeople(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		if(success && jsonData!=null) {
			var i=Number(passthroughData);
			this.tmpJsonData["results"][i]["people"]=jsonData["results"];
		}
		--this.getDetailsCount;
		if(this.getDetailsCount==0)
			onGetIndex(success, callBack);
	}
	
	private function onGetIndex(success:Boolean, callBack:Function):Void {
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
				callBack(this.tmpJsonData["results"],this.currentChunk);
		}
		else
			callBack(null, "YAMJ3 DB access for GetIndexInfo/GetData error");
	}
	
	private function onGetIndex_getDetailsSeriesInfo(success:Boolean, jsonData:Object, callBack:Function, data:Object) {
		if(success) {
			if(jsonData["status"]["status"] == 200)
			{
				var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
				var a:Array = new Array();
				var len:Number = jsonData["results"][0]["seasonList"].length;
				this.tmpJsonData = {totalCount:len , results:a};
				this.getDetailsCount=len;
				for(var i=0;i<len;++i) {
					getDataYAMJ3(yamj3coreurl+"api/video/season/"+jsonData["results"][0]["seasonList"][i]["seasonId"]+".json?dataitems=artwork,plot,outline,files&artwork=all", callBack, i, this.fn.onGetDetailsSeasons2);
				}
			}
			else
				callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+"for getIndexInfo/getData");
		}
		else
			callBack(null, "YAMJ3 DB access for getIndexInfo/getData error");
	}
	
	private function onGetDetailsSeasons2(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		if(success && jsonData!=null) {
			var i=Number(passthroughData);
			this.tmpJsonData["results"][i]=jsonData["result"];
		}
		--this.getDetailsCount;
		if(this.getDetailsCount==0)
			onGetIndex(success, callBack);
	}

	
	private function onGetIndexPerson(success:Boolean, jsonData:Object, callBack:Function, passthroughData:Object) {
		if(success) {
			if(jsonData["status"]["status"] == 200)
			{
				this.tmpJsonData=jsonData;
				this.tmpJsonData["results"]=new Array();
				this.tmpJsonData["results"][0]=jsonData["result"];
				onGetIndex(true, callBack);
			}
			else
				callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+" for getIndexInfo/getData");
		}
		else
			callBack(null, "YAMJ3 DB access for getIndexInfo/getData error");
	}

// ****************************** EPISODES *****************************
	public function episodes(titleArr:Object, callBack:Function) {
		trace("dataYAMJ3 episodes");
		// first load the fanart
		var seasonId:Number;
		if(titleArr["videoType"]=="SERIES")
			seasonId=titleArr["seasonList"][0]["seasonId"];
		else
			seasonId=titleArr["seasonId"];
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		getDataYAMJ3(yamj3coreurl+"api/video/season/"+seasonId+".json?dataitems=artwork,files&artwork=all", callBack, seasonId, this.fn.onEpisodesSeason);
	}
	
	private function onEpisodesSeason(success:Boolean, jsonData:Object, callBack:Function, seasonId:Number) {
		if(success) {
			if(jsonData["status"]["status"] == 200)
			{
				var artwork_files:Array = new Array();;
				artwork_files[0] = jsonData["result"]["artwork"];
				artwork_files[1] = jsonData["result"]["files"];
				var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
				getDataYAMJ3(yamj3coreurl+"api/video/episodes.json?seasonid="+seasonId+"&dataitems=artwork,outline,plot", callBack, artwork_files, this.fn.onEpisodesEpisodes);
			}
			else
				callBack(null, "YAMJ3 DB access error code: "+jsonData["status"]["message"]+"for episodes");
		}
		else
			callBack(null, "YAMJ3 DB access for episodes error");
	}

	private function onEpisodesEpisodes(success:Boolean, jsonData:Object, callBack:Function, artwork_files:Object) {
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
		trace("dataYAMJ3 episodeswithset");
		var seasonId:Number=titleArr["seasonId"];
		var yamj3coreurl:String = ev.Common.evSettings["yamj3coreurl"];
		getDataYAMJ3(yamj3coreurl+"api/video/season/"+seasonId+".json?dataitems=artwork,files&artwork=all", callBack, seasonId, this.fn.onEpisodesSeason);
	}

// ****************************** PEOPLE *****************************
	public function people(titleArr:Object, callBack:Function) {
		trace("dataYAMJ3 people");
		callBack(null, null, titleArr["people"]);
	}

// ************************** data processing ******************************

	public function process_data(field:String,titleArr,howmany:Number):String {
		return(this.fn.onParseData(field, titleArr, howmany));
	}

	private function onParseData(field:String,titleArr:Object,howmany:Number):String {
		var itemResult:String=null;
		// make sure we're good to contine
		if(titleArr != null) {
			// process the request
trace("####Field: "+field);
			switch(field) {
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
				case 'poster1small':
				case 'poster1large':
					itemResult=Common.yamj3artworkurl+titleArr["artwork"]["POSTER"][0]["filename"];
					break;
				case 'fanart':
				case 'smartfanart1large':
				case 'smartfanart1.large':
					itemResult=Common.yamj3artworkurl+titleArr["artwork"]["FANART"][0]["filename"];
					break;
				case 'banner':
				case 'banner1small':
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
						for(var i=0;i<count;++i)
							a.push(titleArr["genres"][i]["name"]);
						itemResult=a.join(", ");
						delete a;
					}
					break;
				case 'actors':
					if(titleArr["people"]!=undefined || titleArr["people"]!=null)
					{
						var count:Number=titleArr["people"].length;
						var a=new Array();
						for(var i=0;i<count;++i)
							if(titleArr["people"][i]["job"]=="ACTOR")
								a.push(titleArr["people"][i]["name"]);
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
						for(var i=0;i<count;++i)
							if(titleArr["people"][i]["job"]=="WRITER")
								a.push(titleArr["people"][i]["name"]);
						itemResult=a.join(", ");
						delete a;
					}
					else
						itemResult="";
					break;
				case 'directors':
					if(titleArr["people"]!=undefined || titleArr["people"]!=null)
					{
						var count:Number=titleArr["people"].length;
						var a=new Array();
						for(var i=0;i<count;++i)
							if(titleArr["people"][i]["job"]=="DIRECTOR")
								a.push(titleArr["people"][i]["name"]);
						itemResult=a.join(", ");
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
					itemResult="UNKNOWN";
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
				case 'score5':
					itemResult="0";
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
					itemResult="";
					itemResult=titleArr["videoYear"];
					break;
				case 'fps':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].fps!=undefined)
						itemResult=titleArr["files"][0].fps;
					break;
				case 'videoSource':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].videoSource!=undefined)
						itemResult=titleArr["files"][0].videoSource;
					break;
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
				case 'flagchannels':
				case 'smartchannels':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].audioCodecs[0].channels!=undefined)
						itemResult=titleArr["files"][0].audioCodecs[0].channels;
					break;
				case 'subtitles':
					itemResult="NO";
					if(titleArr["files"][0].subtitles!=undefined)
						// TODO - substitute full language into 2 letter uppercase
						itemResult=languageFullTo2Letters(titleArr["files"][0].subtitles[0].language.toUpperCase());
					break;
				case 'language':
					itemResult="UNKNOWN";
					if(titleArr["files"][0].audioCodecs[0].language!=undefined);
						itemResult=languageFullTo2Letters(titleArr["files"][0].audioCodecs[0].language.toUpperCase());
					break;
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
				default:
					if(StringUtil.beginsWith(field, "multi-")) {
						itemResult=multi_vars(field,titleArr);
					} else if(StringUtil.beginsWith(field, "person")) {
							// process person variable
						itemResult=person_vars(field,titleArr);
					} else {
						trace("************* "+field);
						itemResult="UNKNOWN";
					}
			}
		}
		trace("getData "+field+" result: "+itemResult);
		return(itemResult);
	}
	
	private function multi_vars(field,titleArr) {
// multi-/movie/cast/actor-1-/actor
// multi-/movie/directors/director-1-/director
// multi-/movie/codecs/audio/codec-1-/codec-langugageFull
// multi-/movie/codecs/audio/codec-1-/codec
// multi-/movie/codecs/audio/codec-1-/codec-channels
// multi-/movie/codecs/audio-1-/audio-count
// multi-/movie/awards/event/award-1-/award
		trace("multi processing: "+field);

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
			case 'CODECS':
				switch(type[3].toUpperCase()) {
					case 'AUDIO':
						var which:Number = int(what[2])-1;
						switch(what[4].toUpperCase()) {
							case 'CHANNELS':
								itemResult = titleArr["files"][0].audioCodecs[which].channels;
								if(itemResult!=undefined)
									return(itemResult);
								break;
							case 'LANGUAGEFULL':
							case 'LANGUGAGEFULL': // evZap skin typo
								itemResult = titleArr["files"][0].audioCodecs[which].language.toUpperCase();
								itemResult=languageFullTo2Letters(itemResult);
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
								// codec type
								itemResult = titleArr["files"][0].audioCodecs[which].codecFormat.toUpperCase();
								// TODO conversion from YAMJ3 needed
								if(itemResult.indexOf("AC-3") != -1) {
									itemResult="AC3";
								}// else if(itemResult.indexOf("MPEG AUDIO") != -1) {
								//	itemResult="MP2";
								//}
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
				// TODO case 'awards'
		}
		return("UNKNOWN");
		
	}
	
	private function person_vars(field,titleArr) {
		trace("person processing: "+field);

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
			}
		}
		var itemResult = a[which-1];
		delete a;

		return(itemResult);
	}

	private function languageFullTo2Letters(lang:String):String { // TODO complete
		switch(lang) {
			case 'ENGLISH':
			case 'FRENCH':
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
		}
		return "UNKNOWN";
	}
}











