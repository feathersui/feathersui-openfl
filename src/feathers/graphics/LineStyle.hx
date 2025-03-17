/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.graphics;

import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.SpreadMethod;
import openfl.geom.Matrix;

/**
	Line styles for graphics.

	@since 1.0.0
**/
enum LineStyle {
	/**
		The line is drawn as a solid color at the specified thickness.

		@see [`openfl.display.Graphics.lineStyle()`](https://api.openfl.org/openfl/display/Graphics.html#lineStyle)

		@since 1.0.0
	**/
	SolidColor(?thickness:Float, ?color:Int, ?alpha:Float, ?pixelHinting:Bool, ?scaleMode:LineScaleMode, ?caps:CapsStyle, ?joints:JointStyle,
		?miterLimit:Float);

	/**
		The line is rendered as a bitmap.

		@see [`openfl.display.Graphics.lineBitmapStyle()`](https://api.openfl.org/openfl/display/Graphics.html#lineBitmapStyle)

		@since 1.0.0
	**/
	Bitmap(thickness:Float, bitmapData:BitmapData, ?matrix:Matrix, ?repeat:Bool, ?smooth:Bool);

	/**
		The line is rendered as a gradient of multiple colors.

		@see [`openfl.display.Graphics.lineGradientStyle()`](https://api.openfl.org/openfl/display/Graphics.html#lineGradientStyle)

		@since 1.0.0
	**/
	Gradient(thickness:Float, type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, ?matrix:CreateGradientBoxMatrix,
		?spreadMethod:SpreadMethod, ?interpolationMethod:InterpolationMethod, ?focalPointRatio:Float);

	/**
		A line is not drawn.

		@since 1.0.0
	**/
	None;
}
