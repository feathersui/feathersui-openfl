package com.feathersui.magic8ball.vo;

class ChatMessage {
	public function new(author:String, text:String, outgoing:Bool) {
		this.author = author;
		this.text = text;
		this.outgoing = outgoing;
	}

	public var author:String;
	public var text:String;
	public var outgoing:Bool;
}
