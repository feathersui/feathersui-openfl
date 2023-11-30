/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class DatePickerTest extends Test {
	private var _datePicker:DatePicker;

	public function new() {
		super();
	}

	public function setup():Void {
		this._datePicker = new DatePicker();
		Lib.current.addChild(this._datePicker);
	}

	public function teardown():Void {
		if (this._datePicker.parent != null) {
			this._datePicker.parent.removeChild(this._datePicker);
		}
		this._datePicker = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._datePicker.validateNow();
		this._datePicker.dispose();
		this._datePicker.dispose();
		Assert.pass();
	}

	public function testDispatchChangeEventOnSetValue():Void {
		final originalValue = Date.now();
		this._datePicker.selectedDate = originalValue;
		var changed = false;
		this._datePicker.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.equals(originalValue.getTime(), this._datePicker.selectedDate.getTime());
		Assert.isFalse(changed);
		final newValue = new Date(1990, 4, 16, 0, 0, 0);
		this._datePicker.selectedDate = newValue;
		Assert.isTrue(changed);
		Assert.equals(newValue.getTime(), this._datePicker.selectedDate.getTime());
	}

	public function testDecrementMonthButtonDefaultVariant():Void {
		var decrementMonthButton:Button = null;
		this._datePicker.decrementMonthButtonFactory = () -> {
			decrementMonthButton = new Button();
			return decrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementMonthButton);
		Assert.equals(DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON, decrementMonthButton.variant);
	}

	public function testDecrementMonthButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._datePicker.customDecrementMonthButtonVariant = customVariant;
		var decrementMonthButton:Button = null;
		this._datePicker.decrementMonthButtonFactory = () -> {
			decrementMonthButton = new Button();
			return decrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementMonthButton);
		Assert.equals(customVariant, decrementMonthButton.variant);
	}

	public function testDecrementMonthButtonCustomVariant2():Void {
		final customVariant = "custom";
		var decrementMonthButton:Button = null;
		this._datePicker.decrementMonthButtonFactory = () -> {
			decrementMonthButton = new Button();
			decrementMonthButton.variant = customVariant;
			return decrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementMonthButton);
		Assert.equals(customVariant, decrementMonthButton.variant);
	}

	public function testDecrementMonthButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._datePicker.customDecrementMonthButtonVariant = customVariant1;
		var decrementMonthButton:Button = null;
		this._datePicker.decrementMonthButtonFactory = () -> {
			decrementMonthButton = new Button();
			decrementMonthButton.variant = customVariant2;
			return decrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementMonthButton);
		Assert.equals(customVariant2, decrementMonthButton.variant);
	}

	public function testIncrementMonthButtonDefaultVariant():Void {
		var incrementMonthButton:Button = null;
		this._datePicker.incrementMonthButtonFactory = () -> {
			incrementMonthButton = new Button();
			return incrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementMonthButton);
		Assert.equals(DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON, incrementMonthButton.variant);
	}

	public function testIncrementMonthButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._datePicker.customIncrementMonthButtonVariant = customVariant;
		var incrementMonthButton:Button = null;
		this._datePicker.incrementMonthButtonFactory = () -> {
			incrementMonthButton = new Button();
			return incrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementMonthButton);
		Assert.equals(customVariant, incrementMonthButton.variant);
	}

	public function testIncrementMonthButtonCustomVariant2():Void {
		final customVariant = "custom";
		var incrementMonthButton:Button = null;
		this._datePicker.incrementMonthButtonFactory = () -> {
			incrementMonthButton = new Button();
			incrementMonthButton.variant = customVariant;
			return incrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementMonthButton);
		Assert.equals(customVariant, incrementMonthButton.variant);
	}

	public function testIncrementMonthButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._datePicker.customIncrementMonthButtonVariant = customVariant1;
		var incrementMonthButton:Button = null;
		this._datePicker.incrementMonthButtonFactory = () -> {
			incrementMonthButton = new Button();
			incrementMonthButton.variant = customVariant2;
			return incrementMonthButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementMonthButton);
		Assert.equals(customVariant2, incrementMonthButton.variant);
	}

	public function testDecrementYearButtonDefaultVariant():Void {
		var decrementYearButton:Button = null;
		this._datePicker.decrementYearButtonFactory = () -> {
			decrementYearButton = new Button();
			return decrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementYearButton);
		Assert.equals(DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON, decrementYearButton.variant);
	}

	public function testDecrementYearButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._datePicker.customDecrementYearButtonVariant = customVariant;
		var decrementYearButton:Button = null;
		this._datePicker.decrementYearButtonFactory = () -> {
			decrementYearButton = new Button();
			return decrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementYearButton);
		Assert.equals(customVariant, decrementYearButton.variant);
	}

	public function testDecrementYearButtonCustomVariant2():Void {
		final customVariant = "custom";
		var decrementYearButton:Button = null;
		this._datePicker.decrementYearButtonFactory = () -> {
			decrementYearButton = new Button();
			decrementYearButton.variant = customVariant;
			return decrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementYearButton);
		Assert.equals(customVariant, decrementYearButton.variant);
	}

	public function testDecrementYearButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._datePicker.customDecrementYearButtonVariant = customVariant1;
		var decrementYearButton:Button = null;
		this._datePicker.decrementYearButtonFactory = () -> {
			decrementYearButton = new Button();
			decrementYearButton.variant = customVariant2;
			return decrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(decrementYearButton);
		Assert.equals(customVariant2, decrementYearButton.variant);
	}

	public function testIncrementYearButtonDefaultVariant():Void {
		var incrementYearButton:Button = null;
		this._datePicker.incrementYearButtonFactory = () -> {
			incrementYearButton = new Button();
			return incrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementYearButton);
		Assert.equals(DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON, incrementYearButton.variant);
	}

	public function testIncrementYearButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._datePicker.customIncrementYearButtonVariant = customVariant;
		var incrementYearButton:Button = null;
		this._datePicker.incrementYearButtonFactory = () -> {
			incrementYearButton = new Button();
			return incrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementYearButton);
		Assert.equals(customVariant, incrementYearButton.variant);
	}

	public function testIncrementYearButtonCustomVariant2():Void {
		final customVariant = "custom";
		var incrementYearButton:Button = null;
		this._datePicker.incrementYearButtonFactory = () -> {
			incrementYearButton = new Button();
			incrementYearButton.variant = customVariant;
			return incrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementYearButton);
		Assert.equals(customVariant, incrementYearButton.variant);
	}

	public function testIncrementYearButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._datePicker.customIncrementYearButtonVariant = customVariant1;
		var incrementYearButton:Button = null;
		this._datePicker.incrementYearButtonFactory = () -> {
			incrementYearButton = new Button();
			incrementYearButton.variant = customVariant2;
			return incrementYearButton;
		}
		this._datePicker.validateNow();
		Assert.notNull(incrementYearButton);
		Assert.equals(customVariant2, incrementYearButton.variant);
	}

	public function testMonthTitleViewDefaultVariant():Void {
		var monthTitleView:Label = null;
		this._datePicker.monthTitleViewFactory = () -> {
			monthTitleView = new Label();
			return monthTitleView;
		}
		this._datePicker.validateNow();
		Assert.notNull(monthTitleView);
		Assert.equals(DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW, monthTitleView.variant);
	}

	public function testMonthTitleViewCustomVariant1():Void {
		final customVariant = "custom";
		this._datePicker.customMonthTitleViewVariant = customVariant;
		var monthTitleView:Label = null;
		this._datePicker.monthTitleViewFactory = () -> {
			monthTitleView = new Label();
			return monthTitleView;
		}
		this._datePicker.validateNow();
		Assert.notNull(monthTitleView);
		Assert.equals(customVariant, monthTitleView.variant);
	}

	public function testMonthTitleViewCustomVariant2():Void {
		final customVariant = "custom";
		var monthTitleView:Label = null;
		this._datePicker.monthTitleViewFactory = () -> {
			monthTitleView = new Label();
			monthTitleView.variant = customVariant;
			return monthTitleView;
		}
		this._datePicker.validateNow();
		Assert.notNull(monthTitleView);
		Assert.equals(customVariant, monthTitleView.variant);
	}

	public function testMonthTitleViewCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._datePicker.customMonthTitleViewVariant = customVariant1;
		var monthTitleView:Label = null;
		this._datePicker.monthTitleViewFactory = () -> {
			monthTitleView = new Label();
			monthTitleView.variant = customVariant2;
			return monthTitleView;
		}
		this._datePicker.validateNow();
		Assert.notNull(monthTitleView);
		Assert.equals(customVariant2, monthTitleView.variant);
	}
}
