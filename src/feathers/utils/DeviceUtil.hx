/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

#if html5
import js.html.Window;
import js.Lib;
#end

/**
	@since 1.0.0
**/
class DeviceUtil {
	/**
		@since 1.0.0
	**/
	public static function isDesktop():Bool {
		#if desktop
		return true;
		#elseif html5
		var htmlWindow = cast(Lib.global, Window);
		if (htmlWindow.matchMedia("(hover: hover) and (pointer: fine)").matches) {
			return true;
		}
		#end
		return false;
	}
}
