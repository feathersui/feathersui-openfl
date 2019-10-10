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
	private static final MEDIA_QUERY_DESKTOP = "screen and (hover: hover) and (pointer: fine)";
	private static final MEDIA_QUERY_MOBILE = "screen and (hover: none) and (pointer: coarse)";

	/**
		@since 1.0.0
	**/
	public static function isDesktop():Bool {
		#if desktop
		return true;
		#elseif html5
		var htmlWindow = cast(Lib.global, Window);
		return htmlWindow.matchMedia(MEDIA_QUERY_DESKTOP).matches;
		#end
		return false;
	}

	/**
		@since 1.0.0
	**/
	public static function isMobile():Bool {
		#if mobile
		return true;
		#elseif html5
		var htmlWindow = cast(Lib.global, Window);
		return htmlWindow.matchMedia(MEDIA_QUERY_MOBILE).matches;
		#end
		return false;
	}
}
