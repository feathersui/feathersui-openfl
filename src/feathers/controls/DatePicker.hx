/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.FeathersControl;
import feathers.core.IDateSelector;
import feathers.core.IFocusObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.DatePickerItemState;
import feathers.events.DatePickerEvent;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.CalendarGridLayout;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.style.IVariantStyleObject;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DateUtil;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end
#if (openfl >= "9.2.0" && !neko)
import openfl.globalization.DateTimeFormatter;
import openfl.globalization.LocaleID;
#elseif flash
import flash.globalization.DateTimeFormatter;
import flash.globalization.LocaleID;
#end
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end

/**
	Displays a calendar month view that allows the selection of a date. The
	header displays the current month and year name, along with buttons to
	change the currently displayed month and year. The buttons in the header may
	be hidden, if desired.

	The following example creates a date picker, sets the selected date, and
	listens for when the selection changes:

	```haxe
	var datePicker = new DatePicker();
	datePicker.selectedDate = new Date(2020, 1, 6);
	datePicker.addEventListener(Event.CHANGE, (event:Event) -> {
		var datePicker = cast(event.currentTarget, DatePicker);
		trace("DatePicker changed: " + datePicker.selectedDate);
	});
	this.addChild(datePicker);
	```

	@event openfl.events.Event.CHANGE Dispatched when `DatePicker.selectedDate`
	changes.

	@event feathers.events.DatePickerEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks an item renderer in the date picker. The pointer must remain
	within the bounds of the item renderer on release, or the gesture will be
	ignored.

	@event feathers.events.DatePickerEvent.ITEM_DOUBLE_CLICK Dispatched when the
	user double-clicks an item renderer in the date picker with a mouse. The item
	renderer's `doubleClickEnabled` property must be set to true, and in some
	cases the same property must be set on its children.

	@see [Tutorial: How to use the DatePicker component](https://feathersui.com/learn/haxe-openfl/date-picker/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.DatePickerEvent.ITEM_TRIGGER)
@:event(feathers.events.DatePickerEvent.ITEM_DOUBLE_CLICK)
@:styleContext
class DatePicker extends FeathersControl implements IDateSelector implements IFocusObject {
	#if ((!flash && openfl < "9.2.0") || neko)
	private static final DEFAULT_MONTH_NAMES = [
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December"
	];

	private var DEFAULT_WEEKDAY_NAMES = ["S", "M", "T", "W", "T", "F", "S"];
	private var DEFAULT_START_OF_WEEK = 0;
	#end

	private static final INVALIDATION_FLAG_MONTH_TITLE_VIEW_FACTORY = InvalidationFlag.CUSTOM("monthTitleViewFactory");
	private static final INVALIDATION_FLAG_DECREMENT_MONTH_BUTTON_FACTORY = InvalidationFlag.CUSTOM("decrementMonthButtonFactory");
	private static final INVALIDATION_FLAG_INCREMENT_MONTH_BUTTON_FACTORY = InvalidationFlag.CUSTOM("incrementMonthButtonFactory");
	private static final INVALIDATION_FLAG_DECREMENT_YEAR_BUTTON_FACTORY = InvalidationFlag.CUSTOM("decrementYearButtonFactory");
	private static final INVALIDATION_FLAG_INCREMENT_YEAR_BUTTON_FACTORY = InvalidationFlag.CUSTOM("incrementYearButtonFactory");
	private static final INVALIDATION_FLAG_DATE_RENDERER_FACTORY = InvalidationFlag.CUSTOM("dateRendererFactory");
	private static final INVALIDATION_FLAG_WEEKDAY_LABEL_FACTORY = InvalidationFlag.CUSTOM("weekdayLabelFactory");

	private static final RESET_ITEM_STATE = new DatePickerItemState();

	/**
		The variant used to style the date picker's date renderers in a theme.

		To override this default variant, set the
		`DatePicker.customDateRendererVariant` property.

		@see `DatePicker.customDateRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DATE_RENDERER = "datePicker_dateRenderer";

	/**
		The variant used to style the date picker's date renderers in a theme.

		To override this default variant, set the
		`DatePicker.customMutedDateRendererVariant` property.

		@see `DatePicker.customMutedDateRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_MUTED_DATE_RENDERER = "datePicker_mutedDateRenderer";

	/**
		The variant used to style the decrement month `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customDecrementMonthButtonVariant` property.

		@see `DatePicker.customDecrementMonthButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DECREMENT_MONTH_BUTTON = "datePicker_decrementMonthButton";

	/**
		The variant used to style the increment month `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customIncrementMonthButtonVariant` property.

		@see `DatePicker.customIncrementMonthButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_INCREMENT_MONTH_BUTTON = "datePicker_incrementMonthButton";

	/**
		The variant used to style the decrement year `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customDecrementYearButtonVariant` property.

		@see `DatePicker.customDecrementYearButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DECREMENT_YEAR_BUTTON = "datePicker_decrementYearButton";

	/**
		The variant used to style the increment year `Button` child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customIncrementYearButtonVariant` property.

		@see `DatePicker.customIncrementYearButtonVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_INCREMENT_YEAR_BUTTON = "datePicker_incrementYearButton";

	/**
		The variant used to style the current month title child component
		in a theme.

		To override this default variant, set the
		`DatePicker.customMonthTitleViewVariant` property.

		@see `DatePicker.customMonthTitleViewVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_MONTH_TITLE_VIEW = "datePicker_monthTitleView";

	/**
		The variant used to style the `Label` child components that display the
		names of weekdays.

		To override this default variant, set the
		`DatePicker.customWeekdayLabelVariant` property.

		@see `DatePicker.customWeekdayLabelVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_WEEKDAY_LABEL = "datePicker_weekdayLabel";

	private static final defaultDecrementMonthButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultIncrementMonthButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultDecrementYearButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultIncrementYearButtonFactory = DisplayObjectFactory.withClass(Button);
	private static final defaultMonthTitleViewFactory = DisplayObjectFactory.withClass(Label);
	private static final defaultWeekdayLabelFactory = DisplayObjectFactory.withClass(Label);

	private static function defaultUpdateDateRenderer(dateRenderer:DisplayObject, state:DatePickerItemState):Void {
		if ((dateRenderer is ITextControl)) {
			var textControl:ITextControl = cast dateRenderer;
			textControl.text = Std.string(state.date.getDate());
		}
	}

	private static function defaultResetDateRenderer(dateRenderer:DisplayObject, state:DatePickerItemState):Void {
		if ((dateRenderer is ITextControl)) {
			var textControl:ITextControl = cast dateRenderer;
			textControl.text = null;
		}
	}

	/**
		Creates a new `DatePicker` object.

		@since 1.0.0
	**/
	public function new() {
		initializeDatePickerTheme();
		super();
		this.addEventListener(KeyboardEvent.KEY_DOWN, datePicker_keyDownHandler);
	}

	private var dateContainer:LayoutGroup;
	private var monthView:ITextControl;
	private var decrementMonthButton:Button;
	private var incrementMonthButton:Button;
	private var decrementYearButton:Button;
	private var incrementYearButton:Button;
	private var monthTitleView:Label;
	private var _dayNameLabels:Array<Label> = [];
	private var dateRendererToItemState = new ObjectMap<DisplayObject, DatePickerItemState>();
	private var _defaultStorage:DateRendererStorage = new DateRendererStorage(null, DisplayObjectRecycler.withClass(ItemRenderer));
	private var _mutedStorage:DateRendererStorage = new DateRendererStorage(null, DisplayObjectRecycler.withClass(ItemRenderer));

	private var decrementMonthButtonMeasurements:Measurements = new Measurements();
	private var incrementMonthButtonMeasurements:Measurements = new Measurements();
	private var decrementYearButtonMeasurements:Measurements = new Measurements();
	private var incrementYearButtonMeasurements:Measurements = new Measurements();
	private var monthTitleViewMeasurements:Measurements = new Measurements();

	private var itemStatePool = new ObjectPool(() -> new DatePickerItemState());

	private var _displayedFullYear:Int = Date.now().getFullYear();

	/**
		Along with the `displayedMonth`, sets the month that is currently
		visible in the calendar. Defaults to the current year.

		@see `DatePicker.displayedMonth`

		@since 1.0.0
	**/
	@:bindable("scroll")
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

		@see `DatePicker.displayedFullYear`

		@since 1.0.0
	**/
	@:bindable("scroll")
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

	private var _ignoreSelectionChange:Bool = false;

	private var _selectedDate:Date = null;

	/**
		The currently selected date.

		@since 1.0.0
	**/
	@:inspectable
	@:bindable("change")
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

		```haxe
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

		```haxe
		datePicker.disabledBackgroundSkin = new Bitmap(bitmapData);
		datePicker.enabled = false;
		```

		@default null

		@see `DatePicker.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _oldDecrementMonthButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	private var _decrementMonthButtonFactory:DisplayObjectFactory<Dynamic, Button>;

	/**
		Creates the decrement month button that is displayed as a sub-component.
		The button must be of type `feathers.controls.Button`.

		In the following example, a custom decrement month button factory is provided:

		```haxe
		datePicker.decrementMonthButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
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
		@see `feathers.style.IVariantStyleObject.variant`

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

		```haxe
		datePicker.incrementMonthButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
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
		@see `feathers.style.IVariantStyleObject.variant`

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

		```haxe
		datePicker.decrementYearButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
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
		@see `feathers.style.IVariantStyleObject.variant`

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

		```haxe
		datePicker.incrementYearButtonFactory = () ->
		{
			return new Button();
		};
		```

		@see `feathers.controls.Button`

		@since 1.0.0
	**/
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
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customIncrementYearButtonVariant:String = null;

	private var _oldMonthTitleViewFactory:DisplayObjectFactory<Dynamic, Label>;

	private var _monthTitleViewFactory:DisplayObjectFactory<Dynamic, Label>;

	/**
		Creates the current month view that is displayed as a sub-component.
		The view must be of type `feathers.controls.Label`.

		In the following example, a custom current month view factory is provided:

		```haxe
		datePicker.monthTitleViewFactory = () ->
		{
			return new Label();
		};
		```

		@since 1.0.0
	**/
	public var monthTitleViewFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Label>;

	private function get_monthTitleViewFactory():AbstractDisplayObjectFactory<Dynamic, Label> {
		return this._monthTitleViewFactory;
	}

	private function set_monthTitleViewFactory(value:AbstractDisplayObjectFactory<Dynamic, Label>):AbstractDisplayObjectFactory<Dynamic, Label> {
		if (this._monthTitleViewFactory == value) {
			return this._monthTitleViewFactory;
		}
		this._monthTitleViewFactory = value;
		this.setInvalid(INVALIDATION_FLAG_MONTH_TITLE_VIEW_FACTORY);
		return this._monthTitleViewFactory;
	}

	private var _previousCustomMonthTitleViewVariant:String = null;

	/**
		A custom variant to set on the month title view sub-component,
		instead of `DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW`.

		The `customMonthTitleViewVariant` will be not be used if the
		result of `monthTitleViewFactory` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customMonthTitleViewVariant:String = null;

	/**
		The space, in pixels, between items in the date picker's header.

		In the following example, the date picker's header gap is set to 20
		pixels:

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
		datePicker.paddingLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		The horizontal position of the month title view, relative to the
		increment and decrement buttons.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:style
	public var monthTitleViewPosition:HorizontalAlign = CENTER;

	/**
		Determines if the name of the month title view is displayed or hidden.

		@since 1.0.0
	**/
	@:style
	public var showMonthTitleView:Bool = true;

	/**
		Determines if the buttons to decrement and increment the month buttons
		are displayed or hidden.

		@since 1.0.0
	**/
	@:style
	public var showMonthButtons:Bool = true;

	/**
		Determines if the buttons to decrement and increment the year buttons
		are displayed or hidden.

		@since 1.0.0
	**/
	@:style
	public var showYearButtons:Bool = true;

	/**
		Determines if the weekday labels are visible or not.

		@since 1.0.0
	**/
	@:style
	public var showWeekdayLabels:Bool = true;

	private var _currentMonthNames:Array<String>;
	private var _currentWeekdayNames:Array<String>;

	#if (flash || (openfl >= "9.2.0" && !neko))
	private var _currentDateFormatter:DateTimeFormatter;
	#end

	private var _requestedLocaleIDName:String = null;

	/**
		The locale ID name that is requested.

		@see `DatePicker.actualLocaleIDName`

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

		@see `DatePicker.requestedLocaleIDName`

		@since 1.0.0
	**/
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

	private var _oldWeekdayLabelFactory:DisplayObjectFactory<Dynamic, Label>;

	private var _weekdayLabelFactory:DisplayObjectFactory<Dynamic, Label>;

	/**
		Creates the weekday labels that are displayed as sub-components.
		The labels must be of type `feathers.controls.Label`.

		In the following example, a custom weekday label factory is provided:

		```haxe
		datePicker.weekdayLabelFactory = () ->
		{
			return new Label();
		};
		```

		@since 1.0.0
	**/
	public var weekdayLabelFactory(get, set):AbstractDisplayObjectFactory<Dynamic, Label>;

	private function get_weekdayLabelFactory():AbstractDisplayObjectFactory<Dynamic, Label> {
		return this._weekdayLabelFactory;
	}

	private function set_weekdayLabelFactory(value:AbstractDisplayObjectFactory<Dynamic, Label>):AbstractDisplayObjectFactory<Dynamic, Label> {
		if (this._weekdayLabelFactory == value) {
			return this._weekdayLabelFactory;
		}
		this._weekdayLabelFactory = value;
		this.setInvalid(INVALIDATION_FLAG_WEEKDAY_LABEL_FACTORY);
		return this._weekdayLabelFactory;
	}

	private var _previousCustomWeekdayLabelVariant:String = null;

	/**
		An optional custom variant to use for the labels that display the names
		of weekdays, instead of `DatePicker.CHILD_VARIANT_WEEKDAY_LABEL`.

		@see `DatePicker.CHILD_VARIANT_WEEKDAY_LABEL`

		@since 1.0.0
	**/
	@:style
	public var customWeekdayLabelVariant:String = null;

	private var _previousCustomDateRendererVariant:String = null;

	/**
		A custom variant to set on all date renderers, instead of
		`DatePicker.CHILD_VARIANT_DATE_RENDERER`.

		The `customDateRendererVariant` will be not be used if the result of
		`dateRendererRecycler.create()` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_DATE_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customDateRendererVariant:String = null;

	private var _previousCustomMutedDateRendererVariant:String = null;

	/**
		A custom variant to set on all date renderers, instead of
		`DatePicker.CHILD_VARIANT_MUTED_DATE_RENDERER`.

		The `customMutedDateRendererVariant` will be not be used if the result
		of `dateRendererRecycler.create()` already has a variant set.

		@see `DatePicker.CHILD_VARIANT_MUTED_DATE_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customMutedDateRendererVariant:String = null;

	/**
		Manages date renderers used by the date picker.

		In the following example, the date picker uses a custom date renderer
		class:

		```haxe
		datePicker.dateRendererRecycler = DisplayObjectRecycler.withClass(CustomDateRenderer);
		```

		@since 1.0.0
	**/
	public var dateRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, DatePickerItemState, DisplayObject>;

	private function get_dateRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, DatePickerItemState, DisplayObject> {
		return this._defaultStorage.dateRendererRecycler;
	}

	private function set_dateRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, DatePickerItemState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, DatePickerItemState, DisplayObject> {
		if (this._defaultStorage.dateRendererRecycler == value) {
			return this._defaultStorage.dateRendererRecycler;
		}
		this._defaultStorage.oldDateRendererRecycler = this._defaultStorage.dateRendererRecycler;
		this._defaultStorage.dateRendererRecycler = value;
		this._defaultStorage.measurements = null;

		this._mutedStorage.oldDateRendererRecycler = this._mutedStorage.dateRendererRecycler;
		this._mutedStorage.dateRendererRecycler = value;
		this._mutedStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_DATE_RENDERER_FACTORY);
		return this._defaultStorage.dateRendererRecycler;
	}

	/**
		Determines if the date renderers for dates in the adjacent months are
		visible or not.

		@since 1.0.0
	**/
	@:style
	public var showDatesFromAdjacentMonths:Bool = true;

	/**
		Indicates if selection is changed with `MouseEvent.CLICK` or
		`TouchEvent.TOUCH_TAP` when the item renderer does not implement the
		`IToggle` interface. If set to `false`, all item renderers must control
		their own selection manually (not only ones that implement `IToggle`).

		The following example disables pointer selection:

		```haxe
		datePicker.pointerSelectionEnabled = false;
		```

		@since 1.0.0
	**/
	public var pointerSelectionEnabled:Bool = true;

	override public function dispose():Void {
		this.destroyMonthTitleView();
		this.destroyDecrementMonthButton();
		this.destroyIncrementMonthButton();
		this.destroyDecrementYearButton();
		this.destroyIncrementYearButton();
		this.refreshInactiveDateRenderers(this._defaultStorage, true);
		this.refreshInactiveDateRenderers(this._mutedStorage, true);
		super.dispose();
	}

	private function initializeDatePickerTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelDatePickerStyles.initialize();
		#end
	}

	override private function initialize():Void {
		if (this.dateContainer == null) {
			this.dateContainer = new LayoutGroup();
			this.dateContainer.layout = new CalendarGridLayout();
			this.addChild(this.dateContainer);
		}
		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		if (this._previousCustomDateRendererVariant != this.customDateRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_DATE_RENDERER_FACTORY);
		}
		if (this._previousCustomMutedDateRendererVariant != this.customMutedDateRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_DATE_RENDERER_FACTORY);
		}
		if (this._previousCustomWeekdayLabelVariant != this.customWeekdayLabelVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_WEEKDAY_LABEL_FACTORY);
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
		if (this._previousCustomMonthTitleViewVariant != this.customMonthTitleViewVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_MONTH_TITLE_VIEW_FACTORY);
		}
		var dateRendererFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_DATE_RENDERER_FACTORY);
		var weekdayLabelFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_WEEKDAY_LABEL_FACTORY);
		var decrementMonthButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_DECREMENT_MONTH_BUTTON_FACTORY);
		var incrementMonthButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_INCREMENT_MONTH_BUTTON_FACTORY);
		var decrementYearButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_DECREMENT_YEAR_BUTTON_FACTORY);
		var incrementYearButtonFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_INCREMENT_YEAR_BUTTON_FACTORY);
		var monthTitleViewFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_MONTH_TITLE_VIEW_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (monthTitleViewFactoryInvalid) {
			this.createMonthTitleView();
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

		if (weekdayLabelFactoryInvalid) {
			this.createWeekdayLabels();
		}

		if (dataInvalid) {
			this.refreshLocale();
		}

		if (dataInvalid || selectionInvalid || dateRendererFactoryInvalid) {
			this.refreshDateRenderers();
		}

		if (weekdayLabelFactoryInvalid || dataInvalid || stylesInvalid) {
			this.refreshWeekdayLabels();
		}

		if (stateInvalid || monthTitleViewFactoryInvalid || decrementMonthButtonFactoryInvalid || incrementMonthButtonFactoryInvalid
			|| decrementYearButtonFactoryInvalid || incrementYearButtonFactoryInvalid) {
			this.refreshEnabled();
		}

		if (dataInvalid || selectionInvalid) {
			this.refreshMonthTitle();
		}

		this.measure();
		this.layoutChildren();

		this._previousCustomDateRendererVariant = this.customDateRendererVariant;
		this._previousCustomMutedDateRendererVariant = this.customMutedDateRendererVariant;
		this._previousCustomMonthTitleViewVariant = this.customMonthTitleViewVariant;
		this._previousCustomWeekdayLabelVariant = this.customWeekdayLabelVariant;
		this._previousCustomDecrementMonthButtonVariant = this.customDecrementMonthButtonVariant;
		this._previousCustomIncrementMonthButtonVariant = this.customIncrementMonthButtonVariant;
		this._previousCustomDecrementYearButtonVariant = this.customDecrementYearButtonVariant;
		this._previousCustomIncrementYearButtonVariant = this.customIncrementYearButtonVariant;
	}

	private function createMonthTitleView():Void {
		var factory = this._monthTitleViewFactory != null ? this._monthTitleViewFactory : defaultMonthTitleViewFactory;
		this._oldMonthTitleViewFactory = factory;
		this.monthTitleView = factory.create();
		if (this.monthTitleView.variant == null) {
			this.monthTitleView.variant = this.customMonthTitleViewVariant != null ? this.customMonthTitleViewVariant : DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW;
		}
		this.monthTitleView.initializeNow();
		this.monthTitleViewMeasurements.save(this.monthTitleView);
		this.addChild(this.monthTitleView);
	}

	private function destroyMonthTitleView():Void {
		if (this.monthTitleView == null) {
			return;
		}
		if (this._oldMonthTitleViewFactory.destroy != null) {
			this._oldMonthTitleViewFactory.destroy(this.monthTitleView);
		}
		this._oldMonthTitleViewFactory = null;
		this.monthTitleView = null;
	}

	private function createDecrementMonthButton():Void {
		this.destroyDecrementMonthButton();
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

	private function destroyDecrementMonthButton():Void {
		if (this.decrementMonthButton == null) {
			return;
		}
		this.decrementMonthButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_decrementMonthButton_triggerHandler);
		if (this._oldDecrementMonthButtonFactory.destroy != null) {
			this._oldDecrementMonthButtonFactory.destroy(this.decrementMonthButton);
		}
		this._oldDecrementMonthButtonFactory = null;
		this.decrementMonthButton = null;
	}

	private function createIncrementMonthButton():Void {
		this.destroyIncrementMonthButton();
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

	private function destroyIncrementMonthButton():Void {
		if (this.incrementMonthButton == null) {
			return;
		}
		this.incrementMonthButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_incrementMonthButton_triggerHandler);
		if (this._oldIncrementMonthButtonFactory.destroy != null) {
			this._oldIncrementMonthButtonFactory.destroy(this.incrementMonthButton);
		}
		this._oldIncrementMonthButtonFactory = null;
		this.incrementMonthButton = null;
	}

	private function createDecrementYearButton():Void {
		this.destroyDecrementYearButton();
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

	private function destroyDecrementYearButton():Void {
		if (this.decrementYearButton == null) {
			return;
		}
		this.decrementYearButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_decrementYearButton_triggerHandler);
		if (this._oldDecrementYearButtonFactory.destroy != null) {
			this._oldDecrementYearButtonFactory.destroy(this.decrementYearButton);
		}
		this._oldDecrementYearButtonFactory = null;
		this.decrementYearButton = null;
	}

	private function createIncrementYearButton():Void {
		this.destroyIncrementYearButton();
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

	private function destroyIncrementYearButton():Void {
		if (this.incrementYearButton == null) {
			return;
		}
		this.incrementYearButton.removeEventListener(TriggerEvent.TRIGGER, datePicker_incrementYearButton_triggerHandler);
		if (this._oldIncrementYearButtonFactory.destroy != null) {
			this._oldIncrementYearButtonFactory.destroy(this.incrementYearButton);
		}
		this._oldIncrementYearButtonFactory = null;
		this.incrementYearButton = null;
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

		this.dateContainer.validateNow();

		this.monthTitleViewMeasurements.restore(this.monthTitleView);
		var oldText = this.monthTitleView.text;
		var measureText = this.getMonthText(this.getMonthWithLongestName(), 0);
		this.monthTitleView.text = measureText;
		this.monthTitleView.validateNow();

		this.decrementMonthButtonMeasurements.restore(this.decrementMonthButton);
		this.decrementMonthButton.validateNow();
		this.incrementMonthButtonMeasurements.restore(this.incrementMonthButton);
		this.incrementMonthButton.validateNow();
		this.decrementYearButtonMeasurements.restore(this.decrementYearButton);
		this.decrementYearButton.validateNow();
		this.incrementYearButtonMeasurements.restore(this.incrementYearButton);
		this.incrementYearButton.validateNow();

		var headerWidth = 0.0;
		var headerHeight = 0.0;
		if (this.showMonthTitleView) {
			headerWidth = this.monthTitleView.width;
			headerHeight = this.monthTitleView.height;
		}
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
			newWidth = Math.max(this.dateContainer.width, headerWidth);
			newWidth += this.paddingLeft + this.paddingRight;
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = headerHeight + this.dateContainer.height;
			newHeight += this.paddingTop + this.paddingBottom;
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = Math.max(this.dateContainer.minWidth, headerWidth);
			newMinWidth += this.paddingLeft + this.paddingRight;
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = headerHeight + this.dateContainer.minHeight;
			newMinHeight += this.paddingTop + this.paddingBottom;
		}

		this.monthTitleView.text = oldText;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}

	private function refreshEnabled():Void {
		this.monthTitleView.enabled = this.enabled;
		this.decrementMonthButton.enabled = this.enabled;
		this.incrementMonthButton.enabled = this.enabled;
		this.decrementYearButton.enabled = this.enabled;
		this.incrementYearButton.enabled = this.enabled;
		this.dateContainer.enabled = this.enabled;
	}

	private function createWeekdayLabels():Void {
		for (dayNameLabel in this._dayNameLabels) {
			this.dateContainer.removeChild(dayNameLabel);
			if (this._oldWeekdayLabelFactory.destroy != null) {
				this._oldWeekdayLabelFactory.destroy(dayNameLabel);
			}
		}
		this._oldWeekdayLabelFactory = null;
		#if (hl && haxe_ver < 4.3)
		this._dayNameLabels.splice(0, this._dayNameLabels.length);
		#else
		this._dayNameLabels.resize(0);
		#end

		var factory = this._weekdayLabelFactory != null ? this._weekdayLabelFactory : defaultWeekdayLabelFactory;
		var weekdayLabelVariant = this.customWeekdayLabelVariant != null ? this.customWeekdayLabelVariant : CHILD_VARIANT_WEEKDAY_LABEL;
		for (i in 0...7) {
			var dayNameLabel = cast(factory.create(), Label);
			this._oldWeekdayLabelFactory = factory;
			if (dayNameLabel.variant == null) {
				dayNameLabel.variant = weekdayLabelVariant;
			}
			this.dateContainer.addChildAt(dayNameLabel, i);
			this._dayNameLabels.push(dayNameLabel);
		}
	}

	private function refreshWeekdayLabels():Void {
		for (i in 0...this._dayNameLabels.length) {
			var nameIndex = (i + this._currentStartOfWeek) % this._dayNameLabels.length;
			var dayNameLabel = this._dayNameLabels[i];
			dayNameLabel.text = this._currentWeekdayNames[nameIndex];
			dayNameLabel.visible = this.showWeekdayLabels;
			dayNameLabel.includeInLayout = this.showWeekdayLabels;
		}
	}

	private function refreshDateRenderers():Void {
		if (this._defaultStorage.dateRendererRecycler.update == null) {
			this._defaultStorage.dateRendererRecycler.update = defaultUpdateDateRenderer;
			if (this._defaultStorage.dateRendererRecycler.reset == null) {
				this._defaultStorage.dateRendererRecycler.reset = defaultResetDateRenderer;
			}
		}
		if (this._mutedStorage.dateRendererRecycler.update == null) {
			this._mutedStorage.dateRendererRecycler.update = defaultUpdateDateRenderer;
			if (this._mutedStorage.dateRendererRecycler.reset == null) {
				this._mutedStorage.dateRendererRecycler.reset = defaultResetDateRenderer;
			}
		}

		var dateRendererInvalid = this.isInvalid(INVALIDATION_FLAG_DATE_RENDERER_FACTORY);
		this.refreshInactiveDateRenderers(this._defaultStorage, dateRendererInvalid);
		this.refreshInactiveDateRenderers(this._mutedStorage, dateRendererInvalid);

		this.recoverInactiveDateRenderers(this._defaultStorage);
		this.recoverInactiveDateRenderers(this._mutedStorage);
		this.renderUnrenderedData();
		this.freeInactiveDateRenderers(this._defaultStorage);
		this.freeInactiveDateRenderers(this._mutedStorage);
	}

	private function refreshInactiveDateRenderers(storage:DateRendererStorage, factoryInvalid:Bool):Void {
		var temp = storage.inactiveDateRenderers;
		storage.inactiveDateRenderers = storage.activeDateRenderers;
		storage.activeDateRenderers = temp;
		if (storage.activeDateRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active date renderers should be empty before updating.');
		}
		if (factoryInvalid) {
			this.recoverInactiveDateRenderers(storage);
			this.freeInactiveDateRenderers(storage);
			storage.oldDateRendererRecycler = null;
		}
	}

	private function recoverInactiveDateRenderers(storage:DateRendererStorage):Void {
		for (dateRenderer in storage.inactiveDateRenderers) {
			if (dateRenderer == null) {
				continue;
			}
			var state = this.dateRendererToItemState.get(dateRenderer);
			if (state == null) {
				continue;
			}
			this.dateRendererToItemState.remove(dateRenderer);
			dateRenderer.removeEventListener(TriggerEvent.TRIGGER, datePicker_dateRenderer_triggerHandler);
			dateRenderer.removeEventListener(MouseEvent.CLICK, datePicker_dateRenderer_clickHandler);
			dateRenderer.removeEventListener(TouchEvent.TOUCH_TAP, datePicker_dateRenderer_touchTapHandler);
			dateRenderer.removeEventListener(MouseEvent.DOUBLE_CLICK, datePicker_dateRenderer_doubleClickHandler);
			dateRenderer.removeEventListener(Event.CHANGE, datePicker_dateRenderer_changeHandler);
			this.resetDateRenderer(dateRenderer, state, storage);
			if (storage.measurements != null) {
				storage.measurements.restore(dateRenderer);
			}
			this.itemStatePool.release(state);
		}
	}

	private function freeInactiveDateRenderers(storage:DateRendererStorage):Void {
		var recycler = storage.oldDateRendererRecycler != null ? storage.oldDateRendererRecycler : storage.dateRendererRecycler;
		for (dateRenderer in storage.inactiveDateRenderers) {
			if (dateRenderer == null) {
				continue;
			}
			this.destroyDateRenderer(dateRenderer, recycler);
		}
		#if (hl && haxe_ver < 4.3)
		storage.inactiveDateRenderers.splice(0, storage.inactiveDateRenderers.length);
		#else
		storage.inactiveDateRenderers.resize(0);
		#end
	}

	private function createDateRenderer(state:DatePickerItemState, storage:DateRendererStorage):DisplayObject {
		var dateRenderer:DisplayObject = null;
		if (storage.inactiveDateRenderers.length == 0) {
			dateRenderer = storage.dateRendererRecycler.create();
			if ((dateRenderer is IVariantStyleObject)) {
				var variantItemRenderer:IVariantStyleObject = cast dateRenderer;
				if (variantItemRenderer.variant == null) {
					if (storage == this._mutedStorage) {
						var variant = (this.customMutedDateRendererVariant != null) ? this.customMutedDateRendererVariant : CHILD_VARIANT_MUTED_DATE_RENDERER;
						variantItemRenderer.variant = variant;
					} else {
						var variant = (this.customDateRendererVariant != null) ? this.customDateRendererVariant : CHILD_VARIANT_DATE_RENDERER;
						variantItemRenderer.variant = variant;
					}
				}
			}
			// for consistency, initialize before passing to the recycler's
			// update function. plus, this ensures that custom item renderers
			// correctly handle property changes in update() instead of trying
			// to access them too early in initialize().
			if ((dateRenderer is IUIControl)) {
				(cast dateRenderer : IUIControl).initializeNow();
			}
			// save measurements after initialize, because width/height could be
			// set explicitly there, and we want to restore those values
			if (storage.measurements == null) {
				storage.measurements = new Measurements(dateRenderer);
			}
		} else {
			dateRenderer = storage.inactiveDateRenderers.shift();
		}
		this.updateDateRenderer(dateRenderer, state, storage);
		if ((dateRenderer is ITriggerView)) {
			// prefer TriggerEvent.TRIGGER
			dateRenderer.addEventListener(TriggerEvent.TRIGGER, datePicker_dateRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			dateRenderer.addEventListener(MouseEvent.CLICK, datePicker_dateRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			dateRenderer.addEventListener(TouchEvent.TOUCH_TAP, datePicker_dateRenderer_touchTapHandler);
			#end
		}
		dateRenderer.addEventListener(MouseEvent.DOUBLE_CLICK, datePicker_dateRenderer_doubleClickHandler);
		if ((dateRenderer is IToggle)) {
			dateRenderer.addEventListener(Event.CHANGE, datePicker_dateRenderer_changeHandler);
		}
		this.dateRendererToItemState.set(dateRenderer, state);
		storage.activeDateRenderers.push(dateRenderer);
		return dateRenderer;
	}

	private function destroyDateRenderer(dateRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, DatePickerItemState, DisplayObject>):Void {
		this.dateContainer.removeChild(dateRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(dateRenderer);
		}
	}

	private function populateCurrentItemState(date:Date, state:DatePickerItemState):Void {
		state.owner = this;
		state.date = date;
		state.selected = this._selectedDate != null
			&& this._displayedFullYear == this._selectedDate.getFullYear()
			&& this._displayedMonth == this._selectedDate.getMonth()
			&& date.getFullYear() == this._selectedDate.getFullYear()
			&& date.getMonth() == this._selectedDate.getMonth()
			&& date.getDate() == this._selectedDate.getDate();
		state.enabled = this._enabled;
	}

	private function resetDateRenderer(dateRenderer:DisplayObject, state:DatePickerItemState, storage:DateRendererStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var recycler = storage.oldDateRendererRecycler != null ? storage.oldDateRendererRecycler : storage.dateRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(dateRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshDateRendererProperties(dateRenderer, RESET_ITEM_STATE);
		dateRenderer.visible = true;
	}

	private function updateDateRenderer(dateRenderer:DisplayObject, state:DatePickerItemState, storage:DateRendererStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (storage.dateRendererRecycler.update != null) {
			storage.dateRendererRecycler.update(dateRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshDateRendererProperties(dateRenderer, state);
		dateRenderer.visible = this.showDatesFromAdjacentMonths
			|| (state.date != null
				&& this._displayedFullYear == state.date.getFullYear()
				&& this._displayedMonth == state.date.getMonth());
	}

	private function refreshDateRendererProperties(dateRenderer:DisplayObject, state:DatePickerItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if ((dateRenderer is IUIControl)) {
			var uiControl:IUIControl = cast dateRenderer;
			uiControl.enabled = state.enabled;
		}
		if ((dateRenderer is IDataRenderer)) {
			var dataRenderer:IDataRenderer = cast dateRenderer;
			dataRenderer.data = state.date;
		}
		if ((dateRenderer is IToggle)) {
			var toggle:IToggle = cast dateRenderer;
			toggle.selected = state.selected;
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function renderUnrenderedData():Void {
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

		var currentFullYear = this._displayedFullYear;
		var currentMonth = this._displayedMonth;
		var currentDate = numDaysLastMonth - dayIndexOfFirst + 1;
		if (currentDate > 1) {
			currentMonth = lastMonth;
			currentFullYear = lastMonthYear;
		}
		for (i in 0...42) {
			if ((currentMonth < this._displayedMonth || currentFullYear < this._displayedFullYear) && currentDate > numDaysLastMonth) {
				currentDate = 1;
				currentMonth++;
				if (currentMonth == 12) {
					currentMonth = 0;
					currentFullYear++;
				}
			}
			if (currentMonth == this._displayedMonth && currentDate > numDays) {
				currentDate = 1;
				currentMonth++;
				if (currentMonth == 12) {
					currentMonth = 0;
					currentFullYear++;
				}
			}

			var state = this.itemStatePool.get();
			// hours is 12 noon on neko to avoid a daylight savings issue
			var stateDate = new Date(currentFullYear, currentMonth, currentDate, #if neko 12 #else 0 #end, 0, 0);
			this.populateCurrentItemState(stateDate, state);
			var storage = (currentMonth == this._displayedMonth) ? this._defaultStorage : this._mutedStorage;
			var dateRenderer = this.createDateRenderer(state, storage);
			this.dateContainer.addChildAt(dateRenderer, 7 + i);
			this.updateDateRenderer(dateRenderer, state, storage);
			currentDate++;
		}
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
		this._currentMonthNames = DEFAULT_MONTH_NAMES;
		this._currentWeekdayNames = this._customWeekdayNames != null ? this._customWeekdayNames : DEFAULT_WEEKDAY_NAMES;
		this._currentStartOfWeek = this._customStartOfWeek != null ? this._customStartOfWeek : DEFAULT_START_OF_WEEK;
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
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
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
		this.monthTitleView.visible = this.showMonthTitleView;
		this.monthTitleView.validateNow();
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
		var headerHeight = maxButtonHeight;
		if (this.showMonthTitleView) {
			headerHeight = Math.max(headerHeight, this.monthTitleView.height);
		}
		switch (this.monthTitleViewPosition) {
			case CENTER:
				this.monthTitleView.x = this.paddingLeft + (this.actualWidth - this.paddingLeft - this.paddingRight - this.monthTitleView.width) / 2.0;
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
				this.monthTitleView.x = this.actualWidth - this.paddingRight - this.monthTitleView.width;
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
				this.monthTitleView.x = this.paddingLeft;
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
				throw new ArgumentError("Invalid month position: " + this.monthTitleViewPosition);
		}
		if (this.showMonthTitleView) {
			this.monthTitleView.y = this.paddingTop + (headerHeight - this.monthTitleView.height) / 2.0;
		}
		if (this.showMonthButtons) {
			this.decrementMonthButton.y = this.paddingTop + (headerHeight - this.decrementMonthButton.height) / 2.0;
			this.incrementMonthButton.y = this.paddingTop + (headerHeight - this.incrementMonthButton.height) / 2.0;
		}
		if (this.showYearButtons) {
			this.decrementYearButton.y = this.paddingTop + (headerHeight - this.decrementYearButton.height) / 2.0;
			this.incrementYearButton.y = this.paddingTop + (headerHeight - this.incrementYearButton.height) / 2.0;
		}

		this.dateContainer.x = this.paddingLeft;
		this.dateContainer.y = this.paddingTop + headerHeight;
		var calendarWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (calendarWidth < 0.0) {
			calendarWidth = 0.0;
		}
		var calendarHeight = this.actualHeight - headerHeight - this.paddingTop - this.paddingBottom;
		if (calendarHeight < 0.0) {
			calendarHeight = 0.0;
		}
		if (this.dateContainer.width != calendarWidth) {
			this.dateContainer.width = calendarWidth;
		}
		if (this.dateContainer.height != calendarHeight) {
			this.dateContainer.height = calendarHeight;
		}
		this.dateContainer.validateNow();
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

	private function refreshMonthTitle():Void {
		this.monthTitleView.text = this.getMonthText(this.displayedMonth, this.displayedFullYear);
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

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		var result:Date = null;
		if (this._selectedDate == null) {
			result = Date.now();
		} else {
			var resultMonth = this._selectedDate.getMonth();
			var resultDate = this._selectedDate.getDate();
			switch (event.keyCode) {
				case Keyboard.UP:
					resultDate = resultDate - 7;
				case Keyboard.DOWN:
					resultDate = resultDate + 7;
				case Keyboard.LEFT:
					resultDate = resultDate - 1;
				case Keyboard.RIGHT:
					resultDate = resultDate + 1;
				case Keyboard.PAGE_UP:
					resultMonth = resultMonth - 1;
				case Keyboard.PAGE_DOWN:
					resultMonth = resultMonth + 1;
				case Keyboard.HOME:
					var currentDay = this._selectedDate.getDay();
					if (currentDay != 0) {
						resultDate -= currentDay;
					}
				case Keyboard.END:
					var currentDay = this._selectedDate.getDay();
					if (currentDay != 6) {
						resultDate += 6 - currentDay;
					}
				default:
					// not keyboard navigation
					return;
			}

			// if the result month or date is out of range, the Date constructor
			// will automatically make adjustments to that field, and whichever
			// other fields will be affected, to get a valid date.
			result = new Date(this._selectedDate.getFullYear(), resultMonth, resultDate, this._selectedDate.getHours(), this._selectedDate.getMinutes(),
				this._selectedDate.getSeconds());
		}
		if (this._selectedDate != null && this._selectedDate.getTime() == result.getTime()) {
			return;
		}
		event.preventDefault();
		// use the setter
		this.selectedDate = result;
		this.displayedFullYear = this.selectedDate.getFullYear();
		this.displayedMonth = this.selectedDate.getMonth();
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

	private function datePicker_dateRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var dateRenderer = cast(event.currentTarget, DisplayObject);
		if (dateRenderer.parent != this.dateContainer) {
			return;
		}
		var state = this.dateRendererToItemState.get(dateRenderer);
		if (state == null) {
			return;
		}
		DatePickerEvent.dispatch(this, DatePickerEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.selectedDate = state.date;
		this.displayedFullYear = this.selectedDate.getFullYear();
		this.displayedMonth = this.selectedDate.getMonth();
	}

	private function datePicker_dateRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var dateRenderer = cast(event.currentTarget, DisplayObject);
		if (dateRenderer.parent != this.dateContainer) {
			return;
		}
		var state = this.dateRendererToItemState.get(dateRenderer);
		if (state == null) {
			return;
		}
		DatePickerEvent.dispatch(this, DatePickerEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.selectedDate = state.date;
		this.displayedFullYear = this.selectedDate.getFullYear();
		this.displayedMonth = this.selectedDate.getMonth();
	}

	private function datePicker_dateRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var dateRenderer = cast(event.currentTarget, DisplayObject);
		if (dateRenderer.parent != this.dateContainer) {
			return;
		}
		var state = this.dateRendererToItemState.get(dateRenderer);
		if (state == null) {
			return;
		}
		DatePickerEvent.dispatch(this, DatePickerEvent.ITEM_TRIGGER, state);

		if (!this._selectable) {
			return;
		}
		this.selectedDate = state.date;
		this.displayedFullYear = this.selectedDate.getFullYear();
		this.displayedMonth = this.selectedDate.getMonth();
	}

	private function datePicker_dateRenderer_doubleClickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var dateRenderer = cast(event.currentTarget, DisplayObject);
		if (dateRenderer.parent != this.dateContainer) {
			return;
		}
		var state = this.dateRendererToItemState.get(dateRenderer);
		if (state == null) {
			return;
		}
		DatePickerEvent.dispatch(this, DatePickerEvent.ITEM_DOUBLE_CLICK, state);
	}

	private function datePicker_dateRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var dateRenderer = cast(event.currentTarget, DisplayObject);
		if (dateRenderer.parent != this.dateContainer) {
			return;
		}
		var state = this.dateRendererToItemState.get(dateRenderer);
		if (state == null) {
			return;
		}
		var toggleDateRenderer = cast(dateRenderer, IToggle);
		if (toggleDateRenderer.selected == state.selected) {
			// nothing has changed
			return;
		}
		// if we get here, the selected property of the renderer changed
		// unexpectedly, and we need to restore its proper state
		this.setInvalid(SELECTION);
	}

	private function datePicker_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (this.stage != null && (this.stage.focus is TextField)) {
			var textField:TextField = cast this.stage.focus;
			if (textField.type == INPUT) {
				// if an input TextField has focus, don't scroll because the
				// TextField should have precedence, and the TextFeeld won't
				// call preventDefault() on the event.
				return;
			}
		}
		this.navigateWithKeyboard(event);
	}
}

private class DateRendererStorage {
	public function new(?id:String, ?recycler:DisplayObjectRecycler<Dynamic, DatePickerItemState, DisplayObject>) {
		this.id = id;
		this.dateRendererRecycler = recycler;
	}

	public var id:String;
	public var oldDateRendererRecycler:DisplayObjectRecycler<Dynamic, DatePickerItemState, DisplayObject>;
	public var dateRendererRecycler:DisplayObjectRecycler<Dynamic, DatePickerItemState, DisplayObject>;
	public var activeDateRenderers:Array<DisplayObject> = [];
	public var inactiveDateRenderers:Array<DisplayObject> = [];
	public var measurements:Measurements;
}
