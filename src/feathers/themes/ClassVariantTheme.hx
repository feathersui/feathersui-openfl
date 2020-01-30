/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes;

import feathers.style.IVariantStyleObject;
import feathers.style.Theme;
import feathers.events.FeathersEvent;
import openfl.events.Event;
import feathers.style.IStyleObject;
import feathers.style.IStyleProvider;
import feathers.style.ClassVariantStyleProvider;
import feathers.style.ITheme;

/**
	A theme based on `ClassVariantStyleProvider`.

	@since 1.0.0
**/
class ClassVariantTheme implements ITheme {
	/**
		Creates a new `ClassVariantTheme` object.

		@since 1.0.0
	**/
	public function new() {}

	private var styleProvider:ClassVariantStyleProvider = new ClassVariantStyleProvider();

	@:dox(hide)
	public function getStyleProvider(target:IStyleObject):IStyleProvider {
		var styleContext:Class<IStyleObject> = null;
		var variant:String = null;
		if (Std.is(target, IVariantStyleObject)) {
			var variantObject = cast(target, IVariantStyleObject);
			styleContext = variantObject.styleContext;
			variant = variantObject.variant;
		}
		if (styleContext == null) {
			styleContext = Type.getClass(target);
		}
		// if this theme has an exact match for the variant, use it
		var styleFunction = this.styleProvider.getStyleFunction(styleContext, variant);
		if (styleFunction != null) {
			return this.styleProvider;
		}
		if (variant == null) {
			// we already tried with a null variant, and didn't find a match,
			// so there's nothing else to try.
			return null;
		}
		// next, check if the fallback theme has an exact match for the variant
		// in that case, we'll defer to the fallback theme
		var fallbackTheme = Theme.fallbackTheme;
		if (fallbackTheme != null && fallbackTheme != this && Std.is(fallbackTheme, ClassVariantTheme)) {
			// but only do that if the fallback theme is a ClassVariantTheme
			// if someone replaces the fallback theme with another type, there's
			// no way for us to know if it should be allowed to take precedence
			// or not.
			var fallbackStyleProvider = Std.downcast(fallbackTheme.getStyleProvider(target), ClassVariantStyleProvider);
			if (fallbackStyleProvider != null) {
				var styleFunction = fallbackStyleProvider.getStyleFunction(styleContext, variant);
				if (styleFunction != null) {
					return null;
				}
			}
		}
		// finally, if neither theme has an exact match for the variant, see
		// if this theme has a match for the context without a variant
		styleFunction = this.styleProvider.getStyleFunction(styleContext, null);
		if (styleFunction != null) {
			return this.styleProvider;
		}
		// no match, so defer to the fallback theme
		return null;
	}

	@:dox(hide)
	public function dispose():Void {
		FeathersEvent.dispatch(this.styleProvider, Event.CLEAR);
	}
}
