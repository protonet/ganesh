function dm(username){
	document.location.href = 'bluebird://direct/'+username;
}
function reply(username,tweetID){
	document.location.href = 'bluebird://reply-to/'+username+'/'+tweetID;	
}