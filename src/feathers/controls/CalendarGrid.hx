/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IDateSelector;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.CalendarGridLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelCalendarGridStyles;
import feathers.utils.DateUtil;
import feathers.utils.MeasurementsUtil;
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
	Displays a calendar for a specific month.

	The following example creates a `CalendarGrid`, selects a date, and listens
	for when the selection changes:

	```haxe
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

	@event openfl.events.Event.CHANGE Dispatched when
	`CalendarGrid.selectedDate` changes.

	@event openfl.events.Event.SCROLL Dispatched when
	`CalendarGrid.displayedMonth` or `CalendarGrid.displayedFullYear` changes.

	@see [Tutorial: How to use the CalendarGrid component](https://feathersui.com/learn/haxe-openfl/calendar-grid/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(openfl.events.Event.SCROLL)
@:deprecated('CalendarGrid is deprecated. Use DatePicker instead.')
class CalendarGrid extends FeathersControl implements IDateSelector {
	#if ((!flash && openfl < "9.2.0") || neko)
	private var DEFAULT_WEEKDAY_NAMES = ["S", "M", "T", "W", "T", "F", "S"];
	private var DEFAULT_START_OF_WEEK = 0;
	#end

	/**
		The variant used to style the `ToggleButton` child components from the
		current month in a theme.

		To override this default variant, set the
		`CalendarGrid.customToggleButtonVariant` property.

		@see `CalendarGrid.customToggleButtonVariant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DATE_TOGGLE_BUTTON = "calendarGrid_dateToggleButton";

	/**
		The variant used to style the `ToggleButton` child components that are
		not from the current month in a theme.

		To override this default variant, set the
		`CalendarGrid.customMutedToggleButtonVariant` property.

		@see `CalendarGrid.customMutedToggleButtonVariant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON = "calendarGrid_mutedDateToggleButton";

	/**
		The variant used to style the `Label` child components that display the
		names of weekdays.

		To override this default variant, set the
		`CalendarGrid.customWeekdayLabelVariant` property.

		@see `CalendarGrid.customWeekdayLabelVariant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_WEEKDAY_LABEL = "calendarGrid_weekdayLabel";

	private static final INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY = InvalidationFlag.CUSTOM("dateToggleButtonFactory");
	private static final INVALIDATION_FLAG_MUTED_TOGGLE_BUTTON_FACTORY = InvalidationFlag.CUSTOM("mutedDateToggleButtonFactory");
	private static final INVALIDATION_FLAG_WEEKDAY_LABEL_FACTORY = InvalidationFlag.CUSTOM("weekdayLabelFactory");

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
	private var _layoutItems:Array<DisplayObject> = [];

	private var _displayedFullYear:Int = Date.now().getFullYear();

	/**
		Along with the `displayedMonth`, sets the month that is currently
		visible in the calendar. Defaults to the current year.

		@see `CalendarGrid.displayedMonth`

		@since 1.0.0
	**/
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
		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, Event.SCROLL);
		return this._displayedMonth;
	}

	private var _selectable:Bool = true;

	/**
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

		```haxe
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

		```haxe
		calendar.disabledBackgroundSkin = new Bitmap(bitmapData);
		calendar.enabled = false;
		```

		@default null

		@see `CalendarGrid.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _previousCustomToggleButtonVariant:String = null;

	/**
		An optional custom variant to use for the toggle buttons that represent
		dates in the current month, instead of
		`CalendarGrid.CHILD_VARIANT_DATE_TOGGLE_BUTTON`.

		@see `CalendarGrid.CHILD_VARIANT_DATE_TOGGLE_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customToggleButtonVariant:String = null;

	private var _previousCustomMutedToggleButtonVariant:String = null;

	/**
		An optional custom variant to use for the toggle buttons that represent
		dates in the adjacent months, instead of
		`CalendarGrid.CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON`.

		@see `CalendarGrid.CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON`

		@since 1.0.0
	**/
	@:style
	public var customMutedToggleButtonVariant:String = null;

	private var _previousCustomWeekdayLabelVariant:String = null;

	/**
		An optional custom variant to use for the labels that display the names
		of weekdays, instead of `CalendarGrid.CHILD_VARIANT_WEEKDAY_LABEL`.

		@see `CalendarGrid.CHILD_VARIANT_WEEKDAY_LABEL`

		@since 1.0.0
	**/
	@:style
	public var customWeekdayLabelVariant:String = null;

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

	#if (flash || (openfl >= "9.2.0" && !neko))
	private var _currentDateFormatter:DateTimeFormatter;
	#end

	private var _currentWeekdayNames:Array<String>;

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

	private var _currentStartOfWeek:Int = 0;

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

	private var _requestedLocaleIDName:String = null;

	/**
		The locale ID name that is requested.

		@see `CalendarGrid.actualLocaleIDName`

		@since 1.0.0
	**/
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
	public var actualLocaleIDName(get, never):String;

	private function get_actualLocaleIDName():String {
		return this._actualLocaleIDName;
	}

	private var _layoutMeasurements:Measurements = new Measurements();
	private var _layout:CalendarGridLayout;
	private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();

	private function initializeCalendarGridTheme():Void {
		SteelCalendarGridStyles.initialize();
	}

	override private function initialize():Void {
		if (this._layout == null) {
			this._layout = new CalendarGridLayout();
		}
		for (i in 0...7) {
			var dayNameLabel = new Label();
			this.addChild(dayNameLabel);
			this._dayNameLabels.push(dayNameLabel);
			this._layoutItems[i] = dayNameLabel;
		}
		for (i in 0...42) {
			var dateButton = new ToggleButton();
			dateButton.toggleable = false;
			dateButton.addEventListener(TriggerEvent.TRIGGER, dateButton_triggerHandler);
			this.addChild(dateButton);
			this._dateButtons.push(dateButton);
			this._layoutItems[i + 7] = dateButton;
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomWeekdayLabelVariant != this.customWeekdayLabelVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_WEEKDAY_LABEL_FACTORY);
		}
		if (this._previousCustomToggleButtonVariant != this.customToggleButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY);
		}
		if (this._previousCustomMutedToggleButtonVariant != this.customMutedToggleButtonVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_MUTED_TOGGLE_BUTTON_FACTORY);
		}
		var weekdayLabelFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_WEEKDAY_LABEL_FACTORY);
		var toggleButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_TOGGLE_BUTTON_FACTORY);
		var mutedToggleButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_MUTED_TOGGLE_BUTTON_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (dataInvalid) {
			this.refreshLocale();
		}

		if (weekdayLabelFactoryInvalid || dataInvalid || stylesInvalid) {
			this.refreshWeekdayLabels();
		}

		if (toggleButtonFactoryInvalid || mutedToggleButtonFactoryInvalid || dataInvalid || selectionInvalid) {
			this.refreshDisplayedMonth();
		}

		if (stateInvalid || weekdayLabelFactoryInvalid || toggleButtonFactoryInvalid || mutedToggleButtonFactoryInvalid) {
			this.refreshEnabled();
		}

		this.refreshViewPortBounds();
		this._layoutResult.reset();
		this._layout.layout(this._layoutItems, this._layoutMeasurements, this._layoutResult);
		this.handleLayoutResult();
	}

	private function refreshLocale():Void {
		#if (flash || (openfl >= "9.2.0" && !neko))
		var localeID = this._requestedLocaleIDName != null ? this._requestedLocaleIDName : LocaleID.DEFAULT;
		this._currentDateFormatter = new DateTimeFormatter(localeID, SHORT, NONE);
		this._actualLocaleIDName = this._currentDateFormatter.actualLocaleIDName;
		this._currentWeekdayNames = this._customWeekdayNames;
		if (this._currentWeekdayNames == null) {
			var weekdayNamesVector = this._currentDateFormatter.getWeekdayNames(SHORT_ABBREVIATION, STANDALONE);
			this._currentWeekdayNames = [];
			for (weekdayName in weekdayNamesVector) {
				this._currentWeekdayNames.push(weekdayName.charAt(0));
			}
		}
		this._currentStartOfWeek = this._customStartOfWeek != null ? this._customStartOfWeek : this._currentDateFormatter.getFirstWeekday();
		#else
		this._actualLocaleIDName = "en-US";
		this._currentWeekdayNames = this._customWeekdayNames != null ? this._customWeekdayNames : DEFAULT_WEEKDAY_NAMES;
		this._currentStartOfWeek = this._customStartOfWeek != null ? this._customStartOfWeek : DEFAULT_START_OF_WEEK;
		#end
	}

	private function refreshEnabled():Void {
		for (dayNameLabel in this._dayNameLabels) {
			dayNameLabel.enabled = this._enabled;
		}
		for (dateButton in this._dateButtons) {
			dateButton.enabled = this._enabled;
		}
	}

	private function refreshViewPortBounds():Void {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;

		if (this._currentBackgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
			if ((this._currentBackgroundSkin is IValidating)) {
				cast(this._currentBackgroundSkin, IValidating).validateNow();
			}
		}

		this._layoutMeasurements.width = this.explicitWidth;
		this._layoutMeasurements.height = this.explicitHeight;

		var viewPortMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			viewPortMinWidth = 0.0;
		}
		var viewPortMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			viewPortMinHeight = 0.0;
		}
		var viewPortMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			viewPortMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		var viewPortMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			viewPortMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		if (this._backgroundSkinMeasurements != null) {
			// because the layout might need it, we account for the
			// dimensions of the background skin when determining the minimum
			// dimensions of the view port.
			if (this._backgroundSkinMeasurements.width != null) {
				if (this._backgroundSkinMeasurements.width > viewPortMinWidth) {
					viewPortMinWidth = this._backgroundSkinMeasurements.width;
				}
			} else if (this._backgroundSkinMeasurements.minWidth != null) {
				if (this._backgroundSkinMeasurements.minWidth > viewPortMinWidth) {
					viewPortMinWidth = this._backgroundSkinMeasurements.minWidth;
				}
			}
			if (this._backgroundSkinMeasurements.height != null) {
				if (this._backgroundSkinMeasurements.height > viewPortMinHeight) {
					viewPortMinHeight = this._backgroundSkinMeasurements.height;
				}
			} else if (this._backgroundSkinMeasurements.minHeight != null) {
				if (this._backgroundSkinMeasurements.minHeight > viewPortMinHeight) {
					viewPortMinHeight = this._backgroundSkinMeasurements.minHeight;
				}
			}
		}
		this._layoutMeasurements.minWidth = viewPortMinWidth;
		this._layoutMeasurements.minHeight = viewPortMinHeight;
		this._layoutMeasurements.maxWidth = viewPortMaxWidth;
		this._layoutMeasurements.maxHeight = viewPortMaxHeight;
	}

	private function handleLayoutResult():Void {
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight, viewPortWidth, viewPortHeight);
	}

	private function refreshWeekdayLabels():Void {
		var weekdayLabelVariant = this.customWeekdayLabelVariant != null ? this.customWeekdayLabelVariant : CHILD_VARIANT_WEEKDAY_LABEL;
		for (i in 0...this._dayNameLabels.length) {
			var nameIndex = (i + this._currentStartOfWeek) % this._dayNameLabels.length;
			var dayNameLabel = this._dayNameLabels[i];
			dayNameLabel.variant = weekdayLabelVariant;
			dayNameLabel.text = this._currentWeekdayNames[nameIndex];
			dayNameLabel.visible = this.showWeekdayLabels;
			dayNameLabel.includeInLayout = this.showWeekdayLabels;
		}
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
		var inCurrentMonth = false;
		var toggleButtonVariant = this.customToggleButtonVariant != null ? this.customToggleButtonVariant : CHILD_VARIANT_DATE_TOGGLE_BUTTON;
		var mutedToggleButtonVariant = this.customMutedToggleButtonVariant != null ? this.customMutedToggleButtonVariant : CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON;
		for (i in 0...this._dateButtons.length) {
			if (!inCurrentMonth && currentDate > numDaysLastMonth) {
				currentDate = 1;
				inCurrentMonth = true;
			}
			if (inCurrentMonth && currentDate > numDays) {
				currentDate = 1;
				inCurrentMonth = false;
			}
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
