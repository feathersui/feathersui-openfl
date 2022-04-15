/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.Button;
import feathers.controls.IRange;
import feathers.controls.TextInput;
import feathers.core.FeathersControl;
import feathers.core.IStageFocusDelegate;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.layout.Direction;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.themes.steel.components.SteelNumericStepperStyles;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.ExclusivePointer;
import feathers.utils.MathUtil;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end

/**
	Select a value between a minimum and a maximum by using increment and
	decrement buttons or typing in a value in a text input.

	The following example sets the stepper's range and listens for when
	the value changes:

	```haxe
	var stepper = new NumericStepper();
	stepper.minimum = 0.o;
	stepper.maximum = 100.o;
	stepper.step = 1.0;
	stepper.value = 12.0;
	stepper.addEventListener(Event.CHANGE, stepper_changeHandler);
	addChild(stepper);
	```

	@event openfl.events.Event.CHANGE Dispatched when `NumericStepper.value`
	changes.

	@see [How to use the NumericStepper component](https://feathersui.com/learn/haxe-openfl/numeric-stepper/)
**/
@:event(openfl.events.Event.CHANGE)
class NumericStepper extends FeathersControl implements IRange implements IStageFocusDelegate {
	private static final INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY = InvalidationFlag.CUSTOM("decrementButtonFactory");
	private static final INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY = InvalidationFlag.CUSTOM("incrementButtonFactory");
	private static final INVALIDATION_FLAG_TEXT_INPUT_FACTORY = InvalidationFlag.CUSTOM("textInputFactory");

	/**
		The variant used to style the decrement `Button` child component in a theme.

		To override this default variant, set the
		`NumericStepper.customDecrementButtonVariant` property.

		@see `NumericStepper.customDecrementButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DECREMENT_BUTTON = "numericStepper_decrementButton";

	/**
		The variant used to style the increment `Button` child component in a theme.

		To override this default variant, set the
		`NumericStepper.customIncrementButtonVariant` property.

		@see `NumericStepper.customIncrementButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_INCREMENT_BUTTON = "numericStepper_incrementButton";

	/**
		The variant used to style the `TextInput` child component in a theme.

		To override this default variant, set the
		`NumericStepper.customTextInputVariant` property.

		@see `NumericStepper.customTextInputVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_TEXT_INPUT = "numericStepper_textInput";

	private static final defaultDecrementButtonFactory = DisplayObjectFactory.withClass(Button);

	private static final defaultIncrementButtonFactory = DisplayObjectFactory.withClass(Button);

	private static final defaultTextInputFactory = DisplayObjectFactory.withClass(TextInput);

	/**
		Creates a new `NumericStepper` object with the given arguments.

		@since 1.0.0
	**/
	public function new(value:Float = 0.0, minimum:Float = 0.0, maximum:Float = 1.0, ?changeListener:(Event) -> Void) {
		initializeNumericStepperTheme();

		super();

		this.addEventListener(FocusEvent.FOCUS_IN, numericStepper_focusInHandler);

		this.minimum = minimum;
		this.maximum = maximum;
		this.value = value;

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var decrementButton:Button;
	private var incrementButton:Button;
	private var textInput:TextInput;

	private var decrementButtonMeasurements = new Measurements();
	private var incrementButtonMeasurements = new Measurements();
	private var textInputMeasurements = new Measurements();

	private var _isDefaultValue = true;

	private var _value:Float = 0.0;

	/**
		The value of the stepper, which must be between the `minimum` and the
		`maximum`.

		When the `value` property changes, the stepper will dispatch an event of
		type `Event.CHANGE`.

		In the following example, the value is changed to `12.0`:

		```haxe
		stepper.minimum = 0.0;
		stepper.maximum = 100.0;
		stepper.step = 1.0;
		stepper.value = 12.0;
		```

		@default 0.0

		@see `NumericStepper.minimum`
		@see `NumericStepper.maximum`
		@see `NumericStepper.step`
		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	public var value(get, set):Float;

	private function get_value():Float {
		return this._value;
	}

	private function set_value(value:Float):Float {
		// don't restrict a value that has been passed in from an external
		// source to the minimum/maximum/snapInterval
		// assume that the user knows what they are doing
		if (this._value == value) {
			return this._value;
		}
		this._isDefaultValue = false;
		this._value = value;
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._value;
	}

	private var _minimum:Float = 0.0;

	/**
		The stepper's value cannot be smaller than the minimum.

		In the following example, the minimum is set to `-100.0`:

		```haxe
		stepper.minimum = -100.0;
		stepper.maximum = 100.0;
		stepper.step = 1.0;
		stepper.value = 50.0;
		```

		@default 0.0

		@see `NumericStepper.value`
		@see `NumericStepper.maximum`

		@since 1.0.0
	**/
	public var minimum(get, set):Float;

	private function get_minimum():Float {
		return this._minimum;
	}

	private function set_minimum(value:Float):Float {
		if (this._minimum == value) {
			return this._minimum;
		}
		this._minimum = value;
		this.setInvalid(DATA);
		return this._minimum;
	}

	private var _maximum:Float = 1.0;

	/**
		The stepper's value cannot be larger than the maximum.

		In the following example, the maximum is set to `100.0`:

		```haxe
		stepper.minimum = 0.0;
		stepper.maximum = 100.0;
		stepper.step = 1.0;
		stepper.value = 12.0;
		```

		@default 1.0

		@see `NumericStepper.value`
		@see `NumericStepper.minimum`

		@since 1.0.0
	**/
	public var maximum(get, set):Float;

	private function get_maximum():Float {
		return this._maximum;
	}

	private function set_maximum(value:Float):Float {
		if (this._maximum == value) {
			return this._maximum;
		}
		this._maximum = value;
		this.setInvalid(DATA);
		return this._maximum;
	}

	// this should not be 0.0 by default because 0.0 breaks keyboard events
	private var _step:Float = 0.01;

	/**
		Indicates the amount that `value` is changed when the stepper has focus
		and one of the arrow keys is pressed.

		In the following example, the step is changed to `1.0`:

		```haxe
		stepper.minimum = 0.0;
		stepper.maximum = 100.0;
		stepper.step = 1.0;
		stepper.value = 10.0;
		```

		@default 0.01

		@see `NumericStepper.value`
		@see `NumericStepper.minimum`
		@see `NumericStepper.maximum`
		@see `NumericStepper.snapInterval`

		@since 1.0.0
	**/
	public var step(get, set):Float;

	private function get_step():Float {
		return this._step;
	}

	private function set_step(value:Float):Float {
		if (this._step == value) {
			return this._step;
		}
		this._step = value;
		this.setInvalid(DATA);
		return this._step;
	}

	private var _snapInterval:Float = 0.0;

	/**
		When the stepper's `value` changes, it may be "snapped" to the nearest
		multiple of `snapInterval`. If `snapInterval` is `0.0`, the `value` is
		not snapped.

		In the following example, the snap inverval is changed to `1.0`:

		```haxe
		stepper.minimum = 0.0;
		stepper.maximum = 100.0;
		stepper.step = 1.0;
		stepper.snapInterval = 1.0;
		stepper.value = 10.0;
		```

		@default 0.0

		@see `NumericStepper.step`

		@since 1.0.0
	**/
	public var snapInterval(get, set):Float;

	private function get_snapInterval():Float {
		return this._snapInterval;
	}

	private function set_snapInterval(value:Float):Float {
		if (this._snapInterval == value) {
			return this._snapInterval;
		}
		this._snapInterval = value;
		this.setInvalid(DATA);
		return this._snapInterval;
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

	private var _valueFormatFunction:(Float) -> String;

	/**
		A callback that formats the numeric stepper's value as a string to
		display to the user.

		In the following example, the stepper's value format function is
		customized:

		```haxe
		stepper.valueFormatFunction = function(value:Float):String
		{
			return currencyFormatter.format(value, true);
		};
		```

		@since 1.0.0
	**/
	public var valueFormatFunction(get, set):(Float) -> String;

	private function get_valueFormatFunction():(Float) -> String {
		return this._valueFormatFunction;
	}

	private function set_valueFormatFunction(value:(Float) -> String):(Float) -> String {
		if (this._valueFormatFunction == value) {
			return this._valueFormatFunction;
		}
		this._valueFormatFunction = value;
		this.setInvalid(DATA);
		return this._valueFormatFunction;
	}

	private var _valueParseFunction:(String) -> Float;

	/**
		A callback that accepts the displayed text of the numeric stepper and
		converts it to a simple `Float` value.

		In the following example, the stepper's value parse function is
		customized:

		```haxe
		stepper.valueParseFunction = (displayedText:String):Float
		{
			return currencyFormatter.parse(displayedText).value;
		};
		```

		 @since 1.0.0
	**/
	public var valueParseFunction(get, set):(String) -> Float;

	private function get_valueParseFunction():(String) -> Float {
		return this._valueParseFunction;
	}

	private function set_valueParseFunction(value:(String) -> Float):(String) -> Float {
		if (this._valueParseFunction == value) {
			return this._valueParseFunction;
		}
		this._valueParseFunction = value;
		this.setInvalid(DATA);
		return this._valueParseFunction;
	}

	@:dox(hide)
	public var stageFocusTarget(get, never):InteractiveObject;

	private function get_stageFocusTarget():InteractiveObject {
		return this.textInput;
	}

	private var _oldDecrementButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _decrementButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the decrement button, which must be of type
		`feathers.controls.Button`.

		In the following example, a custom decrement button factory is provided:

		```haxe
		stepper.decrementButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	public var decrementButtonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_decrementButtonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._decrementButtonFactory;
	}

	private function set_decrementButtonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._decrementButtonFactory == value) {
			return this._decrementButtonFactory;
		}
		this._decrementButtonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		return this._decrementButtonFactory;
	}

	private var _oldIncrementButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _incrementButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the increment button, which must be of type
		`feathers.controls.Button`.

		In the following example, a custom increment button factory is provided:

		```haxe
		stepper.incrementButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	public var incrementButtonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_incrementButtonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._incrementButtonFactory;
	}

	private function set_incrementButtonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._incrementButtonFactory == value) {
			return this._incrementButtonFactory;
		}
		this._incrementButtonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		return this._incrementButtonFactory;
	}

	private var _oldTextInputFactory:DisplayObjectFactory<Dynamic, TextInput>;

	private var _textInputFactory:DisplayObjectFactory<Dynamic, TextInput>;

	/**
		Creates the text input, which must be of type
		`feathers.controls.TextInput`.

		In the following example, a custom text input factory is provided:

		```haxe
		stepper.textInputFactory = () ->
		{
			return new TextInput();
		};
		```

		@see `feathers.controls.TextInput`

		@since 1.0.0
	**/
	public var textInputFactory(get, set):AbstractDisplayObjectFactory<Dynamic, TextInput>;

	private function get_textInputFactory():AbstractDisplayObjectFactory<Dynamic, TextInput> {
		return this._textInputFactory;
	}

	private function set_textInputFactory(value:AbstractDisplayObjectFactory<Dynamic, TextInput>):AbstractDisplayObjectFactory<Dynamic, TextInput> {
		if (this._textInputFactory == value) {
			return this._textInputFactory;
		}
		this._textInputFactory = value;
		this.setInvalid(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		return this._textInputFactory;
	}

	private var _previousCustomDecrementButtonVariant:String = null;

	/**
		A custom variant to set on the decrement button, instead of
		`NumericStepper.CHILD_VARIANT_DECREMENT_BUTTON`.

		The `customDecrementButtonVariant` will be not be used if the result of
		`decrementButtonFactory` already has a variant set.

		@see `NumericStepper.CHILD_VARIANT_DECREMENT_BUTTON`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customDecrementButtonVariant:String = null;

	private var _previousCustomIncrementButtonVariant:String = null;

	/**
		A custom variant to set on the increment button, instead of
		`NumericStepper.CHILD_VARIANT_INCREMENT_BUTTON`.

		The `customIncrementButtonVariant` will be not be used if the result of
		`incrementButtonFactory` already has a variant set.

		@see `NumericStepper.CHILD_VARIANT_INCREMENT_BUTTON`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customIncrementButtonVariant:String = null;

	private var _previousCustomTextInputVariant:String = null;

	/**
		A custom variant to set on the text input, instead of
		`NumericStepper.CHILD_VARIANT_TEXT_INPUT`.

		The `customTextInputVariant` will be not be used if the result of
		`textInputFactory` already has a variant set.

		@see `NumericStepper.CHILD_VARIANT_TEXT_INPUT`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customTextInputVariant:String = null;

	/**
		The horizontal position of the text input, relative to the buttons.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:style
	public var textInputPosition:HorizontalAlign = CENTER;

	/**
		How the buttons are positioned, relative to each other.

		@since 1.0.0
	**/
	@:style
	public var buttonDirection:Direction = HORIZONTAL;

	private var _pendingTextInputChanges:Bool = false;

	override public function showFocus(show:Bool):Void {
		super.showFocus(show);
		if (this.textInput != null) {
			this.textInput.showFocus(show);
		}
	}

	/**
		Applies the `minimum`, `maximum`, and `snapInterval` restrictions to the
		current `value`.

		Because it's possible to set `value` to a numeric value that is outside
		the allowed range, or to a value that has not been snapped to the
		interval, this method may be called to apply the restrictions manually.

		@since 1.0.0
	**/
	public function applyValueRestrictions():Void {
		this.value = this.restrictValue(this._value);
	}

	private function initializeNumericStepperTheme():Void {
		SteelNumericStepperStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();
		// if the user hasn't changed the value, automatically restrict it based
		// on things like minimum, maximum, and snapInterval
		// if the user has changed the value, assume that they know what they're
		// doing and don't want hand holding
		if (this._isDefaultValue) {
			// use the setter
			this.value = this.restrictValue(this._value);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomTextInputVariant != this.customTextInputVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		}
		if (this._previousCustomDecrementButtonVariant != this.customDecrementButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		}
		if (this._previousCustomIncrementButtonVariant != this.customIncrementButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		}
		var decrementButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		var incrementButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		var textInputFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);

		if (decrementButtonFactoryInvalid) {
			this.createDecrementButton();
		}
		if (incrementButtonFactoryInvalid) {
			this.createIncrementButton();
		}
		if (textInputFactoryInvalid) {
			this.createTextInput();
		}

		if (stateInvalid) {
			this.refreshEnabled();
			this.refreshEditable();
		}

		if (dataInvalid) {
			this.refreshMeasureText();
		}

		if (dataInvalid) {
			this.refreshTextInputData();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		this.layoutContent();
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

		this.decrementButtonMeasurements.restore(this.decrementButton);
		this.decrementButton.validateNow();

		this.incrementButtonMeasurements.restore(this.incrementButton);
		this.incrementButton.validateNow();

		this.textInputMeasurements.restore(this.textInput);
		this.textInput.validateNow();

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			var buttonWidth = Math.max(this.decrementButton.width, this.incrementButton.width);
			if (this.buttonDirection == VERTICAL) {
				if (this.textInputPosition == CENTER) {
					newWidth = Math.max(this.textInput.width, buttonWidth);
				} else {
					newWidth = this.textInput.width + buttonWidth;
				}
			} else { // HORIZONTAL
				newWidth = (2.0 * buttonWidth) + this.textInput.width;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			var buttonHeight = Math.max(this.decrementButton.height, this.incrementButton.height);
			if (this.buttonDirection == VERTICAL) {
				if (this.textInputPosition == CENTER) {
					newHeight = (2.0 * buttonHeight) + this.textInput.height;
				} else {
					newHeight = Math.max(this.textInput.height, 2.0 * buttonHeight);
				}
			} else { // HORIZONTAL
				newHeight = Math.max(this.textInput.height, buttonHeight);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			var buttonWidth = Math.max(this.decrementButton.width, this.incrementButton.width);
			if (this.buttonDirection == VERTICAL) {
				if (this.textInputPosition == CENTER) {
					newMinWidth = Math.max(this.textInput.minWidth, buttonWidth);
				} else {
					newMinWidth = this.textInput.minWidth + buttonWidth;
				}
			} else { // HORIZONTAL
				newMinWidth = (2.0 * buttonWidth) + this.textInput.minWidth;
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			var buttonHeight = Math.max(this.decrementButton.height, this.incrementButton.height);
			if (this.buttonDirection == VERTICAL) {
				if (this.textInputPosition == CENTER) {
					newMinHeight = this.decrementButton.minHeight + (2.0 * buttonHeight);
				} else {
					newMinHeight = Math.max(this.textInput.minHeight, 2.0 * buttonHeight);
				}
			} else { // HORIZONTAL
				newMinHeight = Math.max(this.textInput.minHeight, buttonHeight);
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}

	private function refreshMeasureText():Void {
		var maxCharactersBeforeDecimal = Std.int(Math.max(Math.max(Std.string(Std.int(this._minimum)).length, Std.string(Std.int(this._maximum)).length),
			Std.string(Std.int(this._step)).length));

		// roundToPrecision() helps us to avoid numbers like 1.00000000000000001
		// caused by the inaccuracies of floating point math.
		var maxCharactersAfterDecimal = Std.int(Math.max(Math.max(Std.string(MathUtil.roundToPrecision(this._minimum - Std.int(this._minimum), 10)).length,
			Std.string(MathUtil.roundToPrecision(this._maximum - Std.int(this._maximum), 10)).length),
			Std.string(MathUtil.roundToPrecision(this._step - Std.int(this._step), 10)).length))
			- 2;
		if (maxCharactersAfterDecimal < 0) {
			maxCharactersAfterDecimal = 0;
		}
		var measureText = "";
		for (i in 0...(maxCharactersBeforeDecimal + maxCharactersAfterDecimal)) {
			measureText += "0";
		}
		if (maxCharactersAfterDecimal > 0) {
			measureText += ".";
		}
		this.textInput.measureText = measureText;
	}

	private function refreshEnabled():Void {
		this.decrementButton.enabled = this._enabled;
		this.incrementButton.enabled = this._enabled;
		this.textInput.enabled = this._enabled;
	}

	private function refreshEditable():Void {
		this.textInput.editable = this._editable;
	}

	private function refreshTextInputData():Void {
		// roundToPrecision() helps us to avoid numbers like 1.00000000000000001
		// caused by the inaccuracies of floating point math.
		var valueToFormat = MathUtil.roundToPrecision(this._value, 10);
		if (this._valueFormatFunction != null) {
			this.textInput.text = this._valueFormatFunction(valueToFormat);
		} else {
			this.textInput.text = Std.string(valueToFormat);
		}
	}

	private function parseTextInputValue():Void {
		var newValue = this._value;
		if (this._valueFormatFunction != null) {
			newValue = this._valueParseFunction(this.textInput.text);
		} else {
			newValue = Std.parseFloat(this.textInput.text);
		}
		if (!Math.isNaN(newValue)) {
			newValue = this.restrictValue(newValue);
			this.value = newValue;
		}
		// we need to force invalidation just to be sure that the text input
		// is displaying the correct value.
		this.setInvalid(DATA);
		this._pendingTextInputChanges = false;
	}

	private function layoutContent():Void {
		this.decrementButton.validateNow();
		this.incrementButton.validateNow();
		this.textInput.validateNow();

		if (this.buttonDirection == VERTICAL) {
			this.layoutContentWithVerticalButtons();
		} else { // HORIZONTAL
			this.layoutContentWithHorizontalButtons();
		}
	}

	private function layoutContentWithHorizontalButtons():Void {
		var buttonWidth = Math.max(this.decrementButton.width, this.incrementButton.width);
		var textInputWidth = Math.max(0.0, this.actualWidth - (2.0 * buttonWidth));
		if (this.textInput.width != textInputWidth) {
			this.textInput.width = textInputWidth;
		}
		if (this.textInput.height != this.actualHeight) {
			this.textInput.height = this.actualHeight;
		}
		if (this.decrementButton.width != buttonWidth) {
			this.decrementButton.width = buttonWidth;
		}
		if (this.decrementButton.height != this.actualHeight) {
			this.decrementButton.height = this.actualHeight;
		}
		if (this.incrementButton.width != buttonWidth) {
			this.incrementButton.width = buttonWidth;
		}
		if (this.incrementButton.height != this.actualHeight) {
			this.incrementButton.height = this.actualHeight;
		}
		switch (this.textInputPosition) {
			case LEFT:
				this.textInput.x = 0.0;
				this.textInput.y = 0.0;
				this.incrementButton.x = this.actualWidth - buttonWidth;
				this.incrementButton.y = 0.0;
				this.decrementButton.x = this.actualWidth - (2.0 * buttonWidth);
				this.decrementButton.y = 0.0;
			case RIGHT:
				this.decrementButton.x = 0.0;
				this.decrementButton.y = 0.0;
				this.incrementButton.x = buttonWidth;
				this.incrementButton.y = 0.0;
				this.textInput.x = this.actualWidth - textInputWidth;
				this.textInput.y = 0.0;
			case CENTER:
				this.decrementButton.x = 0.0;
				this.decrementButton.y = 0.0;
				this.incrementButton.x = this.actualWidth - buttonWidth;
				this.incrementButton.y = 0.0;
				this.textInput.x = buttonWidth;
				this.textInput.y = 0.0;
			default:
				throw new ArgumentError("Invalid text input position: " + this.textInputPosition);
		}
	}

	private function layoutContentWithVerticalButtons():Void {
		switch (this.textInputPosition) {
			case LEFT:
				var buttonWidth = Math.max(this.incrementButton.width, this.decrementButton.width);
				var buttonHeight = this.actualHeight / 2.0;
				var textInputWidth = Math.max(0.0, this.actualWidth - buttonWidth);
				if (this.textInput.width != textInputWidth) {
					this.textInput.width = textInputWidth;
				}
				if (this.textInput.height != this.actualHeight) {
					this.textInput.height = this.actualHeight;
				}
				this.textInput.x = 0.0;
				this.textInput.y = 0.0;
				this.incrementButton.x = this.actualWidth - buttonWidth;
				this.incrementButton.y = 0.0;
				if (this.incrementButton.width != buttonWidth) {
					this.incrementButton.width = buttonWidth;
				}
				if (this.incrementButton.height != buttonHeight) {
					this.incrementButton.height = buttonHeight;
				}
				this.decrementButton.x = this.actualWidth - buttonWidth;
				this.decrementButton.y = this.actualHeight = buttonHeight;
				if (this.decrementButton.width != buttonWidth) {
					this.decrementButton.width = buttonWidth;
				}
				if (this.decrementButton.height != buttonHeight) {
					this.decrementButton.height = buttonHeight;
				}
			case RIGHT:
				var buttonWidth = Math.max(this.incrementButton.width, this.decrementButton.width);
				var buttonHeight = this.actualHeight / 2.0;
				var textInputWidth = Math.max(0.0, this.actualWidth - buttonWidth);
				if (this.textInput.width != textInputWidth) {
					this.textInput.width = textInputWidth;
				}
				if (this.textInput.height != this.actualHeight) {
					this.textInput.height = this.actualHeight;
				}
				this.textInput.x = buttonWidth;
				this.textInput.y = 0.0;
				this.incrementButton.x = 0.0;
				this.incrementButton.y = 0.0;
				if (this.incrementButton.width != buttonWidth) {
					this.incrementButton.width = buttonWidth;
				}
				if (this.incrementButton.height != buttonHeight) {
					this.incrementButton.height = buttonHeight;
				}
				this.decrementButton.x = 0.0;
				this.decrementButton.y = this.actualHeight - buttonHeight;
				if (this.decrementButton.width != buttonWidth) {
					this.decrementButton.width = buttonWidth;
				}
				if (this.decrementButton.height != buttonHeight) {
					this.decrementButton.height = buttonHeight;
				}
			case CENTER:
				var buttonHeight = Math.max(this.decrementButton.height, this.incrementButton.height);
				var textInputHeight = Math.max(0.0, this.actualHeight - (2.0 * buttonHeight));
				this.incrementButton.x = 0.0;
				this.incrementButton.y = 0.0;
				if (this.incrementButton.width != this.actualWidth) {
					this.incrementButton.width = this.actualWidth;
				}
				if (this.incrementButton.height != buttonHeight) {
					this.incrementButton.height = buttonHeight;
				}
				this.textInput.x = 0.0;
				this.textInput.y = buttonHeight;
				if (this.textInput.width != this.actualWidth) {
					this.textInput.width = this.actualWidth;
				}
				if (this.textInput.height != textInputHeight) {
					this.textInput.height = textInputHeight;
				}
				this.decrementButton.x = 0.0;
				this.decrementButton.y = this.actualHeight - buttonHeight;
				if (this.decrementButton.width != this.actualWidth) {
					this.decrementButton.width = this.actualWidth;
				}
				if (this.decrementButton.height != buttonHeight) {
					this.decrementButton.height = buttonHeight;
				}
			default:
				throw new ArgumentError("Invalid text input position: " + this.textInputPosition);
		}
	}

	private function createDecrementButton():Void {
		if (this.decrementButton != null) {
			this.decrementButton.removeEventListener(MouseEvent.MOUSE_DOWN, numericStepper_decrementButton_mouseDownHandler);
			this.decrementButton.removeEventListener(TouchEvent.TOUCH_BEGIN, numericStepper_decrementButton_touchBeginHandler);
			this.removeChild(this.decrementButton);
			if (this._oldDecrementButtonFactory.destroy != null) {
				this._oldDecrementButtonFactory.destroy(this.decrementButton);
			}
			this._oldDecrementButtonFactory = null;
			this.decrementButton = null;
		}
		var factory = this._decrementButtonFactory != null ? this._decrementButtonFactory : defaultDecrementButtonFactory;
		this._oldDecrementButtonFactory = factory;
		this.decrementButton = factory.create();
		if (this.decrementButton.variant == null) {
			this.decrementButton.variant = this.customDecrementButtonVariant != null ? this.customDecrementButtonVariant : NumericStepper.CHILD_VARIANT_DECREMENT_BUTTON;
		}
		this.decrementButton.text = "-";
		this.decrementButton.addEventListener(MouseEvent.MOUSE_DOWN, numericStepper_decrementButton_mouseDownHandler);
		this.decrementButton.addEventListener(TouchEvent.TOUCH_BEGIN, numericStepper_decrementButton_touchBeginHandler);
		this.decrementButton.initializeNow();
		this.decrementButtonMeasurements.save(this.decrementButton);
		this.addChild(this.decrementButton);
	}

	private function createIncrementButton():Void {
		if (this.incrementButton != null) {
			this.incrementButton.removeEventListener(MouseEvent.MOUSE_DOWN, numericStepper_incrementButton_mouseDownHandler);
			this.incrementButton.removeEventListener(TouchEvent.TOUCH_BEGIN, numericStepper_incrementButton_touchBeginHandler);
			this.removeChild(this.incrementButton);
			if (this._oldIncrementButtonFactory.destroy != null) {
				this._oldIncrementButtonFactory.destroy(this.incrementButton);
			}
			this._oldIncrementButtonFactory = null;
			this.incrementButton = null;
		}
		var factory = this._incrementButtonFactory != null ? this._incrementButtonFactory : defaultIncrementButtonFactory;
		this._oldIncrementButtonFactory = factory;
		this.incrementButton = factory.create();
		if (this.incrementButton.variant == null) {
			this.incrementButton.variant = this.customIncrementButtonVariant != null ? this.customIncrementButtonVariant : NumericStepper.CHILD_VARIANT_INCREMENT_BUTTON;
		}
		this.incrementButton.text = "+";
		this.incrementButton.addEventListener(MouseEvent.MOUSE_DOWN, numericStepper_incrementButton_mouseDownHandler);
		this.incrementButton.addEventListener(TouchEvent.TOUCH_BEGIN, numericStepper_incrementButton_touchBeginHandler);
		this.incrementButton.initializeNow();
		this.incrementButtonMeasurements.save(this.incrementButton);
		this.addChild(this.incrementButton);
	}

	private function createTextInput():Void {
		if (this.textInput != null) {
			this.textInput.removeEventListener(KeyboardEvent.KEY_DOWN, numericStepper_textInput_keyDownHandler);
			this.textInput.removeEventListener(Event.CHANGE, numericStepper_textInput_changeHandler);
			this.textInput.removeEventListener(FocusEvent.FOCUS_IN, numericStepper_textInput_focusInHandler);
			this.textInput.removeEventListener(FocusEvent.FOCUS_OUT, numericStepper_textInput_focusOutHandler);
			this.removeChild(this.textInput);
			if (this._oldTextInputFactory.destroy != null) {
				this._oldTextInputFactory.destroy(this.textInput);
			}
			this._oldTextInputFactory = null;
			this.textInput = null;
		}
		var factory = this._textInputFactory != null ? this._textInputFactory : defaultTextInputFactory;
		this._oldTextInputFactory = factory;
		this.textInput = factory.create();
		if (this.textInput.variant == null) {
			this.textInput.variant = this.customTextInputVariant != null ? this.customTextInputVariant : NumericStepper.CHILD_VARIANT_TEXT_INPUT;
		}
		this.textInput.addEventListener(KeyboardEvent.KEY_DOWN, numericStepper_textInput_keyDownHandler);
		this.textInput.addEventListener(Event.CHANGE, numericStepper_textInput_changeHandler);
		this.textInput.addEventListener(FocusEvent.FOCUS_IN, numericStepper_textInput_focusInHandler);
		this.textInput.addEventListener(FocusEvent.FOCUS_OUT, numericStepper_textInput_focusOutHandler);
		this.textInput.initializeNow();
		this.textInputMeasurements.save(this.textInput);
		this.addChild(this.textInput);
	}

	private function restrictValue(value:Float):Float {
		if (this._snapInterval != 0.0 && value != this._minimum && value != this._maximum) {
			value = MathUtil.roundToNearest(value, this._snapInterval);
		}
		if (value < this._minimum) {
			value = this._minimum;
		} else if (value > this._maximum) {
			value = this._maximum;
		}
		return value;
	}

	private function decrement():Void {
		var newValue = this._value - this._step;
		newValue = this.restrictValue(newValue);
		this.value = newValue;
	}

	private function increment():Void {
		var newValue = this._value + this._step;
		newValue = this.restrictValue(newValue);
		this.value = newValue;
	}

	private function numericStepper_focusInHandler(event:FocusEvent):Void {
		if (this.stage != null && this.stage.focus != null && this.textInput != null && !this.textInput.contains(this.stage.focus)) {
			event.stopImmediatePropagation();
			this.stage.focus = this.textInput;
		}
	}

	private function canKeyCodeUpdateValue(keyCode:Int):Bool {
		return keyCode == Keyboard.UP || keyCode == Keyboard.DOWN || keyCode == Keyboard.HOME || keyCode == Keyboard.END;
	}

	private function updateValueWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (!this._enabled || !this.canKeyCodeUpdateValue(event.keyCode)) {
			return;
		}
		this.parseTextInputValue();
		var newValue = this._value;
		switch (event.keyCode) {
			case Keyboard.DOWN:
				newValue -= this._step;
			case Keyboard.UP:
				newValue += this._step;
			case Keyboard.HOME:
				newValue = this._minimum;
			case Keyboard.END:
				newValue = this._maximum;
			default:
				return;
		}
		if (newValue < this._minimum) {
			newValue = this._minimum;
		} else if (newValue > this._maximum) {
			newValue = this._maximum;
		}
		event.preventDefault();
		// use the setter
		this.value = newValue;
	}

	private function numericStepper_decrementButton_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) {
			return;
		}
		this.decrement();
	}

	private function numericStepper_decrementButton_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}

		if (!this._enabled || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) {
			return;
		}
		this.decrement();
	}

	private function numericStepper_incrementButton_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) {
			return;
		}
		this.increment();
	}

	private function numericStepper_incrementButton_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}

		if (!this._enabled || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) {
			return;
		}
		this.increment();
	}

	private function numericStepper_textInput_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		switch (event.keyCode) {
			case Keyboard.ENTER:
				event.preventDefault();
				this.parseTextInputValue();
				return;
			default:
				this.updateValueWithKeyboard(event);
		}
	}

	private function numericStepper_textInput_focusInHandler(event:FocusEvent):Void {
		this._pendingTextInputChanges = false;
	}

	private function numericStepper_textInput_changeHandler(event:Event):Void {
		this._pendingTextInputChanges = true;
	}

	private function numericStepper_textInput_focusOutHandler(event:FocusEvent):Void {
		if (!this._pendingTextInputChanges) {
			return;
		}
		this.parseTextInputValue();
	}
}
