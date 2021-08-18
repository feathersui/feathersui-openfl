/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.layout.ILayoutIndexObject;
import feathers.data.ListViewItemState;
import feathers.utils.DisplayObjectRecycler;
import feathers.controls.dataRenderers.IListViewItemRenderer;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.events.ScrollEvent;
import openfl.events.Event;
import feathers.data.ArrayCollection;
import utest.Assert;
import utest.Test;

@:keep
class ListViewTest extends Test {
	private var _listView:ListView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._listView = new ListView();
		TestMain.openfl_root.addChild(this._listView);
	}

	public function teardown():Void {
		if (this._listView.parent != null) {
			this._listView.parent.removeChild(this._listView);
		}
		this._listView = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
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
		Assert.isNull(this._listView.selectedItem);
		this._listView.selectedIndex = 1;
		Assert.equals(this._listView.dataProvider.get(1), this._listView.selectedItem);
	}

	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(-1, this._listView.selectedIndex);
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
		Assert.equals(null, this._listView.selectedItem);
	}

	public function testResetScrollOnNullDataProvider():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.scrollX = 10.0;
		this._listView.scrollY = 10.0;
		var scrolled = false;
		this._listView.addEventListener(ScrollEvent.SCROLL, function(event:ScrollEvent):Void {
			scrolled = true;
		});
		Assert.isFalse(scrolled);
		this._listView.dataProvider = null;
		Assert.isTrue(scrolled);
		Assert.equals(0.0, this._listView.scrollX);
		Assert.equals(0.0, this._listView.scrollY);
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
		Assert.equals(null, this._listView.selectedItem);
	}

	public function testUpdateItemSetsInterfaceProperties():Void {
		this._listView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var itemIndex = 1;
		var item = this._listView.dataProvider.get(itemIndex);
		this._listView.selectedIndex = itemIndex;
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._listView.validateNow();
		var sampleItemRenderer = cast(this._listView.itemToItemRenderer(item), CustomRendererWithInterfaces);
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		var setSelectedValues = sampleItemRenderer.setSelectedValues;
		var setIndexValues = sampleItemRenderer.setIndexValues;
		var setListViewOwnerValues = sampleItemRenderer.setListViewOwnerValues;
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);
		Assert.equals(1, setSelectedValues.length);
		Assert.equals(1, setIndexValues.length);
		Assert.equals(1, setListViewOwnerValues.length);

		this._listView.dataProvider.updateAt(itemIndex);

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

		Assert.equals(3, setIndexValues.length);
		Assert.equals(itemIndex, setIndexValues[0]);
		Assert.equals(-1, setIndexValues[1]);
		Assert.equals(itemIndex, setIndexValues[2]);

		Assert.equals(3, setListViewOwnerValues.length);
		Assert.equals(this._listView, setListViewOwnerValues[0]);
		Assert.isNull(setListViewOwnerValues[1]);
		Assert.equals(this._listView, setListViewOwnerValues[2]);
	}

	public function testAddItemToDataProviderCreatesNewItemRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._listView.dataProvider = new ArrayCollection([item1]);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.isNull(this._listView.itemToItemRenderer(item2));
		this._listView.dataProvider.add(item2);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.notNull(this._listView.itemToItemRenderer(item2));
	}

	public function testRemoveItemFromDataProviderDestroysItemRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._listView.dataProvider = new ArrayCollection([item1, item2]);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.notNull(this._listView.itemToItemRenderer(item2));
		this._listView.dataProvider.remove(item2);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.isNull(this._listView.itemToItemRenderer(item2));
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
		Assert.equals(null, eventItem);
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
		Assert.equals(null, eventItem);
		Assert.equals(null, this._listView.selectedItem);
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
		Assert.equals(null, eventItem);
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
		Assert.equals(null, eventItem);
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
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}
}

private class CustomRendererWithInterfaces extends LayoutGroup implements IToggle implements IDataRenderer implements ILayoutIndexObject
		implements IListViewItemRenderer {
	public function new() {
		super();
	}

	public var setDataValues:Array<Dynamic> = [];

	private var _data:Dynamic;

	@:flash.property
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

	@:flash.property
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

	private var _selected:Bool;

	@:flash.property
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return _selected;
	}

	private function set_selected(value:Bool):Bool {
		if (_selected == value) {
			return _selected;
		}
		_selected = value;
		setSelectedValues.push(value);
		return _selected;
	}

	public var setIndexValues:Array<Int> = [];

	private var _index:Int = -1;

	@:flash.property
	public var index(get, set):Int;

	private function get_index():Int {
		return _index;
	}

	private function set_index(value:Int):Int {
		if (_index == value) {
			return _index;
		}
		_index = value;
		setIndexValues.push(value);
		return _index;
	}

	public var setListViewOwnerValues:Array<ListView> = [];

	private var _listViewOwner:ListView;

	@:flash.property
	public var listViewOwner(get, set):ListView;

	private function get_listViewOwner():ListView {
		return _listViewOwner;
	}

	private function set_listViewOwner(value:ListView):ListView {
		if (_listViewOwner == value) {
			return _listViewOwner;
		}
		_listViewOwner = value;
		setListViewOwnerValues.push(value);
		return _listViewOwner;
	}
}
