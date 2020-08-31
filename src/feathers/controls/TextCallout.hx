/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.ITextControl;
import feathers.layout.RelativePositions;
import feathers.text.TextFormat;
import feathers.themes.steel.components.SteelTextCalloutStyles;
import openfl.display.DisplayObject;

/**
	A special type of `Callout` designed to display text only.

	In the following example, a text callout is shown when a `Button` is
	triggered:

	```hx
	function button_triggerHandler(event:TriggerEvent):Void
	{
		var button = cast(event.currentTarget, Button);
		TextCallout.show("Hello World", button);
	}
	button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
	```

	@see [Tutorial: How to use the TextCallout component](https://feathersui.com/learn/haxe-openfl/text-callout/)
	@see `TextCallout.show()`

	@since 1.0.0
**/
@:styleContext
class TextCallout extends Callout implements ITextControl {
	/**
		Creates a text callout, and then positions and sizes it automatically
		based based on an origin component and an optional set of positions.

		In the following example, a text callout is shown when a `Button` is
		triggered:

		```hx
		function button_triggerHandler(event:TriggerEvent):Void
		{
			var button = cast(event.currentTarget, Button);
			TextCallout.show("Hello World", button);
		}
		button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
		```

		@since 1.0.0
	**/
	public static function show(text:String, origin:DisplayObject, ?supportedPositions:RelativePositions, modal:Bool = true):TextCallout {
		var callout = new TextCallout();
		callout.text = text;
		return cast(Callout.showCallout(callout, origin, supportedPositions, modal), TextCallout);
	}

	/**
		Creates a new `TextCallout` object.

		In general, a `TextCallout` shouldn't be instantiated directly with the
		constructor. Instead, use the static function `TextCallout.show()` to
		create a `TextCallout`, as this often requires less pop-up management
		code.

		@see `TextCallout.show()`

		@since 1.0.0
	**/
	public function new() {
		initializeTextCalloutTheme();
		super();
	}

	private var label:Label;

	private var _text:String;

	/**
		The text displayed by the text callout.

		The following example creates a text callout and changes its text:

		```hx
		var callout = TextCallout.show("Good morning!", origin);
		callout.text = "Good afternoon!";
		```

		@see `TextCallout.textFormat`

		@since 1.0.0
	**/
	@:flash.property
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		this.setInvalid(DATA);
		return this._text;
	}

	/**
		The font styles used to render the text callout's text.

		In the following example, the text callout's formatting is customized:

		```hx
		callout.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextCallout.text`
		@see `TextCallout.disabledTextFormat`
		@see `TextCallout.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:TextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the callout uses embedded fonts:

		```hx
		callout.embedFonts = true;
		```

		@see `TextCallout.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	/**
		The font styles used to render the text callout's text when the text
		callout is disabled.

		In the following example, the text callout's disabled text formatting is
		customized:

		```hx
		callout.enabled = false;
		callout.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `TextCallout.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:TextFormat = null;

	private function initializeTextCalloutTheme():Void {
		SteelTextCalloutStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();
		if (this.label == null) {
			this.label = new Label();
			this.addChild(this.label);
			this.content = this.label;
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		super.update();
	}

	private function refreshTextStyles():Void {
		this.label.textFormat = this.textFormat;
		this.label.disabledTextFormat = this.disabledTextFormat;
		this.label.embedFonts = this.embedFonts;
	}

	private function refreshText():Void {
		this.label.text = this._text;
	}
}
