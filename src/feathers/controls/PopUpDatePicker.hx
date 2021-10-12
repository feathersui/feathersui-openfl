/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.popups.DropDownPopUpAdapter;
import feathers.controls.popups.IPopUpAdapter;
import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IStageFocusDelegate;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.themes.steel.components.SteelPopUpDatePickerStyles;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end
#if lime
import lime.ui.KeyCode;
#end
#if (openfl >= "9.2.0" && !neko)
import openfl.globalization.DateTimeFormatter;
import openfl.globalization.LocaleID;
#elseif flash
import flash.globalization.DateTimeFormatter;
import flash.globalization.LocaleID;
#end

@:event(openfl.events.Event.CHANGE)
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:styleContext
class PopUpDatePicker extends FeathersControl implements IFocusObject implements IStageFocusDelegate {
	private static final INVALIDATION_FLAG_BUTTON_FACTORY = InvalidationFlag.CUSTOM("buttonFactory");
	private static final INVALIDATION_FLAG_TEXT_INPUT_FACTORY = InvalidationFlag.CUSTOM("textInputFactory");
	private static final INVALIDATION_FLAG_DATE_PICKER_FACTORY = InvalidationFlag.CUSTOM("datePickerFactory");

	/**
		The variant used to style the `Button` child component in a theme.

		To override this default variant, set the
		`PopUpDatePicker.customButtonVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `PopUpDatePicker.customButtonVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_BUTTON = "popUpDatePicker_button";

	/**
		The variant used to style the `TextInput` child component in a theme.

		To override this default variant, set the
		`PopUpDatePicker.customTextInputVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `PopUpDatePicker.customTextInputVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_TEXT_INPUT = "popUpDatePicker_textInput";

	/**
		The variant used to style the `DatePicker` child component in a theme.

		To override this default variant, set the
		`PopUpDatePicker.customDatePickerVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `PopUpDatePicker.customDatePickerVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DATE_PICKER = "popUpDatePicker_datePicker";

	private static final defaultButtonFactory = DisplayObjectFactory.withClass(Button);

	private static final defaultTextInputFactory = DisplayObjectFactory.withClass(TextInput);

	private static final defaultDatePickerFactory = DisplayObjectFactory.withClass(DatePicker);

	/**
		Creates a new `PopUpDatePicker` object.

		@since 1.0.0
	**/
	public function new() {
		initializePopUpDatePickerTheme();
		super();

		this.addEventListener(FocusEvent.FOCUS_IN, popUpDatePicker_focusInHandler);
	}

	private var button:Button;
	private var textInput:TextInput;
	private var datePicker:DatePicker;

	private var buttonMeasurements = new Measurements();
	private var textInputMeasurements = new Measurements();

	@:flash.property
	public var stageFocusTarget(get, never):InteractiveObject;

	private function get_stageFocusTarget():InteractiveObject {
		return this.textInput;
	}

	#if (flash || (openfl >= "9.2.0" && !neko))
	private var _currentDateFormatter:DateTimeFormatter;
	#end

	private var _selectedDate:Date = null;

	/**
		The currently selected date.

		@since 1.0.0
	**/
	@:flash.property
	public var selectedDate(get, set):Date;

	private function get_selectedDate():Date {
		return this._selectedDate;
	}

	private function set_selectedDate(value:Date):Date {
		if (this._selectedDate == value) {
			return this._selectedDate;
		}
		this._selectedDate = value;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedDate;
	}

	private var _prompt:String;

	/**
		The text displayed by the text input when no date is selected.

		The following example sets the date picker's prompt:

		```hx
		popUpDatePicker.prompt = "Select an item";
		```

		@default null

		@since 1.0.0
	**/
	@:flash.property
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

	private var _ignoreTextInputChange = false;
	private var _ignoreDatePickerChange = false;

	/**
		Manages how the pop-up `DatePicker` is displayed when it is opened and
		closed.

		In the following example, a custom pop-up adapter is provided:

		```hx
		popUpDatePicker.popUpAdapter = new DropDownPopUpAdapter();
		```

		@since 1.0.0
	**/
	@:style
	public var popUpAdapter:IPopUpAdapter = new DropDownPopUpAdapter();

	private var _previousCustomTextInputVariant:String = null;

	/**
		A custom variant to set on the text input, instead of
		`PopUpDatePicker.CHILD_VARIANT_TEXT_INPUT`.

		The `customTextInputVariant` will be not be used if the result of
		`textInputFactory` already has a variant set.

		@see `PopUpDatePicker.CHILD_VARIANT_TEXT_INPUT`

		@since 1.0.0
	**/
	@:style
	public var customTextInputVariant:String = null;

	private var _previousCustomButtonVariant:String = null;

	/**
		A custom variant to set on the button, instead of
		`PopUpDatePicker.CHILD_VARIANT_BUTTON`.

		The `customButtonVariant` will be not be used if the result of
		`buttonFactory` already has a variant set.

		@see `PopUpDatePicker.CHILD_VARIANT_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customButtonVariant:String = null;

	private var _previousCustomDatePickerVariant:String = null;

	/**
		A custom variant to set on the pop-up date picker, instead of
		`PopUpDatePicker.CHILD_VARIANT_DATE_PICKER`.

		The `customDatePickerVariant` will be not be used if the result of
		`datePickerFactory` already has a variant set.

		@see `PopUpDatePicker.CHILD_VARIANT_DATE_PICKER`

		@since 1.0.0
	**/
	@:style
	public var customDatePickerVariant:String = null;

	private var _oldButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _buttonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the button, which must be of type `feathers.controls.Button`.

		In the following example, a custom button factory is provided:

		```hx
		datePicker.buttonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	@:flash.property
	public var buttonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_buttonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._buttonFactory;
	}

	private function set_buttonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._buttonFactory == value) {
			return this._buttonFactory;
		}
		this._buttonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		return this._buttonFactory;
	}

	private var _oldTextInputFactory:DisplayObjectFactory<Dynamic, TextInput>;

	private var _textInputFactory:DisplayObjectFactory<Dynamic, TextInput>;

	/**
		Creates the text input, which must be of type `feathers.controls.TextInput`.

		In the following example, a custom text input factory is provided:

		```hx
		datePicker.textInputFactory = () ->
		{
			return new TextInput();
		};
		```

		@see `feathers.controls.TextInput`

		@since 1.0.0
	**/
	@:flash.property
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

	private var _oldDatePickerFactory:DisplayObjectFactory<Dynamic, DatePicker>;

	private var _datePickerFactory:DisplayObjectFactory<Dynamic, DatePicker>;

	/**
		Creates the date picker that is displayed as a pop-up. The date picker
		must be of type `feathers.controls.DatePicker`.

		Note: The following properties should not be set in the
		`datePickerFactory` because they will be overridden by the
		`PopUpDatePicker` when it validates.

		- `DatePicker.requestedLocaleIDName`
		- `DatePicker.displayedMonth`
		- `DatePicker.displayedFullYear`
		- `DatePicker.selectedDate`
		- `DatePicker.customMonthNames`;
		- `DatePicker.customWeekdayNames`
		- `DatePicker.customStartOfWeek`

		In the following example, a custom date picker factory is provided:

		```hx
		datePicker.datePickerFactory = () ->
		{
			return new DatePicker();
		};
		```

		@see `feathers.controls.DatePicker`

		@since 1.0.0
	**/
	@:flash.property
	public var datePickerFactory(get, set):AbstractDisplayObjectFactory<Dynamic, DatePicker>;

	private function get_datePickerFactory():AbstractDisplayObjectFactory<Dynamic, DatePicker> {
		return this._datePickerFactory;
	}

	private function set_datePickerFactory(value:AbstractDisplayObjectFactory<Dynamic, DatePicker>):AbstractDisplayObjectFactory<Dynamic, DatePicker> {
		if (this._datePickerFactory == value) {
			return this._datePickerFactory;
		}
		this._datePickerFactory = value;
		this.setInvalid(INVALIDATION_FLAG_DATE_PICKER_FACTORY);
		return this._datePickerFactory;
	}

	private var _requestedLocaleIDName:String = null;

	/**
		The locale ID name that is requested.

		@see `CalendarGrid.actualLocaleIDName`

		@since 1.0.0
	**/
	@:flash.property
	public var requestedLocaleIDName(get, set):String;

	private function get_requestedLocaleIDName():String {
		return this._requestedLocaleIDName;
	}

	private function set_requestedLocaleIDName(value:String):String {
		if (this._requestedLocaleIDName == value) {
			return this._requestedLocaleIDName;
		}
		this._requestedLocaleIDName = value;
		this._actualLocaleIDName = null;
		this.setInvalid(DATA);
		return this._requestedLocaleIDName;
	}

	private var _actualLocaleIDName:String = null;

	/**
		The locale ID name that is being used, which may be different from the
		requested locale ID name.

		@see `CalendarGrid.requestedLocaleIDName`

		@since 1.0.0
	**/
	@:flash.property
	public var actualLocaleIDName(get, never):String;

	private function get_actualLocaleIDName():String {
		return this._actualLocaleIDName;
	}

	private var _customMonthNames:Array<String> = null;

	/**
		A custom set of month names to use instead of the default.

		@since 1.0.0
	**/
	public var customMonthNames(get, set):Array<String>;

	private function get_customMonthNames():Array<String> {
		return this._customMonthNames;
	}

	private function set_customMonthNames(value:Array<String>):Array<String> {
		if (value != null && value.length != 12) {
			throw new ArgumentError("Length of customMonthNames must be exactly equal to 12");
		}
		if (this._customMonthNames == value) {
			return this._customMonthNames;
		}
		this._customMonthNames = value;
		this.setInvalid(DATA);
		return this._customMonthNames;
	}

	private var _customWeekdayNames:Array<String> = null;

	/**
		A custom set of weekday names to use instead of the default.

		@since 1.0.0
	**/
	public var customWeekdayNames(get, set):Array<String>;

	private function get_customWeekdayNames():Array<String> {
		return this._customWeekdayNames;
	}

	private function set_customWeekdayNames(value:Array<String>):Array<String> {
		if (value != null && value.length != 7) {
			throw new ArgumentError("Length of customWeekdayNames must be exactly equal to 7");
		}
		if (this._customWeekdayNames == value) {
			return this._customWeekdayNames;
		}
		this._customWeekdayNames = value;
		this.setInvalid(DATA);
		return this._customWeekdayNames;
	}

	private var _customStartOfWeek:Null<Int> = null;

	/**
		The index of the day that starts each week. `0` is Sunday and `6` is
		Saturday. Set to `null` to use the default.

		@since 1.0.0
	**/
	public var customStartOfWeek(get, set):Null<Int>;

	private function get_customStartOfWeek():Null<Int> {
		return this._customStartOfWeek;
	}

	private function set_customStartOfWeek(value:Null<Int>):Null<Int> {
		if (value < 0 || value > 6) {
			throw new RangeError("startOfWeek must be in the range 0-6");
		}
		if (this._customStartOfWeek == value) {
			return this._customStartOfWeek;
		}
		this._customStartOfWeek = value;
		this.setInvalid(DATA);
		return this._customStartOfWeek;
	}

	/**
		Indicates if the pop-up date picker is open or closed.

		@see `PopUpDatePicker.openDatePicker()`
		@see `PopUpDatePicker.closeDatePicker()`

		@since 1.0.0
	**/
	@:flash.property
	public var open(get, never):Bool;

	private function get_open():Bool {
		return this.datePicker != null && this.datePicker.parent != null;
	}

	private var _filterText:String = null;

	override public function showFocus(show:Bool):Void {
		super.showFocus(show);
		if (this.textInput != null) {
			this.textInput.showFocus(show);
		}
	}

	/**
		Determines if the pop-up date picker should automatically open when the
		date picker receives focus, or if the user is required to click the
		open button.

		@since 1.0.0
	**/
	public var openDatePickerOnFocus:Bool = false;

	/**
		Opens the pop-up date picker, if it is not already open.

		The following example opens the pop-up date picker:

		```hx
		if(!datePicker.open)
		{
			datePicker.openDatePicker();
		}
		```

		When the pop-up date picker opens, the component will dispatch an event
		of type `Event.OPEN`.

		@see `PopUpDatePicker.open`
		@see `PopUpDatePicker.closeDatePicker()`
		@see [`openfl.events.Event.OPEN`](https://api.openfl.org/openfl/events/Event.html#OPEN)
		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)

		@since 1.0.0
	**/
	public function openDatePicker():Void {
		if (this.open || this.stage == null) {
			return;
		}
		this.validateNow();
		this.popUpAdapter.addEventListener(Event.OPEN, popUpDatePicker_popUpAdapter_openHandler);
		this.popUpAdapter.addEventListener(Event.CLOSE, popUpDatePicker_popUpAdapter_closeHandler);
		this.popUpAdapter.open(this.datePicker, this);
		if (this.selectedDate != null) {
			this.datePicker.displayedFullYear = this.selectedDate.getFullYear();
			this.datePicker.displayedMonth = this.selectedDate.getMonth();
		} else {
			var now = Date.now();
			this.datePicker.displayedFullYear = now.getFullYear();
			this.datePicker.displayedMonth = now.getMonth();
		}
		this.datePicker.validateNow();
		this.textInput.addEventListener(FocusEvent.FOCUS_OUT, popUpDatePicker_textInput_focusOutHandler);
		this.datePicker.addEventListener(Event.REMOVED_FROM_STAGE, popUpDatePicker_datePicker_removedFromStageHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, popUpDatePicker_stage_mouseDownHandler, false, 0, true);
		this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, popUpDatePicker_stage_touchBeginHandler, false, 0, true);
	}

	/**
		Closes the pop-up date picker, if it is open.

		The following example closes the pop-up date picker:

		```hx
		if(datePicker.open)
		{
			datePicker.closeDatePicker();
		}
		```

		When the pop-up date picker closes, the component will dispatch an event of
		type `Event.CLOSE`.

		@see `PopUpDatePicker.open`
		@see `PopUpDatePicker.openDatePicker()`
		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)

		@since 1.0.0
	**/
	public function closeDatePicker():Void {
		if (!this.open) {
			return;
		}
		this.popUpAdapter.close();
	}

	private function initializePopUpDatePickerTheme():Void {
		SteelPopUpDatePickerStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		if (this._previousCustomTextInputVariant != this.customTextInputVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		}
		if (this._previousCustomButtonVariant != this.customButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_BUTTON_FACTORY);
		}
		if (this._previousCustomDatePickerVariant != this.customDatePickerVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_DATE_PICKER_FACTORY);
		}
		var buttonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_BUTTON_FACTORY);
		var textInputFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		var datePickerFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_DATE_PICKER_FACTORY);

		if (buttonFactoryInvalid) {
			this.createButton();
		}
		if (textInputFactoryInvalid) {
			this.createTextInput();
		}
		if (datePickerFactoryInvalid) {
			this.createDatePicker();
		}

		if (dataInvalid) {
			this.refreshLocale();
		}

		if (dataInvalid || selectionInvalid || datePickerFactoryInvalid) {
			this.refreshDatePickerData();
		}

		if (dataInvalid || selectionInvalid || textInputFactoryInvalid) {
			this.refreshTextInputData();
		}

		if (stateInvalid || datePickerFactoryInvalid || buttonFactoryInvalid || textInputFactoryInvalid) {
			this.refreshEnabled();
		}

		this.measure();
		this.layoutChildren();

		this._previousCustomTextInputVariant = this.customTextInputVariant;
		this._previousCustomButtonVariant = this.customButtonVariant;
		this._previousCustomDatePickerVariant = this.customDatePickerVariant;
	}

	private function createButton():Void {
		if (this.button != null) {
			this.button.removeEventListener(MouseEvent.MOUSE_DOWN, popUpDatePicker_button_mouseDownHandler);
			this.button.removeEventListener(TouchEvent.TOUCH_BEGIN, popUpDatePicker_button_touchBeginHandler);
			this.removeChild(this.button);
			if (this._oldButtonFactory.destroy != null) {
				this._oldButtonFactory.destroy(this.button);
			}
			this._oldButtonFactory = null;
			this.button = null;
		}
		var factory = this._buttonFactory != null ? this._buttonFactory : defaultButtonFactory;
		this._oldButtonFactory = factory;
		this.button = factory.create();
		if (this.button.variant == null) {
			this.button.variant = this.customButtonVariant != null ? this.customButtonVariant : PopUpDatePicker.CHILD_VARIANT_BUTTON;
		}
		this.button.focusEnabled = false;
		this.button.addEventListener(MouseEvent.MOUSE_DOWN, popUpDatePicker_button_mouseDownHandler);
		this.button.addEventListener(TouchEvent.TOUCH_BEGIN, popUpDatePicker_button_touchBeginHandler);
		this.button.initializeNow();
		this.buttonMeasurements.save(this.button);
		this.addChild(this.button);
	}

	private function refreshLocale():Void {
		#if (flash || (openfl >= "9.2.0" && !neko))
		var localeID = this._requestedLocaleIDName != null ? this._requestedLocaleIDName : LocaleID.DEFAULT;
		this._currentDateFormatter = new DateTimeFormatter(localeID, SHORT, NONE);
		this._actualLocaleIDName = this._currentDateFormatter.actualLocaleIDName;
		#else
		this._actualLocaleIDName = "en-US";
		#end
	}

	private function createTextInput():Void {
		if (this.textInput != null) {
			this.textInput.removeEventListener(MouseEvent.MOUSE_DOWN, popUpDatePicker_textInput_mouseDownHandler);
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
		this.textInput.editable = false;
		if (this.textInput.variant == null) {
			this.textInput.variant = this.customTextInputVariant != null ? this.customTextInputVariant : PopUpDatePicker.CHILD_VARIANT_TEXT_INPUT;
		}
		this.textInput.initializeNow();
		this.textInputMeasurements.save(this.textInput);
		this.textInput.addEventListener(MouseEvent.MOUSE_DOWN, popUpDatePicker_textInput_mouseDownHandler);
		this.addChild(this.textInput);
	}

	private function createDatePicker():Void {
		if (this.datePicker != null) {
			this.datePicker.removeEventListener(Event.CHANGE, popUpDatePicker_datePicker_changeHandler);
			this.datePicker.focusOwner = null;
			if (this._oldDatePickerFactory.destroy != null) {
				this._oldDatePickerFactory.destroy(this.datePicker);
			}
			this._oldDatePickerFactory = null;
			this.datePicker = null;
		}
		var factory = this._datePickerFactory != null ? this._datePickerFactory : defaultDatePickerFactory;
		this._oldDatePickerFactory = factory;
		this.datePicker = factory.create();
		this.datePicker.focusOwner = this;
		this.datePicker.focusEnabled = false;
		if (this.datePicker.variant == null) {
			this.datePicker.variant = this.customDatePickerVariant != null ? this.customDatePickerVariant : PopUpDatePicker.CHILD_VARIANT_DATE_PICKER;
		}
		this.datePicker.addEventListener(Event.CHANGE, popUpDatePicker_datePicker_changeHandler);
	}

	private function refreshDatePickerData():Void {
		var oldIgnoreDatePickerChange = this._ignoreDatePickerChange;
		this._ignoreDatePickerChange = true;
		this.datePicker.requestedLocaleIDName = this._requestedLocaleIDName;
		this.datePicker.selectedDate = this._selectedDate;
		this.datePicker.customMonthNames = this._customMonthNames;
		this.datePicker.customWeekdayNames = this._customWeekdayNames;
		this.datePicker.customStartOfWeek = this._customStartOfWeek;
		this._ignoreDatePickerChange = oldIgnoreDatePickerChange;
	}

	private function refreshTextInputData():Void {
		this.textInput.prompt = this._prompt;
		if (this._selectedDate != null) {
			#if (flash || (openfl >= "9.2.0" && !neko))
			this.textInput.text = this._currentDateFormatter.format(this._selectedDate);
			#else
			this.textInput.text = '${this._selectedDate.getMonth() + 1}/${this._selectedDate.getDate()}/${this._selectedDate.getFullYear()}';
			#end
		} else {
			this.textInput.text = "";
		}
	}

	private function refreshEnabled():Void {
		this.button.enabled = this._enabled;
		this.textInput.enabled = this._enabled;
		this.datePicker.enabled = this._enabled;
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

		this.buttonMeasurements.restore(this.button);
		this.button.validateNow();

		this.textInputMeasurements.restore(this.textInput);
		this.textInput.validateNow();

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.button.width + this.textInput.width;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = Math.max(this.button.height, this.textInput.height);
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this.button.minWidth + this.textInput.minWidth;
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = Math.max(this.button.minHeight, this.textInput.minHeight);
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}

	private function layoutChildren():Void {
		this.button.validateNow();
		this.button.x = this.actualWidth - this.button.width;
		this.button.y = 0.0;
		if (this.button.height != this.actualHeight) {
			this.button.height = this.actualHeight;
		}
		this.textInput.x = 0.0;
		this.textInput.y = 0.0;
		var textInputWidth = this.actualWidth - this.button.width;
		if (this.textInput.width != textInputWidth) {
			this.textInput.width = textInputWidth;
		}
		if (this.textInput.height != this.actualHeight) {
			this.textInput.height = this.actualHeight;
		}
		this.button.validateNow();
		this.textInput.validateNow();
	}

	private function popUpDatePicker_textInput_focusOutHandler(event:FocusEvent):Void {
		if (event.relatedObject != null && (event.relatedObject == this.datePicker || this.datePicker.contains(event.relatedObject))) {
			return;
		}
		#if (flash || openfl > "9.1.0")
		this.closeDatePicker();
		#end
	}

	private function popUpDatePicker_button_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (this.open) {
			this.closeDatePicker();
		} else {
			this.openDatePicker();
		}
	}

	private function popUpDatePicker_button_touchBeginHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.open) {
			this.closeDatePicker();
		} else {
			this.openDatePicker();
		}
	}

	private function popUpDatePicker_datePicker_changeHandler(event:Event):Void {
		if (this._ignoreDatePickerChange) {
			return;
		}
		this.selectedDate = this.datePicker.selectedDate;
	}

	private function popUpDatePicker_datePicker_removedFromStageHandler(event:Event):Void {
		this.textInput.removeEventListener(FocusEvent.FOCUS_OUT, popUpDatePicker_textInput_focusOutHandler);
		this.datePicker.removeEventListener(Event.REMOVED_FROM_STAGE, popUpDatePicker_datePicker_removedFromStageHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, popUpDatePicker_stage_mouseDownHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, popUpDatePicker_stage_touchBeginHandler);
	}

	private function popUpDatePicker_focusInHandler(event:FocusEvent):Void {
		if (this.stage != null && this.stage.focus != null && this.textInput != null && !this.textInput.contains(this.stage.focus)) {
			event.stopImmediatePropagation();
			this.stage.focus = this.textInput;
		}
	}

	private function popUpDatePicker_removedFromStageHandler(event:Event):Void {
		// if something went terribly wrong, at least make sure that the
		// DatePicker isn't still visible and blocking the rest of the app
		this.closeDatePicker();
	}

	private function popUpDatePicker_keyUpHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		switch (event.keyCode) {
			case Keyboard.ESCAPE:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeDatePicker();
			#if flash
			case Keyboard.BACK:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeDatePicker();
			#end
			#if lime
			case KeyCode.APP_CONTROL_BACK:
				if (event.isDefaultPrevented()) {
					return;
				}
				if (!this.open) {
					return;
				}
				event.preventDefault();
				this.closeDatePicker();
			#end
		}
	}

	private function popUpDatePicker_stage_mouseDownHandler(event:MouseEvent):Void {
		if (this.hitTestPoint(event.stageX, event.stageY) || this.datePicker.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeDatePicker();
	}

	private function popUpDatePicker_stage_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.hitTestPoint(event.stageX, event.stageY) || this.datePicker.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.closeDatePicker();
	}

	private function popUpDatePicker_popUpAdapter_openHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.OPEN);
	}

	private function popUpDatePicker_popUpAdapter_closeHandler(event:Event):Void {
		this.popUpAdapter.removeEventListener(Event.OPEN, popUpDatePicker_popUpAdapter_openHandler);
		this.popUpAdapter.removeEventListener(Event.CLOSE, popUpDatePicker_popUpAdapter_closeHandler);
		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function popUpDatePicker_textInput_mouseDownHandler(event:MouseEvent):Void {
		this.openDatePicker();
	}
}
