/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IDateSelector;
import feathers.core.IUIControl;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelCalendarGridStyles;
import feathers.utils.DateUtil;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.RangeError;
import openfl.events.Event;

@:event("change", openfl.events.Event)
@:event("scroll", openfl.events.Event)

/**
	Displays a calendar for a specific month.

	The following example creates a `CalendarGrid`, selects a date, and listens
	for when the selection changes:

	```hx
	var calendar = new CalendarGrid();

	calendar.displayedFullYear = Date.now().getFullYear();
	calendar.displayedMonth = Date.now().getMonth();
	calendar.selectedDate = Date.now();

	calendar.addEventListener(Event.CHANGE, (event:Event) -> {
		var calendar = cast(event.currentTarget, CalendarGrid);
		trace("CalendarGrid changed: " + calendar.selectedDate);
	});

	this.addChild(calendar);
	```

	@see [Tutorial: How to use the CalendarGrid component](https://feathersui.com/learn/haxe-openfl/calendar-grid/)

	@since 1.0.0
**/
class CalendarGrid extends FeathersControl implements IDateSelector {
	// TODO: get these values from openfl.globalization.DateTimeFormatter
	private var DEFAULT_WEEKDAY_NAMES = ["S", "M", "T", "W", "T", "F", "S"];
	// TODO: get this value from openfl.globalization.DateTimeFormatter
	private var DEFAULT_START_OF_WEEK = 0;

	/**
		The variant used to style the `ToggleButton` child components from the
		current month in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DATE_TOGGLE_BUTTON = "calendarGrid_dateToggleButton";

	/**
		The variant used to style the `ToggleButton` child components that are
		not from the current month in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON = "calendarGrid_mutedDateToggleButton";

	/**
		The variant used to style the `Label` child components that display the
		names of weekdays.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_WEEKDAY_LABEL = "calendarGrid_weekdayLabel";

	/**
		Creates a new `CalendarGrid` object.

		@since 1.0.0
	**/
	public function new() {
		initializeCalendarGridTheme();
		super();
	}

	private var _dayNameLabels:Array<Label> = [];
	private var _dateButtons:Array<ToggleButton> = [];

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
		this.setInvalid(DATA);
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
			throw new RangeError("displayedMonth must be in the range 0-6");
		}
		if (this._displayedMonth == value) {
			return this._displayedMonth;
		}
		this._displayedMonth = value;
		this.setInvalid(DATA);
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
		The default background skin to display behind the calendar's content.

		The following example passes a bitmap for the calendar to use as a
		background skin:

		```hx
		calendar.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `CalendarGrid.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the calendar's content when the
		calendar is disabled.

		The following example gives the calendar a disabled background skin:

		```hx
		calendar.disabledBackgroundSkin = new Bitmap(bitmapData);
		calendar.enabled = false;
		```

		@default null

		@see `CalendarGrid.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	/**
		An optional custom variant to use for the toggle buttons that represent
		dates in the current month.

		@see `CalendarGrid.CHILD_VARIANT_DATE_TOGGLE_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var toggleButtonVariant:String = null;

	/**
		An optional custom variant to use for the toggle buttons that represent
		dates in the adjacent months.

		@see `CalendarGrid.CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var mutedToggleButtonVariant:String = null;

	/**
		An optional custom variant to use for the labels that display the names
		of weekdays.

		@see `CalendarGrid.CHILD_VARIANT_WEEKDAY_LABEL`

		@since 1.0.0
	**/
	@:style
	public var weekdayLabelVariant:String = null;

	/**
		Determines if the weekday labels are visible or not.

		@since 1.0.0
	**/
	@:style
	public var showWeekdayLabels:Bool = true;

	/**
		Determines if the toggle buttons for dates in the adjacent months are
		visible or not.

		@since 1.0.0
	**/
	@:style
	public var showDatesFromAdjacentMonths:Bool = true;

	private var _customWeekdayNames:Array<String> = null;

	/**
		A custom set of weekday names to use instead of the default.

		@default ["S", "M", "T", "W", "T", "F", "S"]

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

		@default 0

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

	private function initializeCalendarGridTheme():Void {
		SteelCalendarGridStyles.initialize();
	}

	override private function initialize():Void {
		for (i in 0...7) {
			var dayNameLabel = new Label();
			this.addChild(dayNameLabel);
			this._dayNameLabels.push(dayNameLabel);
		}
		for (i in 0...42) {
			var dateButton = new ToggleButton();
			dateButton.toggleable = false;
			dateButton.addEventListener(TriggerEvent.TRIGGER, dateButton_triggerHandler);
			this.addChild(dateButton);
			this._dateButtons.push(dateButton);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (dataInvalid || stylesInvalid) {
			this.refreshWeekdayLabels();
		}

		if (dataInvalid || selectionInvalid) {
			this.refreshDisplayedMonth();
		}

		this.measure();

		this.layoutContent();
	}

	private function measure():Bool {
		return this.saveMeasurements(200.0, 250.0, 200.0, 250.0);
	}

	private function refreshWeekdayLabels():Void {
		var weekdayNames = this._customWeekdayNames != null ? this._customWeekdayNames : DEFAULT_WEEKDAY_NAMES;
		var weekdayLabelVariant = this.weekdayLabelVariant != null ? this.weekdayLabelVariant : CHILD_VARIANT_WEEKDAY_LABEL;
		var startOfWeek = this._customStartOfWeek != null ? this._customStartOfWeek : DEFAULT_START_OF_WEEK;
		for (i in 0...this._dayNameLabels.length) {
			var nameIndex = (i + startOfWeek) % this._dayNameLabels.length;
			var dayNameLabel = this._dayNameLabels[i];
			dayNameLabel.variant = weekdayLabelVariant;
			dayNameLabel.text = weekdayNames[nameIndex];
			dayNameLabel.visible = this.showWeekdayLabels;
			dayNameLabel.includeInLayout = this.showWeekdayLabels;
		}
	}

	private function layoutContent() {
		var columnWidth = this.actualWidth / 7.0;
		var rowHeight = columnWidth;

		var currentX = 0.0;
		var currentY = 0.0;
		for (i in 0...this._dayNameLabels.length) {
			var dayNameLabel = this._dayNameLabels[i];
			if (dayNameLabel.includeInLayout) {
				dayNameLabel.validateNow();
				dayNameLabel.x = currentX + (columnWidth - dayNameLabel.width) / 2.0;
				dayNameLabel.y = currentY + (rowHeight - dayNameLabel.height) / 2.0;
				currentX += columnWidth;
			}
		}

		currentX = 0.0;
		if (this.showWeekdayLabels) {
			currentY += rowHeight;
		}
		for (i in 0...this._dateButtons.length) {
			var dateButton = this._dateButtons[i];
			dateButton.validateNow();
			dateButton.x = currentX + (columnWidth - dateButton.width) / 2.0;
			dateButton.y = currentY + (rowHeight - dateButton.height) / 2.0;
			if (i % 7 == 6) {
				currentX = 0.0;
				currentY += rowHeight;
			} else {
				currentX += columnWidth;
			}
		}
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
		if (Std.is(this._currentBackgroundSkin, IProgrammaticSkin)) {
			cast(this._currentBackgroundSkin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshDisplayedMonth():Void {
		var startOfWeek = this._customStartOfWeek != null ? this._customStartOfWeek : 0;
		var dayIndexOfFirst = -startOfWeek + (new Date(this._displayedFullYear, this._displayedMonth, 1, 0, 0, 0)).getDay();
		if (dayIndexOfFirst < 0) {
			dayIndexOfFirst = 0;
		}
		var lastMonthYear = this._displayedFullYear;
		var lastMonth = this._displayedMonth - 1;
		if (lastMonth < 0) {
			lastMonth = 11;
			lastMonthYear--;
		}
		var numDays = DateUtil.getDaysInMonth(this._displayedMonth, this._displayedFullYear);
		var numDaysLastMonth = DateUtil.getDaysInMonth(lastMonth, lastMonthYear);
		var currentDate = numDaysLastMonth - dayIndexOfFirst + 1;
		var inCurrentMonth = currentDate == 1;
		var toggleButtonVariant = this.toggleButtonVariant != null ? this.toggleButtonVariant : CHILD_VARIANT_DATE_TOGGLE_BUTTON;
		var mutedToggleButtonVariant = this.mutedToggleButtonVariant != null ? this.mutedToggleButtonVariant : CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON;
		for (i in 0...this._dateButtons.length) {
			var dateButton = this._dateButtons[i];
			dateButton.selected = inCurrentMonth
				&& this._selectedDate != null
				&& this._displayedFullYear == this._selectedDate.getFullYear()
				&& this._displayedMonth == this._selectedDate.getMonth()
				&& currentDate == this._selectedDate.getDate();
			dateButton.text = Std.string(currentDate);
			dateButton.variant = inCurrentMonth ? toggleButtonVariant : mutedToggleButtonVariant;
			dateButton.toggleable = this._selectable;
			dateButton.visible = inCurrentMonth || this.showDatesFromAdjacentMonths;
			currentDate++;
			if (!inCurrentMonth && currentDate > numDaysLastMonth) {
				currentDate = 1;
				inCurrentMonth = true;
			}
			if (inCurrentMonth && currentDate > numDays) {
				currentDate = 1;
				inCurrentMonth = false;
			}
		}
	}

	private function getDateForButtonIndex(index:Int):Date {
		var startOfWeek = this._customStartOfWeek != null ? this._customStartOfWeek : 0;
		var dayIndexOfFirst = -startOfWeek + (new Date(this._displayedFullYear, this._displayedMonth, 1, 0, 0, 0)).getDay();
		if (dayIndexOfFirst < 0) {
			dayIndexOfFirst = 0;
		}
		var numDays = DateUtil.getDaysInMonth(this._displayedMonth, this._displayedFullYear);

		if (index < dayIndexOfFirst) {
			var lastMonthYear = this._displayedFullYear;
			var lastMonth = this._displayedMonth - 1;
			if (lastMonth < 0) {
				lastMonth = 11;
				lastMonthYear--;
			}
			var numDaysLastMonth = DateUtil.getDaysInMonth(lastMonth, lastMonthYear);
			return new Date(lastMonthYear, lastMonth, numDaysLastMonth - (dayIndexOfFirst - index) + 1, 0, 0, 0);
		}
		var offset = index - dayIndexOfFirst - numDays;
		if (offset >= 0) {
			var nextMonth = this._displayedMonth + 1;
			var nextYear = this._displayedFullYear;
			if (nextMonth > 11) {
				nextMonth = 0;
				nextYear++;
			}
			return new Date(nextYear, nextMonth, offset + 1, 0, 0, 0);
		}
		return new Date(this._displayedFullYear, this._displayedMonth, index - dayIndexOfFirst + 1, 0, 0, 0);
	}

	private function dateButton_triggerHandler(event:TriggerEvent):Void {
		var button = cast(event.currentTarget, ToggleButton);
		this.selectedDate = this.getDateForButtonIndex(this._dateButtons.indexOf(button));
		this.displayedFullYear = this.selectedDate.getFullYear();
		this.displayedMonth = this.selectedDate.getMonth();
	}
}
