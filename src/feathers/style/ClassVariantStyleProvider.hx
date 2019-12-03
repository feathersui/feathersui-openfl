/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import feathers.events.FeathersEvent;
import feathers.core.IUIControl;
import haxe.rtti.Meta;
import openfl.events.Event;
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
	var styleProvider:ClassVariantStyleProvider = new ClassVariantStyleProvider();
	styleProvider.setFunctionForStyleName(Button, null, function(target:Button):Void {
		target.backgroundSkin = new Bitmap(bitmapData);
		// set other styles...
	});
	styleProvider.setFunctionForStyleName(Button, "alternate-button", function(target:Button):Void {
		target.backgroundSkin = new Bitmap(alternateBitmapData);
		// set other styles...
	});

	var button:Button = new Button();
	button.label = "Click Me";
	button.styleProvider = styleProvider;
	this.addChild(button);

	var alternateButton:Button = new Button()
	button.label = "No, click me!";
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

		 The function is expected to have the following signature:

		 ```hx
		 (IStyleObject) -> Void
		 ```
		@since 1.0.0
	**/
	public function setStyleFunction<T>(type:Class<T>, variant:String, callback:(T) -> Void):Void {
		if (styleTargets == null) {
			styleTargets = [];
		}
		var typeName = Type.getClassName(type);
		var styleTarget = variant == null ? Class(typeName) : ClassAndVariant(typeName, variant);
		if (callback == null) {
			styleTargets.remove(styleTarget);
		} else {
			styleTargets.set(styleTarget, callback);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		Gets a style function registered with `setStyleFunction)`.

		@since 1.0.0
	**/
	public function getStyleFunction<T>(type:Class<T>, variant:String):(T) -> Void {
		if (styleTargets == null) {
			return null;
		}
		var typeName = Type.getClassName(type);
		var styleTarget = variant == null ? Class(typeName) : ClassAndVariant(typeName, variant);
		return this.styleTargets.get(styleTarget);
	}

	/**
		Applies styles to a specific Feathers UI component.

		@since 1.0.0
	**/
	public function applyStyles(target:IStyleObject):Void {
		if (this.styleTargets == null) {
			return;
		}

		var styleContext:Class<IStyleObject> = null;
		var variant:String = null;
		if (Std.is(target, IUIControl)) {
			var uiControl = cast(target, IUIControl);
			styleContext = uiControl.styleContext;
			variant = uiControl.variant;
		}

		if (styleContext == null) {
			styleContext = Type.getClass(target);
		}

		var styleContextName = Type.getClassName(styleContext);
		var styleTarget = variant == null ? Class(styleContextName) : ClassAndVariant(styleContextName, variant);
		var callback = this.styleTargets.get(styleTarget);
		if (callback == null && variant != null) {
			// try again without the variant
			styleTarget = Class(styleContextName);
			callback = this.styleTargets.get(styleTarget);
		}
		if (callback == null) {
			return;
		}
		callback(target);
	}
}

private enum StyleTarget {
	Class(type:String);
	ClassAndVariant(type:String, variant:String);
}
