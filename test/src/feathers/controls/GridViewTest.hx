/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.events.ScrollEvent;
import openfl.events.Event;
import feathers.data.ArrayCollection;
import utest.Assert;
import utest.Test;

@:keep
class GridViewTest extends Test {
	private var _gridView:GridView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._gridView = new GridView();
		TestMain.openfl_root.addChild(this._gridView);
	}

	public function teardown():Void {
		if (this._gridView.parent != null) {
			this._gridView.parent.removeChild(this._gridView);
		}
		this._gridView = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._gridView.validateNow();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.validateNow();
		this._gridView.dataProvider = null;
		this._gridView.validateNow();
	}

	public function testDispatchChangeEventAfterSetSelectedIndex():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.validateNow();
		var changed = false;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._gridView.selectedIndex = 1;
		Assert.isTrue(changed);
	}

	public function testDispatchChangeEventAfterSetSelectedItem():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.validateNow();
		var changed = false;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._gridView.selectedItem = this._gridView.dataProvider.get(1);
		Assert.isTrue(changed);
	}

	public function testSelectedItemAfterSetSelectedIndex():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.isNull(this._gridView.selectedItem);
		this._gridView.selectedIndex = 1;
		Assert.equals(this._gridView.dataProvider.get(1), this._gridView.selectedItem);
	}

	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(-1, this._gridView.selectedIndex);
		this._gridView.selectedItem = this._gridView.dataProvider.get(1);
		Assert.equals(1, this._gridView.selectedIndex);
	}

	public function testDeselectAllOnNullDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.selectedIndex = 1;
		var changed = false;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._gridView.dataProvider = null;
		Assert.isTrue(changed);
		Assert.equals(-1, this._gridView.selectedIndex);
		Assert.equals(null, this._gridView.selectedItem);
	}

	public function testResetScrollOnNullDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.scrollX = 10.0;
		this._gridView.scrollY = 10.0;
		var scrolled = false;
		this._gridView.addEventListener(ScrollEvent.SCROLL, function(event:ScrollEvent):Void {
			scrolled = true;
		});
		Assert.isFalse(scrolled);
		this._gridView.dataProvider = null;
		Assert.isTrue(scrolled);
		Assert.equals(0.0, this._gridView.scrollX);
		Assert.equals(0.0, this._gridView.scrollY);
	}

	public function testDeselectAllOnDataProviderRemoveAll():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.selectedIndex = 1;
		var changed = false;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._gridView.dataProvider.removeAll();
		Assert.isTrue(changed);
		Assert.equals(-1, this._gridView.selectedIndex);
		Assert.equals(null, this._gridView.selectedItem);
	}
}
