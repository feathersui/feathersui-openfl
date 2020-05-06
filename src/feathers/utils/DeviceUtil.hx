/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

#if html5
import js.html.Window;
import js.Lib;
#end
#if flash
import flash.ui.Mouse;
#end

/**
	Utility functions for determining the capabilities of the current device.

	@since 1.0.0
**/
class DeviceUtil {
	private static final MEDIA_QUERY_DESKTOP = "screen and (hover: hover) and (pointer: fine)";
	private static final MEDIA_QUERY_MOBILE = "screen and (hover: none) and (pointer: coarse)";

	/**
		Determines if the current device is likely a desktop computer or not.

		@since 1.0.0
	**/
	public static function isDesktop():Bool {
		#if mobile
		return false;
		#elseif desktop
		return true;
		#elseif flash
		return Mouse.supportsCursor;
		#elseif html5
		var htmlWindow = cast(Lib.global, Window);
		return htmlWindow.matchMedia(MEDIA_QUERY_DESKTOP).matches;
		#end
		return false;
	}

	/**
		Determines if the current device is likely a mobile device, such as a
		smartphone or tablet.

		@since 1.0.0
	**/
	public static function isMobile():Bool {
		#if mobile
		return true;
		#elseif desktop
		return false;
		#elseif flash
		return !Mouse.supportsCursor;
		#elseif html5
		var htmlWindow = cast(Lib.global, Window);
		return htmlWindow.matchMedia(MEDIA_QUERY_MOBILE).matches;
		#end
		return false;
	}
}
