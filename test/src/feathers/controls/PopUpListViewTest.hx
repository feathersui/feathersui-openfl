/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.Button;
import openfl.errors.RangeError;
import feathers.data.ArrayCollection;
import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class PopUpListViewTest extends Test {
	private var _listView:PopUpListView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._listView = new PopUpListView();
		Lib.current.addChild(this._listView);
	}

	public function teardown():Void {
		if (this._listView.parent != null) {
			this._listView.parent.removeChild(this._listView);
		}
		this._listView = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._listView.validateNow();
		this._listView.dispose();
		this._listView.dispose();
		Assert.pass();
	}

	public function testValidateWithNullDataProvider():Void {
		this._listView.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.validateNow();
		this._listView.dataProvider = null;
		this._listView.validateNow();
		Assert.pass();
	}

	public function testExceptionOnInvalidNegativeSelectedIndex():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.raises(() -> {
			this._listView.selectedIndex = -2;
		}, RangeError);
	}

	public function testExceptionOnInvalidTooLargeSelectedIndex():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.raises(() -> {
			this._listView.selectedIndex = 3;
		}, RangeError);
	}

	public function testDispatchChangeEventAfterSetSelectedIndex():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.validateNow();
		var changed = false;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._listView.selectedIndex = 1;
		Assert.isTrue(changed);
	}

	public function testDispatchChangeEventAfterSetSelectedItem():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.validateNow();
		var changed = false;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._listView.selectedItem = this._listView.dataProvider.get(1);
		Assert.isTrue(changed);
	}

	public function testSelectedItemAfterSetSelectedIndex():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(this._listView.dataProvider.get(0), this._listView.selectedItem);
		this._listView.selectedIndex = 1;
		Assert.equals(this._listView.dataProvider.get(1), this._listView.selectedItem);
	}

	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(0, this._listView.selectedIndex);
		this._listView.selectedItem = this._listView.dataProvider.get(1);
		Assert.equals(1, this._listView.selectedIndex);
	}

	public function testDeselectAllOnNullDataProvider():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.selectedIndex = 1;
		var changed = false;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._listView.dataProvider = null;
		Assert.isTrue(changed);
		Assert.equals(-1, this._listView.selectedIndex);
		Assert.isNull(this._listView.selectedItem);
	}

	public function testDeselectAllOnDataProviderRemoveAll():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.selectedIndex = 1;
		var changed = false;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._listView.dataProvider.removeAll();
		Assert.isTrue(changed);
		Assert.equals(-1, this._listView.selectedIndex);
		Assert.isNull(this._listView.selectedItem);
	}

	public function testSelectionOnNewDataProvider():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.selectedIndex = 1;
		var changed = false;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		// validate to ensure that it propagates to the internal ListView
		this._listView.validateNow();
		Assert.isFalse(changed);
		var newDataProvider = new ArrayCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		this._listView.dataProvider = newDataProvider;
		Assert.isTrue(changed);
		Assert.equals(0, this._listView.selectedIndex);
		Assert.notNull(this._listView.selectedItem);
		Assert.equals(newDataProvider.get(0), this._listView.selectedItem);
		changed = false;
		// validate to ensure that it propagates to the internal ListView again
		this._listView.validateNow();
		Assert.isFalse(changed);
		Assert.equals(0, this._listView.selectedIndex);
		Assert.notNull(this._listView.selectedItem);
		Assert.equals(newDataProvider.get(0), this._listView.selectedItem);
	}

	public function testSelectionOnNewDataProviderWithSelectedIndexAlready0():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.selectedIndex = 0;
		var changed = false;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		// validate to ensure that it propagates to the internal ListView
		this._listView.validateNow();
		Assert.isFalse(changed);
		var newDataProvider = new ArrayCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		this._listView.dataProvider = newDataProvider;
		Assert.isTrue(changed);
		Assert.equals(0, this._listView.selectedIndex);
		Assert.notNull(this._listView.selectedItem);
		Assert.equals(newDataProvider.get(0), this._listView.selectedItem);
		changed = false;
		// validate to ensure that it propagates to the internal ListView again
		this._listView.validateNow();
		Assert.isFalse(changed);
		Assert.equals(0, this._listView.selectedIndex);
		Assert.notNull(this._listView.selectedItem);
		Assert.equals(newDataProvider.get(0), this._listView.selectedItem);
	}

	public function testOpenListView():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var dispatchedOpenEvent = false;
		var dispatchedCloseEvent = false;
		this._listView.addEventListener(Event.OPEN, function(event:Event):Void {
			dispatchedOpenEvent = true;
		});
		this._listView.addEventListener(Event.CLOSE, function(event:Event):Void {
			dispatchedCloseEvent = true;
		});
		Assert.isFalse(dispatchedOpenEvent);
		Assert.isFalse(dispatchedCloseEvent);
		Assert.isFalse(this._listView.open);
		this._listView.openListView();
		Assert.isTrue(dispatchedOpenEvent);
		Assert.isFalse(dispatchedCloseEvent);
		Assert.isTrue(this._listView.open);
	}

	public function testCloseListView():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.openListView();
		var dispatchedOpenEvent = false;
		var dispatchedCloseEvent = false;
		this._listView.addEventListener(Event.OPEN, function(event:Event):Void {
			dispatchedOpenEvent = true;
		});
		this._listView.addEventListener(Event.CLOSE, function(event:Event):Void {
			dispatchedCloseEvent = true;
		});
		Assert.isFalse(dispatchedOpenEvent);
		Assert.isFalse(dispatchedCloseEvent);
		Assert.isTrue(this._listView.open);
		this._listView.closeListView();
		Assert.isFalse(dispatchedOpenEvent);
		Assert.isTrue(dispatchedCloseEvent);
		Assert.isFalse(this._listView.open);
	}

	public function testAddItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, 0);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._listView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testAddItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, 1);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._listView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testAddItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, 2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testRemoveItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt(0);
		Assert.isTrue(changed);
		Assert.equals(0, eventIndex);
		Assert.equals(0, this._listView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testRemoveItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt(1);
		Assert.isTrue(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(-1, this._listView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.isNull(this._listView.selectedItem);
	}

	public function testRemoveItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt(2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testReplaceItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set(0, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testReplaceItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set(1, item4);
		Assert.isTrue(changed);
		Assert.equals(1, eventIndex);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._listView.selectedItem);
	}

	public function testReplaceItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._listView.selectedIndex;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set(2, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._listView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testButtonDefaultVariant():Void {
		var button:Button = null;
		this._listView.buttonFactory = () -> {
			button = new Button();
			return button;
		}
		this._listView.validateNow();
		Assert.notNull(button);
		Assert.equals(PopUpListView.CHILD_VARIANT_BUTTON, button.variant);
	}

	public function testButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._listView.customButtonVariant = customVariant;
		var button:Button = null;
		this._listView.buttonFactory = () -> {
			button = new Button();
			return button;
		}
		this._listView.validateNow();
		Assert.notNull(button);
		Assert.equals(customVariant, button.variant);
	}

	public function testButtonCustomVariant2():Void {
		final customVariant = "custom";
		var button:Button = null;
		this._listView.buttonFactory = () -> {
			button = new Button();
			button.variant = customVariant;
			return button;
		}
		this._listView.validateNow();
		Assert.notNull(button);
		Assert.equals(customVariant, button.variant);
	}

	public function testButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._listView.customButtonVariant = customVariant1;
		var button:Button = null;
		this._listView.buttonFactory = () -> {
			button = new Button();
			button.variant = customVariant2;
			return button;
		}
		this._listView.validateNow();
		Assert.notNull(button);
		Assert.equals(customVariant2, button.variant);
	}

	public function testSetSelectedIndexInCloseListener():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		var oldSelectedIndex = 2;
		var newSelectedIndex = 1;
		this._listView.selectedIndex = oldSelectedIndex;
		this._listView.addEventListener(Event.CLOSE, event -> {
			this._listView.selectedIndex = newSelectedIndex;
		});
		this._listView.validateNow();
		this._listView.openListView();
		Assert.equals(oldSelectedIndex, this._listView.selectedIndex);
		this._listView.closeListView();
		Assert.equals(newSelectedIndex, this._listView.selectedIndex);
	}

	public function testSetSelectedItemInCloseListener():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._listView.dataProvider = new ArrayCollection([item1, item2, item3]);
		var oldSelectedItem = item2;
		var newSelectedItem = item3;
		this._listView.selectedItem = oldSelectedItem;
		this._listView.addEventListener(Event.CLOSE, event -> {
			this._listView.selectedItem = newSelectedItem;
		});
		this._listView.validateNow();
		this._listView.openListView();
		Assert.equals(oldSelectedItem, this._listView.selectedItem);
		this._listView.closeListView();
		Assert.equals(newSelectedItem, this._listView.selectedItem);
	}

	public function testItemToText():Void {
		var button = new Button();
		this._listView.buttonFactory = () -> button;
		Assert.equals("", this._listView.text);
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._listView.dataProvider = new ArrayCollection([item1, item2]);
		this._listView.itemToText = (item:Dynamic) -> item.text;
		this._listView.selectedIndex = 1;
		this._listView.validateNow();
		Assert.equals("Two", this._listView.text);
		Assert.equals("Two", button.text);
		this._listView.itemToText = (item:Dynamic) -> "Test: " + item.text;
		this._listView.validateNow();
		Assert.equals("Test: Two", this._listView.text);
		Assert.equals("Test: Two", button.text);
		item2.text = "Three";
		this._listView.dataProvider.updateAt(1);
		this._listView.validateNow();
		Assert.equals("Test: Three", this._listView.text);
		Assert.equals("Test: Three", button.text);
	}
}
