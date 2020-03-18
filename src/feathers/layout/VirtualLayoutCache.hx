/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.display.DisplayObject;

/**


	@since 1.0.0
**/
class VirtualLayoutCache {
	public function new() {}

	private var cache:Array<Dynamic> = [];

	/**


		@since 1.0.0
	**/
	public function reset():Void {
		this.cache = [];
	}

	/**


		@since 1.0.0
	**/
	public function set(index:Int, data:Dynamic):Void {
		this.cache[index] = data;
	}

	/**


		@since 1.0.0
	**/
	public function get(index:Int):Dynamic {
		return this.cache[index];
	}

	/**


		@since 1.0.0
	**/
	public function has(index:Int):Bool {
		return this.cache[index] != null;
	}

	/**


		@since 1.0.0
	**/
	public function initialize(index:Int):Void {
		this.cache[index] = {};
	}

	/**


		@since 1.0.0
	**/
	public function insert(index:Int):Void {
		this.cache.insert(index, {});
	}

	/**


		@since 1.0.0
	**/
	public function remove(index:Int):Void {
		this.cache.splice(index, 1);
	}
}
