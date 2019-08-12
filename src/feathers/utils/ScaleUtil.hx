/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.geom.Rectangle;

/**
	@since 1.0.0
**/
class ScaleUtil {
	/**
		@since 1.0.0
	**/
	public static function fitRectangle(width:Float, height:Float, into:Rectangle, ?result:Rectangle):Rectangle {
		var intoWidth = into.width;
		var intoHeight = into.height;
		var scale = scaleToFit(width, height, intoWidth, intoHeight);
		if (result == null) {
			result = new Rectangle();
		}
		result.width = width * scale;
		result.height = height * scale;
		result.x = (intoWidth - result.width) / 2.0;
		result.y = (intoHeight - result.height) / 2.0;
		return result;
	}

	/**
		@since 1.0.0
	**/
	public static function fillRectangle(width:Float, height:Float, into:Rectangle, ?result:Rectangle):Rectangle {
		var scale = scaleToFill(width, height, into.width, into.height);
		if (result == null) {
			result = new Rectangle();
		}
		result.width = width * scale;
		result.height = height * scale;
		result.x = (into.width - result.width) / 2.0;
		result.y = (into.height - result.height) / 2.0;
		return result;
	}

	/**
		@since 1.0.0
	**/
	public static function scaleToFit(originalWidth:Float, originalHeight:Float, targetWidth:Float, targetHeight:Float):Float {
		var widthRatio = targetWidth / originalWidth;
		var heightRatio = targetHeight / originalHeight;
		if (widthRatio < heightRatio) {
			return widthRatio;
		}
		return heightRatio;
	}

	/**
		@since 1.0.0
	**/
	public static function scaleToFill(originalWidth:Float, originalHeight:Float, targetWidth:Float, targetHeight:Float):Float {
		var widthRatio = targetWidth / originalWidth;
		var heightRatio = targetHeight / originalHeight;
		if (widthRatio > heightRatio) {
			return widthRatio;
		}
		return heightRatio;
	}
}
