/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.ArrayCollection;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class ComboBoxTest extends Test {
	private var _comboBox:ComboBox;

	public function new() {
		super();
	}

	public function setup():Void {
		this._comboBox = new ComboBox();
		TestMain.openfl_root.addChild(this._comboBox);
	}

	public function teardown():Void {
		if (this._comboBox.parent != null) {
			this._comboBox.parent.removeChild(this._comboBox);
		}
		this._comboBox = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._comboBox.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.validateNow();
		this._comboBox.dataProvider = null;
		this._comboBox.validateNow();
		Assert.pass();
	}

	public function testDispatchChangeEventAfterSetSelectedIndex():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.validateNow();
		var changed = false;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._comboBox.selectedIndex = 1;
		Assert.isTrue(changed);
	}

	public function testDispatchChangeEventAfterSetSelectedItem():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.validateNow();
		var changed = false;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._comboBox.selectedItem = this._comboBox.dataProvider.get(1);
		Assert.isTrue(changed);
	}

	public function testSelectedItemAfterSetSelectedIndex():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(this._comboBox.dataProvider.get(0), this._comboBox.selectedItem);
		this._comboBox.selectedIndex = 1;
		Assert.equals(this._comboBox.dataProvider.get(1), this._comboBox.selectedItem);
	}

	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(0, this._comboBox.selectedIndex);
		this._comboBox.selectedItem = this._comboBox.dataProvider.get(1);
		Assert.equals(1, this._comboBox.selectedIndex);
	}

	public function testDeselectAllOnNullDataProvider():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.selectedIndex = 1;
		var changed = false;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._comboBox.dataProvider = null;
		Assert.isTrue(changed);
		Assert.equals(-1, this._comboBox.selectedIndex);
		Assert.equals(null, this._comboBox.selectedItem);
	}

	public function testDeselectAllOnDataProviderRemoveAll():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.selectedIndex = 1;
		var changed = false;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._comboBox.dataProvider.removeAll();
		Assert.isTrue(changed);
		Assert.equals(-1, this._comboBox.selectedIndex);
		Assert.equals(null, this._comboBox.selectedItem);
	}

	public function testOpenListView():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var dispatchedOpenEvent = false;
		var dispatchedCloseEvent = false;
		this._comboBox.addEventListener(Event.OPEN, function(event:Event):Void {
			dispatchedOpenEvent = true;
		});
		this._comboBox.addEventListener(Event.CLOSE, function(event:Event):Void {
			dispatchedCloseEvent = true;
		});
		Assert.isFalse(dispatchedOpenEvent);
		Assert.isFalse(dispatchedCloseEvent);
		Assert.isFalse(this._comboBox.open);
		this._comboBox.openListView();
		Assert.isTrue(dispatchedOpenEvent);
		Assert.isFalse(dispatchedCloseEvent);
		Assert.isTrue(this._comboBox.open);
	}

	public function testCloseListView():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.openListView();
		var dispatchedOpenEvent = false;
		var dispatchedCloseEvent = false;
		this._comboBox.addEventListener(Event.OPEN, function(event:Event):Void {
			dispatchedOpenEvent = true;
		});
		this._comboBox.addEventListener(Event.CLOSE, function(event:Event):Void {
			dispatchedCloseEvent = true;
		});
		Assert.isFalse(dispatchedOpenEvent);
		Assert.isFalse(dispatchedCloseEvent);
		Assert.isTrue(this._comboBox.open);
		this._comboBox.closeListView();
		Assert.isFalse(dispatchedOpenEvent);
		Assert.isTrue(dispatchedCloseEvent);
		Assert.isFalse(this._comboBox.open);
	}
}
