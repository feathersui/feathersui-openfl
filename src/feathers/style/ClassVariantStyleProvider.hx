/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import feathers.events.StyleProviderEvent;
import openfl.events.EventDispatcher;

/**
	Similar to `FunctionStyleProvider`, sets styles on a Feathers UI component
	by passing it to a function, but also provides a way to define alternate
	functions that may be called based on the contents of the component's
	`variant` property.

	Alternate functions may be registered with the style provider by calling
	`setStyleFunction()` and passing in a variant name and a function. The
	style provider will search its registered variants to see if a function
	should be called. If the component's variant has not been registered with
	the style provider (or if the component has no variant), then the default
	style function will be called.

	In the following example, a `ClassVariantStyleProvider` is created with a
	a default style function and an alternate style function:

	```hx
	var styleProvider = new ClassVariantStyleProvider();
	styleProvider.setFunctionForStyleName(Button, null, (target:Button) -> {
		target.backgroundSkin = new Bitmap(bitmapData);
		// set other styles...
	});
	styleProvider.setFunctionForStyleName(Button, "alternate-button", (target:Button) -> {
		target.backgroundSkin = new Bitmap(alternateBitmapData);
		// set other styles...
	});

	var button = new Button();
	button.text = "Click Me";
	button.styleProvider = styleProvider;
	this.addChild(button);

	var alternateButton = new Button()
	button.text = "No, click me!";
	alternateButton.styleProvider = styleProvider;
	alternateButton.variant = "alternate-button";
	this.addChild(alternateButton);
	```

	@see [Styling and skinning Feathers UI components](https://feathersui.com/learn/haxe-openfl/styling-and-skinning/)

	@since 1.0.0
**/
class ClassVariantStyleProvider extends EventDispatcher implements IStyleProvider {
	/**
		Creates a new `ClassVariantStyleProvider` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var styleTargets:Map<StyleTarget, (Dynamic) -> Void>;

	/**
		The target Feathers UI component is passed to this function when
		`applyStyles()` is called and the component's `variant` property
		contains the specified value.

		@since 1.0.0
	**/
	public function setStyleFunction<T>(type:Class<T>, variant:String, callback:(T) -> Void):Void {
		if (styleTargets == null) {
			styleTargets = [];
		}
		var typeName = Type.getClassName(type);
		var styleTarget = variant == null ? Class(typeName) : ClassAndVariant(typeName, variant);
		if (callback == null) {
			if (!styleTargets.exists(styleTarget)) {
				// nothing changed
				return;
			}
			styleTargets.remove(styleTarget);
		} else {
			var oldCallback = styleTargets.get(styleTarget);
			if (Reflect.compareMethods(callback, oldCallback) || (Reflect.compare(callback, oldCallback) == 0)) {
				// nothing changed
				return;
			}
			styleTargets.set(styleTarget, callback);
		}
		StyleProviderEvent.dispatch(this, StyleProviderEvent.STYLES_CHANGE, (target:IStyleObject) -> {
			var styleContext:Class<IStyleObject> = this.getStyleContext(target);
			var variant:String = this.getVariant(target);
			var otherCallback:Dynamic = this.getStyleFunctionInternal(styleContext, variant, false);
			return Reflect.compareMethods(callback, otherCallback) || (Reflect.compare(callback, otherCallback) == 0);
		});
	}

	/**
		Gets a style function registered with `setStyleFunction`.

		@since 1.0.0
	**/
	public function getStyleFunction<T>(type:Class<T>, variant:String):(T) -> Void {
		return this.getStyleFunctionInternal(type, variant, true);
	}

	/**
		Applies styles to the target object.

		@since 1.0.0
	**/
	public function applyStyles(target:IStyleObject):Void {
		if (this.styleTargets == null) {
			return;
		}
		var styleContext:Class<IStyleObject> = this.getStyleContext(target);
		var variant:String = this.getVariant(target);
		var callback = this.getStyleFunctionInternal(styleContext, variant, false);
		if (callback == null) {
			return;
		}
		callback(target);
	}

	private function getStyleContext(target:IStyleObject):Class<IStyleObject> {
		var styleContext:Class<IStyleObject> = null;
		var variant:String = null;
		if (Std.is(target, IVariantStyleObject)) {
			var variantObject = cast(target, IVariantStyleObject);
			styleContext = variantObject.styleContext;
		}
		if (styleContext == null) {
			styleContext = Type.getClass(target);
		}
		return styleContext;
	}

	private function getVariant(target:IStyleObject):String {
		var variant:String = null;
		if (Std.is(target, IVariantStyleObject)) {
			var variantObject = cast(target, IVariantStyleObject);
			variant = variantObject.variant;
		}
		return variant;
	}

	private function getStyleFunctionInternal<T>(type:Class<T>, variant:String, strict:Bool):(T) -> Void {
		if (styleTargets == null) {
			return null;
		}
		var typeName = Type.getClassName(type);
		var styleTarget = variant == null ? Class(typeName) : ClassAndVariant(typeName, variant);
		var result = this.styleTargets.get(styleTarget);
		if (result != null || strict) {
			return result;
		}
		// if not strict, try again without the variant
		return this.styleTargets.get(Class(typeName));
	}
}

private enum StyleTarget {
	Class(type:String);
	ClassAndVariant(type:String, variant:String);
}
