/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObjectContainer;
import openfl.display.Stage;
import openfl.events.IEventDispatcher;

/**
	Conveniently provides a number of display object properties that may be
	useful on other interfaces. Should not be used for runtime type checking
	to see if something is a display object because not all display objects
	will implement this interface.

	@since 1.0.0
**/
@:dox(hide)
interface IDisplayObject extends IEventDispatcher {
	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#x
	**/
	#if (flash && haxe_ver < 4.3)
	public var x:Float;
	#else
	#if flash @:flash.property #end
	public var x(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#y
	**/
	#if (flash && haxe_ver < 4.3)
	public var y:Float;
	#else
	#if flash @:flash.property #end
	public var y(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#alpha
	**/
	#if (flash && haxe_ver < 4.3)
	public var alpha:Float;
	#else
	#if flash @:flash.property #end
	public var alpha(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#width
	**/
	#if (flash && haxe_ver < 4.3)
	public var width:Float;
	#else
	#if flash @:flash.property #end
	public var width(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#height
	**/
	#if (flash && haxe_ver < 4.3)
	public var height:Float;
	#else
	#if flash @:flash.property #end
	public var height(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#scaleX
	**/
	#if (flash && haxe_ver < 4.3)
	public var scaleX:Float;
	#else
	#if flash @:flash.property #end
	public var scaleX(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#scaleY
	**/
	#if (flash && haxe_ver < 4.3)
	public var scaleY:Float;
	#else
	#if flash @:flash.property #end
	public var scaleY(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#visible
	**/
	#if (flash && haxe_ver < 4.3)
	public var visible:Bool;
	#else
	#if flash @:flash.property #end
	public var visible(get, set):Bool;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#parent
	**/
	#if (!flash || haxe_ver < 4.3)
	public var parent(default, never):DisplayObjectContainer;
	#else
	#if flash @:flash.property #end
	public var parent(get, never):DisplayObjectContainer;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#stage
	**/
	#if (!flash || haxe_ver < 4.3)
	public var stage(default, never):Stage;
	#else
	#if flash @:flash.property #end
	public var stage(get, never):Stage;
	#end
}
