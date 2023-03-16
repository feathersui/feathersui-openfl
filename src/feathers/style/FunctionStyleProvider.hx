/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

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

	```haxe
	var button = new Button();
	button.text = "Click Me";
	button.styleProvider = new FunctionStyleProvider(function(target:Button):Void
	{
		target.backgroundSkin = new Bitmap(bitmapData);
		// set other styles...
	});
	this.addChild(button);
	```

	@event feathers.events.StyleProviderEvent.STYLES_CHANGE Dispatched when the
	styles have changed, and style objects should request for their styles to be
	re-applied.

	@see [Styling and skinning Feathers UI components](https://feathersui.com/learn/haxe-openfl/styling-and-skinning/)

	@since 1.0.0
**/
@:event(feathers.events.StyleProviderEvent.STYLES_CHANGE)
class FunctionStyleProvider extends EventDispatcher implements IStyleProvider {
	/**
		Creates a new `FunctionStyleProvider` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?callback:(Dynamic) -> Void) {
		super();
		// use the setter
		this.callback = callback;
	}

	private var _callback:(Dynamic) -> Void;

	/**
		The function that is called when this style provider is asked to apply
		styles to a target object.

		@since 1.0.0
	**/
	@:bindable("stylesChange")
	public var callback(get, set):(Dynamic) -> Void;

	private function get_callback():(Dynamic) -> Void {
		return this._callback;
	}

	private function set_callback(value:(Dynamic) -> Void):(Dynamic) -> Void {
		if (this._callback == value) {
			return this._callback;
		}
		this._callback = value;
		StyleProviderEvent.dispatch(this, StyleProviderEvent.STYLES_CHANGE);
		return this._callback;
	}

	/**
		Applies styles to the target object.

		@since 1.0.0
	**/
	public function applyStyles(target:IStyleObject):Void {
		if (this._callback == null) {
			return;
		}
		this._callback(target);
	}
}
