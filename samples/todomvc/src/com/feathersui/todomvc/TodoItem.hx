package com.feathersui.todomvc;

class TodoItem {
	public function new(?text:String) {
		this.text = text;
	}

	public var text:String;
	public var completed:Bool = false;
}
