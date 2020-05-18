/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.display.DisplayObject;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.controls.supportClasses.TextFieldViewPort;
import feathers.core.IStateContext;
import feathers.core.ITextControl;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.themes.steel.components.SteelTextAreaStyles;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextFormat;

/**
	@since 1.0.0
**/
class TextArea extends BaseScrollContainer implements IStateContext<TextInputState> implements ITextControl {
	/**
		Creates a new `TextArea` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTextAreaTheme();

		super();

		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.textFieldViewPort = new TextFieldViewPort();
			this.textFieldViewPort.wordWrap = true;
			this.textFieldViewPort.multiline = true;
			this.textFieldViewPort.addEventListener(Event.CHANGE, textArea_viewPort_changeHandler);
			this.textFieldViewPort.addEventListener(FocusEvent.FOCUS_IN, textArea_viewPort_focusInHandler);
			this.textFieldViewPort.addEventListener(FocusEvent.FOCUS_OUT, textArea_viewPort_focusOutHandler);
			this.addChild(this.textFieldViewPort);
			this.viewPort = this.textFieldViewPort;
		}

		this.addEventListener(FocusEvent.FOCUS_IN, textArea_focusInHandler);
	}

	private var textFieldViewPort:TextFieldViewPort;

	override private function get_focusEnabled():Bool {
		return this.enabled && this.focusEnabled;
	}

	/**
		Indicates if the text area is editable.

		The following example disables editing:

		```hx
		textArea.editable = false;
		```

		@since 1.0.0
	**/
	public var editable(default, set):Bool = true;

	private function set_editable(value:Bool):Bool {
		if (this.editable == value) {
			return this.editable;
		}
		this.editable = value;
		this.setInvalid(InvalidationFlag.STATE);
		return this.editable;
	}

	/**
		The current state of the text area.

		@see `feathers.controls.TextInputState`
		@see `FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	public var currentState(get, null):TextInputState = ENABLED;

	private function get_currentState():TextInputState {
		return this.currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		if (this.enabled) {
			if (this.currentState == DISABLED) {
				this.changeState(ENABLED);
			}
		} else {
			this.changeState(DISABLED);
		}
		return this.enabled;
	}

	/**
		The text displayed by the text area.

		When the value of the `text` property changes, the text area will
		dispatch an event of type `Event.CHANGE`.

		The following example sets the text area's text:

		```hx
		textArea.text = "Good afternoon!";
		```

		@default ""

		@see `TextArea.textFormat`
		@see `openfl.events.Event.CHANGE`

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
		Indicates if scrolling is smooth or strictly by line.

		In the following example, smooth scrolling is enabled:

		```hx
		textArea.smoothScrolling = true;
		```

		@since 1.0.0
	**/
	@:style
	public var smoothScrolling:Bool = false;

	private var _stateToTextFormat:Map<TextInputState, TextFormat> = new Map();

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

	/**
		Determines if the text will wrap when reaching the right edge, or if
		horizontal scrolling will be required.

		In the following example, the text area will not wrap its text:

		```hx
		textArea.wordWrap = false;
		```

		@since 1.0.0
	**/
	@:style
	public var wordWrap:Bool = true;

	/**
		The minimum space, in pixels, between the view port's top edge and the
		text.

		In the following example, the text padding is set to 20 pixels on the
		top edge:

		```hx
		textArea.textPaddingTop = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var textPaddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the view port's right edge and
		the text.

		In the following example, the text padding is set to 20 pixels on the
		right edge:

		```hx
		textArea.textPaddingRight = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var textPaddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the view port's bottom edge and
		the text.

		In the following example, the text padding is set to 20 pixels on the
		bottom edge:

		```hx
		textArea.textPaddingBottom = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var textPaddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the view port's left edge and the
		text.

		In the following example, the text padding is set to 20 pixels on the
		left edge:

		```hx
		textArea.textPaddingLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var textPaddingLeft:Float = 0.0;

	private var _ignoreViewPortTextChange = false;

	override private function get_measureViewPort():Bool {
		return false;
	}

	private var _stateToSkin:Map<TextInputState, DisplayObject> = new Map();

	/**
		Gets the skin to be used by the text area when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, returns `null`.

		@see `TextArea.setSkinForState()`
		@see `TextArea.backgroundSkin`
		@see `TextArea.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	public function getSkinForState(state:TextInputState):DisplayObject {
		return this._stateToSkin.get(state);
	}

	/**
		Set the skin to be used by the text area when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, the value of the
		`backgroundSkin` property will be used instead.

		@see `TextArea.getSkinForState()`
		@see `TextArea.backgroundSkin`
		@see `TextArea.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	@style
	public function setSkinForState(state:TextInputState, skin:DisplayObject):Void {
		if (!this.setStyle("setSkinForState", state)) {
			return;
		}
		var oldSkin = this._stateToSkin.get(state);
		if (oldSkin != null && oldSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(oldSkin);
			this._currentBackgroundSkin = null;
		}
		if (skin == null) {
			this._stateToSkin.remove(state);
		} else {
			this._stateToSkin.set(state, skin);
		}
		this.setInvalid(InvalidationFlag.STYLES);
	}

	/**
		Gets the text format to be used by the text area when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, returns `null`.

		@see `TextArea.setTextFormatForState()`
		@see `TextArea.textFormat`
		@see `TextArea.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	public function getTextFormatForState(state:TextInputState):TextFormat {
		return this._stateToTextFormat.get(state);
	}

	/**
		Set the text format to be used by the text area when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `TextArea.getTextFormatForState()`
		@see `TextArea.textFormat`
		@see `TextArea.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	@style
	public function setTextFormatForState(state:TextInputState, textFormat:TextFormat):Void {
		if (!this.setStyle("setTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToTextFormat.remove(state);
		} else {
			this._stateToTextFormat.set(state, textFormat);
		}
		this.setInvalid(InvalidationFlag.STYLES);
	}

	private function initializeTextAreaTheme():Void {
		SteelTextAreaStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (stylesInvalid) {
			this.textFieldViewPort.textFormat = this.getCurrentTextFormat();
			this.textFieldViewPort.embedFonts = this.embedFonts;
			this.textFieldViewPort.wordWrap = this.wordWrap;
			this.textFieldViewPort.paddingTop = this.textPaddingTop;
			this.textFieldViewPort.paddingRight = this.textPaddingRight;
			this.textFieldViewPort.paddingBottom = this.textPaddingBottom;
			this.textFieldViewPort.paddingLeft = this.textPaddingLeft;
			this.textFieldViewPort.smoothScrolling = this.smoothScrolling;
		}

		if (dataInvalid) {
			var oldIgnoreViewPortTextChange = this._ignoreViewPortTextChange;
			this._ignoreViewPortTextChange = true;
			this.textFieldViewPort.text = this.text;
			this._ignoreViewPortTextChange = oldIgnoreViewPortTextChange;
			this.textFieldViewPort.restrict = this.restrict;
		}

		if (stateInvalid) {
			this.textFieldViewPort.enabled = this.enabled;
			this.textFieldViewPort.textFieldType = this.editable ? INPUT : DYNAMIC;
		}

		super.update();
	}

	override private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this.currentState);
		if (result != null) {
			return result;
		}
		return super.getCurrentBackgroundSkin();
	}

	private function getCurrentTextFormat():TextFormat {
		var result = this._stateToTextFormat.get(this.currentState);
		if (result != null) {
			return result;
		}
		return this.textFormat;
	}

	private function changeState(state:TextInputState):Void {
		if (!this.enabled) {
			state = DISABLED;
		}
		if (this.currentState == state) {
			return;
		}
		this.currentState = state;
		this.setInvalid(InvalidationFlag.STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	private function textArea_focusInHandler(event:FocusEvent):Void {
		if (Reflect.compare(event.target, this) == 0) {
			this.stage.focus = this.textFieldViewPort;
		}
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled || event.isDefaultPrevented()) {
			return;
		}
		switch (event.keyCode) {
			case Keyboard.UP:
			case Keyboard.DOWN:
			case Keyboard.LEFT:
			case Keyboard.RIGHT:
			case Keyboard.PAGE_UP:
			case Keyboard.PAGE_DOWN:
			case Keyboard.HOME:
			case Keyboard.END:
			default:
				return;
		}
		event.stopPropagation();
	}

	private function textArea_viewPort_changeHandler(event:Event):Void {
		if (this._ignoreViewPortTextChange) {
			return;
		}
		// don't try to use @:bypassAccessor here because we need to measure
		// again just in case it affected the maximum y scroll position
		this.text = this.textFieldViewPort.text;
	}

	private function textArea_viewPort_focusInHandler(event:FocusEvent):Void {
		this.changeState(FOCUSED);
	}

	private function textArea_viewPort_focusOutHandler(event:FocusEvent):Void {
		this.changeState(ENABLED);
	}
}
