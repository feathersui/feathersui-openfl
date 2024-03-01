/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.graphics;

import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.SpreadMethod;
import openfl.geom.Matrix;

/**
	Fill styles for graphics.

	@since 1.0.0
**/
enum FillStyle {
	/**
		The fill is rendered as a solid color with the specified alpha.

		@see [`openfl.display.Graphics.beginFill()`](https://api.openfl.org/openfl/display/Graphics.html#beginFill)

		@since 1.0.0
	**/
	SolidColor(color:Int, ?alpha:Float);

	/**
		The fill is rendered as a bitmap.

		@see [`openfl.display.Graphics.beginBitmapFill()`](https://api.openfl.org/openfl/display/Graphics.html#beginBitmapFill)

		@since 1.0.0
	**/
	Bitmap(bitmapData:BitmapData, ?matrix:Matrix, ?repeat:Bool, ?smoothing:Bool);

	/**
		The fill is rendered as a gradient of multiple colors.

		@see [`openfl.display.Graphics.beginGradientFill()`](https://api.openfl.org/openfl/display/Graphics.html#beginGradientFill)

		@since 1.0.0
	**/
	Gradient(type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, ?matrix:CreateGradientBoxMatrix, ?spreadMethod:SpreadMethod,
		?interpolationMethod:InterpolationMethod, ?focalPointRatio:Float);

	/**
		A fill is not rendered.

		@since 1.0.0
	**/
	None;
}
