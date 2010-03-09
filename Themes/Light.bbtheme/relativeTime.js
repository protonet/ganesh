/* 
   Relative Time - 1.1
   ===================
    
   Features
   --------
   - return a relative time
   - tweaked for Bluebird 1.1b
 
   Thanks
   ------
   - Old tweet won't the time problem fixed by alexsancho
 
   Coded by Na Wong 
   http://nadesign.net
 */
  
function convertTime(objs) {
	for(obj in objs) {
		var htmlContainer = objs[obj].getElementsByClassName('relativeTime');
		var time = htmlContainer[0].rel;
		var splitTime = time.split(",");
		var result = relativeTime(splitTime[0],splitTime[1],splitTime[2],splitTime[3],splitTime[4],splitTime[5]);
		htmlContainer[0].innerHTML = result;		
	}
}
function relativeTime(yyyy,mm,d,h,m,s){
	var timeNow = new Date();
	var event = new Date(yyyy,mm-1,d,h,m,s);
	
	var oneSec = 1000;
	var oneMin = oneSec*60;
	var oneHour = oneMin*60;
	var oneDay = oneHour*24;
	var oneWeek = oneDay*7;
	var oneMonth = oneWeek*4;
	var oneYear = oneMonth*12;

	var diff = Math.ceil((timeNow.getTime()-event.getTime()));
	if (diff > oneYear){
		years = Math.round(diff/oneYear);
		if (years > 1){
			result =  years + " years ago";
		}else{
			result =  "a year ago";
		}
	}else if (diff > oneMonth){
		months = Math.round(diff/oneMonth);
		if (months > 1){
			result =  months + " months ago";
		}else{
			result =  "a month ago";
		}	
	}else if (diff > oneWeek){
		weeks = Math.round(diff/oneWeek);
		if (weeks > 1){
			result =  weeks + " weeks ago";
		}else{
			result =  "a week ago";
		}	
	}else if (diff > oneDay){
		days = Math.round(diff/oneDay);
		if (days > 1){
			result =  days + " days ago";
		}else{
			result =  "a day ago";
		}
	}else if(diff > oneHour){
		hours = Math.round(diff/oneHour);
		if (hours > 1){
			result = hours + " hours ago";
		}else{
			result = "an hour ago";		
		}
	}else if(diff > oneMin){
		mins = Math.round(diff/oneMin);
		if (mins > 1){
			result = mins + " minutes ago";
		}else{
			result = "a minute ago";
		}
	}else{
		result = "Just Now";
	}
	return result;
	//document.write(result);
}