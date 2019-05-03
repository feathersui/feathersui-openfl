/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.events.Event;
import feathers.events.FeathersEvent;
import openfl.events.EventDispatcher;

class ArrayCollection<T> extends EventDispatcher implements IFlatCollection<T> {
	public function new(array:Array<T>) {
		super();
		if (array == null) {
			array = [];
		}
		this.array = array;
	}

	public var array(default, set):Array<T> = null;

	public function set_array(value:Array<T>):Array<T> {
		if (this.array == value) {
			return this.array;
		}
		if (value == null) {
			value = [];
		}
		this.array = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.array;
	}

	public var length(get, null):Int;

	private function get_length():Int {
		return this.array.length;
	}

	public function get(index:Int):T {
		return this.array[index];
	}

	public function set(item:T, index:Int):Void {
		this.array[index] = item;
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	public function add(item:T):Void {
		this.array.insert(this.array.length, item);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	public function addAt(item:T, index:Int):Void {
		this.array.insert(index, item);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	public function remove(item:T):Void {
		this.array.remove(item);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	public function removeAt(index:Int):T {
		var item = this.array[index];
		this.array.remove(item);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return item;
	}
}
