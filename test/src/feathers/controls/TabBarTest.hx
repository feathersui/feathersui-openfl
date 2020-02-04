/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.Event;
import feathers.data.ArrayCollection;
import massive.munit.Assert;

@:keep
class TabBarTest {
	private var _tabBar:TabBar;

	@Before
	public function prepare():Void {
		this._tabBar = new TabBar();
		TestMain.openfl_root.addChild(this._tabBar);
	}

	@After
	public function cleanup():Void {
		if (this._tabBar.parent != null) {
			this._tabBar.parent.removeChild(this._tabBar);
		}
		this._tabBar = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
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

	@Test
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

	@Test
	public function testSelectedItemAfterSetSelectedIndex():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.areEqual(this._tabBar.dataProvider.get(0), this._tabBar.selectedItem);
		this._tabBar.selectedIndex = 1;
		Assert.areEqual(this._tabBar.dataProvider.get(1), this._tabBar.selectedItem);
	}

	@Test
	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.areEqual(0, this._tabBar.selectedIndex);
		this._tabBar.selectedItem = this._tabBar.dataProvider.get(1);
		Assert.areEqual(1, this._tabBar.selectedIndex);
	}
}
