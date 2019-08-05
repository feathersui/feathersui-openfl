/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.IEventDispatcher;

interface IDisplayObject extends IEventDispatcher {
	#if flash
	public var x:Float;
	#else
	public var x(get, set):Float;
	#end

	#if flash
	public var y:Float;
	#else
	public var y(get, set):Float;
	#end

	#if flash
	public var width:Float;
	#else
	public var width(get, set):Float;
	#end

	#if flash
	public var height:Float;
	#else
	public var height(get, set):Float;
	#end

	#if flash
	public var scaleX:Float;
	#else
	public var scaleX(get, set):Float;
	#end

	#if flash
	public var scaleY:Float;
	#else
	public var scaleY(get, set):Float;
	#end

	#if flash
	public var alpha:Float;
	#else
	public var alpha(get, set):Float;
	#end

	#if flash
	public var visible:Bool;
	#else
	public var visible(get, set):Bool;
	#end
}
