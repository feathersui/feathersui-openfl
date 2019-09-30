/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.DefaultTheme;
import feathers.core.ITextControl;
import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.InvalidationFlag;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.VerticalAlign;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
	A text entry control that allows users to enter and edit a single line of
	uniformly-formatted text.

	The following example sets the text in a text input, selects the text,
	and listens for when the text value changes:

	```hx
	var input:TextInput = new TextInput();
	input.text = "Hello World";
	input.selectRange( 0, input.text.length );
	input.addEventListener( Event.CHANGE, input_changeHandler );
	this.addChild( input );
	```

	@see [Tutorial: How to use the TextInput component](https://feathersui.com/learn/haxe-openfl/text-input/)
	@see `feathers.controls.AutoComplete`
	@see `feathers.controls.TextArea`

	@since 1.0.0
**/
@:access(feathers.themes.DefaultTheme)
@:styleContext
class TextInput extends FeathersControl implements IStateContext<TextInputState> implements ITextControl {
	public function new() {
		var theme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(TextInput, null) == null) {
			theme.styleProvider.setStyleFunction(TextInput, null, setTextInputStyles);
		}
		super();
	}

	/**
		The current state of the text input.

		@see `feathers.controls.TextInputState`
		@see `FeathersEvent.STATE_CHANGE`

		@since 1.0.0
	**/
	public var currentState(get, null):TextInputState = TextInputState.ENABLED;

	private function get_currentState():TextInputState {
		return this.currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		if (this.enabled) {
			if (this.currentState == TextInputState.DISABLED) {
				this.changeState(TextInputState.ENABLED);
			}
		} else {
			this.changeState(TextInputState.DISABLED);
		}
		return this.enabled;
	}

	private var _backgroundSkinMeasurements:Measurements = null;
	private var _currentBackgroundSkin:DisplayObject = null;

	/**
		The default background skin for the text input, which is used when no
		other skin is defined for the current state with `setSkinForState()`.

		The following example gives the text input a default skin to use for all
		states when no specific skin is available:

		```hx
		input.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `TextInput.getSkinForState()`
		@see `TextInput.setSkinForState()`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	private var _stateToSkin:Map<TextInputState, DisplayObject> = new Map();
	private var textField:TextField;

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

	/**
		The minimum space, in pixels, between the text input's top edge and the
		text input's content.

		In the following example, the text input's top padding is set to 20
		pixels:

		```hx
		input.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Null<Float> = 0.0;

	/**
		The minimum space, in pixels, between the text input's right edge and
		the text input's content.

		In the following example, the text input's right padding is set to 20
		pixels:

		```hx
		input.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Null<Float> = 0.0;

	/**
		The minimum space, in pixels, between the text input's bottom edge and
		the text input's content.

		In the following example, the text input's bottom padding is set to 20
		pixels:

		```hx
		input.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Null<Float> = 0.0;

	/**
		The minimum space, in pixels, between the text input's left edge and the
		text input's content.

		In the following example, the text input's left padding is set to 20
		pixels:

		```hx
		input.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Null<Float> = 0.0;

	/**
		How the content is positioned vertically (along the y-axis) within the
		text input.

		The following example aligns the text input's content to the top:

		```hx
		input.verticalAlign = VerticalAlign.TOP;
		```

		@default `feathers.layout.VerticalAlign.MIDDLE`

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`
	**/
	@:style
	public var verticalAlign:VerticalAlign = VerticalAlign.MIDDLE;

	/**
		Gets the skin to be used by the text input when its `currentState`
		property matches the specified state value.

		If a skin is not defined for a specific state, returns `null`.

		@see `TextInput.backgroundSkin`
		@see `TextInput.setSkinForState()`
		@see `TextInput.currentState`

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

		@see `TextInput.backgroundSkin`
		@see `TextInput.getSkinForState()`
		@see `TextInput.currentState`

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

	private var _textMeasuredWidth:Float;
	private var _textMeasuredHeight:Float;

	override private function initialize():Void {
		super.initialize();
		if (this.textField == null) {
			this.textField = new TextField();
			this.textField.type = TextFieldType.INPUT;
			this.textField.selectable = true;
			this.textField.addEventListener(Event.CHANGE, textField_changeHandler);
			this.textField.addEventListener(FocusEvent.FOCUS_IN, textField_focusInHandler);
			this.textField.addEventListener(FocusEvent.FOCUS_OUT, textField_focusOutHandler);
			this.addChild(this.textField);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}

		if (dataInvalid || stylesInvalid || stateInvalid) {
			this.refreshText();
		}

		this.autoSizeIfNeeded();
		this.layoutContent();
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = this;
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this.currentState);
		if (result != null) {
			return result;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	/**
		If the component's dimensions have not been set explicitly, it will
		measure its content and determine an ideal size for itself. For
		instance, if the `explicitWidth` property is set, that value will be
		used without additional measurement. If `explicitWidth` is set, but
		`explicitHeight` is not (or the other way around), the dimension with
		the explicit value will not be measured, but the other non-explicit
		dimension will still require measurement.

		Calls `saveMeasurements()` to set up the `actualWidth` and
		`actualHeight` member variables used for layout.

		Meant for internal use, and subclasses may override this function with a
		custom implementation.

		@see `FeathersControl.saveMeasurements()`
		@see `FeathersControl.explicitWidth`
		@see `FeathersControl.explicitHeight`
		@see `FeathersControl.actualWidth`
		@see `FeathersControl.actualHeight`

		@since 1.0.0
	**/
	@:dox(show)
	private function autoSizeIfNeeded():Bool {
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
			this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this._currentBackgroundSkin != null) {
				newWidth = this._currentBackgroundSkin.width;
			} else {
				newWidth = 0.0;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(this._currentBackgroundSkin.height, newHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (measureSkin != null) {
				newMinWidth = measureSkin.minWidth;
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = this._backgroundSkinMeasurements.minWidth;
			} else {
				newMinWidth = 0.0;
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this._textMeasuredHeight + this.paddingTop + this.paddingBottom;
			if (measureSkin != null) {
				newMinHeight = Math.max(measureSkin.minHeight, newMinHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = Math.max(this._backgroundSkinMeasurements.minHeight, newMinHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureSkin != null) {
				newMaxWidth = measureSkin.maxWidth;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = this._backgroundSkinMeasurements.maxWidth;
			} else {
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureSkin != null) {
				newMaxHeight = measureSkin.maxHeight;
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = this._backgroundSkinMeasurements.maxHeight;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshTextStyles():Void {
		var textFormat = this.getCurrentTextFormat();
		if (textFormat != null) {
			this.textField.defaultTextFormat = textFormat;
		}
	}

	private function refreshText():Void {
		var hasText = this.text != null && this.text.length > 0;
		if (hasText) {
			this.textField.text = this.text;
		} else {
			this.textField.text = "\u8203"; // zero-width space
		}
		this.textField.autoSize = TextFieldAutoSize.LEFT;
		this._textMeasuredWidth = this.textField.width;
		this._textMeasuredHeight = this.textField.height;
		this.textField.autoSize = TextFieldAutoSize.NONE;
		if (!hasText) {
			this.textField.text = "";
		}
	}

	private function getCurrentTextFormat():TextFormat {
		if (!this.enabled && this.disabledTextFormat != null) {
			return this.disabledTextFormat;
		}
		return this.textFormat;
	}

	private function layoutContent():Void {
		this.layoutBackgroundSkin();

		this.textField.x = this.paddingLeft;
		this.textField.width = this.actualWidth - this.paddingLeft - this.paddingRight;

		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (this._textMeasuredHeight > maxHeight) {
			this.textField.height = maxHeight;
		} else {
			this.textField.height = this._textMeasuredHeight;
		}
		switch (this.verticalAlign) {
			case TOP:
				this.textField.y = this.paddingTop;
				this.textField.height = Math.min(maxHeight, this.textField.height);
			case BOTTOM:
				this.textField.y = this.actualHeight - this.paddingBottom - this.textField.height;
				this.textField.height = Math.min(maxHeight, this.textField.height);
			case JUSTIFY:
				this.textField.y = this.paddingTop;
				this.textField.height = maxHeight;
			default: // middle or null
				this.textField.y = this.paddingTop + (maxHeight - this.textField.height) / 2;
				this.textField.height = Math.min(maxHeight, this.textField.height);
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
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function changeState(state:TextInputState):Void {
		if (!this.enabled) {
			state = TextInputState.DISABLED;
		}
		if (this.currentState == state) {
			return;
		}
		this.currentState = state;
		this.setInvalid(InvalidationFlag.STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	private function textField_changeHandler(event:Event):Void {
		// don't let this event bubble. Feathers components don't bubble their
		// events — especially not Event.CHANGE!
		event.stopPropagation();

		this.text = this.textField.text;
	}

	private function textField_focusInHandler(event:FocusEvent):Void {
		this.changeState(TextInputState.FOCUSED);
	}

	private function textField_focusOutHandler(event:FocusEvent):Void {
		this.changeState(TextInputState.ENABLED);
	}

	private static function setTextInputStyles(input:TextInput):Void {
		var defaultTheme:DefaultTheme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (defaultTheme == null) {
			return;
		}

		if (input.backgroundSkin == null) {
			var inputSkin = new RectangleSkin();
			inputSkin.cornerRadius = 6.0;
			inputSkin.width = 160.0;
			inputSkin.fill = defaultTheme.getInsetFill();
			inputSkin.border = defaultTheme.getInsetBorder();
			inputSkin.setBorderForState(TextInputState.FOCUSED, defaultTheme.getThemeBorder());
			input.backgroundSkin = inputSkin;
		}

		if (input.textFormat == null) {
			input.textFormat = defaultTheme.getTextFormat();
		}
		if (input.disabledTextFormat == null) {
			input.disabledTextFormat = defaultTheme.getDisabledTextFormat();
		}

		input.paddingTop = 6.0;
		input.paddingRight = 10.0;
		input.paddingBottom = 6.0;
		input.paddingLeft = 10.0;
	}
}
