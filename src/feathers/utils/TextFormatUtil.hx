/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.text.TextFormat;

/**
	Utility functions for `openfl.text.TextFormat` objects.

	@since 1.0.0
**/
class TextFormatUtil {
	/**
		Creates a copy of the `openfl.text.TextFormat` object.

		@since 1.0.0
	**/
	public static function clone(original:TextFormat):TextFormat {
		var clone = new TextFormat(original.font, original.size, original.color, original.bold, original.italic, original.underline, original.url,
			original.target, original.align, original.leftMargin, original.rightMargin, original.indent, original.leading);
		clone.blockIndent = original.blockIndent;
		clone.bullet = original.bullet;
		clone.kerning = original.kerning;
		clone.letterSpacing = original.letterSpacing;
		clone.tabStops = original.tabStops;
		return clone;
	}
}
