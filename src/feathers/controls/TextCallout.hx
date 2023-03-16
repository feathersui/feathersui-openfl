/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IHTMLTextControl;
import feathers.core.ITextControl;
import feathers.layout.RelativePositions;
import feathers.text.TextFormat;
import openfl.display.DisplayObject;
#if (openfl >= "9.2.0")
import openfl.text.StyleSheet;
#elseif flash
import flash.text.StyleSheet;
#end

/**
	A special type of `Callout` designed to display text only.

	In the following example, a text callout is shown when a `Button` is
	triggered:

	```haxe
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
@defaultXmlProperty("text")
@:styleContext
class TextCallout extends Callout implements ITextControl implements IHTMLTextControl {
	/**
		A variant used to style the callout in a style that indicates that
		something related to the origin is considered dangerous or in error.
		Variants allow themes to provide an assortment of different appearances
		for the same type of UI component.

		The following example uses this variant:

		```haxe
		callout.variant = TextCallout.VARIANT_DANGER;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_DANGER = "danger";

	/**
		Creates a text callout, and then positions and sizes it automatically
		based based on an origin component and an optional set of positions.

		In the following example, a text callout is shown when a `Button` is
		triggered:

		```haxe
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
		var callout = new TextCallout(text);
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
	public function new(text:String = "") {
		initializeTextCalloutTheme();
		super();

		this.text = text;
	}

	private var label:Label;

	private var _text:String;

	/**
		The text displayed by the text callout.

		The following example creates a text callout and changes its text:

		```haxe
		var callout = TextCallout.show("Good morning!", origin);
		callout.text = "Good afternoon!";
		```

		@see `TextCallout.textFormat`

		@since 1.0.0
	**/
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

	private var _htmlText:String = null;

	/**
		Text displayed by the callout that is parsed as a simple form of HTML.

		The following example sets the callout's HTML text:

		```haxe
		callout.htmlText = "<b>Hello</b> <i>World</i>";
		```

		@default null

		@see `TextCallout.text`
		@see [`openfl.text.TextField.htmlText`](https://api.openfl.org/openfl/text/TextField.html#htmlText)

		@since 1.0.0
	**/
	public var htmlText(get, set):String;

	private function get_htmlText():String {
		return this._htmlText;
	}

	private function set_htmlText(value:String):String {
		if (this._htmlText == value) {
			return this._htmlText;
		}
		this._htmlText = value;
		this.setInvalid(DATA);
		return this._htmlText;
	}

	/**
		@see `feathers.controls.ITextControl.baseline`
	**/
	public var baseline(get, never):Float;

	private function get_baseline():Float {
		if (this.label == null) {
			return 0.0;
		}
		return this.label.y + this.label.baseline;
	}

	/**
		The font styles used to render the text callout's text.

		In the following example, the text callout's formatting is customized:

		```haxe
		callout.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextCallout.text`
		@see `TextCallout.disabledTextFormat`
		@see `TextCallout.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	#if (openfl >= "9.2.0" || flash)
	/**
		A custom stylesheet to use with `htmlText`.

		If the `styleSheet` style is not `null`, the `textFormat` style will
		be ignored.

		@see `TextCallout.htmlText`

		@since 1.0.0
	**/
	@:style
	public var styleSheet:StyleSheet = null;
	#end

	/**
		Determines if an embedded font is used or not.

		In the following example, the callout uses embedded fonts:

		```haxe
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

		```haxe
		callout.enabled = false;
		callout.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `TextCallout.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	/**
		Determines if the text is displayed on a single line, or if it wraps.

		In the following example, the callout's text wraps at 150 pixels:

		```haxe
		callout.width = 150.0;
		callout.wordWrap = true;
		```

		@default false

		@since 1.0.0
	**/
	@:style
	public var wordWrap:Bool = false;

	private function initializeTextCalloutTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelTextCalloutStyles.initialize();
		#end
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
		this.label.wordWrap = this.wordWrap;
		this.label.textFormat = this.textFormat;
		this.label.disabledTextFormat = this.disabledTextFormat;
		this.label.embedFonts = this.embedFonts;
		#if (openfl >= "9.2.0" || flash)
		this.label.styleSheet = this.styleSheet;
		#end
	}

	private function refreshText():Void {
		this.label.text = this._text;
		this.label.htmlText = this._htmlText;
	}
}
