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
	Sets styles on a Feathers UI component by passing the component to a
	callback function when the style provider's `applyStyles()` method is
	called.

	In the following example, a `FunctionStyleProvider` is created:

	```hx
	var button = new Button();
	button.text = "Click Me";
	button.styleProvider = new FunctionStyleProvider(function(target:Button):Void
	{
		target.backgroundSkin = new Bitmap(bitmapData);
		// set other styles...
	});
	this.addChild(button);
	```

	@see [Styling and skinning Feathers UI components](https://feathersui.com/learn/haxe-openfl/styling-and-skinning/)

	@since 1.0.0
**/
class FunctionStyleProvider extends EventDispatcher implements IStyleProvider {
	/**
		Creates a new `FunctionStyleProvider` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?callback:(Dynamic) -> Void) {
		super();
		this.callback = callback;
	}

	/**
		The function that is called when this style provider is asked to apply
		styles to a target object.

		@since 1.0.0
	**/
	public var callback(default, set):(Dynamic) -> Void;

	private function set_callback(value:(Dynamic) -> Void):(Dynamic) -> Void {
		if (this.callback == value) {
			return this.callback;
		}
		this.callback = value;
		StyleProviderEvent.dispatch(this, StyleProviderEvent.STYLES_CHANGE);
		return this.callback;
	}

	/**
		Applies styles to the target object.

		@since 1.0.0
	**/
	public function applyStyles(target:IStyleObject):Void {
		if (this.callback == null) {
			return;
		}
		this.callback(target);
	}
}
