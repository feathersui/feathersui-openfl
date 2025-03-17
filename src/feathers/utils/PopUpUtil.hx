/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.core.PopUpManager;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

/**
	Utility functions for working with the `PopUpManager`.

	@since 1.0.0
**/
class PopUpUtil {
	/**
		Determines if the display object is a top-level pop-up, or if it is
		contained by a top-level pop-up.

		@since 1.0.0
	**/
	public static function isTopLevelPopUpOrIsContainedByTopLevelPopUp(target:DisplayObject):Bool {
		if (target.stage == null) {
			return false;
		}
		var popUpManager = PopUpManager.forStage(target.stage);
		for (i in (popUpManager.popUpCount - popUpManager.topLevelPopUpCount)...popUpManager.popUpCount) {
			var popUp = popUpManager.getPopUpAt(i);
			if (target == popUp) {
				return true;
			}
			if ((popUp is DisplayObjectContainer)) {
				var popUpContainer:DisplayObjectContainer = cast popUp;
				if (popUpContainer.contains(target)) {
					return true;
				}
			}
		}
		return false;
	}
}
