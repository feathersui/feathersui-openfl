/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.graphics;

import openfl.display.JointStyle;
import openfl.display.CapsStyle;
import openfl.display.LineScaleMode;

/**
	Line styles for graphics.

	@since 1.0.0
**/
enum LineStyle {
	/**
		The line is drawn as a solid color at the specified thickness.

		@since 1.0.0.
	**/
	SolidColor(?thickness:Float, ?color:Int, ?alpha:Float, ?pixelHinting:Bool, ?scaleMode:LineScaleMode, ?caps:CapsStyle, ?joints:JointStyle, ?miterLimit:Float);
}
