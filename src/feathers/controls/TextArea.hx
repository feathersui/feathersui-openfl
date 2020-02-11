/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.controls.supportClasses.TextFieldViewPort;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.themes.steel.components.SteelTextAreaStyles;
import openfl.events.Event;
import openfl.text.TextFormat;

class TextArea extends BaseScrollContainer {
	/**
		Creates a new `TextArea` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTextAreaTheme();

		super();

		if (this.viewPort == null) {
			this.textFieldViewPort = new TextFieldViewPort();
			this.textFieldViewPort.textFieldType = INPUT;
			this.textFieldViewPort.wordWrap = true;
			this.textFieldViewPort.multiline = true;
			this.addChild(this.textFieldViewPort);
			this.viewPort = this.textFieldViewPort;
		}
	}

	private var textFieldViewPort:TextFieldViewPort;

	/**
		The text displayed by the text area.

		The following example sets the text area's text:

		```hx
		textArea.text = "Good afternoon!";
		```

		@default ""

		@see `TextArea.textFormat`

		@since 1.0.0
	**/
	@:isVar
	public var text(get, set):String = "";

	private function get_text():String {
		return this.text;
	}

	private function set_text(value:String):String {
		if (value == null) {
			// null gets converted to an empty string
			if (this.text.length == 0) {
				// already an empty string
				return this.text;
			}
			value = "";
		}
		if (this.text == value) {
			return this.text;
		}
		this.text = value;
		this.setInvalid(InvalidationFlag.DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.text;
	}

	/**
		Limits the set of characters that may be typed into the `TextArea`.

		In the following example, the text area's allowed characters are
		restricted:

		```hx
		textArea.restrict = "0-9";
		```

		@default null

		@see [`TextField.restrict`](https://api.openfl.org/openfl/text/TextField.html#restrict)

		@since 1.0.0
	**/
	public var restrict(default, set):String;

	private function set_restrict(value:String):String {
		if (this.restrict == value) {
			return this.restrict;
		}
		this.restrict = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.restrict;
	}

	/**
		The font styles used to render the text area's text.

		In the following example, the text area's formatting is customized:

		```hx
		textArea.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextArea.text`
		@see `TextArea.getTextFormatForState()`
		@see `TextArea.setTextFormatForState()`
		@see `TextArea.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:TextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the text area uses embedded fonts:

		```hx
		textArea.embedFonts = true;
		```

		@see `TextArea.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	private function initializeTextAreaTheme():Void {
		SteelTextAreaStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (stylesInvalid) {
			this.textFieldViewPort.textFormat = this.textFormat;
			this.textFieldViewPort.embedFonts = this.embedFonts;
		}

		if (dataInvalid) {
			this.textFieldViewPort.text = this.text;
		}

		if (stateInvalid) {
			this.textFieldViewPort.enabled = this.enabled;
		}

		super.update();
	}
}
