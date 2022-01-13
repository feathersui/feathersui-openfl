/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.Stage;
import openfl.display.DisplayObjectContainer;
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
	#if flash
	public var x:Float;
	#else
	public var x(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#y
	**/
	#if flash
	public var y:Float;
	#else
	public var y(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#width
	**/
	#if flash
	public var width:Float;
	#else
	public var width(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#height
	**/
	#if flash
	public var height:Float;
	#else
	public var height(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#scaleX
	**/
	#if flash
	public var scaleX:Float;
	#else
	public var scaleX(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#scaleY
	**/
	#if flash
	public var scaleY:Float;
	#else
	public var scaleY(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#alpha
	**/
	#if flash
	public var alpha:Float;
	#else
	public var alpha(get, set):Float;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#visible
	**/
	#if flash
	public var visible:Bool;
	#else
	public var visible(get, set):Bool;
	#end

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#parent
	**/
	public var parent(default, never):DisplayObjectContainer;

	/**
		@see https://api.openfl.org/openfl/display/DisplayObject.html#stage
	**/
	public var stage(default, never):Stage;
}
