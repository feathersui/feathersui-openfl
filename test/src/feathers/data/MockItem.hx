/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

class MockItem {
	public function new(text:String, value:Float) {
		this.text = text;
		this.value = value;
	}

	public var text:String;
	public var value:Float;

	public function toString():String {
		return 'MockItem("${this.text}", ${this.value})';
	}
}
