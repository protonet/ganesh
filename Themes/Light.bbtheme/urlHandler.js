/* 
   URL Handler - 1.5
   =================
   
   Features
   --------
   - Replace TwitPic links by thumbnails
   - Trim the http:// and https:// prefix
   - Replace Youtube link by thumbnails
   - tweaked for Bluebird 1.1b
   
   Coded by Na Wong 
   http://nadesign.net
*/

function replaceTwitPic(obj){
	var links = obj.getElementsByClassName('BBExternalLink');
	for(i=0;i<links.length;i++){
		var href = links[i].getAttribute('href');
		var twitPicRE = /http:\/\/twitpic.com/;
		if(href.match(twitPicRE)){
			id = href.replace('http://twitpic.com/','');
			if (id != ''){
				links[i].innerHTML = '<img src="http://twitpic.com/show/mini/'+id+'" alt="" class="twitPicThumb"/>';
			}
		}
	}
}
function replaceHttpPrefix(obj){
	var links = obj.getElementsByClassName('BBExternalLink');
	for(i=0;i<links.length;i++){	
		var href = links[i].getAttribute('href');
		var httpPrefix = /http:\/\//;
		var httpsPrefix = /https:\/\//;
		if(href.match(httpPrefix) || href.match(httpsPrefix)){
			var url = href;
			var prefix = new Array('http://www.','https://www.','http://','https://');
			for (var p=0; p<prefix.length;p++){
				url = url.replace(prefix[p],'');	
			}
			
			if (url.charAt(url.length-1) == "/"){
				url = url.substring(0,url.length-1);	
			}
			if (url != ''){
				links[i].innerHTML = url;
			}
		}
	}
}
function replaceYouTube(obj){	
	var links = obj.getElementsByClassName('BBExternalLink');
	for(i=0;i<links.length;i++){
		var href = links[i].getAttribute('href');
		var youtubeURL = /http:\/\/youtube.com/;
		var youtubeWwwURL = /http:\/\/www.youtube.com/;		
		if(href.match(youtubeURL) || href.match(youtubeWwwURL)){
			/* Youtube regExp. match string from http://jquery-howto.blogspot.com */
			results = href.match("[\\?&]v=([^&#]*)");
			id = ( results === null ) ? href : results[1];
			links[i].innerHTML = '<img src="http://img.youtube.com/vi/'+id+'/0.jpg" alt="" class="youtubeThumb"/>';
		}
	}
}