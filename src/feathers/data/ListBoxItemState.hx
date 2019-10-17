/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	Represents the current state of a `ListBox` item renderer.

	@see `feathers.controls.ListBox`

	@since 1.0.0
**/
class ListBoxItemState {
	public function new(data:Dynamic = null, index:Int = -1, selected:Bool = false) {
		this.data = data;
		this.index = index;
		this.selected = false;
	}

	public var data(default, null):Dynamic;
	public var index(default, null):Int;
	public var selected(default, null):Bool;
}
