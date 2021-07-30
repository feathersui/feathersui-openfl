/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.display.DisplayObjectContainer;
import feathers.core.IFocusContainer;
import feathers.core.IFocusExtras;
import feathers.core.IFocusObject;
import openfl.geom.Point;
import openfl.errors.ArgumentError;
import openfl.display.DisplayObject;

/**
	Focus utility functions.

	@see `feathers.core.FocusManager`

	@since 1.0.0
**/
class FocusUtil {
	public static function findAllFocusableObjects(target:DisplayObject, ?result:Array<IFocusObject>):Array<IFocusObject> {
		if (result == null) {
			result = [];
		}
		if ((target is IFocusObject)) {
			var focusableObject = cast(target, IFocusObject);
			if (focusableObject.focusEnabled) {
				result.push(focusableObject);
			}
		}
		if ((target is IFocusExtras)) {
			var focusExtras = cast(target, IFocusExtras);
			var extras = focusExtras.focusExtrasBefore;
			if (extras != null) {
				for (i in 0...extras.length) {
					var childOfTarget = extras[i];
					findAllFocusableObjects(childOfTarget, result);
				}
			}
		}
		if ((target is IFocusObject)) {
			if ((target is IFocusContainer) && cast(target, IFocusContainer).childFocusEnabled) {
				var otherContainer = cast(target, DisplayObjectContainer);
				for (i in 0...otherContainer.numChildren) {
					var childOfTarget = otherContainer.getChildAt(i);
					findAllFocusableObjects(childOfTarget, result);
				}
			}
		} else if ((target is DisplayObjectContainer)) {
			var otherContainer = cast(target, DisplayObjectContainer);
			for (i in 0...otherContainer.numChildren) {
				var childOfTarget = otherContainer.getChildAt(i);
				findAllFocusableObjects(childOfTarget, result);
			}
		}
		if ((target is IFocusExtras)) {
			var focusExtras = cast(target, IFocusExtras);
			var extras = focusExtras.focusExtrasAfter;
			if (extras != null) {
				for (i in 0...extras.length) {
					var childOfTarget = extras[i];
					findAllFocusableObjects(childOfTarget, result);
				}
			}
		}
		return result;
	}
}
