/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.display.DisplayObject;

/**
	A layout that supports snap positions.

	@since 1.0.0
**/
interface ISnapLayout extends ILayout {
	/**
		The snap positions on the horizontal x-axis. May return `null`, if there
		are no snap positions.

		@since 1.0.0
	**/
	public function getSnapPositionsX(items:Array<DisplayObject>, viewPortWidth:Float, viewPortHeight:Float, ?result:Array<Float>):Array<Float>;

	/**
		The snap positions on the vertical y-axis. May return `null`, if there
		are no snap positions.

		@since 1.0.0
	**/
	public function getSnapPositionsY(items:Array<DisplayObject>, viewPortWidth:Float, viewPortHeight:Float, ?result:Array<Float>):Array<Float>;
}
