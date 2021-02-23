/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.Event;
import feathers.data.ArrayCollection;
import utest.Assert;
import utest.Test;

@:keep
class TabBarTest extends Test {
	private var _tabBar:TabBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._tabBar = new TabBar();
		TestMain.openfl_root.addChild(this._tabBar);
	}

	public function teardown():Void {
		if (this._tabBar.parent != null) {
			this._tabBar.parent.removeChild(this._tabBar);
		}
		this._tabBar = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._tabBar.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.validateNow();
		this._tabBar.dataProvider = null;
		this._tabBar.validateNow();
		Assert.pass();
	}

	public function testDispatchChangeEventAfterSetSelectedIndex():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.validateNow();
		var changed = false;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._tabBar.selectedIndex = 1;
		Assert.isTrue(changed);
	}

	public function testDispatchChangeEventAfterSetSelectedItem():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.validateNow();
		var changed = false;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._tabBar.selectedItem = this._tabBar.dataProvider.get(1);
		Assert.isTrue(changed);
	}

	public function testSelectedItemAfterSetSelectedIndex():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(this._tabBar.dataProvider.get(0), this._tabBar.selectedItem);
		this._tabBar.selectedIndex = 1;
		Assert.equals(this._tabBar.dataProvider.get(1), this._tabBar.selectedItem);
	}

	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(0, this._tabBar.selectedIndex);
		this._tabBar.selectedItem = this._tabBar.dataProvider.get(1);
		Assert.equals(1, this._tabBar.selectedIndex);
	}
}
