/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.controls.supportClasses.TextFieldViewPort;
import feathers.core.IStageFocusDelegate;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.ITextControl;
import feathers.core.InvalidationFlag;
import feathers.core.PopUpManager;
import feathers.events.FeathersEvent;
import feathers.text.TextFormat;
import feathers.themes.steel.components.SteelTextAreaStyles;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;

/**
	A text entry control that allows users to enter and edit multiple lines of
	uniformly-formatted text with the ability to scroll.

	The following example sets the text in a text area, selects the text, and
	listens for when the text value changes:

	```haxe
	var textArea = new TextArea();
	textArea.text = "Hello\nWorld"; //it's multiline!
	textArea.selectRange(0, textArea.text.length);
	textArea.addEventListener(Event.CHANGE, textArea_changeHandler);
	this.addChild( textArea );
	```

	@event openfl.events.Event.CHANGE Dispatched when `TextArea.text` changes.

	@see [Tutorial: How to use the TextArea component](https://feathersui.com/learn/haxe-openfl/text-area/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@defaultXmlProperty("text")
@:styleContext
class TextArea extends BaseScrollContainer implements IStateContext<TextInputState> implements ITextControl implements IStageFocusDelegate {
	private static final INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY = InvalidationFlag.CUSTOM("errorCalloutFactory");

	/**
		The variant used to style the error string `TextCallout` child component
		in a theme.

		To override this default variant, set the
		`TextArea.customErrorCalloutVariant` property.

		@see `TextArea.customErrorCalloutVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_ERROR_CALLOUT = "textArea_errorCallout";

	/**
		Creates a new `TextArea` object.

		@since 1.0.0
	**/
	public function new(text:String = "", ?prompt:String, ?changeListener:(Event) -> Void) {
		initializeTextAreaTheme();

		super();

		this.text = text;
		this.prompt = prompt;

		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.textFieldViewPort = new TextFieldViewPort();
			this.textFieldViewPort.wordWrap = true;
			this.textFieldViewPort.multiline = true;
			this.textFieldViewPort.addEventListener(Event.CHANGE, textArea_viewPort_changeHandler);
			this.addChild(this.textFieldViewPort);
			this.viewPort = this.textFieldViewPort;
		}

		this.addEventListener(FocusEvent.FOCUS_IN, textArea_focusInHandler);
		this.addEventListener(FocusEvent.FOCUS_OUT, textArea_focusOutHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var textFieldViewPort:TextFieldViewPort;
	private var promptTextField:TextField;
	private var errorStringCallout:TextCallout;

	private var _previousTextFormat:TextFormat = null;
	private var _previousSimpleTextFormat:openfl.text.TextFormat = null;
	private var _previousPrompt:String = null;
	private var _previousPromptTextFormat:TextFormat = null;
	private var _previousSimplePromptTextFormat:openfl.text.TextFormat = null;
	private var _updatedPromptStyles = false;
	private var _promptTextMeasuredWidth:Float;
	private var _promptTextMeasuredHeight:Float;

	@:getter(tabEnabled)
	override private function get_tabEnabled():Bool {
		return this._enabled && this.rawTabEnabled;
	}

	private var _editable:Bool = true;

	/**
		Indicates if the text area is editable.

		The following example disables editing:

		```haxe
		textArea.editable = false;
		```

		@since 1.0.0
	**/
	public var editable(get, set):Bool;

	private function get_editable():Bool {
		return this._editable;
	}

	private function set_editable(value:Bool):Bool {
		if (this._editable == value) {
			return this._editable;
		}
		this._editable = value;
		this.setInvalid(STATE);
		return this._editable;
	}

	private var _selectable:Bool = true;

	/**
		Indicates if the text can be selected.

		The following example disables selection:

		```haxe
		textArea.selectable = false;
		```

		@since 1.0.0
	**/
	public var selectable(get, set):Bool;

	private function get_selectable():Bool {
		return this._selectable;
	}

	private function set_selectable(value:Bool):Bool {
		if (this._selectable == value) {
			return this._selectable;
		}
		this._selectable = value;
		this.setInvalid(DATA);
		return this._selectable;
	}

	private var _currentState:TextInputState = ENABLED;

	/**
		The current state of the text area.

		@see `feathers.controls.TextInputState`
		@see `FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	public var currentState(get, never):#if flash Dynamic #else TextInputState #end;

	private function get_currentState():#if flash Dynamic #else TextInputState #end {
		return this._currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		this.refreshState();
		return this._enabled;
	}

	private var _text:String;

	/**
		The text displayed by the text area.

		When the value of the `text` property changes, the text area will
		dispatch an event of type `Event.CHANGE`.

		The following example sets the text area's text:

		```haxe
		textArea.text = "Good afternoon!";
		```

		@default ""

		@see `TextArea.textFormat`
		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	public var text(get, set):String;

	private function get_text():String {
		return this._text;
	}

	private function set_text(value:String):String {
		if (value == null) {
			// null gets converted to an empty string
			if (this._text.length == 0) {
				// already an empty string
				return this._text;
			}
			value = "";
		}
		if (this._text == value) {
			return this._text;
		}
		this._text = value;
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._text;
	}

	/**
		@see `feathers.controls.ITextControl.baseline`
	**/
	public var baseline(get, never):Float;

	private function get_baseline():Float {
		if (this.textFieldViewPort == null) {
			return 0.0;
		}
		return this.paddingTop + this.textFieldViewPort.baseline;
	}

	private var _prompt:String;

	/**
		The text displayed by the text area when the length of the `text`
		property is `0`.

		The following example sets the text area's prompt:

		```haxe
		textArea.prompt = "Minimum 8 characters required";
		```

		@default null

		@see `TextArea.promptTextFormat`

		@since 1.0.0
	**/
	public var prompt(get, set):String;

	private function get_prompt():String {
		return this._prompt;
	}

	private function set_prompt(value:String):String {
		if (this._prompt == value) {
			return this._prompt;
		}
		this._prompt = value;
		this.setInvalid(DATA);
		return this._prompt;
	}

	// for some reason, naming this _restrict fails in hxcpp
	private var __restrict:String;

	/**
		Limits the set of characters that may be typed into the `TextArea`.

		In the following example, the text area's allowed characters are
		restricted:

		```haxe
		textArea.restrict = "0-9";
		```

		@default null

		@see [`TextField.restrict`](https://api.openfl.org/openfl/text/TextField.html#restrict)

		@since 1.0.0
	**/
	public var restrict(get, set):String;

	private function get_restrict():String {
		return this.__restrict;
	}

	private function set_restrict(value:String):String {
		if (this.__restrict == value) {
			return this.__restrict;
		}
		this.__restrict = value;
		this.setInvalid(DATA);
		return this.__restrict;
	}

	private var _displayAsPassword:Bool = false;

	/**
		Masks the text so that it cannot be read.

		In the following example, the text area's text is displayed as a
		password:

		```haxe
		textArea.displayAsPassword = true;
		```

		@default null

		@see [`TextField.displayAsPassword`](https://api.openfl.org/openfl/text/TextField.html#displayAsPassword)

		@since 1.0.0
	**/
	public var displayAsPassword(get, set):Bool;

	private function get_displayAsPassword():Bool {
		return this._displayAsPassword;
	}

	private function set_displayAsPassword(value:Bool):Bool {
		if (this._displayAsPassword == value) {
			return this._displayAsPassword;
		}
		this._displayAsPassword = value;
		this.setInvalid(DATA);
		return this._displayAsPassword;
	}

	private var _errorString:String = null;

	/**
		Error text to display in a `TextCallout` when the text input has focus.
		When this value is not `null` the text area's `currentState` is
		changed to `TextInputState.ERROR`.

		An empty string will change the background, but no `TextCallout` will
		appear on focus.

		To clear an error, the `errorString` property must be set to `null`.

		The following example displays an error string:

		```haxe
		texterror.errorString = "Something is wrong";
		```

		@see `TextArea.currentState`

		@since 1.0.0
	**/
	public var errorString(get, set):String;

	private function get_errorString():String {
		return this._errorString;
	}

	private function set_errorString(value:String):String {
		if (this._errorString == value) {
			return this._errorString;
		}
		this._errorString = value;
		this.refreshState();
		this.setInvalid(DATA);
		return this._text;
	}

	/**
		Indicates if the callout for the `errorString` is currently open or
		closed.

		@see `TextInput.errorString`

		@since 1.0.0
	**/
	public var errorStringCalloutOpen(get, never):Bool;

	private function get_errorStringCalloutOpen():Bool {
		return this.errorStringCallout != null && this.errorStringCallout.parent != null;
	}

	/**
		Indicates if scrolling is smooth or strictly by line.

		In the following example, smooth scrolling is enabled:

		```haxe
		textArea.smoothScrolling = true;
		```

		@since 1.0.0
	**/
	@:style
	public var smoothScrolling:Bool = false;

	private var _stateToTextFormat:Map<TextInputState, AbstractTextFormat> = new Map();

	/**
		The font styles used to render the text area's text.

		In the following example, the text area's formatting is customized:

		```haxe
		textArea.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextArea.text`
		@see `TextArea.getTextFormatForState()`
		@see `TextArea.setTextFormatForState()`
		@see `TextArea.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the text area's text when the text area
		is disabled.

		In the following example, the text area's disabled text formatting is
		customized:

		```haxe
		textArea.enabled = false;
		textArea.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `TextArea.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the text area's prompt text.

		In the following example, the text area's prompt formatting is customized:

		```haxe
		textArea.promptTextFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextArea.prompt`

		@since 1.0.0
	**/
	@:style
	public var promptTextFormat:AbstractTextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the text area uses embedded fonts:

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
		textArea.textPaddingLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var textPaddingLeft:Float = 0.0;

	/**
		The character position of the anchor part of the selection. If the
		selection is changed with the arrow keys, the active index changes and
		the anchor index stays fixed. If both the active index and the anchor
		index are equal, then no text is selected and both values represent the
		position of the caret.

		@see `TextArea.selectionActiveIndex`
		@see `TextArea.selectRange()`
		@see `TextArea.selectAll()`

		@since 1.0.0
	**/
	public var selectionAnchorIndex(get, never):Int;

	private function get_selectionAnchorIndex():Int {
		return this.textFieldViewPort.selectionAnchorIndex;
	}

	/**
		The character position of the active part of the selection. If the
		selection is changed with the arrow keys, the active index changes and
		the anchor index stays fixed. If both the active index and the anchor
		index are equal, then no text is selected and both values represent the
		position of the caret.

		@see `TextArea.selectionAnchorIndex`
		@see `TextArea.selectRange()`
		@see `TextArea.selectAll()`

		@since 1.0.0
	**/
	public var selectionActiveIndex(get, never):Int;

	private function get_selectionActiveIndex():Int {
		return this.textFieldViewPort.selectionActiveIndex;
	}

	private var _maxChars:Int = 0;

	/**
		The maximum number of characters that may be entered into the text
		input. If set to `0`, the length of the text is unrestricted.

		@default 0

		@since 1.0.0
	**/
	public var maxChars(get, set):Int;

	private function get_maxChars():Int {
		return this._maxChars;
	}

	private function set_maxChars(value:Int):Int {
		if (this._maxChars == value) {
			return this._maxChars;
		}
		this._maxChars = value;
		this.setInvalid(DATA);
		return this._maxChars;
	}

	private var _previousCustomErrorCalloutVariant:String = null;

	/**
		A custom variant to set on the error callout, instead of
		`TextArea.CHILD_VARIANT_ERROR_CALLOUT`.

		The `customErrorCalloutVariant` will be not be used if the `TextCallout`
		already has a variant set.

		@see `TextArea.CHILD_VARIANT_ERROR_CALLOUT`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customErrorCalloutVariant:String = null;

	private var _ignoreViewPortTextChange = false;

	override private function get_measureViewPort():Bool {
		return false;
	}

	@:dox(hide)
	public var stageFocusTarget(get, never):InteractiveObject;

	private function get_stageFocusTarget():InteractiveObject {
		return this.textFieldViewPort;
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
		this.setInvalid(STYLES);
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
	public function getTextFormatForState(state:TextInputState):AbstractTextFormat {
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
	public function setTextFormatForState(state:TextInputState, textFormat:AbstractTextFormat):Void {
		if (!this.setStyle("setTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToTextFormat.remove(state);
		} else {
			this._stateToTextFormat.set(state, textFormat);
		}
		this.setInvalid(STYLES);
	}

	/**
		Selects the specified range of characters.

		The following example selects the first three characters:

		```haxe
		input.selectRange(0, 3);
		```

		@see `TextArea.selectAll()`
		@see `TextArea.selectionAnchorIndex`
		@see `TextArea.selectionActiveIndex`

		@since 1.0.0
	**/
	public function selectRange(anchorIndex:Int, activeIndex:Int):Void {
		this.textFieldViewPort.selectRange(anchorIndex, activeIndex);
	}

	/**
		Selects all of the text displayed by the text area.

		@see `TextArea.selectRange()`
		@see `TextArea.selectionAnchorIndex`
		@see `TextArea.selectionActiveIndex`

		@since 1.0.0
	**/
	public function selectAll():Void {
		this.textFieldViewPort.selectRange(0, this._text.length);
	}

	/**
		Sets all four text padding properties to the same value.

		@see `TextArea.textPaddingTop`
		@see `TextArea.textPaddingRight`
		@see `TextArea.textPaddingBottom`
		@see `TextArea.textPaddingLeft`

		@since 1.0.0
	**/
	public function setTextPadding(value:Float):Void {
		this.textPaddingTop = value;
		this.textPaddingRight = value;
		this.textPaddingBottom = value;
		this.textPaddingLeft = value;
	}

	override public function showFocus(show:Bool):Void {
		super.showFocus(show);
		if (show) {
			this.selectRange(this._text.length, 0);
		}
	}

	private function initializeTextAreaTheme():Void {
		SteelTextAreaStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomErrorCalloutVariant != this.customErrorCalloutVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY);
		}
		var errorCalloutFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY);

		this._updatedPromptStyles = false;

		// the state might not change if the text input has focus when
		// the error string changes, so check for data too!
		if (errorCalloutFactoryInvalid || dataInvalid) {
			this.createErrorCallout();
		}

		if (dataInvalid) {
			this.refreshPrompt();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshPromptStyles();
		}

		if (dataInvalid || stylesInvalid || sizeInvalid) {
			this.refreshPromptText(sizeInvalid);
		}

		if (stylesInvalid) {
			this.refreshTextStyles();
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
			this.textFieldViewPort.text = this._text;
			this._ignoreViewPortTextChange = oldIgnoreViewPortTextChange;
			this.textFieldViewPort.restrict = this.__restrict;
			this.textFieldViewPort.maxChars = this._maxChars;
			this.textFieldViewPort.displayAsPassword = this._displayAsPassword;
			if (this._editable) {
				this.textFieldViewPort.selectable = this._enabled;
			} else {
				this.textFieldViewPort.selectable = this._enabled && this._selectable;
			}
		}

		if (stateInvalid) {
			this.textFieldViewPort.enabled = this._enabled;
			this.textFieldViewPort.textFieldType = this._editable ? INPUT : DYNAMIC;
		}

		super.update();

		// the state might not change if the text input has focus when
		// the error string changes, so check for data too!
		if (errorCalloutFactoryInvalid || stateInvalid || dataInvalid) {
			this.refreshErrorString();
		}
		this._previousCustomErrorCalloutVariant = this.customErrorCalloutVariant;
	}

	override private function layoutChildren():Void {
		super.layoutChildren();
		this.layoutPrompt();
	}

	override private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin != null) {
			if ((skin is IStateObserver)) {
				cast(skin, IStateObserver).stateContext = this;
			}
		}
		super.addCurrentBackgroundSkin(skin);
	}

	override private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		super.removeCurrentBackgroundSkin(skin);
	}

	private function refreshTextStyles():Void {
		var textFormat = this.getCurrentTextFormat();
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (simpleTextFormat == this._previousSimpleTextFormat) {
			// nothing to refresh
			return;
		}
		if (this._previousTextFormat != null) {
			this._previousTextFormat.removeEventListener(Event.CHANGE, textArea_textFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, textArea_textFormat_changeHandler, false, 0, true);
			this.textFieldViewPort.textFormat = simpleTextFormat;
		}
		this._previousTextFormat = textFormat;
		this._previousSimpleTextFormat = simpleTextFormat;
	}

	private function refreshPrompt():Void {
		if (this._prompt == null) {
			if (this.promptTextField != null) {
				this.removeChild(this.promptTextField);
				this.promptTextField = null;
			}
			return;
		}
		if (this.promptTextField == null) {
			this.promptTextField = new TextField();
			this.promptTextField.selectable = false;
			this.promptTextField.mouseWheelEnabled = false;
			this.promptTextField.mouseEnabled = false;
			this.promptTextField.multiline = true;
			this.addChildAt(this.promptTextField, this.getChildIndex(this.textFieldViewPort));
		}
		this.promptTextField.visible = this._text.length == 0;
	}

	private function refreshPromptText(sizeInvalid:Bool):Void {
		if (this._prompt == null || this._prompt == this._previousPrompt && !this._updatedPromptStyles && !sizeInvalid) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.promptTextField.autoSize = LEFT;
		var hasText = this._prompt.length > 0;
		if (hasText) {
			this.promptTextField.text = this._prompt;
		} else {
			this.promptTextField.text = "\u200b"; // zero-width space
		}
		// to get an accurate measurement, we need to temporarily disable
		// wrapping to multiple lines
		this.promptTextField.wordWrap = false;
		this._promptTextMeasuredWidth = this.promptTextField.width;
		this._promptTextMeasuredHeight = this.promptTextField.height;
		this.promptTextField.autoSize = NONE;
		this.promptTextField.wordWrap = true;
		if (!hasText) {
			this.promptTextField.text = "";
		}
		this._previousPrompt = this._prompt;
	}

	private function refreshPromptStyles():Void {
		if (this._prompt == null) {
			return;
		}
		if (this.promptTextField.embedFonts != this.embedFonts) {
			this.promptTextField.embedFonts = this.embedFonts;
			this._updatedPromptStyles = true;
		}
		var textFormat = this.getCurrentPromptTextFormat();
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (simpleTextFormat == this._previousSimplePromptTextFormat) {
			// nothing to refresh
			return;
		}
		if (this._previousPromptTextFormat != null) {
			this._previousPromptTextFormat.removeEventListener(Event.CHANGE, textArea_promptTextFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, textArea_promptTextFormat_changeHandler, false, 0, true);
			this.promptTextField.defaultTextFormat = simpleTextFormat;
			this._updatedPromptStyles = true;
		}
		this._previousPromptTextFormat = textFormat;
		this._previousSimplePromptTextFormat = simpleTextFormat;
	}

	private function getCurrentPromptTextFormat():TextFormat {
		var textFormat = this.promptTextFormat;
		if (textFormat == null) {
			textFormat = this.textFormat;
		}
		return textFormat;
	}

	private function refreshErrorString():Void {
		if (this.errorStringCallout == null) {
			return;
		}

		this.errorStringCallout.text = this._errorString;
		if (this._currentState == FOCUSED && this.errorStringCallout.parent == null) {
			PopUpManager.addPopUp(this.errorStringCallout, this, false, false);
		} else if (this._currentState != FOCUSED && this.errorStringCallout.parent != null) {
			this.errorStringCallout.parent.removeChild(this.errorStringCallout);
		}
	}

	private function layoutPrompt():Void {
		if (this._prompt == null) {
			return;
		}

		this.promptTextField.x = this.leftViewPortOffset + this.textPaddingLeft;
		this.promptTextField.y = this.topViewPortOffset + this.textPaddingTop;

		var maxPromptWidth = this.viewPort.visibleWidth - this.textPaddingLeft - this.textPaddingRight;
		if (this._promptTextMeasuredWidth > maxPromptWidth) {
			#if flash
			this.promptTextField.autoSize = NONE;
			this.promptTextField.wordWrap = true;
			#end
			this.promptTextField.width = maxPromptWidth;
		} else {
			#if flash
			// this is workaround for a weird flash text measurement bug
			// sometimes, TextField width is wrong when autoSize is enabled,
			// and that causes the last word to wrap to the next line
			this.promptTextField.autoSize = LEFT;
			this.promptTextField.wordWrap = false;
			#end
			this.promptTextField.width = this._promptTextMeasuredWidth;
		}
		this.promptTextField.height = this.viewPort.visibleHeight - this.textPaddingTop - this.textPaddingBottom;
	}

	override private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this._currentState);
		if (result != null) {
			return result;
		}
		return super.getCurrentBackgroundSkin();
	}

	private function getCurrentTextFormat():TextFormat {
		var result = this._stateToTextFormat.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.disabledTextFormat != null) {
			return this.disabledTextFormat;
		}
		return this.textFormat;
	}

	private function createErrorCallout():Void {
		if (this.errorStringCallout != null) {
			if (this.errorStringCallout.parent != null) {
				this.errorStringCallout.parent.removeChild(this.errorStringCallout);
			}
			this.errorStringCallout = null;
		}

		if (this._errorString == null || this._errorString.length == 0) {
			return;
		}
		this.errorStringCallout = new TextCallout();
		if (this.errorStringCallout.variant == null) {
			this.errorStringCallout.variant = this.customErrorCalloutVariant != null ? this.customErrorCalloutVariant : TextInput.CHILD_VARIANT_ERROR_CALLOUT;
		}
		this.errorStringCallout.origin = this;
		this.errorStringCallout.closeOnPointerOutside = false;
	}

	private function changeState(state:TextInputState):Void {
		if (!this._enabled) {
			state = DISABLED;
		}
		if (this._currentState == state) {
			return;
		}
		this._currentState = state;
		this.setInvalid(STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	private function refreshState():Void {
		if (this._enabled) {
			// this component can have focus while its text editor does not
			// have focus. StageText, in particular, can't receive focus
			// when its enabled property is false, but we still want to show
			// that the input is focused.
			var focused = this.stage != null && this.stage.focus == this.textFieldViewPort.textField;
			if (focused) {
				this.changeState(FOCUSED);
			} else if (this._errorString != null) {
				this.changeState(ERROR);
			} else {
				this.changeState(ENABLED);
			}
		} else {
			this.changeState(TextInputState.DISABLED);
		}
	}

	private function textArea_focusInHandler(event:FocusEvent):Void {
		if (this.stage != null
			&& this.stage.focus != null
			&& this.textFieldViewPort != null
			&& !this.textFieldViewPort.contains(this.stage.focus)) {
			event.stopImmediatePropagation();
			this.stage.focus = this.textFieldViewPort;
		}
		this.refreshState();
	}

	private function textArea_focusOutHandler(event:FocusEvent):Void {
		this.refreshState();
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		// ignore default scrolling behavior because TextField will handle it
	}

	private function textArea_viewPort_changeHandler(event:Event):Void {
		if (this._ignoreViewPortTextChange) {
			return;
		}
		// don't try to skip the setter because we need to measure again. the
		// new text may result in a different maximum y scroll position.
		this.text = this.textFieldViewPort.text;
	}

	private function textArea_textFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function textArea_promptTextFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}
}
