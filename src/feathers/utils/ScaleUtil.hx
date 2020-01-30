/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.geom.Rectangle;

/**
	Utility functions for scaling geometry.

	@since 1.0.0
**/
class ScaleUtil {
	/**
		The entire rectangle will be scaled to fit into the specified area,
		while maintaining the original aspect ratio. This might leave empty bars
		at either the top and bottom, or left and right.

		@since 1.0.0
	**/
	public static function fitRectangle(original:Rectangle, into:Rectangle, ?result:Rectangle):Rectangle {
		var width = original.width;
		var height = original.height;
		var intoWidth = into.width;
		var intoHeight = into.height;
		var scale = scaleToFit(width, height, intoWidth, intoHeight);
		if (result == null) {
			result = new Rectangle();
		}
		var resultWidth = width * scale;
		var resultHeight = height * scale;
		result.width = resultWidth;
		result.height = resultHeight;
		result.x = into.x + (intoWidth - resultWidth) / 2.0;
		result.y = into.y + (intoHeight - resultHeight) / 2.0;
		return result;
	}

	/**
		Specifies that the rectangle fills the specified area, without
		distortion but possibly with some cropping, while maintaining the
		original aspect ratio.

		@since 1.0.0
	**/
	public static function fillRectangle(original:Rectangle, into:Rectangle, ?result:Rectangle):Rectangle {
		var width = original.width;
		var height = original.height;
		var intoWidth = into.width;
		var intoHeight = into.height;
		var scale = scaleToFill(width, height, intoWidth, intoHeight);
		if (result == null) {
			result = new Rectangle();
		}
		var resultWidth = width * scale;
		var resultHeight = height * scale;
		result.width = resultWidth;
		result.height = resultHeight;
		result.x = into.x + (intoWidth - resultWidth) / 2.0;
		result.y = into.y + (intoHeight - resultHeight) / 2.0;
		return result;
	}

	private inline static function scaleToFit(originalWidth:Float, originalHeight:Float, targetWidth:Float, targetHeight:Float):Float {
		var widthRatio = targetWidth / originalWidth;
		var heightRatio = targetHeight / originalHeight;
		if (widthRatio < heightRatio) {
			return widthRatio;
		}
		return heightRatio;
	}

	private inline static function scaleToFill(originalWidth:Float, originalHeight:Float, targetWidth:Float, targetHeight:Float):Float {
		var widthRatio = targetWidth / originalWidth;
		var heightRatio = targetHeight / originalHeight;
		if (widthRatio > heightRatio) {
			return widthRatio;
		}
		return heightRatio;
	}
}
