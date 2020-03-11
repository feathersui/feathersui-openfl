/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import feathers.themes.steel.DefaultSteelTheme;

/**
	Register themes globally in a Feathers UI application. May apply to the
	entire application, or to the contents of a specific container.

	@since 1.0.0
**/
final class Theme {
	/**
		The fallback theme used when the primary theme does not provide styles
		for a target object. Generally, this function is only used internally
		by Feathers UI.

		@since 1.0.0
	**/
	public static var fallbackTheme(get, null):ITheme;

	private static function get_fallbackTheme():ITheme {
		#if !disable_default_theme
		if (fallbackTheme == null) {
			fallbackTheme = new DefaultSteelTheme();
		}
		#end
		return fallbackTheme;
	}

	private static var primaryTheme:ITheme;
	private static var roots:Array<DisplayObjectContainer> = null;
	private static var rootToTheme:Map<DisplayObjectContainer, ITheme>;

	/**
		Sets the application's theme, or the theme of a specific container.

		@since 1.0.0
	**/
	public static function setTheme(theme:ITheme, ?root:DisplayObjectContainer, disposeOldTheme:Bool = true):Void {
		var oldTheme:ITheme = null;
		if (root == null) {
			oldTheme = primaryTheme;
			primaryTheme = theme;
		} else {
			if (roots == null) {
				roots = [root];
				rootToTheme = [root => theme];
			} else {
				oldTheme = rootToTheme.get(root);
				if (oldTheme == null) {
					// TODO: keep themes sorted
					roots.push(root);
				}
				rootToTheme.set(root, theme);
			}
		}
		if (oldTheme != null && disposeOldTheme) {
			oldTheme.dispose();
		}
	}

	/**
		Returns the theme that applies to a specific object, or the primary
		theme, if no object is specified. Generally, this function is only used
		internally by Feathers UI.

		@since 1.0.0
	**/
	public static function getTheme(?object:IStyleObject):ITheme {
		if (roots != null && Std.is(object, DisplayObject)) {
			var displayObject = cast(object, DisplayObject);
			for (root in roots) {
				if (root.contains(displayObject)) {
					return rootToTheme.get(root);
				}
			}
		}
		if (primaryTheme != null) {
			return primaryTheme;
		}
		return fallbackTheme;
	}
}
