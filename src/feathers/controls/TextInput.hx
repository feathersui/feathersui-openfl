/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.IStageFocusDelegate;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.core.PopUpManager;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.layout.VerticalAlign;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
import openfl.text.TextField;
import openfl.text.TextFieldType;

/**
	A text entry control that allows users to enter and edit a single line of
	uniformly-formatted text.

	The following example sets the text in a text input, selects the text,
	and listens for when the text value changes:

	```haxe
	var input = new TextInput();
	input.text = "Hello World";
	input.selectRange(0, input.text.length);
	input.addEventListener(Event.CHANGE, input_changeHandler);
	this.addChild(input);
	```

	@event openfl.events.Event.CHANGE Dispatched when `TextInput.text` changes.

	@event openfl.events.Event.SCROLL Dispatched when `TextInput.scrollX`
	changes.

	@see [Tutorial: How to use the TextInput component](https://feathersui.com/learn/haxe-openfl/text-input/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(openfl.events.Event.SCROLL)
@defaultXmlProperty("text")
@:styleContext
class TextInput extends FeathersControl implements IStateContext<TextInputState> implements ITextControl implements IStageFocusDelegate {
	private static final INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY = InvalidationFlag.CUSTOM("errorCalloutFactory");

	/**
		A variant used to style the text input as a search box. Variants allow
		themes to provide an assortment of different appearances for the same
		type of UI component.

		The following example uses this variant:

		```haxe
		var input = new TextInput();
		input.variant = Label.VARIANT_SEARCH;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_SEARCH = "search";

	/**
		The variant used to style the error string `TextCallout` child component
		in a theme.

		To override this default variant, set the
		`TextInput.customErrorCalloutVariant` property.

		@see `TextInput.customErrorCalloutVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_ERROR_CALLOUT = "textInput_errorCallout";

	private static final defaultErrorCalloutFactory = DisplayObjectFactory.withClass(TextCallout);

	/**
		Creates a new `TextInput` object.

		@since 1.0.0
	**/
	public function new(text:String = "", ?prompt:String, ?changeListener:(Event) -> Void) {
		initializeTextInputTheme();

		super();

		this.text = text;
		this.prompt = prompt;

		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = null;

		this.addEventListener(FocusEvent.FOCUS_IN, textInput_focusInHandler);
		this.addEventListener(FocusEvent.FOCUS_OUT, textInput_focusOutHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var _editable:Bool = true;

	/**
		Indicates if the text input is editable.

		The following example disables editing:

		```haxe
		textInput.editable = false;
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
		If the `editable` property is `false`, indicates if the text can still
		be selected. If the `editable` property is `true`, the text is always
		selectable, and this property is ignored.

		The following example disables selection:

		```haxe
		textInput.editable = false;
		textInput.selectable = false;
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
		this.setInvalid(STATE);
		return this._selectable;
	}

	@:dox(hide)
	public var stageFocusTarget(get, never):InteractiveObject;

	private function get_stageFocusTarget():InteractiveObject {
		return this.textField;
	}

	private var _currentState:TextInputState = ENABLED;

	/**
		The current state of the text input.

		@see `feathers.controls.TextInputState`
		@see `FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	@:bindable("stateChange")
	public var currentState(get, never):#if flash Dynamic #else TextInputState #end;

	private function get_currentState():#if flash Dynamic #else TextInputState #end {
		return this._currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		this.refreshState();
		return this._enabled;
	}

	private var _backgroundSkinMeasurements:Measurements = null;
	private var _currentBackgroundSkin:DisplayObject = null;

	/**
		The default background skin for the text input, which is used when no
		other skin is defined for the current state with `setSkinForState()`.

		The following example passes a bitmap for the text input to use as a
		background skin:

		```haxe
		input.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `TextInput.getSkinForState()`
		@see `TextInput.setSkinForState()`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		Indicates if the prompt is shown when the length of the text is `0` and
		the text input is focused. Keeping the prompt visible until the user
		types something is considered better for usability because the user may
		look away for a moment and forget the prompt when they return.

		The following example set the prompt to be hidden when focused and the
		text is empty:

		```haxe
		input.showPromptWhenEmptyAndFocused = false;
		```

		@since 1.1.0
	**/
	@:style
	public var showPromptWhenEmptyAndFocused:Bool = true;

	private var _currentLeftView:DisplayObject;
	private var _leftViewMeasurements:Measurements;
	private var _ignoreLeftViewResize = false;

	/**
		An optional view displayed inside the text input, to the left of its
		text.

		The following example passes a bitmap for the text input to use as a
		left view:

		```haxe
		input.leftView = new Bitmap(bitmapData);
		```

		@see `TextInput.rightView`
		@see `TextInput.leftViewGap`

		@since 1.0.0
	**/
	@:style
	public var leftView:DisplayObject = null;

	/**
		The gap between the left view and the text.

		The following example sets the left view's gap to 20 pixels:

		```haxe
		input.leftViewGap = 20.0;
		```

		@see `TextInput.leftView`

		@since 1.0.0
	**/
	@:style
	public var leftViewGap:Float = 0.0;

	private var _currentRightView:DisplayObject;
	private var _rightViewMeasurements:Measurements;
	private var _ignoreRightViewResize = false;

	/**
		An optional view displayed inside the text input, to the right of its
		text.

		The following example passes a bitmap for the text input to use as a
		right view:

		```haxe
		input.rightView = new Bitmap(bitmapData);
		```

		@see `TextInput.leftView`
		@see `TextInput.rightViewGap`

		@since 1.0.0
	**/
	@:style
	public var rightView:DisplayObject = null;

	/**
		The gap between the right view and the text.

		The following example sets the right view's gap to 20 pixels:

		```haxe
		input.rightViewGap = 20.0;
		```

		@see `TextInput.rightView`

		@since 1.0.0
	**/
	@:style
	public var rightViewGap:Float = 0.0;

	private var _stateToSkin:Map<TextInputState, DisplayObject> = new Map();

	private var textField:TextField;
	private var promptTextField:TextField;
	private var errorStringCallout:TextCallout;

	private var _previousText:String = null;
	private var _previousMeasureText:String = null;
	private var _previousPrompt:String = null;
	private var _previousTextFormat:TextFormat = null;
	private var _previousSimpleTextFormat:openfl.text.TextFormat;
	private var _previousPromptTextFormat:TextFormat = null;
	private var _previousPromptSimpleTextFormat:openfl.text.TextFormat;
	private var _updatedTextStyles = false;
	private var _updatedPromptStyles = false;

	private var _text:String;

	/**
		The text displayed by the text input.

		When the value of the `text` property changes, the text input will
		dispatch an event of type `Event.CHANGE`.

		The following example sets the text input's text:

		```haxe
		input.text = "Good afternoon!";
		```

		@default ""

		@see `TextInput.textFormat`
		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	@:bindable("change")
	@:inspectable
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

	private var _measureText:String = null;

	/**
		If not `null`, the dimensions of the `measureText` will be used in the
		calculation of the text input's width. If the text input's width hasn't
		been set explicitly, its calculated dimensions will be at least large
		enough to display the `measureText`. If other children of the text
		input, such as the background skin or the prompt text is larger than the
		width of the `measureText`, the text input will choose the largest
		required width.

		@since 1.0.0
	**/
	public var measureText(get, set):String;

	private function get_measureText():String {
		return this._measureText;
	}

	private function set_measureText(value:String):String {
		if (this._measureText == value) {
			return this._measureText;
		}
		this._measureText = value;
		this.setInvalid(DATA);
		return this._measureText;
	}

	/**
		@see `feathers.core.ITextControl.baseline`
	**/
	public var baseline(get, never):Float;

	private function get_baseline():Float {
		if (this.textField == null) {
			return 0.0;
		}
		// usually, hasText doesn't check the length, but TextField height may
		// not be accurate with an empty string
		var hasText = this._text != null && this._text.length > 0;
		if (!hasText) {
			this.textField.text = "\u200b";
			var result = this.textField.y + this.textField.getLineMetrics(0).ascent;
			this.textField.text = "";
			return result;
		}
		return this.textField.y + this.textField.getLineMetrics(0).ascent;
	}

	private var _prompt:String;

	/**
		The text displayed by the text input when the length of the `text`
		property is `0`.

		The following example sets the text input's prompt:

		```haxe
		input.prompt = "Minimum 8 characters required";
		```

		@default null

		@see `TextInput.promptTextFormat`

		@since 1.0.0
	**/
	@:inspectable
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

	// for some reason, naming this _restrict fails in hxcpp, and __restrict
	// fails in hl/c. how many underscores to work everywhere?
	private var ___restrict:String;

	/**
		Limits the set of characters that may be typed into the `TextInput`.

		In the following example, the text input's allowed characters are
		restricted:

		```haxe
		input.restrict = "0-9";
		```

		@default null

		@see [`TextField.restrict`](https://api.openfl.org/openfl/text/TextField.html#restrict)

		@since 1.0.0
	**/
	public var restrict(get, set):String;

	private function get_restrict():String {
		return this.___restrict;
	}

	private function set_restrict(value:String):String {
		if (this.___restrict == value) {
			return this.___restrict;
		}
		this.___restrict = value;
		this.setInvalid(DATA);
		return this.___restrict;
	}

	private var _displayAsPassword:Bool = false;

	/**
		Masks the text so that it cannot be read.

		In the following example, the text input's text is displayed as a
		password:

		```haxe
		input.displayAsPassword = true;
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
		When this value is not `null` the text input's `currentState` is
		changed to `TextInputState.ERROR`.

		An empty string will change the background, but no `TextCallout` will
		appear on focus.

		To clear an error, the `errorString` property must be set to `null`.

		The following example displays an error string:

		```haxe
		input.errorString = "Something is wrong";
		```

		@see `TextInput.currentState`

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
		return this._errorString;
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
		The font styles used to render the text input's text.

		In the following example, the text input's formatting is customized:

		```haxe
		input.textFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextInput.text`
		@see `TextInput.getTextFormatForState()`
		@see `TextInput.setTextFormatForState()`
		@see `TextInput.embedFonts`

		@since 1.0.0
	**/
	@:style
	public var textFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the text input's text when the text input
		is disabled.

		In the following example, the text input's disabled text formatting is
		customized:

		```haxe
		input.enabled = false;
		input.disabledTextFormat = new TextFormat("Helvetica", 20, 0xee0000);
		```

		@see `TextInput.textFormat`

		@since 1.0.0
	**/
	@:style
	public var disabledTextFormat:AbstractTextFormat = null;

	/**
		The font styles used to render the text input's prompt text.

		In the following example, the text input's prompt formatting is customized:

		```haxe
		input.promptTextFormat = new TextFormat("Helvetica", 20, 0xcc0000);
		```

		@see `TextInput.prompt`

		@since 1.0.0
	**/
	@:style
	public var promptTextFormat:AbstractTextFormat = null;

	/**
		Determines if an embedded font is used or not.

		In the following example, the text input uses embedded fonts:

		```haxe
		input.embedFonts = true;
		```

		@see `TextInput.textFormat`

		@since 1.0.0
	**/
	@:style
	public var embedFonts:Bool = false;

	/**
		Determines the type of anti-aliasing used for embedded fonts.

		In the following example, the text input uses advanced anti-aliasing:

		```haxe
		textInput.embedFonts = true;
		textInput.antiAliasType = ADVANCED;
		```

		@see `TextInput.embedFonts`
		@see `TextInput.gridFitType`

		@since 1.4.0
	**/
	@:style
	public var antiAliasType:AntiAliasType = NORMAL;

	/**
		Determines the type of anti-aliasing used for embedded fonts.

		In the following example, the text input uses sub-pixel grid fitting:

		```haxe
		textInput.embedFonts = true;
		textInput.antiAliasType = ADVANCED;
		textInput.gridFitType = SUBPIXEL;
		```

		@see `TextInput.antiAliasType`
		@see `TextInput.embedFonts`

		@since 1.4.0
	**/
	@:style
	public var gridFitType:GridFitType = PIXEL;

	private var _stateToTextFormat:Map<TextInputState, AbstractTextFormat> = new Map();

	/**
		The minimum space, in pixels, between the text input's top edge and the
		text input's content.

		In the following example, the text input's top padding is set to 20
		pixels:

		```haxe
		input.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the text input's right edge and
		the text input's content.

		In the following example, the text input's right padding is set to 20
		pixels:

		```haxe
		input.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the text input's bottom edge and
		the text input's content.

		In the following example, the text input's bottom padding is set to 20
		pixels:

		```haxe
		input.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the text input's left edge and the
		text input's content.

		In the following example, the text input's left padding is set to 20
		pixels:

		```haxe
		input.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		How the content is positioned vertically (along the y-axis) within the
		text input.

		The following example aligns the text input's content to the top:

		```haxe
		input.verticalAlign = TOP;
		```

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`

		@since 1.0.0
	**/
	@:style
	public var verticalAlign:VerticalAlign = MIDDLE;

	private var _scrollX:Float = 0.0;

	/**
		The horizontal scroll position (on the x-axis) of the text, measured in
		pixels.

		The following example changes the text input's scroll position:

		```haxe
		input.scrollX = 20.0;
		```

		@since 1.0.0
	**/
	@:bindable("scroll")
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		return this._scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this._scrollX == value) {
			return this._scrollX;
		}
		this._scrollX = value;
		this.setInvalid(SCROLL);
		FeathersEvent.dispatch(this, Event.SCROLL);
		return this._scrollX;
	}

	private var _pendingSelectionAnchorIndex:Int = -1;

	/**
		The character position of the anchor part of the selection. If the
		selection is changed with the arrow keys, the active index changes and
		the anchor index stays fixed. If both the active index and the anchor
		index are equal, then no text is selected and both values represent the
		position of the caret.

		@see `TextInput.selectionActiveIndex`
		@see `TextInput.selectRange()`
		@see `TextInput.selectAll()`

		@since 1.0.0
	**/
	public var selectionAnchorIndex(get, never):Int;

	private function get_selectionAnchorIndex():Int {
		if (this.textField != null && this._pendingSelectionAnchorIndex == -1) {
			// return the opposite of the caret index
			if (this.textField.caretIndex == this.textField.selectionBeginIndex) {
				return this.textField.selectionEndIndex;
			}
			return this.textField.selectionBeginIndex;
		}
		return this._pendingSelectionAnchorIndex;
	}

	private var _pendingSelectionActiveIndex:Int = -1;

	/**
		The character position of the active part of the selection. If the
		selection is changed with the arrow keys, the active index changes and
		the anchor index stays fixed. If both the active index and the anchor
		index are equal, then no text is selected and both values represent the
		position of the caret.

		@see `TextInput.selectionAnchorIndex`
		@see `TextInput.selectRange()`
		@see `TextInput.selectAll()`

		@since 1.0.0
	**/
	public var selectionActiveIndex(get, never):Int;

	private function get_selectionActiveIndex():Int {
		if (this.textField != null && this._pendingSelectionActiveIndex == -1) {
			// always the same as caret index
			return this.textField.caretIndex;
		}
		return this._pendingSelectionActiveIndex;
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

	/**
		Indicates if the text width is considered when calculating the ideal
		size of the text input.

		The following example changes the text input's auto size behavior:

		```haxe
		input.autoSizeWidth = true;
		```

		@since 1.0.0
	**/
	@:style
	public var autoSizeWidth:Bool = false;

	/**
		An alternate to `focusRectSkin` that is displayed when the text input is
		focused and `errorString` is not `null`.

		@since 1.3.0
	**/
	@:style
	public var errorFocusRectSkin:DisplayObject = null;

	private var _errorStatePriority:Int = 0;

	/**
		Sets the priority of `TextInputState.ERROR`. If two states are
		possible, the state with the higher priority takes precedence. If the
		priorities are equal, `TextInputState.FOCUSED` takes the default
		precedence.

		@since 1.3.0
	**/
	public var errorStatePriority(get, set):Int;

	private function get_errorStatePriority():Int {
		return this._errorStatePriority;
	}

	private function set_errorStatePriority(value:Int):Int {
		if (this._errorStatePriority == value) {
			return this._errorStatePriority;
		}
		this._errorStatePriority = value;
		this.setInvalid(STATE);
		return this._errorStatePriority;
	}

	private var _focusedStatePriority:Int = 0;

	/**
		Sets the priority of `TextInputState.FOCUSED`. If two states are
		possible, the state with the higher priority takes precedence. If the
		priorities are equal, `TextInputState.FOCUSED` takes the default
		precedence.

		@since 1.3.0
	**/
	public var focusedStatePriority(get, set):Int;

	private function get_focusedStatePriority():Int {
		return this._errorStatePriority;
	}

	private function set_focusedStatePriority(value:Int):Int {
		if (this._focusedStatePriority == value) {
			return this._focusedStatePriority;
		}
		this._focusedStatePriority = value;
		this.setInvalid(STATE);
		return this._focusedStatePriority;
	}

	private var _oldErrorCalloutFactory:DisplayObjectFactory<Dynamic, TextCallout>;

	private var _errorCalloutFactory:DisplayObjectFactory<Dynamic, TextCallout>;

	/**
		Creates the error callout, which must be of type
		`feathers.controls.TextCallout`.

		In the following example, a custom error callout factory is provided:

		```haxe
		textInput.errorCalloutFactory = () ->
		{
			return new TextCallout();
		};
		```

		@see `feathers.controls.TextCallout`

		@since 1.3.0
	**/
	public var errorCalloutFactory(get, set):AbstractDisplayObjectFactory<Dynamic, TextCallout>;

	private function get_errorCalloutFactory():AbstractDisplayObjectFactory<Dynamic, TextCallout> {
		return this._errorCalloutFactory;
	}

	private function set_errorCalloutFactory(value:AbstractDisplayObjectFactory<Dynamic, TextCallout>):AbstractDisplayObjectFactory<Dynamic, TextCallout> {
		if (this._errorCalloutFactory == value) {
			return this._errorCalloutFactory;
		}
		this._errorCalloutFactory = value;
		this.setInvalid(INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY);
		return this._errorCalloutFactory;
	}

	private var _previousCustomErrorCalloutVariant:String = null;

	/**
		A custom variant to set on the error callout, instead of
		`TextInput.CHILD_VARIANT_ERROR_CALLOUT`.

		The `customErrorCalloutVariant` will be not be used if the `TextCallout`
		already has a variant set.

		@see `TextInput.CHILD_VARIANT_ERROR_CALLOUT`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customErrorCalloutVariant:String = null;

	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;
	private var _promptTextMeasuredWidth:Float;
	private var _promptTextMeasuredHeight:Float;

	/**
		Gets the skin to be used by the text input when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, returns `null`.

		@see `TextInput.setSkinForState()`
		@see `TextInput.backgroundSkin`
		@see `TextInput.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	public function getSkinForState(state:TextInputState):DisplayObject {
		return this._stateToSkin.get(state);
	}

	/**
		Set the skin to be used by the text input when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, the value of the
		`backgroundSkin` property will be used instead.

		@see `TextInput.getSkinForState()`
		@see `TextInput.backgroundSkin`
		@see `TextInput.currentState`
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
		Gets the text format to be used by the text input when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, returns `null`.

		@see `TextInput.setTextFormatForState()`
		@see `TextInput.textFormat`
		@see `TextInput.currentState`
		@see `feathers.controls.TextInputState`

		@since 1.0.0
	**/
	public function getTextFormatForState(state:TextInputState):AbstractTextFormat {
		return this._stateToTextFormat.get(state);
	}

	/**
		Set the text format to be used by the text input when its `currentState`
		property matches the specified state value.

		If a text format is not defined for a specific state, the value of the
		`textFormat` property will be used instead.

		@see `TextInput.getTextFormatForState()`
		@see `TextInput.textFormat`
		@see `TextInput.currentState`
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

		@see `TextInput.selectAll()`
		@see `TextInput.selectionAnchorIndex`
		@see `TextInput.selectionActiveIndex`

		@since 1.0.0
	**/
	public function selectRange(anchorIndex:Int, activeIndex:Int):Void {
		// we can't call textField.setSelection() directly here because the
		// TextField may not have been updated yet
		this._pendingSelectionAnchorIndex = anchorIndex;
		this._pendingSelectionActiveIndex = activeIndex;
		this.setInvalid(SELECTION);
	}

	/**
		Selects all of the text displayed by the text input.

		@see `TextInput.selectRange()`
		@see `TextInput.selectionAnchorIndex`
		@see `TextInput.selectionActiveIndex`

		@since 1.0.0
	**/
	public function selectAll():Void {
		this.selectRange(0, this._text.length);
	}

	/**
		Sets all four padding properties to the same value.

		@see `TextInput.paddingTop`
		@see `TextInput.paddingRight`
		@see `TextInput.paddingBottom`
		@see `TextInput.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	override public function showFocus(show:Bool):Void {
		super.showFocus(show);
		if (show) {
			this.selectRange(this._text.length, 0);
		}
	}

	override public function dispose():Void {
		this.destroyErrorCallout();
		super.dispose();
	}

	private function initializeTextInputTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelTextInputStyles.initialize();
		#end
	}

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.tabEnabled = false;
			// make sure that the TextField type is set right away so that the
			// TextInput can receive focus in openfl <= 9.2.0
			this.refreshTextFieldType();
			this.textField.addEventListener(Event.CHANGE, textInput_textField_changeHandler);
			this.textField.addEventListener(Event.SCROLL, textInput_textField_scrollHandler);
			this.addChild(this.textField);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var scrollInvalid = this.isInvalid(SCROLL);
		var selectionInvalid = this.isInvalid(SELECTION);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomErrorCalloutVariant != this.customErrorCalloutVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY);
		}
		var errorCalloutFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY);

		this._updatedTextStyles = false;
		this._updatedPromptStyles = false;

		// the state might not change if the text input has focus when
		// the error string changes, so check for data too!
		if (errorCalloutFactoryInvalid || dataInvalid) {
			this.createErrorCallout();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
			this.refreshLeftView();
			this.refreshRightView();
		}

		if (dataInvalid || stateInvalid) {
			this.refreshPrompt();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshPromptStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid || sizeInvalid) {
			this.refreshText(sizeInvalid);
		}

		if (dataInvalid || stylesInvalid || sizeInvalid) {
			this.refreshPromptText(sizeInvalid);
		}

		if (selectionInvalid) {
			this.refreshSelection();
		}

		if (scrollInvalid) {
			this.refreshScrollPosition();
		}

		this.measure();
		this.layoutContent();

		// the state might not change if the text input has focus when
		// the error string changes, so check for data too!
		if (errorCalloutFactoryInvalid || stateInvalid || dataInvalid) {
			this.refreshErrorString();
		}
		this._previousCustomErrorCalloutVariant = this.customErrorCalloutVariant;
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		this.addCurrentBackgroundSkin(this._currentBackgroundSkin);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this._currentState);
		if (result != null) {
			return result;
		}
		return this.backgroundSkin;
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		if ((skin is IStateObserver)) {
			(cast skin : IStateObserver).stateContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		if ((skin is IStateObserver)) {
			(cast skin : IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshLeftView():Void {
		var oldView = this._currentLeftView;
		this._currentLeftView = this.getCurrentLeftView();
		if (this._currentLeftView == oldView) {
			return;
		}
		this.removeCurrentLeftView(oldView);
		if (this._currentLeftView == null) {
			this._leftViewMeasurements = null;
			return;
		}
		if ((this._currentLeftView is IUIControl)) {
			(cast this._currentLeftView : IUIControl).initializeNow();
		}
		if (this._leftViewMeasurements == null) {
			this._leftViewMeasurements = new Measurements(this._currentLeftView);
		} else {
			this._leftViewMeasurements.save(this._currentLeftView);
		}
		if ((this._currentLeftView is IProgrammaticSkin)) {
			(cast this._currentLeftView : IProgrammaticSkin).uiContext = this;
		}
		if ((this._currentLeftView is IStateObserver)) {
			(cast this._currentLeftView : IStateObserver).stateContext = this;
		}
		this._currentLeftView.addEventListener(Event.RESIZE, textInput_leftView_resizeHandler, false, 0, true);
		this.addChild(this._currentLeftView);
	}

	private function getCurrentLeftView():DisplayObject {
		return this.leftView;
	}

	private function removeCurrentLeftView(view:DisplayObject):Void {
		if (view == null) {
			return;
		}
		view.removeEventListener(Event.RESIZE, textInput_leftView_resizeHandler);
		if ((view is IProgrammaticSkin)) {
			(cast view : IProgrammaticSkin).uiContext = null;
		}
		if ((view is IStateObserver)) {
			(cast view : IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._leftViewMeasurements.restore(view);
		if (view.parent == this) {
			this.removeChild(view);
		}
	}

	private function refreshRightView():Void {
		var oldView = this._currentRightView;
		this._currentRightView = this.getCurrentRightView();
		if (this._currentRightView == oldView) {
			return;
		}
		this.removeCurrentRightView(oldView);
		if (this._currentRightView == null) {
			this._rightViewMeasurements = null;
			return;
		}
		if ((this._currentRightView is IUIControl)) {
			(cast this._currentRightView : IUIControl).initializeNow();
		}
		if (this._rightViewMeasurements == null) {
			this._rightViewMeasurements = new Measurements(this._currentRightView);
		} else {
			this._rightViewMeasurements.save(this._currentRightView);
		}
		if ((this._currentRightView is IProgrammaticSkin)) {
			(cast this._currentRightView : IProgrammaticSkin).uiContext = this;
		}
		if ((this._currentRightView is IStateObserver)) {
			(cast this._currentRightView : IStateObserver).stateContext = this;
		}
		this._currentRightView.addEventListener(Event.RESIZE, textInput_rightView_resizeHandler, false, 0, true);
		this.addChild(this._currentRightView);
	}

	private function getCurrentRightView():DisplayObject {
		return this.rightView;
	}

	private function removeCurrentRightView(view:DisplayObject):Void {
		if (view == null) {
			return;
		}
		view.removeEventListener(Event.RESIZE, textInput_rightView_resizeHandler);
		if ((view is IProgrammaticSkin)) {
			(cast view : IProgrammaticSkin).uiContext = null;
		}
		if ((view is IStateObserver)) {
			(cast view : IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._rightViewMeasurements.restore(view);
		if (view.parent == this) {
			this.removeChild(view);
		}
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._backgroundSkinMeasurements != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if ((this._currentBackgroundSkin is IMeasureObject)) {
			measureSkin = cast this._currentBackgroundSkin;
		}
		if ((this._currentBackgroundSkin is IValidating)) {
			(cast this._currentBackgroundSkin : IValidating).validateNow();
		}

		var oldIgnoreLeftViewResize = this._ignoreLeftViewResize;
		this._ignoreLeftViewResize = true;
		var oldIgnoreRightViewResize = this._ignoreRightViewResize;
		this._ignoreRightViewResize = true;

		var measureLeftView:IMeasureObject = null;
		if ((this._currentLeftView is IMeasureObject)) {
			measureLeftView = cast this._currentLeftView;
		}
		if ((this._currentLeftView is IValidating)) {
			(cast this._currentLeftView : IValidating).validateNow();
		}

		var measureRightView:IMeasureObject = null;
		if ((this._currentRightView is IMeasureObject)) {
			measureRightView = cast this._currentRightView;
		}
		if ((this._currentRightView is IValidating)) {
			(cast this._currentRightView : IValidating).validateNow();
		}

		this._ignoreLeftViewResize = oldIgnoreLeftViewResize;
		this._ignoreRightViewResize = oldIgnoreRightViewResize;

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this.autoSizeWidth || this._measureText != null) {
				newWidth = this._textMeasuredWidth;
			} else {
				newWidth = 0.0;
			}
			if (this._prompt != null) {
				newWidth = Math.max(newWidth, this._promptTextMeasuredWidth);
			}
			if (measureLeftView != null) {
				newWidth += measureLeftView.width + this.leftViewGap;
			} else if (this._leftViewMeasurements != null && this._leftViewMeasurements.width != null) {
				newWidth += this._leftViewMeasurements.width + this.leftViewGap;
			}
			if (measureRightView != null) {
				newWidth += measureRightView.width + this.rightViewGap;
			} else if (this._rightViewMeasurements != null && this._rightViewMeasurements.width != null) {
				newWidth += this._rightViewMeasurements.width + this.rightViewGap;
			}
			newWidth += this.paddingLeft + this.paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(this._currentBackgroundSkin.width, newWidth);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight;
			if (this._prompt != null) {
				newHeight = Math.max(newHeight, this._promptTextMeasuredHeight);
			}
			if (measureLeftView != null && newHeight < measureLeftView.height) {
				newHeight = measureLeftView.height;
			} else if (this._leftViewMeasurements != null && newHeight < this._leftViewMeasurements.height) {
				newHeight = this._leftViewMeasurements.height;
			}
			if (measureRightView != null && newHeight < measureRightView.height) {
				newHeight = measureRightView.height;
			} else if (this._rightViewMeasurements != null && newHeight < this._rightViewMeasurements.height) {
				newHeight = this._rightViewMeasurements.height;
			}
			newHeight += this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (this.autoSizeWidth || this._measureText != null) {
				newMinWidth = this._textMeasuredWidth;
			} else {
				newMinWidth = 0.0;
			}
			if (this._prompt != null) {
				newMinWidth = Math.max(newMinWidth, this._promptTextMeasuredWidth);
			}
			if (measureLeftView != null) {
				newMinWidth += measureLeftView.minWidth + this.leftViewGap;
			} else if (this._leftViewMeasurements != null && this._leftViewMeasurements.minWidth != null) {
				newMinWidth += this._leftViewMeasurements.minWidth + this.leftViewGap;
			}
			if (measureRightView != null) {
				newMinWidth += measureRightView.minWidth + this.rightViewGap;
			} else if (this._rightViewMeasurements != null && this._rightViewMeasurements.minWidth != null) {
				newMinWidth += this._rightViewMeasurements.minWidth + this.rightViewGap;
			}
			newMinWidth += this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMinWidth = Math.max(measureSkin.minWidth, newMinWidth);
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.minWidth != null) {
				newMinWidth = Math.max(this._backgroundSkinMeasurements.minWidth, newMinWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight;
			if (this._prompt != null) {
				newMinHeight = Math.max(newMinHeight, this._promptTextMeasuredHeight);
			}
			if (measureLeftView != null && newMinHeight < measureLeftView.minHeight) {
				newMinHeight = measureLeftView.minHeight;
			} else if (this._leftViewMeasurements != null && newMinHeight < this._leftViewMeasurements.minHeight) {
				newMinHeight = this._leftViewMeasurements.minHeight;
			}
			if (measureRightView != null && newMinHeight < measureRightView.minHeight) {
				newMinHeight = measureRightView.minHeight;
			} else if (this._rightViewMeasurements != null && newMinHeight < this._rightViewMeasurements.minHeight) {
				newMinHeight = this._rightViewMeasurements.minHeight;
			}
			newMinHeight += this.paddingTop + this.paddingBottom;
			if (measureSkin != null) {
				newMinHeight = Math.max(measureSkin.minHeight, newMinHeight);
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.minHeight != null) {
				newMinHeight = Math.max(this._backgroundSkinMeasurements.minHeight, newMinHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxWidth != null) {
				newMaxWidth = this._backgroundSkinMeasurements.maxWidth;
			} else {
				newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxHeight != null) {
				newMaxHeight = this._backgroundSkinMeasurements.maxHeight;
			} else {
				newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshTextFieldType():Void {
		if (this._enabled && this._editable && this.textField.type != TextFieldType.INPUT) {
			this.textField.type = TextFieldType.INPUT;
		} else if ((!this._enabled || !this._editable) && this.textField.type == TextFieldType.INPUT) {
			this.textField.type = TextFieldType.DYNAMIC;
		}
	}

	private function refreshTextStyles():Void {
		this.refreshTextFieldType();
		if (this.textField.embedFonts != this.embedFonts) {
			this.textField.embedFonts = this.embedFonts;
			this._updatedTextStyles = true;
		}
		if (this.textField.antiAliasType != this.antiAliasType) {
			this.textField.antiAliasType = this.antiAliasType;
			this._updatedTextStyles = true;
		}
		if (this.textField.gridFitType != this.gridFitType) {
			this.textField.gridFitType = this.gridFitType;
			this._updatedTextStyles = true;
		}
		if (this.textField.displayAsPassword != this._displayAsPassword) {
			this.textField.displayAsPassword = this._displayAsPassword;
			this._updatedTextStyles = true;
		}
		var textFormat = this.getCurrentTextFormat();
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (simpleTextFormat == this._previousSimpleTextFormat) {
			// nothing to refresh
			return;
		}
		if (this._previousTextFormat != null) {
			this._previousTextFormat.removeEventListener(Event.CHANGE, textInput_textFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, textInput_textFormat_changeHandler, false, 0, true);
			this.textField.defaultTextFormat = simpleTextFormat;
			this._updatedTextStyles = true;
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
			this.addChildAt(this.promptTextField, this.getChildIndex(this.textField));
		}
		this.promptTextField.selectable = false;
		this.promptTextField.mouseWheelEnabled = false;
		this.promptTextField.mouseEnabled = false;
		this.promptTextField.visible = this._text.length == 0
			&& (this.currentState != TextInputState.FOCUSED || this.showPromptWhenEmptyAndFocused);
	}

	private function refreshPromptText(forceMeasurement:Bool):Void {
		if (this._prompt == null || (this._prompt == this._previousPrompt && !this._updatedPromptStyles && !forceMeasurement)) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.promptTextField.autoSize = LEFT;
		var hasPromptText = this._prompt.length > 0;
		if (hasPromptText) {
			this.promptTextField.text = this._prompt;
		} else {
			this.promptTextField.text = "\u200b"; // zero-width space
		}
		this._promptTextMeasuredWidth = this.promptTextField.width;
		this._promptTextMeasuredHeight = this.promptTextField.height;
		this.promptTextField.autoSize = NONE;
		if (!hasPromptText) {
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
		if (this.promptTextField.antiAliasType != this.antiAliasType) {
			this.promptTextField.antiAliasType = this.antiAliasType;
			this._updatedPromptStyles = true;
		}
		if (this.promptTextField.gridFitType != this.gridFitType) {
			this.promptTextField.gridFitType = this.gridFitType;
			this._updatedPromptStyles = true;
		}
		var textFormat = this.getCurrentPromptTextFormat();
		var simpleTextFormat = textFormat != null ? textFormat.toSimpleTextFormat() : null;
		if (simpleTextFormat == this._previousPromptSimpleTextFormat) {
			// nothing to refresh
			return;
		}
		if (this._previousPromptTextFormat != null) {
			this._previousPromptTextFormat.removeEventListener(Event.CHANGE, textInput_promptTextFormat_changeHandler);
		}
		if (textFormat != null) {
			textFormat.addEventListener(Event.CHANGE, textInput_textFormat_changeHandler, false, 0, true);
			this.promptTextField.defaultTextFormat = simpleTextFormat;
			this._updatedPromptStyles = true;
		}
		this._previousPromptTextFormat = textFormat;
		this._previousPromptSimpleTextFormat = simpleTextFormat;
	}

	private function getCurrentPromptTextFormat():TextFormat {
		var textFormat = this.promptTextFormat;
		if (!this._enabled && this.disabledTextFormat != null) {
			textFormat = this.disabledTextFormat;
		}
		if (textFormat == null) {
			textFormat = this.textFormat;
		}
		return textFormat;
	}

	private function refreshText(forceMeasurement:Bool):Void {
		this.textField.restrict = this.___restrict;
		this.textField.maxChars = this._maxChars;
		if (this._editable) {
			this.textField.selectable = this._enabled;
		} else {
			this.textField.selectable = this._enabled && this._selectable;
		}
		var hasMeasureText = this._measureText != null;
		var measureText = hasMeasureText ? this._measureText : this._text;
		if (measureText == null || measureText.length == 0) {
			hasMeasureText = true;
			measureText = "\u200b"; // zero-width space
		}
		if (this._text == this._previousText
			&& measureText == this._previousMeasureText
			&& !this._updatedTextStyles
			&& !forceMeasurement) {
			// nothing to refresh
			return;
		}
		// set autoSize before text because setting text first can trigger an
		// extra text engine reflow
		this.textField.autoSize = LEFT;
		this.textField.text = measureText;
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = NONE;
		var finalText:String = null;
		if (this._text == null || this._text.length == 0) {
			finalText = "";
		} else if (hasMeasureText) {
			finalText = this._text;
		}
		if (finalText != null) {
			this.textField.text = finalText;
		}
		this._previousText = this._text;
		this._previousMeasureText = measureText;
	}

	private function refreshSelection():Void {
		if (this._pendingSelectionActiveIndex == -1 && this._pendingSelectionAnchorIndex == -1) {
			return;
		}
		var anchorIndex = this._pendingSelectionAnchorIndex;
		var activeIndex = this._pendingSelectionActiveIndex;
		this._pendingSelectionAnchorIndex = -1;
		this._pendingSelectionActiveIndex = -1;
		this.textField.setSelection(anchorIndex, activeIndex);
	}

	private function refreshScrollPosition():Void {
		this.textField.scrollH = Math.round(this._scrollX);
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

	private function layoutContent():Void {
		var oldIgnoreLeftViewResize = this._ignoreLeftViewResize;
		this._ignoreLeftViewResize = true;
		var oldIgnoreRightViewResize = this._ignoreRightViewResize;
		this._ignoreRightViewResize = true;

		this.layoutBackgroundSkin();

		var textFieldHeight = this._textMeasuredHeight;
		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (maxHeight < 0.0) {
			maxHeight = 0.0;
		}
		if (textFieldHeight > maxHeight || this.verticalAlign == JUSTIFY) {
			textFieldHeight = maxHeight;
		}
		if (textFieldHeight < 0.0) {
			textFieldHeight = 0.0;
		}
		this.textField.height = textFieldHeight;

		var leftViewOffset = 0.0;
		if (this._currentLeftView != null) {
			if ((this._currentLeftView is IValidating)) {
				(cast this._currentLeftView : IValidating).validateNow();
			}
			this._currentLeftView.x = this.paddingLeft;
			this._currentLeftView.y = Math.max(this.paddingTop, this.paddingTop + (maxHeight - this._currentLeftView.height) / 2.0);
			leftViewOffset = this._currentLeftView.width + this.leftViewGap;
		}
		var rightViewOffset = 0.0;
		if (this._currentRightView != null) {
			if ((this._currentRightView is IValidating)) {
				(cast this._currentRightView : IValidating).validateNow();
			}
			this._currentRightView.x = this.actualWidth - this.paddingRight - this._currentRightView.width;
			this._currentRightView.y = Math.max(this.paddingTop, this.paddingTop + (maxHeight - this._currentRightView.height) / 2.0);
			rightViewOffset = this._currentRightView.width + this.rightViewGap;
		}

		var textFieldWidth = this.actualWidth - this.paddingLeft - this.paddingRight - leftViewOffset - rightViewOffset;
		if (textFieldWidth < 0.0) {
			// flash may sometimes render a TextField with negative width
			// so make sure it is never smaller than 0.0
			textFieldWidth = 0.0;
		}
		this.textField.width = textFieldWidth;

		this.textField.x = this.paddingLeft + leftViewOffset;
		this.alignTextField(this.textField, textFieldHeight, maxHeight);

		if (this.promptTextField != null) {
			this.promptTextField.width = textFieldWidth;

			var textFieldHeight = this._promptTextMeasuredHeight;
			if (textFieldHeight > maxHeight || this.verticalAlign == JUSTIFY) {
				textFieldHeight = maxHeight;
			}
			if (textFieldHeight < 0.0) {
				textFieldHeight = 0.0;
			}
			this.promptTextField.height = textFieldHeight;

			this.promptTextField.x = this.paddingLeft + leftViewOffset;
			this.alignTextField(this.promptTextField, textFieldHeight, maxHeight);
		}
		this._ignoreLeftViewResize = oldIgnoreLeftViewResize;
		this._ignoreRightViewResize = oldIgnoreRightViewResize;
	}

	private inline function alignTextField(textField:TextField, textFieldHeight:Float, maxHeight:Float):Void {
		// performance: use the textFieldHeight variable instead of calling the
		// TextField height getter, which can trigger a text engine reflow
		switch (this.verticalAlign) {
			case TOP:
				textField.y = this.paddingTop;
			case BOTTOM:
				textField.y = this.actualHeight - this.paddingBottom - textFieldHeight;
			case JUSTIFY:
				textField.y = this.paddingTop;
			default: // middle or null
				textField.y = this.paddingTop + (maxHeight - textFieldHeight) / 2.0;
		}
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if ((this._currentBackgroundSkin is IValidating)) {
			(cast this._currentBackgroundSkin : IValidating).validateNow();
		}
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

	private function createErrorCallout():Void {
		this.destroyErrorCallout();
		if (this._errorString == null || this._errorString.length == 0) {
			return;
		}
		var factory = this._errorCalloutFactory != null ? this._errorCalloutFactory : defaultErrorCalloutFactory;
		this._oldErrorCalloutFactory = factory;
		this.errorStringCallout = factory.create();
		if (this.errorStringCallout.variant == null) {
			this.errorStringCallout.variant = this.customErrorCalloutVariant != null ? this.customErrorCalloutVariant : TextInput.CHILD_VARIANT_ERROR_CALLOUT;
		}
		this.errorStringCallout.origin = this;
		this.errorStringCallout.closeOnPointerOutside = false;
	}

	private function destroyErrorCallout():Void {
		if (this.errorStringCallout == null) {
			return;
		}
		if (this.errorStringCallout.parent != null) {
			this.errorStringCallout.parent.removeChild(this.errorStringCallout);
		}
		if (this._oldErrorCalloutFactory.destroy != null) {
			this._oldErrorCalloutFactory.destroy(this.errorStringCallout);
		}
		this._oldErrorCalloutFactory = null;
		this.errorStringCallout = null;
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

	override private function getCurrentFocusRectSkin():DisplayObject {
		if (this._errorString != null && this.errorFocusRectSkin != null) {
			return this.errorFocusRectSkin;
		}
		return super.getCurrentFocusRectSkin();
	}

	private function refreshState():Void {
		if (this._enabled) {
			// this component can have focus while its text editor does not
			// have focus. StageText, in particular, can't receive focus
			// when its enabled property is false, but we still want to show
			// that the input is focused.
			var focused = this.stage != null && this.stage.focus == this.textField;
			var error = this._errorString != null;
			if (focused && (!error || this._focusedStatePriority >= this._errorStatePriority)) {
				this.changeState(FOCUSED);
			} else if (error) {
				this.changeState(ERROR);
			} else {
				this.changeState(ENABLED);
			}
		} else {
			this.changeState(TextInputState.DISABLED);
		}
	}

	private function textInput_textField_changeHandler(event:Event):Void {
		// don't let this event bubble. Feathers UI components don't bubble their
		// events — especially not Event.CHANGE!
		event.stopPropagation();

		var oldText = this._text;
		var newText = this.textField.text;

		// no need to invalidate here. just store the new text.
		this._text = newText;
		// ...UNLESS the prompt needs to be shown or hidden as a result of the
		// changed text, or if autoSizeWidth is true
		var hasMeasureText = this._measureText != null;
		var measureText = hasMeasureText ? this._measureText : this._text;
		if (measureText == null || measureText.length == 0) {
			hasMeasureText = true;
			measureText = "\u200b"; // zero-width space
		}
		// usually, hasText doesn't check the length, but we display the prompt
		// when the text is null or the length is 0
		var hasText = this._text != null && this._text.length > 0;
		var hasOldText = oldText != null && oldText.length > 0;
		var hasPrompt = this._prompt != null && this._prompt.length > 0;
		if (this.autoSizeWidth || (hasPrompt && ((!hasText && hasOldText) || (hasText && !hasOldText)))) {
			// we need to measure, so invalidate
			this.setInvalid(DATA);
		} else {
			// we don't need to measure again, so just save the value
			this._previousMeasureText = measureText;
			this._previousText = this._text;
		}
		// either way, the event still needs to be dispatched
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function textInput_textField_scrollHandler(event:Event):Void {
		// no need to invalidate here. just store the new scroll position.
		this._scrollX = this.textField.scrollH;
		// but the event still needs to be dispatched
		FeathersEvent.dispatch(this, Event.SCROLL);
	}

	private function textInput_focusInHandler(event:FocusEvent):Void {
		if (this.stage != null && this.stage.focus != this.textField) {
			event.stopImmediatePropagation();
			this.stage.focus = this.textField;
		}
		this.refreshState();
	}

	private function textInput_focusOutHandler(event:FocusEvent):Void {
		this.refreshState();
	}

	private function textInput_textFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function textInput_promptTextFormat_changeHandler(event:Event):Void {
		this.setInvalid(STYLES);
	}

	private function textInput_leftView_resizeHandler(event:Event):Void {
		if (this._ignoreLeftViewResize) {
			return;
		}
		this.setInvalid(STYLES);
	}

	private function textInput_rightView_resizeHandler(event:Event):Void {
		if (this._ignoreRightViewResize) {
			return;
		}
		this.setInvalid(STYLES);
	}
}
