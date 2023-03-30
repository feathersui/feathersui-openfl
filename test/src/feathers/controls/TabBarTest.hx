/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.data.ArrayCollection;
import feathers.data.TabBarItemState;
import feathers.layout.ILayoutIndexObject;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
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
		Lib.current.addChild(this._tabBar);
	}

	public function teardown():Void {
		if (this._tabBar.parent != null) {
			this._tabBar.parent.removeChild(this._tabBar);
		}
		this._tabBar = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
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

	public function testItemToTab():Void {
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.dataProvider = collection;
		this._tabBar.validateNow();
		var tab0 = this._tabBar.itemToTab(collection.get(0));
		Assert.notNull(tab0);
		Assert.isOfType(tab0, ToggleButton);
		var tab1 = this._tabBar.itemToTab(collection.get(1));
		Assert.notNull(tab1);
		Assert.isOfType(tab1, ToggleButton);
		Assert.notEquals(tab0, tab1);
		var tab2 = this._tabBar.itemToTab(collection.get(2));
		Assert.notNull(tab2);
		Assert.isOfType(tab2, ToggleButton);
		Assert.notEquals(tab0, tab2);
		Assert.notEquals(tab1, tab2);
		var tabNull = this._tabBar.itemToTab(null);
		Assert.isNull(tabNull);
	}

	public function testItemToText():Void {
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.dataProvider = collection;
		this._tabBar.itemToText = item -> item.text;
		this._tabBar.validateNow();
		var tab0 = this._tabBar.itemToTab(collection.get(0));
		Assert.notNull(tab0);
		Assert.isOfType(tab0, ToggleButton);
		Assert.equals("One", cast(tab0, ToggleButton).text);
		var tab1 = this._tabBar.itemToTab(collection.get(1));
		Assert.notNull(tab1);
		Assert.isOfType(tab1, ToggleButton);
		Assert.equals("Two", cast(tab1, ToggleButton).text);
		var tab2 = this._tabBar.itemToTab(collection.get(2));
		Assert.notNull(tab2);
		Assert.isOfType(tab2, ToggleButton);
		Assert.equals("Three", cast(tab2, ToggleButton).text);
	}

	public function testItemToEnabled():Void {
		var collection = new ArrayCollection([
			{text: "One", disable: false},
			{text: "Two", disable: true},
			{text: "Three", disable: false}
		]);
		this._tabBar.dataProvider = collection;
		this._tabBar.itemToEnabled = item -> !item.disable;
		this._tabBar.validateNow();
		var tab0 = this._tabBar.itemToTab(collection.get(0));
		Assert.notNull(tab0);
		Assert.isOfType(tab0, ToggleButton);
		Assert.isTrue(cast(tab0, ToggleButton).enabled);
		var tab1 = this._tabBar.itemToTab(collection.get(1));
		Assert.notNull(tab1);
		Assert.isOfType(tab1, ToggleButton);
		Assert.isFalse(cast(tab1, ToggleButton).enabled);
		var tab2 = this._tabBar.itemToTab(collection.get(2));
		Assert.notNull(tab2);
		Assert.isOfType(tab2, ToggleButton);
		Assert.isTrue(cast(tab2, ToggleButton).enabled);
	}

	public function testTabRecycler():Void {
		var createCount = 0;
		var updateCount = 0;
		var resetCount = 0;
		var destroyCount = 0;
		this._tabBar.tabRecycler = DisplayObjectRecycler.withFunction(() -> {
			createCount++;
			return new ToggleButton();
		}, (target:ToggleButton, state:TabBarItemState) -> {
			updateCount++;
		}, (target:ToggleButton, state:TabBarItemState) -> {
			resetCount++;
		}, (target:ToggleButton) -> {
			destroyCount++;
		});
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}]);
		this._tabBar.dataProvider = collection;
		this._tabBar.itemToText = item -> item.text;
		this._tabBar.validateNow();
		Assert.equals(2, createCount);
		Assert.equals(2, updateCount);
		Assert.equals(0, resetCount);
		Assert.equals(0, destroyCount);
		collection.removeAt(1);
		this._tabBar.validateNow();
		Assert.equals(2, createCount);
		Assert.equals(2, updateCount);
		Assert.equals(1, resetCount);
		Assert.equals(1, destroyCount);
		collection.add({text: "New"});
		this._tabBar.validateNow();
		Assert.equals(3, createCount);
		Assert.equals(3, updateCount);
		Assert.equals(1, resetCount);
		Assert.equals(1, destroyCount);
		collection.set(1, {text: "New 2"});
		this._tabBar.validateNow();
		Assert.equals(3, createCount);
		Assert.equals(4, updateCount);
		Assert.equals(2, resetCount);
		Assert.equals(1, destroyCount);
		this._tabBar.dataProvider = null;
		this._tabBar.validateNow();
		Assert.equals(3, createCount);
		Assert.equals(4, updateCount);
		Assert.equals(4, resetCount);
		Assert.equals(3, destroyCount);
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

	public function testDeselectAllOnNullDataProvider():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.selectedIndex = 1;
		var changed = false;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._tabBar.dataProvider = null;
		Assert.isTrue(changed);
		Assert.equals(-1, this._tabBar.selectedIndex);
		Assert.isNull(this._tabBar.selectedItem);
	}

	public function testDeselectAllOnDataProviderRemoveAll():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.selectedIndex = 1;
		var changed = false;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._tabBar.dataProvider.removeAll();
		Assert.isTrue(changed);
		Assert.equals(-1, this._tabBar.selectedIndex);
		Assert.isNull(this._tabBar.selectedItem);
	}

	public function testSelectionOnNewDataProvider():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.selectedIndex = 1;
		var changed = false;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		// validate to ensure that it propagates to the internal ListView
		this._tabBar.validateNow();
		Assert.isFalse(changed);
		var newDataProvider = new ArrayCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		this._tabBar.dataProvider = newDataProvider;
		Assert.isTrue(changed);
		Assert.equals(0, this._tabBar.selectedIndex);
		Assert.notNull(this._tabBar.selectedItem);
		Assert.equals(newDataProvider.get(0), this._tabBar.selectedItem);
		changed = false;
		// validate to ensure that it propagates to the internal ListView again
		this._tabBar.validateNow();
		Assert.isFalse(changed);
		Assert.equals(0, this._tabBar.selectedIndex);
		Assert.notNull(this._tabBar.selectedItem);
		Assert.equals(newDataProvider.get(0), this._tabBar.selectedItem);
	}

	public function testSelectionOnNewDataProviderWithSelectedIndexAlready0():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._tabBar.selectedIndex = 0;
		var changed = false;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		// validate to ensure that it propagates to the internal ListView
		this._tabBar.validateNow();
		Assert.isFalse(changed);
		var newDataProvider = new ArrayCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		this._tabBar.dataProvider = newDataProvider;
		Assert.isTrue(changed);
		Assert.equals(0, this._tabBar.selectedIndex);
		Assert.notNull(this._tabBar.selectedItem);
		Assert.equals(newDataProvider.get(0), this._tabBar.selectedItem);
		changed = false;
		// validate to ensure that it propagates to the internal ListView again
		this._tabBar.validateNow();
		Assert.isFalse(changed);
		Assert.equals(0, this._tabBar.selectedIndex);
		Assert.notNull(this._tabBar.selectedItem);
		Assert.equals(newDataProvider.get(0), this._tabBar.selectedItem);
	}

	public function testUpdateItemSetsInterfaceProperties():Void {
		this._tabBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var itemIndex = 1;
		var item = this._tabBar.dataProvider.get(itemIndex);
		this._tabBar.selectedIndex = itemIndex;
		this._tabBar.tabRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._tabBar.validateNow();
		var sampleItemRenderer = cast(this._tabBar.itemToTab(item), CustomRendererWithInterfaces);
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		var setSelectedValues = sampleItemRenderer.setSelectedValues;
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);
		Assert.equals(1, setSelectedValues.length);

		this._tabBar.dataProvider.updateAt(itemIndex);

		Assert.equals(3, setDataValues.length);
		Assert.equals(item, setDataValues[0]);
		Assert.isNull(setDataValues[1]);
		Assert.equals(item, setDataValues[2]);

		Assert.equals(3, setLayoutIndexValues.length);
		Assert.equals(itemIndex, setLayoutIndexValues[0]);
		Assert.equals(-1, setLayoutIndexValues[1]);
		Assert.equals(itemIndex, setLayoutIndexValues[2]);

		Assert.equals(3, setSelectedValues.length);
		Assert.equals(true, setSelectedValues[0]);
		Assert.equals(false, setSelectedValues[1]);
		Assert.equals(true, setSelectedValues[2]);
	}

	public function testAddItemToDataProviderCreatesNewTab():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._tabBar.dataProvider = new ArrayCollection([item1]);
		this._tabBar.validateNow();
		Assert.notNull(this._tabBar.itemToTab(item1));
		Assert.isNull(this._tabBar.itemToTab(item2));
		this._tabBar.dataProvider.add(item2);
		this._tabBar.validateNow();
		Assert.notNull(this._tabBar.itemToTab(item1));
		Assert.notNull(this._tabBar.itemToTab(item2));
	}

	public function testRemoveItemFromDataProviderDestroysTab():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2]);
		this._tabBar.validateNow();
		Assert.notNull(this._tabBar.itemToTab(item1));
		Assert.notNull(this._tabBar.itemToTab(item2));
		this._tabBar.dataProvider.remove(item2);
		this._tabBar.validateNow();
		Assert.notNull(this._tabBar.itemToTab(item1));
		Assert.isNull(this._tabBar.itemToTab(item2));
	}

	public function testAddItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.addAt(item3, 0);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._tabBar.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._tabBar.selectedItem);
	}

	public function testAddItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.addAt(item3, 1);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._tabBar.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._tabBar.selectedItem);
	}

	public function testAddItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.addAt(item3, 2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._tabBar.selectedItem);
	}

	public function testRemoveItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.removeAt(0);
		Assert.isTrue(changed);
		Assert.equals(0, eventIndex);
		Assert.equals(0, this._tabBar.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._tabBar.selectedItem);
	}

	public function testRemoveItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.removeAt(1);
		Assert.isTrue(changed);
		Assert.equals(1, eventIndex);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item3, eventItem);
		Assert.equals(item3, this._tabBar.selectedItem);
	}

	public function testRemoveItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.removeAt(2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._tabBar.selectedItem);
	}

	public function testReplaceItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.set(0, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._tabBar.selectedItem);
	}

	public function testReplaceItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.set(1, item4);
		Assert.isTrue(changed);
		Assert.equals(1, eventIndex);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._tabBar.selectedItem);
	}

	public function testReplaceItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._tabBar.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._tabBar.selectedIndex = 1;
		this._tabBar.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		this._tabBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._tabBar.selectedIndex;
			eventItem = this._tabBar.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.equals(item2, this._tabBar.selectedItem);
		this._tabBar.dataProvider.set(2, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._tabBar.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._tabBar.selectedItem);
	}
}

private class CustomRendererWithInterfaces extends ToggleButton implements IDataRenderer implements ILayoutIndexObject {
	public function new() {
		super();
	}

	public var setDataValues:Array<Dynamic> = [];

	private var _data:Dynamic;

	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return _data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (_data == value) {
			return _data;
		}
		_data = value;
		setDataValues.push(value);
		return _data;
	}

	public var setLayoutIndexValues:Array<Int> = [];

	private var _layoutIndex:Int = -1;

	public var layoutIndex(get, set):Int;

	private function get_layoutIndex():Int {
		return _layoutIndex;
	}

	private function set_layoutIndex(value:Int):Int {
		if (_layoutIndex == value) {
			return _layoutIndex;
		}
		_layoutIndex = value;
		setLayoutIndexValues.push(value);
		return _layoutIndex;
	}

	public var setSelectedValues:Array<Bool> = [];

	override private function set_selected(value:Bool):Bool {
		if (_selected == value) {
			return _selected;
		}
		super.selected = value;
		setSelectedValues.push(value);
		return _selected;
	}

	override private function update():Void {
		saveMeasurements(1.0, 1.0);
	}
}
