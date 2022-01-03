/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.DisplayObjectRecycler;
import feathers.layout.ILayoutIndexObject;
import feathers.controls.dataRenderers.IDataRenderer;
import openfl.events.Event;
import feathers.data.ArrayCollection;
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
		TestMain.openfl_root.addChild(this._pageIndicator);
	}

	public function teardown():Void {
		if (this._pageIndicator.parent != null) {
			this._pageIndicator.parent.removeChild(this._pageIndicator);
		}
		this._pageIndicator = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
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
}
