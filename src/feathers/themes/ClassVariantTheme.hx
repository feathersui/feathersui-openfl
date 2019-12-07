/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes;

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
		if (!this.styleProvider.canApplyStyles(target)) {
			// if there's no style function, fall back to the default theme
			return null;
		}
		// use the same style provider for all objects
		return this.styleProvider;
	}

	@:dox(hide)
	public function dispose():Void {
		FeathersEvent.dispatch(this.styleProvider, Event.CLEAR);
	}
}
