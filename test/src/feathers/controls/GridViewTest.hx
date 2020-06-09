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
class GridViewTest {
	private var _gridView:GridView;

	@Before
	public function prepare():Void {
		this._gridView = new GridView();
		TestMain.openfl_root.addChild(this._gridView);
	}

	@After
	public function cleanup():Void {
		if (this._gridView.parent != null) {
			this._gridView.parent.removeChild(this._gridView);
		}
		this._gridView = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testValidateWithNullDataProvider():Void {
		this._gridView.validateNow();
	}

	@Test
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

	@Test
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

	@Test
	public function testSelectedItemAfterSetSelectedIndex():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.isNull(this._gridView.selectedItem);
		this._gridView.selectedIndex = 1;
		Assert.areEqual(this._gridView.dataProvider.get(1), this._gridView.selectedItem);
	}

	@Test
	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.areEqual(-1, this._gridView.selectedIndex);
		this._gridView.selectedItem = this._gridView.dataProvider.get(1);
		Assert.areEqual(1, this._gridView.selectedIndex);
	}
}
