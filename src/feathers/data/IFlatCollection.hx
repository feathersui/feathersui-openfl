/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.events.IEventDispatcher;

interface IFlatCollection<T> extends IEventDispatcher {
	public var length(get, null):Int;
	public function get(index:Int):T;
	public function set(item:T, index:Int):Void;
	public function add(item:T):Void;
	public function addAt(item:T, index:Int):Void;
	public function remove(item:T):Void;
	public function removeAt(index:Int):T;
}
