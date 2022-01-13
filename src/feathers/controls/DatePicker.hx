/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IDateSelector;
import feathers.core.IFocusObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelDatePickerStyles;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.RangeError;
import openfl.events.Event;
#if (openfl >= "9.2.0" && !neko)
import openfl.globalization.DateTimeFormatter;
import openfl.globalization.LocaleID;
#elseif flash
import flash.globalization.DateTimeFormatter;
import flash.globalization.LocaleID;
#end

/**
	Displays a calendar month view that allows the selection of a date. The
	header displays the current month and year name, along with buttons to
	change the currently displayed month and year. The buttons in the header may
	be hidden, if desired.

	The following example creates a date picker, sets the selected date, and
	listens for when the selection changes:

	```hx
	var datePicker = new DatePicker();
	datePicker.selectedDate = new Date(2020, 1, 6);
	datePicker.addEventListener(Event.CHANGE, (event:Event) -> {
		var datePicker = cast(event.currentTarget, DatePicker);
		trace("DatePicker changed: " + datePicker.selectedDate);
	});
	this.addChild(datePicker);
	```

	@see [Tutorial: How to use the DatePicker component](https://feathersui.com/learn/haxe-openfl/date-picker/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:styleContext
class DatePicker extends FeathersControl implements IDateSelector implements IFocusObject {
	#if ((!flash && openfl < "9.2.0") || neko)
	private static final DEFAULT_MONTH_NAMES = [
		"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
	];
	#end

	private static final INVALIDATION_FLAG_CURRENT_MONTH_VIEW_FACTORY = InvalidationFlag.CUSTOM("currentMonthViewFactory");
	private static final INVALIDATION_FLAG_DECREMENT_MONTH_BUTTON_FACTORY = InvalidationFlag.CUSTOM("decrementMonthButtonFactory");
	private static final INVALIDATION_FLAG_INCREMENT_MONTH_BUTTON_FACTORY = InvalidationFlag.CUSTOM("incrementMonthButtonFactory");
	private static final INVALIDATION_FLAG_DECREMENT_YEAR_BUTTON_FACTORY = InvalidationFlag.CUSTOM("decrementYearButtonFactory");
	private static final INVALIDATION_FLAG_INCREMENT_YEAR_BUTTON_FACTORY = InvalidationFlag.CUSTOM("incrementYearButtonFactory");
	private static final INVALIDATION_FLAG_CALENDAR_GRID_FACTORY = InvalidationFlag.CUSTOM("calendarGridFactory");

	/**
		The variant used to style the `CalendarGrid` child component in a theme.

		To override this default variant, set the
		`DatePicker.customCalendarGridVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `DatePicker.customCalendarGridVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_CALENDAR_GRID = "datePicker_calendarGrid";

	/**
		The variant used to style the decrement month `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customDecrementMonthButtonVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `DatePicker.customDecrementMonthButtonVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DECREMENT_MONTH_BUTTON = "datePicker_decrementMonthButton";

	/**
		The variant used to style the increment month `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customIncrementMonthButtonVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `DatePicker.customIncrementMonthButtonVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_INCREMENT_MONTH_BUTTON = "datePicker_incrementMonthButton";

	/**
		The variant used to style the decrement year `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customDecrementYearButtonVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `DatePicker.customDecrementYearButtonVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DECREMENT_YEAR_BUTTON = "datePicker_decrementYearButton";

	/**
		The variant used to style the increment year `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customIncrementYearButtonVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `DatePicker.customIncrementYearButtonVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_INCREMENT_YEAR_BUTTON = "datePicker_incrementYearButton";

	/**
		The variant used to style the current month `Label` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customCurrentMonthViewVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `DatePicker.customCurrentMonthViewVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_CURRENT_MONTH_VIEW = "datePicker_currentMonthView";

	private static final defaultCalendarGridFactory = DisplayObjectFactory.withClass(CalendarGrid);
	private static final defaultDecrementMonthButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultIncrementMonthButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultDecrementYearButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultIncrementYearButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultCurrentMonthViewFactory = DisplayObjectFactory.withClass(Label);

	/**
		Creates a new `DatePicker` object.

		@since 1.0.0
	**/
	public function new() {
		initializeDatePickerTheme();
		super();
	}

	private var calendarGrid:CalendarGrid;
	private var monthView:ITextControl;
	private var decrementMonthButton:Button;
	private var incrementMonthButton:Button;
	private var decrementYearButton:Button;
	private var incrementYearButton:Button;
	private var currentMonthView:Label;

	private var calendarGridMeasurements:Measurements = new Measurements();
	private var decrementMonthButtonMeasurements:Measurements = new Measurements();
	private var incrementMonthButtonMeasurements:Measurements = new Measurements();
	private var decrementYearButtonMeasurements:Measurements = new Measurements();
	private var incrementYearButtonMeasurements:Measurements = new Measurements();
	private var currentMonthViewMeasurements:Measurements = new Measurements();

	private var _displayedFullYear:Int = Date.now().getFullYear();

	/**
		Along with the `displayedMonth`, sets the month that is currently
		visible in the calendar. Defaults to the current year.

		@see `CalendarGrid.displayedMonth`

		@since 1.0.0
	**/
	@:flash.property
	public var displayedFullYear(get, set):Int;

	private function get_displayedFullYear():Int {
		return this._displayedFullYear;
	}

	private function set_displayedFullYear(value:Int):Int {
		if (this._displayedFullYear == value) {
			return this._displayedFullYear;
		}
		this._displayedFullYear = value;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.SCROLL);
		return this._displayedFullYear;
	}

	private var _displayedMonth:Int = Date.now().getMonth();

	/**
		Along with the `displayedFullYear`, sets the month that is currently
		visible in the calendar. Defaults to the current month.

		Months are indexed starting from `0`. So the index of January is `0`,
		and the index of December is `11`.

		@see `CalendarGrid.displayedFullYear`

		@since 1.0.0
	**/
	@:flash.property
	public var displayedMonth(get, set):Int;

	private function get_displayedMonth():Int {
		return this._displayedMonth;
	}

	private function set_displayedMonth(value:Int):Int {
		if (value < 0 || value > 11) {
			throw new RangeError("displayedMonth must be in the range 0-11");
		}
		if (this._displayedMonth == value) {
			return this._displayedMonth;
		}
		this._displayedMonth = value;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.SCROLL);
		return this._displayedMonth;
	}

	private var _selectable:Bool = true;

	/**
		@since 1.0.0
	**/
	@:flash.property
	public var selectable(get, set):Bool;

	private function get_selectable():Bool {
		return this._selectable;
	}

	private function set_selectable(value:Bool):Bool {
		if (this._selectable == value) {
			return this._selectable;
		}
		this._selectable = value;
		if (!this._selectable && this._selectedDate != null) {
			this.selectedDate = null;
		}
		this.setInvalid(SELECTION);
		return this._selectable;
	}

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
		if (!this._selectable) {
			value = null;
		}
		if (this._selectedDate == value) {
			return this._selectedDate;
		}
		this._selectedDate = value;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedDate;
	}

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the date picker's content.

		The following example passes a bitmap for the date picker to use as a
		background skin:

		```hx
		datePicker.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `DatePicker.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the date picker's content when the
		date picker is disabled.

		The following example gives the date picker a disabled background skin:

		```hx
		datePicker.disabledBackgroundSkin = new Bitmap(bitmapData);
		datePicker.enabled = false;
		```

		@default null

		@see `DatePicker.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _oldCalendarGridFactory:DisplayObjectFactory<Dynamic, CalendarGrid>;

	private var _calendarGridFactory:DisplayObjectFactory<Dynamic, CalendarGrid>;

	/**
		Creates the calendar grid that is displayed as a sub-component. The
		calendar grid must be of type
		`feathers.controls.supportClasses.CalendarGrid`.

		Note: The following properties should not be set in the
		`calendarGridFactory` because they will be overridden by the
		`DatePicker` when it validates.

		- `CalendarGrid.requestedLocaleIDName`
		- `CalendarGrid.displayedMonth`
		- `CalendarGrid.displayedFullYear`
		- `CalendarGrid.selectable`
		- `CalendarGrid.selectedDate`
		- `CalendarGrid.customWeekdayNames`
		- `CalendarGrid.customStartOfWeek`

		In the following example, a custom calendar grid factory is provided:

		```hx
		datePicker.calendarGridFactory = () ->
		{
			return new CalendarGrid();
		};
		```

		@see `feathers.controls.supportClasses.CalendarGrid`

		@since 1.0.0
	**/
	@:flash.property
	public var calendarGridFactory(get, set):AbstractDisplayObjectFactory<Dynamic, CalendarGrid>;

	private function get_calendarGridFactory():AbstractDisplayObjectFactory<Dynamic, CalendarGrid> {
		return this._calendarGridFactory;
	}

	private function set_calendarGridFactory(value:AbstractDisplayObjectFactory<Dynamic, CalendarGrid>):AbstractDisplayObjectFactory<Dynamic, CalendarGrid> {
		if (this._calendarGridFactory == value) {
			return this._calendarGridFactory;
		}
		this._calendarGridFactory = value;
		this.setInvalid(INVALIDATION_FLAG_CALENDAR_GRID_FACTORY);
		return this._calendarGridFactory;
	}

	private var _previousCustomCalendarGridVariant:String = null;

	/**
		A custom variant to set on the calendar grid sub-component, instead of
		`DatePicker.CHILD_VARIANT_CALENDAR_GRID`.

		The `customCalendarGridVariant` will be not be used if the result of
		`calendarGridFactory` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_CALENDAR_GRID`

		@since 1.0.0
	**/
	@:style
	public var customCalendarGridVariant:String = null;

	private var _oldDecrementMonthButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _decrementMonthButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the decrement month button that is displayed as a sub-component.
		The button must be of type `feathers.controls.Button`.

		In the following example, a custom decrement month button factory is provided:

		```hx
		datePicker.decrementMonthButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	@:flash.property
	public var decrementMonthButtonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_decrementMonthButtonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._decrementMonthButtonFactory;
	}

	private function set_decrementMonthButtonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._decrementMonthButtonFactory == value) {
			return this._decrementMonthButtonFactory;
		}
		this._decrementMonthButtonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_DECREMENT_MONTH_BUTTON_FACTORY);
		return this._decrementMonthButtonFactory;
	}

	private var _previousCustomDecrementMonthButtonVariant:String = null;

	/**
		A custom variant to set on the decrement month button sub-component,
		instead of `DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON`.

		The `customDecrementMonthButtonVariant` will be not be used if the
		result of `decrementMonthButtonFactory` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customDecrementMonthButtonVariant:String = null;

	private var _oldIncrementMonthButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _incrementMonthButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the increment month button that is displayed as a sub-component.
		The button must be of type `feathers.controls.Button`.

		In the following example, a custom increment month button factory is provided:

		```hx
		datePicker.incrementMonthButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	@:flash.property
	public var incrementMonthButtonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_incrementMonthButtonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._incrementMonthButtonFactory;
	}

	private function set_incrementMonthButtonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._incrementMonthButtonFactory == value) {
			return this._incrementMonthButtonFactory;
		}
		this._incrementMonthButtonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_INCREMENT_MONTH_BUTTON_FACTORY);
		return this._incrementMonthButtonFactory;
	}

	private var _previousCustomIncrementMonthButtonVariant:String = null;

	/**
		A custom variant to set on the increment month button sub-component,
		instead of `DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON`.

		The `customIncrementMonthButtonVariant` will be not be used if the
		result of `incrementMonthButtonFactory` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customIncrementMonthButtonVariant:String = null;

	private var _oldDecrementYearButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _decrementYearButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the decrement year button that is displayed as a sub-component.
		The button must be of type `feathers.controls.Button`.

		In the following example, a custom decrement year button factory is provided:

		```hx
		datePicker.decrementYearButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	@:flash.property
	public var decrementYearButtonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_decrementYearButtonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._decrementYearButtonFactory;
	}

	private function set_decrementYearButtonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._decrementYearButtonFactory == value) {
			return this._decrementYearButtonFactory;
		}
		this._decrementYearButtonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_DECREMENT_YEAR_BUTTON_FACTORY);
		return this._decrementYearButtonFactory;
	}

	private var _previousCustomDecrementYearButtonVariant:String = null;

	/**
		A custom variant to set on the decrement year button sub-component,
		instead of `DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON`.

		The `customDecrementYearButtonVariant` will be not be used if the
		result of `decrementYearButtonFactory` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customDecrementYearButtonVariant:String = null;

	private var _oldIncrementYearButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _incrementYearButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the increment year button that is displayed as a sub-component.
		The button must be of type `feathers.controls.Button`.

		In the following example, a custom increment year button factory is provided:

		```hx
		datePicker.incrementYearButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
	@:flash.property
	public var incrementYearButtonFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Button>;

	private function get_incrementYearButtonFactory():AbstractDisplayObjectFactory<Dynamic, Button> {
		return this._incrementYearButtonFactory;
	}

	private function set_incrementYearButtonFactory(value:AbstractDisplayObjectFactory<Dynamic, Button>):AbstractDisplayObjectFactory<Dynamic, Button> {
		if (this._incrementYearButtonFactory == value) {
			return this._incrementYearButtonFactory;
		}
		this._incrementYearButtonFactory = value;
		this.setInvalid(INVALIDATION_FLAG_INCREMENT_YEAR_BUTTON_FACTORY);
		return this._incrementYearButtonFactory;
	}

	private var _previousCustomIncrementYearButtonVariant:String = null;

	/**
		A custom variant to set on the increment year button sub-component,
		instead of `DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON`.

		The `customIncrementYearButtonVariant` will be not be used if the
		result of `incrementYearButtonFactory` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customIncrementYearButtonVariant:String = null;

	private var _oldCurrentMonthViewFactory:DisplayObjectFactory<Dynamic, Label>;

	private var _currentMonthViewFactory:DisplayObjectFactory<Dynamic, Label>;

	/**
		Creates the current month view that is displayed as a sub-component.
		The button must be of type `feathers.controls.Label`.

		In the following example, a custom current month view factory is provided:

		```hx
		datePicker.currentMonthViewFactory = () ->
		{
			return new Label();
		};
		```

		@since 1.0.0
	**/
	@:flash.property
	public var currentMonthViewFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Label>;

	private function get_currentMonthViewFactory():AbstractDisplayObjectFactory<Dynamic, Label> {
		return this._currentMonthViewFactory;
	}

	private function set_currentMonthViewFactory(value:AbstractDisplayObjectFactory<Dynamic, Label>):AbstractDisplayObjectFactory<Dynamic, Label> {
		if (this._currentMonthViewFactory == value) {
			return this._currentMonthViewFactory;
		}
		this._currentMonthViewFactory = value;
		this.setInvalid(INVALIDATION_FLAG_CURRENT_MONTH_VIEW_FACTORY);
		return this._currentMonthViewFactory;
	}

	private var _previousCustomCurrentMonthViewVariant:String = null;

	/**
		A custom variant to set on the current month button sub-component,
		instead of `DatePicker.CHILD_VARIANT_CURRENT_MONTH_VIEW`.

		The `customCurrentMonthViewVariant` will be not be used if the
		result of `currentMonthViewFactory` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_CURRENT_MONTH_VIEW`

		@since 1.0.0
	**/
	@:style
	public var customCurrentMonthViewVariant:String = null;

	private var _ignoreCalendarGridChange = false;

	/**
		The space, in pixels, between items in the date picker's header.

		In the following example, the date picker's header gap is set to 20
		pixels:

		```hx
		datePicker.headerGap = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var headerGap:Float = 0.0;

	/**
		The minimum space, in pixels, between the date picker's top edge and the
		date picker's content.

		In the following example, the date picker's top padding is set to 20
		pixels:

		```hx
		datePicker.paddingTop = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the date picker's right edge and
		the date picker's content.

		In the following example, the date picker's right padding is set to 20
		pixels:

		```hx
		datePicker.paddingRight = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the date picker's bottom edge and
		the date picker's content.

		In the following example, the date picker's bottom padding is set to 20
		pixels:

		```hx
		datePicker.paddingBottom = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the date picker's left edge and
		the date picker's content.

		In the following example, the date picker's left padding is set to 20
		pixels:

		```hx
		datePicker.paddingLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		The horizontal position of the current month button, relative to the
		increment and decrement buttons.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:style
	public var currentMonthViewPosition:HorizontalAlign = CENTER;

	/**
		Determines if the buttons to decrement and increment the current month
		are displayed or hidden.

		@since 1.0.0
	**/
	@:style
	public var showMonthButtons:Bool = true;

	/**
		Determines if the buttons to decrement and increment the current year
		are displayed or hidden.

		@since 1.0.0
	**/
	@:style
	public var showYearButtons:Bool = true;

	private var _currentMonthNames:Array<String>;

	#if (flash || (openfl >= "9.2.0" && !neko))
	private var _currentDateFormatter:DateTimeFormatter;
	#end

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

	/**
		Sets all four padding properties to the same value.

		@see `DatePicker.paddingTop`
		@see `DatePicker.paddingRight`
		@see `DatePicker.paddingBottom`
		@see `DatePicker.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	private var _customMonthNames:Array<String> = null;

	/**
		A custom set of month names to use instead of the default.

		@since 1.0.0
	**/
	@:flash.property
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
	@:flash.property
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
	@:flash.property
	public var customStartOfWeek(get, set):Null<Int>;

	private function get_customStartOfWeek():Null<Int> {
		return this._customStartOfWeek;
	}

	private function set_customStartOfWeek(value:Null<Int>):Null<Int> {
		if (value != null && (value < 0 || value > 6)) {
			throw new RangeError("startOfWeek must be in the range 0-6");
		}
		if (this._customStartOfWeek == value) {
			return this._customStartOfWeek;
		}
		this._customStartOfWeek = value;
		this.setInvalid(DATA);
		return this._customStartOfWeek;
	}

	private function initializeDatePickerTheme():Void {
		SteelDatePickerStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomCalendarGridVariant != this.customCalendarGridVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_CALENDAR_GRID_FACTORY);
		}
		if (this._previousCustomDecrementMonthButtonVariant != this.customDecrementMonthButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_DECREMENT_MONTH_BUTTON_FACTORY);
		}
		if (this._previousCustomIncrementMonthButtonVariant != this.customIncrementMonthButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_INCREMENT_MONTH_BUTTON_FACTORY);
		}
		if (this._previousCustomDecrementYearButtonVariant != this.customDecrementYearButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_DECREMENT_YEAR_BUTTON_FACTORY);
		}
		if (this._previousCustomIncrementYearButtonVariant != this.customIncrementYearButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_INCREMENT_YEAR_BUTTON_FACTORY);
		}
		if (this._previousCustomCurrentMonthViewVariant != this.customCurrentMonthViewVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_CURRENT_MONTH_VIEW_FACTORY);
		}
		var calendarGridFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_CALENDAR_GRID_FACTORY);
		var decrementMonthButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_DECREMENT_MONTH_BUTTON_FACTORY);
		var incrementMonthButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_INCREMENT_MONTH_BUTTON_FACTORY);
		var decrementYearButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_DECREMENT_YEAR_BUTTON_FACTORY);
		var incrementYearButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_INCREMENT_YEAR_BUTTON_FACTORY);
		var currentMonthViewFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_CURRENT_MONTH_VIEW_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (calendarGridFactoryInvalid) {
			this.createCalendarGrid();
		}

		if (currentMonthViewFactoryInvalid) {
			this.createCurrentMonthView();
		}

		if (decrementMonthButtonFactoryInvalid) {
			this.createDecrementMonthButton();
		}

		if (incrementMonthButtonFactoryInvalid) {
			this.createIncrementMonthButton();
		}

		if (decrementYearButtonFactoryInvalid) {
			this.createDecrementYearButton();
		}

		if (incrementYearButtonFactoryInvalid) {
			this.createIncrementYearButton();
		}

		if (dataInvalid) {
			this.refreshLocale();
		}

		if (stateInvalid || calendarGridFactoryInvalid || currentMonthViewFactoryInvalid || decrementMonthButtonFactoryInvalid
			|| incrementMonthButtonFactoryInvalid || decrementYearButtonFactoryInvalid || incrementYearButtonFactoryInvalid) {
			this.refreshEnabled();
		}

		if (dataInvalid || selectionInvalid) {
			this.refreshCalendarGrid();
			this.refreshCurrentMonth();
		}

		this.measure();
		this.layoutChildren();

		this._previousCustomCalendarGridVariant = this.customCalendarGridVariant;
		this._previousCustomCurrentMonthViewVariant = this.customCurrentMonthViewVariant;
		this._previousCustomDecrementMonthButtonVariant = this.customDecrementMonthButtonVariant;
		this._previousCustomIncrementMonthButtonVariant = this.customIncrementMonthButtonVariant;
		this._previousCustomDecrementYearButtonVariant = this.customDecrementYearButtonVariant;
		this._previousCustomIncrementYearButtonVariant = this.customIncrementYearButtonVariant;
	}

	private function createCalendarGrid():Void {
		if (this.calendarGrid != null) {
			this.calendarGrid.removeEventListener(Event.CHANGE, datePicker_calendarGrid_changeHandler);
			this.calendarGrid.removeEventListener(Event.SCROLL, datePicker_calendarGrid_scrollHandler);
			if (this._oldCalendarGridFactory.destroy != null) {
				this._oldCalendarGridFactory.destroy(this.calendarGrid);
			}
			this._oldCalendarGridFactory = null;
			this.calendarGrid = null;
		}
		var factory = this._calendarGridFactory != null ? this._calendarGridFactory : defaultCalendarGridFactory;
		this._oldCalendarGridFactory = factory;
		this.calendarGrid = factory.create();
		if (this.calendarGrid.variant == null) {
			this.calendarGrid.variant = this.customCalendarGridVariant != null ? this.customCalendarGridVariant : DatePicker.CHILD_VARIANT_CALENDAR_GRID;
		}
		this.calendarGrid.initializeNow();
		this.calendarGridMeasurements.save(this.calendarGrid);
		this.addChild(this.calendarGrid);
		this.calendarGrid.addEventListener(Event.CHANGE, datePicker_calendarGrid_changeHandler);
		this.calendarGrid.addEventListener(Event.SCROLL, datePicker_calendarGrid_scrollHandler);
	}

	private function createCurrentMonthView():Void {
		if (this.currentMonthView != null) {
			if (this._oldCurrentMonthViewFactory.destroy != null) {
				this._oldCurrentMonthViewFactory.destroy(this.currentMonthView);
			}
			this._oldCurrentMonthViewFactory = null;
			this.currentMonthView = null;
		}
		var factory = this._currentMonthViewFactory != null ? this._currentMonthViewFactory : defaultCurrentMonthViewFactory;
		this._oldCurrentMonthViewFactory = factory;
		this.currentMonthView = factory.create();
		if (this.currentMonthView.variant == null) {
			this.currentMonthView.variant = this.customCurrentMonthViewVariant != null ? this.customCurrentMonthViewVariant : DatePicker.CHILD_VARIANT_CURRENT_MONTH_VIEW;
		}
		this.currentMonthView.initializeNow();
		this.currentMonthViewMeasurements.save(this.currentMonthView);
		this.addChild(this.currentMonthView);
	}

	private function createDecrementMonthButton():Void {
		if (this.decrementMonthButton != null) {
			this.decrementMonthButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_decrementMonthButton_triggerHandler);
			if (this._oldDecrementMonthButtonFactory.destroy != null) {
				this._oldDecrementMonthButtonFactory.destroy(this.decrementMonthButton);
			}
			this._oldDecrementMonthButtonFactory = null;
			this.decrementMonthButton = null;
		}
		var factory = this._decrementMonthButtonFactory != null ? this._decrementMonthButtonFactory : defaultDecrementMonthButtonFactory;
		this._oldDecrementMonthButtonFactory = factory;
		this.decrementMonthButton = factory.create();
		if (this.decrementMonthButton.variant == null) {
			this.decrementMonthButton.variant = this.customDecrementMonthButtonVariant != null ? this.customDecrementMonthButtonVariant : DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON;
		}
		this.decrementMonthButton.initializeNow();
		this.decrementMonthButtonMeasurements.save(this.decrementMonthButton);
		this.addChild(this.decrementMonthButton);
		this.decrementMonthButton.addEventListener(TriggerEvent.TRIGGER, datePicker_decrementMonthButton_triggerHandler);
	}

	private function createIncrementMonthButton():Void {
		if (this.incrementMonthButton != null) {
			this.incrementMonthButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_incrementMonthButton_triggerHandler);
			if (this._oldIncrementMonthButtonFactory.destroy != null) {
				this._oldIncrementMonthButtonFactory.destroy(this.incrementMonthButton);
			}
			this._oldIncrementMonthButtonFactory = null;
			this.incrementMonthButton = null;
		}
		var factory = this._incrementMonthButtonFactory != null ? this._incrementMonthButtonFactory : defaultIncrementMonthButtonFactory;
		this._oldIncrementMonthButtonFactory = factory;
		this.incrementMonthButton = factory.create();
		if (this.incrementMonthButton.variant == null) {
			this.incrementMonthButton.variant = this.customIncrementMonthButtonVariant != null ? this.customIncrementMonthButtonVariant : DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON;
		}
		this.incrementMonthButton.initializeNow();
		this.incrementMonthButtonMeasurements.save(this.incrementMonthButton);
		this.addChild(this.incrementMonthButton);
		this.incrementMonthButton.addEventListener(TriggerEvent.TRIGGER, datePicker_incrementMonthButton_triggerHandler);
	}

	private function createDecrementYearButton():Void {
		if (this.decrementYearButton != null) {
			this.decrementYearButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_decrementYearButton_triggerHandler);
			if (this._oldDecrementYearButtonFactory.destroy != null) {
				this._oldDecrementYearButtonFactory.destroy(this.decrementYearButton);
			}
			this._oldDecrementYearButtonFactory = null;
			this.decrementYearButton = null;
		}
		var factory = this._decrementYearButtonFactory != null ? this._decrementYearButtonFactory : defaultDecrementYearButtonFactory;
		this._oldDecrementYearButtonFactory = factory;
		this.decrementYearButton = factory.create();
		if (this.decrementYearButton.variant == null) {
			this.decrementYearButton.variant = this.customDecrementYearButtonVariant != null ? this.customDecrementYearButtonVariant : DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON;
		}
		this.decrementYearButton.initializeNow();
		this.decrementYearButtonMeasurements.save(this.decrementYearButton);
		this.addChild(this.decrementYearButton);
		this.decrementYearButton.addEventListener(TriggerEvent.TRIGGER, datePicker_decrementYearButton_triggerHandler);
	}

	private function createIncrementYearButton():Void {
		if (this.incrementYearButton != null) {
			this.incrementYearButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_incrementYearButton_triggerHandler);
			if (this._oldIncrementYearButtonFactory.destroy != null) {
				this._oldIncrementYearButtonFactory.destroy(this.incrementYearButton);
			}
			this._oldIncrementYearButtonFactory = null;
			this.incrementYearButton = null;
		}
		var factory = this._incrementYearButtonFactory != null ? this._incrementYearButtonFactory : defaultIncrementYearButtonFactory;
		this._oldIncrementYearButtonFactory = factory;
		this.incrementYearButton = factory.create();
		if (this.incrementYearButton.variant == null) {
			this.incrementYearButton.variant = this.customIncrementYearButtonVariant != null ? this.customIncrementYearButtonVariant : DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON;
		}
		this.incrementYearButton.initializeNow();
		this.incrementYearButtonMeasurements.save(this.incrementYearButton);
		this.addChild(this.incrementYearButton);
		this.incrementYearButton.addEventListener(TriggerEvent.TRIGGER, datePicker_incrementYearButton_triggerHandler);
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

		this.calendarGridMeasurements.restore(this.calendarGrid);
		this.calendarGrid.validateNow();

		this.currentMonthViewMeasurements.restore(this.currentMonthView);
		var oldText = this.currentMonthView.text;
		var measureText = this.getMonthText(this.getMonthWithLongestName(), 0);
		this.currentMonthView.text = measureText;
		this.currentMonthView.validateNow();

		this.decrementMonthButtonMeasurements.restore(this.decrementMonthButton);
		this.decrementMonthButton.validateNow();
		this.incrementMonthButtonMeasurements.restore(this.incrementMonthButton);
		this.incrementMonthButton.validateNow();
		this.decrementYearButtonMeasurements.restore(this.decrementYearButton);
		this.decrementYearButton.validateNow();
		this.incrementYearButtonMeasurements.restore(this.incrementYearButton);
		this.incrementYearButton.validateNow();

		var headerWidth = this.currentMonthView.width;
		var headerHeight = this.currentMonthView.height;
		if (this.showMonthButtons) {
			headerWidth += (2.0 * this.headerGap) + this.decrementMonthButton.width + this.incrementMonthButton.width;
			headerHeight = Math.max(headerHeight, Math.max(this.decrementMonthButton.height, this.incrementMonthButton.height));
		}
		if (this.showYearButtons) {
			headerWidth += (2.0 * this.headerGap) + this.decrementYearButton.width + this.incrementYearButton.width;
			headerHeight = Math.max(headerHeight, Math.max(this.decrementYearButton.height, this.incrementYearButton.height));
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = Math.max(this.calendarGrid.width, headerWidth);
			newWidth += this.paddingLeft + this.paddingRight;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = headerHeight + this.calendarGrid.height;
			newHeight += this.paddingTop + this.paddingBottom;
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = Math.max(this.calendarGrid.minWidth, headerWidth);
			newMinWidth += this.paddingLeft + this.paddingRight;
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = headerHeight + this.calendarGrid.minHeight;
			newMinHeight += this.paddingTop + this.paddingBottom;
		}

		this.currentMonthView.text = oldText;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}

	private function refreshEnabled():Void {
		this.currentMonthView.enabled = this.enabled;
		this.decrementMonthButton.enabled = this.enabled;
		this.incrementMonthButton.enabled = this.enabled;
		this.decrementYearButton.enabled = this.enabled;
		this.incrementYearButton.enabled = this.enabled;
		this.calendarGrid.enabled = this.enabled;
	}

	private function refreshLocale():Void {
		#if (flash || (openfl >= "9.2.0" && !neko))
		var localeID = this._requestedLocaleIDName != null ? this._requestedLocaleIDName : LocaleID.DEFAULT;
		this._currentDateFormatter = new DateTimeFormatter(localeID, LONG, NONE);
		this._actualLocaleIDName = this._currentDateFormatter.actualLocaleIDName;
		this._currentDateFormatter.setDateTimePattern("MMMM yyyy");
		this._currentMonthNames = this._customMonthNames;
		if (this._currentMonthNames == null) {
			var monthNamesVector = this._currentDateFormatter.getMonthNames(FULL, FORMAT);
			this._currentMonthNames = [];
			for (monthName in monthNamesVector) {
				this._currentMonthNames.push(monthName);
			}
		}
		#else
		this._currentMonthNames = DEFAULT_MONTH_NAMES;
		this._actualLocaleIDName = "en-US";
		#end
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
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function layoutChildren():Void {
		this.layoutBackgroundSkin();

		this.decrementMonthButton.visible = this.showMonthButtons;
		this.incrementMonthButton.visible = this.showMonthButtons;
		this.decrementYearButton.visible = this.showYearButtons;
		this.incrementYearButton.visible = this.showYearButtons;
		this.currentMonthView.validateNow();
		this.decrementMonthButton.validateNow();
		this.incrementMonthButton.validateNow();
		this.decrementYearButton.validateNow();
		this.incrementYearButton.validateNow();
		var maxButtonHeight = 0.0;
		if (this.showMonthButtons) {
			maxButtonHeight = Math.max(maxButtonHeight, Math.max(this.decrementMonthButton.height, this.incrementMonthButton.height));
		}
		if (this.showYearButtons) {
			maxButtonHeight = Math.max(maxButtonHeight, Math.max(this.decrementYearButton.height, this.incrementYearButton.height));
		}
		if (this.decrementMonthButton.height != maxButtonHeight) {
			this.decrementMonthButton.height = maxButtonHeight;
		}
		if (this.incrementMonthButton.height != maxButtonHeight) {
			this.incrementMonthButton.height = maxButtonHeight;
		}
		if (this.decrementYearButton.height != maxButtonHeight) {
			this.decrementYearButton.height = maxButtonHeight;
		}
		if (this.incrementYearButton.height != maxButtonHeight) {
			this.incrementYearButton.height = maxButtonHeight;
		}
		var headerHeight = Math.max(this.currentMonthView.height, maxButtonHeight);
		switch (this.currentMonthViewPosition) {
			case CENTER:
				this.currentMonthView.x = this.paddingLeft + (this.actualWidth - this.paddingLeft - this.paddingRight - this.currentMonthView.width) / 2.0;
				var currentX = this.paddingLeft;
				if (this.showYearButtons) {
					this.decrementYearButton.x = currentX;
					currentX += this.decrementYearButton.width + this.headerGap;
				}
				if (this.showMonthButtons) {
					this.decrementMonthButton.x = currentX;
					currentX += this.decrementMonthButton.width + this.headerGap;
				}
				var currentX = this.actualWidth - this.paddingRight;
				if (this.showYearButtons) {
					currentX -= this.incrementYearButton.width;
					this.incrementYearButton.x = currentX;
					currentX -= this.headerGap;
				}
				if (this.showMonthButtons) {
					currentX -= this.incrementMonthButton.width;
					this.incrementMonthButton.x = currentX;
					currentX -= this.headerGap;
				}
			case RIGHT:
				this.currentMonthView.x = this.actualWidth - this.paddingRight - this.currentMonthView.width;
				var currentX = this.paddingLeft;
				if (this.showYearButtons) {
					this.decrementYearButton.x = currentX;
					currentX += this.decrementYearButton.width + this.headerGap;
				}
				if (this.showMonthButtons) {
					this.decrementMonthButton.x = currentX;
					currentX += this.decrementMonthButton.width + this.headerGap;
				}
				if (this.showMonthButtons) {
					this.incrementMonthButton.x = currentX;
					currentX += this.incrementMonthButton.width + this.headerGap;
				}
				if (this.showYearButtons) {
					this.incrementYearButton.x = currentX;
					currentX += this.incrementYearButton.width + this.headerGap;
				}
			case LEFT:
				this.currentMonthView.x = this.paddingLeft;
				var currentX = this.actualWidth - this.paddingRight;
				if (this.showYearButtons) {
					currentX -= this.incrementYearButton.width;
					this.incrementYearButton.x = currentX;
					currentX -= this.headerGap;
				}
				if (this.showMonthButtons) {
					currentX -= this.incrementMonthButton.width;
					this.incrementMonthButton.x = currentX;
					currentX -= this.headerGap;
				}
				if (this.showMonthButtons) {
					currentX -= this.decrementMonthButton.width;
					this.decrementMonthButton.x = currentX;
					currentX -= this.headerGap;
				}
				if (this.showYearButtons) {
					currentX -= this.decrementYearButton.width;
					this.decrementYearButton.x = currentX;
					currentX -= this.headerGap;
				}
			default:
				throw new ArgumentError("Invalid month position: " + this.currentMonthViewPosition);
		}
		this.currentMonthView.y = this.paddingTop + (headerHeight - this.currentMonthView.height) / 2.0;
		this.decrementMonthButton.y = this.paddingTop + (headerHeight - this.decrementMonthButton.height) / 2.0;
		this.incrementMonthButton.y = this.paddingTop + (headerHeight - this.incrementMonthButton.height) / 2.0;
		this.decrementYearButton.y = this.paddingTop + (headerHeight - this.decrementYearButton.height) / 2.0;
		this.incrementYearButton.y = this.paddingTop + (headerHeight - this.incrementYearButton.height) / 2.0;

		this.calendarGrid.x = this.paddingLeft;
		this.calendarGrid.y = this.paddingTop + headerHeight;
		var calendarWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		var calendarHeight = this.actualHeight - headerHeight - this.paddingTop - this.paddingBottom;
		if (this.calendarGrid.width != calendarWidth) {
			this.calendarGrid.width = calendarWidth;
		}
		if (this.calendarGrid.height != calendarHeight) {
			this.calendarGrid.height = calendarHeight;
		}
		this.calendarGrid.validateNow();
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
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function refreshCalendarGrid():Void {
		var oldIgnoreCalendarGridChange = this._ignoreCalendarGridChange;
		this._ignoreCalendarGridChange = true;
		this.calendarGrid.requestedLocaleIDName = this._requestedLocaleIDName;
		this.calendarGrid.displayedMonth = this._displayedMonth;
		this.calendarGrid.displayedFullYear = this._displayedFullYear;
		this.calendarGrid.selectable = this._selectable;
		this.calendarGrid.selectedDate = this._selectedDate;
		this.calendarGrid.customWeekdayNames = this._customWeekdayNames;
		this.calendarGrid.customStartOfWeek = this._customStartOfWeek;
		this._ignoreCalendarGridChange = oldIgnoreCalendarGridChange;
	}

	private function refreshCurrentMonth():Void {
		this.currentMonthView.text = this.getMonthText(this.displayedMonth, this.displayedFullYear);
	}

	private function getMonthWithLongestName():Int {
		var maxLength = 0;
		var maxIndex = -1;
		for (i in 0...this._currentMonthNames.length) {
			var monthName = this._currentMonthNames[i];
			var currentLength = monthName.length;
			if (maxLength < currentLength) {
				maxLength = currentLength;
				maxIndex = i;
			}
		}
		return maxIndex;
	}

	private function getMonthText(month:Int, fullYear:Int):String {
		#if (flash || (openfl >= "9.2.0" && !neko))
		if (this._customMonthNames != null) {
			var monthName = this._currentMonthNames[month];
			return '$monthName ${StringTools.lpad(Std.string(fullYear), "0", 4)}';
		} else {
			return this._currentDateFormatter.format(new Date(fullYear, month, 1, 0, 0, 0));
		}
		#else
		var monthName = this._currentMonthNames[month];
		return '$monthName ${StringTools.lpad(Std.string(fullYear), "0", 4)}';
		#end
	}

	private function datePicker_calendarGrid_changeHandler(event:Event):Void {
		if (this._ignoreCalendarGridChange) {
			return;
		}
		this.selectedDate = this.calendarGrid.selectedDate;
	}

	private function datePicker_calendarGrid_scrollHandler(event:Event):Void {
		if (this._ignoreCalendarGridChange) {
			return;
		}
		this.displayedMonth = this.calendarGrid.displayedMonth;
		this.displayedFullYear = this.calendarGrid.displayedFullYear;
	}

	private function datePicker_decrementMonthButton_triggerHandler(event:TriggerEvent):Void {
		var displayedMonth = this._displayedMonth;
		var displayedFullYear = this._displayedFullYear;
		displayedMonth--;
		if (displayedMonth < 0) {
			displayedMonth = 11;
			displayedFullYear--;
		}
		this.displayedMonth = displayedMonth;
		this.displayedFullYear = displayedFullYear;
	}

	private function datePicker_incrementMonthButton_triggerHandler(event:TriggerEvent):Void {
		var displayedMonth = this._displayedMonth;
		var displayedFullYear = this._displayedFullYear;
		displayedMonth++;
		if (displayedMonth > 11) {
			displayedMonth = 0;
			displayedFullYear++;
		}
		this.displayedMonth = displayedMonth;
		this.displayedFullYear = displayedFullYear;
	}

	private function datePicker_decrementYearButton_triggerHandler(event:TriggerEvent):Void {
		this.displayedFullYear--;
	}

	private function datePicker_incrementYearButton_triggerHandler(event:TriggerEvent):Void {
		this.displayedFullYear++;
	}
}
