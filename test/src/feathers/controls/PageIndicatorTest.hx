/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.data.ArrayCollection;
import feathers.layout.ILayoutIndexObject;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class PageIndicatorTest extends Test {
	private var _pageIndicator:PageIndicator;

	public function new() {
		super();
	}

	public function setup():Void {
		this._pageIndicator = new PageIndicator();
		Lib.current.addChild(this._pageIndicator);
	}

	public function teardown():Void {
		if (this._pageIndicator.parent != null) {
			this._pageIndicator.parent.removeChild(this._pageIndicator);
		}
		this._pageIndicator = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._pageIndicator.validateNow();
		this._pageIndicator.dispose();
		this._pageIndicator.dispose();
		Assert.pass();
	}

	public function testValidateWithNoMaximum():Void {
		this._pageIndicator.maxSelectedIndex = -1;
		this._pageIndicator.validateNow();
		Assert.pass();
	}

	public function testValidateWithMaximumAndThenNoMaximum():Void {
		this._pageIndicator.maxSelectedIndex = 2;
		this._pageIndicator.validateNow();
		this._pageIndicator.maxSelectedIndex = -1;
		this._pageIndicator.validateNow();
		Assert.pass();
	}

	public function testDispatchChangeEventAfterSetSelectedIndex():Void {
		this._pageIndicator.maxSelectedIndex = 2;
		this._pageIndicator.validateNow();
		var changed = false;
		this._pageIndicator.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._pageIndicator.selectedIndex = 1;
		Assert.isTrue(changed);
	}

	public function testAddItemToDataProviderCreatesNewToggleButton():Void {
		this._pageIndicator.maxSelectedIndex = 0;
		this._pageIndicator.validateNow();
		Assert.notNull(this._pageIndicator.indexToToggleButton(0));
		Assert.isNull(this._pageIndicator.indexToToggleButton(1));
		this._pageIndicator.maxSelectedIndex = 1;
		this._pageIndicator.validateNow();
		Assert.notNull(this._pageIndicator.indexToToggleButton(0));
		Assert.notNull(this._pageIndicator.indexToToggleButton(1));
	}

	public function testRemoveItemFromDataProviderDestroysToggleButton():Void {
		this._pageIndicator.maxSelectedIndex = 1;
		this._pageIndicator.validateNow();
		Assert.notNull(this._pageIndicator.indexToToggleButton(0));
		Assert.notNull(this._pageIndicator.indexToToggleButton(1));
		this._pageIndicator.maxSelectedIndex = 0;
		this._pageIndicator.validateNow();
		Assert.notNull(this._pageIndicator.indexToToggleButton(0));
		Assert.isNull(this._pageIndicator.indexToToggleButton(1));
	}

	public function testToggleButtonDefaultVariant():Void {
		this._pageIndicator.maxSelectedIndex = 2;
		this._pageIndicator.validateNow();
		var toggleButton:ToggleButton = this._pageIndicator.indexToToggleButton(0);
		Assert.notNull(toggleButton);
		Assert.equals(PageIndicator.CHILD_VARIANT_TOGGLE_BUTTON, toggleButton.variant);
	}

	public function testToggleButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._pageIndicator.customToggleButtonVariant = customVariant;
		this._pageIndicator.maxSelectedIndex = 2;
		this._pageIndicator.validateNow();
		var toggleButton:ToggleButton = this._pageIndicator.indexToToggleButton(0);
		Assert.notNull(toggleButton);
		Assert.equals(customVariant, toggleButton.variant);
	}

	public function testToggleButtonCustomVariant2():Void {
		final customVariant = "custom";
		this._pageIndicator.maxSelectedIndex = 2;
		this._pageIndicator.toggleButtonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var toggleButton = new ToggleButton();
			toggleButton.variant = customVariant;
			return toggleButton;
		});
		this._pageIndicator.validateNow();
		var toggleButton:ToggleButton = this._pageIndicator.indexToToggleButton(0);
		Assert.notNull(toggleButton);
		Assert.equals(customVariant, toggleButton.variant);
	}

	public function testToggleButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._pageIndicator.customToggleButtonVariant = customVariant1;
		this._pageIndicator.maxSelectedIndex = 2;
		this._pageIndicator.toggleButtonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var toggleButton = new ToggleButton();
			toggleButton.variant = customVariant2;
			return toggleButton;
		});
		this._pageIndicator.validateNow();
		var toggleButton:ToggleButton = this._pageIndicator.indexToToggleButton(0);
		Assert.notNull(toggleButton);
		Assert.equals(customVariant2, toggleButton.variant);
	}
}
