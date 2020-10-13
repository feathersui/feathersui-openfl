/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.errors.ArgumentError;
import openfl.display.DisplayObject;

/**
	Display list utility functions.

	@since 1.0.0
**/
class DisplayUtil {
	/**
		Calculates how many levels deep the target object is on the display
		list, starting from the stage. If the target object is the stage, the
		depth will be `0`. A direct child of the stage will have a depth of `1`,
		and it increases with each new level. If the object does not have a
		reference to the stage, the depth will always be `-1`, even if the
		object has a parent.

		@since 1.0.0
	**/
	public static function getDisplayObjectDepthFromStage(target:DisplayObject):Int {
		if (target.stage == null) {
			return -1;
		}
		var count:Int = 0;
		while (target.parent != null) {
			target = target.parent;
			count++;
		}
		return count;
	}

	/**
		Calculates the concatenated scale from the target display object to
		the stage.

		@since 1.0.0
	**/
	public static function getConcatenatedScale(target:DisplayObject, useY:Bool = false):Float {
		var result = 1.0;
		if (target == null) {
			throw new ArgumentError("getConcatenatedScale target must not be null");
		}
		var current = target;
		do {
			if (useY) {
				result /= current.scaleY;
			} else {
				result /= current.scaleX;
			}
			current = current.parent;
		} while (current != null && current != current.stage);
		return result;
	}
}
