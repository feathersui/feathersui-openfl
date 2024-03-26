/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.geom.Rectangle;
import openfl.display.DisplayObject;

/**
	A layout that provides support for drag and drop.

	@see `feathers.dragDrop.DragDropManager`

	@since 1.3.0
**/
interface IDragDropLayout extends ILayout {
	/**
		Returns the index of the item in the layout where a new item can be
		dropped, based on the `x` and `y` coordinates.

		@since 1.3.0
	**/
	function getDragDropIndex(items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float):Int;

	/**
		Returns the region representing the specified index in the layout where
		a drop indicator may be positioned. The result will include the `x` and
		`y` positions, and one of either the `width` or the `height`. The other
		of the rectangle's dimensions will be equal to `0.0` because the result
		represents a line.

		@since 1.3.0
	**/
	function getDragDropRegion(items:Array<DisplayObject>, dropIndex:Int, x:Float, y:Float, width:Float, height:Float, result:Rectangle = null):Rectangle;
}
