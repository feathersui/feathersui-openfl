/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.graphics;

import openfl.geom.Matrix;
import openfl.display.BitmapData;

/**
	Fill styles for graphics.

	@since 1.0.0
**/
enum FillStyle {
	/**
		The fill is rendered as a solid color with the specified alpha.

		@since 1.0.0.
	**/
	SolidColor(color:Int, ?alpha:Float);

	/**
		The fill is rendered as a bitmap.

		@since 1.0.0.
	**/
	Bitmap(bitmapData:BitmapData, ?matrix:Matrix, ?repeat:Bool, ?smoothing:Bool);
}
