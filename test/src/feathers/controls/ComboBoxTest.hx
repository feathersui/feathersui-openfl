/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.ArrayCollection;
import openfl.Lib;
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
		Lib.current.addChild(this._comboBox);
	}

	public function teardown():Void {
		if (this._comboBox.parent != null) {
			this._comboBox.parent.removeChild(this._comboBox);
		}
		this._comboBox = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._comboBox.validateNow();
		Assert.pass();
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._comboBox.validateNow();
		this._comboBox.dispose();
		this._comboBox.dispose();
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
		Assert.isNull(this._comboBox.selectedItem);
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
		Assert.isNull(this._comboBox.selectedItem);
	}

	public function testSelectionOnNewDataProvider():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.selectedIndex = 1;
		var changed = false;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		// validate to ensure that it propagates to the internal ListView
		this._comboBox.validateNow();
		Assert.isFalse(changed);
		var newDataProvider = new ArrayCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		this._comboBox.dataProvider = newDataProvider;
		Assert.isTrue(changed);
		Assert.equals(0, this._comboBox.selectedIndex);
		Assert.notNull(this._comboBox.selectedItem);
		Assert.equals(this._comboBox.selectedItem, newDataProvider.get(0));
		changed = false;
		// validate to ensure that it propagates to the internal ListView again
		this._comboBox.validateNow();
		Assert.isFalse(changed);
		Assert.equals(0, this._comboBox.selectedIndex);
		Assert.notNull(this._comboBox.selectedItem);
		Assert.equals(this._comboBox.selectedItem, newDataProvider.get(0));
	}

	public function testSelectionOnNewDataProviderWithSelectedIndexAlready0():Void {
		this._comboBox.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._comboBox.selectedIndex = 0;
		var changed = false;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		// validate to ensure that it propagates to the internal ListView
		this._comboBox.validateNow();
		Assert.isFalse(changed);
		var newDataProvider = new ArrayCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		this._comboBox.dataProvider = newDataProvider;
		Assert.isTrue(changed);
		Assert.equals(0, this._comboBox.selectedIndex);
		Assert.notNull(this._comboBox.selectedItem);
		Assert.equals(this._comboBox.selectedItem, newDataProvider.get(0));
		changed = false;
		// validate to ensure that it propagates to the internal ListView again
		this._comboBox.validateNow();
		Assert.isFalse(changed);
		Assert.equals(0, this._comboBox.selectedIndex);
		Assert.notNull(this._comboBox.selectedItem);
		Assert.equals(this._comboBox.selectedItem, newDataProvider.get(0));
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

	public function testAddItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.addAt(item3, 0);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._comboBox.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._comboBox.selectedItem);
	}

	public function testAddItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.addAt(item3, 1);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._comboBox.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._comboBox.selectedItem);
	}

	public function testAddItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.addAt(item3, 2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._comboBox.selectedItem);
	}

	public function testRemoveItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.removeAt(0);
		Assert.isTrue(changed);
		Assert.equals(0, eventIndex);
		Assert.equals(0, this._comboBox.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._comboBox.selectedItem);
	}

	public function testRemoveItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.removeAt(1);
		Assert.isTrue(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(-1, this._comboBox.selectedIndex);
		Assert.isNull(eventItem);
		Assert.isNull(this._comboBox.selectedItem);
	}

	public function testRemoveItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.removeAt(2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._comboBox.selectedItem);
	}

	public function testReplaceItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.set(0, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._comboBox.selectedItem);
	}

	public function testReplaceItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.set(1, item4);
		Assert.isTrue(changed);
		Assert.equals(1, eventIndex);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._comboBox.selectedItem);
	}

	public function testReplaceItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._comboBox.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._comboBox.selectedIndex = 1;
		this._comboBox.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._comboBox.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._comboBox.selectedIndex;
			eventItem = this._comboBox.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.equals(item2, this._comboBox.selectedItem);
		this._comboBox.dataProvider.set(2, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._comboBox.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._comboBox.selectedItem);
	}
}
