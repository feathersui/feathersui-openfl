/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.layout.RelativePosition;
import feathers.themes.steel.components.SteelTextCalloutStyles;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextField;
import feathers.core.InvalidationFlag;
import feathers.core.ITextControl;
import openfl.display.DisplayObject;

/**
	@since 1.0.0
**/
@:styleContext
class TextCallout extends Callout implements ITextControl {
	public static function show(text:String, origin:DisplayObject, ?supportedPositions:Callout.RelativePositions, modal:Bool = true):TextCallout {
		var callout = new TextCallout();
		callout.text = text;
		return cast(Callout.showCallout(callout, origin, supportedPositions, modal), TextCallout);
	}

	/**
		Creates a new `TextCallout` object.

		@see `TextCallout.show`

		@since 1.0.0
	**/
	public function new() {
		initializeTextCalloutTheme();
		super();
	}

	private var label:Label;

	@:isVar
	public var text(get, set):String;

	private function get_text():String {
		return this.text;
	}

	private function set_text(value:String):String {
		if (this.text == value) {
			return this.text;
		}
		this.text = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.text;
	}

	@:style
	public var textFormat:TextFormat = null;

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
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		super.update();
	}

	private function refreshTextStyles():Void {
		this.label.textFormat = textFormat;
		this.label.disabledTextFormat = disabledTextFormat;
	}

	private function refreshText():Void {
		this.label.text = this.text;
	}
}
