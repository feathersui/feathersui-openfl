package com.feathersui.hn.vo;

typedef Item = {
	id:UInt,
	title:String,
	points:Null<UInt>,
	user:Null<String>,
	time:UInt,
	time_ago:String,
	content:String,
	?deleted:Bool,
	?dead:Bool,
	type:String,
	?url:String,
	?domain:String,
	comments:Array<Item> /* Comments are items too */,
	level:UInt,
	comments_count:UInt,
}
