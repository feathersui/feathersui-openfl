package com.feathersui.hn.vo;

typedef FeedItem = {
	id:UInt,
	title:String,
	?points:Null<UInt>,
	?user:Null<String>,
	time:UInt,
	time_ago:String,
	comments_count:UInt,
	type:String,
	?url:String,
	?domain:String,
}
