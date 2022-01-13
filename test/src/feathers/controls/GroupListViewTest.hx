/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.Event;
import feathers.utils.DisplayObjectRecycler;
import feathers.data.ArrayHierarchicalCollection;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.layout.ILayoutIndexObject;
import feathers.controls.dataRenderers.IGroupListViewItemRenderer;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import utest.Assert;
import utest.Test;

@:keep
class GroupListViewTest extends Test {
	private var _listView:GroupListView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._listView = new GroupListView();
		TestMain.openfl_root.addChild(this._listView);
	}

	public function teardown():Void {
		if (this._listView.parent != null) {
			this._listView.parent.removeChild(this._listView);
		}
		this._listView = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function compareLocations(location1:Array<Int>, location2:Array<Int>):Int {
		var null1 = location1 == null;
		var null2 = location2 == null;
		if (null1 && null2) {
			return 0;
		} else if (null1) {
			return 1;
		} else if (null2) {
			return -1;
		}
		var length1 = location1.length;
		var length2 = location2.length;
		var min = length1;
		if (length2 < min) {
			min = length2;
		}
		for (i in 0...min) {
			var index1 = location1[i];
			var index2 = location2[i];
			if (index1 < index2) {
				return -1;
			}
			if (index1 > index2) {
				return 1;
			}
		}
		if (length1 < length2) {
			return -1;
		} else if (length1 > length2) {
			return 1;
		}
		return 0;
	}

	public function testValidateWithNullDataProvider():Void {
		this._listView.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._listView.dataProvider = new TreeCollection([
			new TreeNode({text: "Group A"},
				[
					new TreeNode({text: "Node A1"}),
					new TreeNode({text: "Node A2"}),
					new TreeNode({text: "Node A3"}),
				]),
			new TreeNode({text: "Group B"}, [new TreeNode({text: "Node B1"}), new TreeNode({text: "Node B2"}),]),
			new TreeNode({text: "Group C"}, [new TreeNode({text: "Node C1"})])
		]);
		this._listView.validateNow();
		this._listView.dataProvider = null;
		this._listView.validateNow();
		Assert.pass();
	}

	public function testUpdateItemSetsInterfaceProperties():Void {
		this._listView.dataProvider = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		var itemLocation = [0, 1];
		var item = this._listView.dataProvider.get(itemLocation);
		this._listView.selectedLocation = itemLocation;
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._listView.validateNow();
		var sampleItemRenderer = cast(this._listView.itemToItemRenderer(item), CustomRendererWithInterfaces);
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		var setSelectedValues = sampleItemRenderer.setSelectedValues;
		var setLocationValues = sampleItemRenderer.setLocationValues;
		var setGroupListViewOwnerValues = sampleItemRenderer.setGroupListViewOwnerValues;
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);
		Assert.equals(1, setSelectedValues.length);
		Assert.equals(1, setLocationValues.length);
		Assert.equals(1, setGroupListViewOwnerValues.length);

		this._listView.dataProvider.updateAt(itemLocation);

		Assert.equals(3, setDataValues.length);
		Assert.equals(item, setDataValues[0]);
		Assert.isNull(setDataValues[1]);
		Assert.equals(item, setDataValues[2]);

		Assert.equals(3, setLayoutIndexValues.length);
		Assert.equals(2, setLayoutIndexValues[0]);
		Assert.equals(-1, setLayoutIndexValues[1]);
		Assert.equals(2, setLayoutIndexValues[2]);

		Assert.equals(3, setSelectedValues.length);
		Assert.equals(true, setSelectedValues[0]);
		Assert.equals(false, setSelectedValues[1]);
		Assert.equals(true, setSelectedValues[2]);

		Assert.equals(3, setLocationValues.length);
		Assert.equals(0, compareLocations(itemLocation, setLocationValues[0]));
		Assert.isNull(setLocationValues[1]);
		Assert.equals(0, compareLocations(itemLocation, setLocationValues[2]));

		Assert.equals(3, setGroupListViewOwnerValues.length);
		Assert.equals(this._listView, setGroupListViewOwnerValues[0]);
		Assert.isNull(setGroupListViewOwnerValues[1]);
		Assert.equals(this._listView, setGroupListViewOwnerValues[2]);
	}

	public function testAddItemToDataProviderCreatesNewItemRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._listView.dataProvider = new ArrayHierarchicalCollection([item1]);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.isNull(this._listView.itemToItemRenderer(item2));
		this._listView.dataProvider.addAt(item2, [1]);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.notNull(this._listView.itemToItemRenderer(item2));
	}

	public function testRemoveItemFromDataProviderDestroysItemRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._listView.dataProvider = new ArrayHierarchicalCollection([item1, item2]);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.notNull(this._listView.itemToItemRenderer(item2));
		this._listView.dataProvider.remove(item2);
		this._listView.validateNow();
		Assert.notNull(this._listView.itemToItemRenderer(item1));
		Assert.isNull(this._listView.itemToItemRenderer(item2));
	}

	public function testAddItemBeforeSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, [0, 0]);
		Assert.isTrue(changed);
		Assert.equals(0, compareLocations([0, 2], eventLocation));
		Assert.equals(0, compareLocations([0, 2], this._listView.selectedLocation));
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testAddItemAtSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, [0, 1]);
		Assert.isTrue(changed);
		Assert.equals(0, compareLocations([0, 2], eventLocation));
		Assert.equals(0, compareLocations([0, 2], this._listView.selectedLocation));
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testAddItemAfterSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, [0, 2]);
		Assert.isFalse(changed);
		Assert.equals(null, eventLocation);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testRemoveItemBeforeSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt([0, 0]);
		Assert.isTrue(changed);
		Assert.equals(0, compareLocations([0, 0], eventLocation));
		Assert.equals(0, compareLocations([0, 0], this._listView.selectedLocation));
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testRemoveItemAtSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt([0, 1]);
		Assert.isTrue(changed);
		Assert.equals(null, eventLocation);
		Assert.equals(null, this._listView.selectedLocation);
		Assert.equals(null, eventItem);
		Assert.equals(null, this._listView.selectedItem);
	}

	public function testRemoveItemAfterSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt([0, 2]);
		Assert.isFalse(changed);
		Assert.equals(null, eventLocation);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testReplaceItemBeforeSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set([0, 0], item4);
		Assert.isFalse(changed);
		Assert.equals(null, eventLocation);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testReplaceItemAtSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set([0, 1], item4);
		Assert.isTrue(changed);
		Assert.equals(0, compareLocations([0, 1], eventLocation));
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._listView.selectedItem);
	}

	public function testReplaceItemAfterSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.selectedLocation = [0, 1];
		this._listView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._listView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._listView.selectedLocation;
			eventItem = this._listView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set([0, 2], item4);
		Assert.isFalse(changed);
		Assert.equals(null, eventLocation);
		Assert.equals(0, compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}
}

private class CustomRendererWithInterfaces extends LayoutGroup implements IToggle implements IDataRenderer implements ILayoutIndexObject
		implements IGroupListViewItemRenderer {
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

	private var _selected:Bool;

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

	public var setLocationValues:Array<Array<Int>> = [];

	private var _location:Array<Int>;

	public var location(get, set):Array<Int>;

	private function get_location():Array<Int> {
		return _location;
	}

	private function set_location(value:Array<Int>):Array<Int> {
		if (_location == value) {
			return _location;
		}
		_location = value;
		setLocationValues.push(value);
		return _location;
	}

	public var setGroupListViewOwnerValues:Array<GroupListView> = [];

	private var _groupListViewOwner:GroupListView;

	public var groupListViewOwner(get, set):GroupListView;

	private function get_groupListViewOwner():GroupListView {
		return _groupListViewOwner;
	}

	private function set_groupListViewOwner(value:GroupListView):GroupListView {
		if (_groupListViewOwner == value) {
			return _groupListViewOwner;
		}
		_groupListViewOwner = value;
		setGroupListViewOwnerValues.push(value);
		return _groupListViewOwner;
	}
}
