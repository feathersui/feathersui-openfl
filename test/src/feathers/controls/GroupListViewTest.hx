/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.TouchEvent;
import feathers.events.GroupListViewEvent;
import openfl.events.MouseEvent;
import feathers.events.TriggerEvent;
import openfl.errors.ArgumentError;
import openfl.errors.RangeError;
import feathers.data.GroupListViewItemState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.IGroupListViewItemRenderer;
import feathers.data.ArrayHierarchicalCollection;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import feathers.layout.ILayoutIndexObject;
import feathers.style.IVariantStyleObject;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
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
		Lib.current.addChild(this._listView);
	}

	public function teardown():Void {
		if (this._listView.parent != null) {
			this._listView.parent.removeChild(this._listView);
		}
		this._listView = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._listView.validateNow();
		Assert.pass();
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._listView.validateNow();
		this._listView.dispose();
		this._listView.dispose();
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

	public function testExceptionOnInvalidNegativeSelectedLocation():Void {
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		Assert.raises(() -> {
			this._listView.selectedLocation = [0, -1];
		}, RangeError);
	}

	public function testExceptionOnInvalidTooLargeSelectedLocation():Void {
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		Assert.raises(() -> {
			this._listView.selectedLocation = [0, 3];
		}, RangeError);
	}

	public function testExceptionOnInvalidArrayTooSmallSelectionLocation1():Void {
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		Assert.raises(() -> {
			this._listView.selectedLocation = [0];
		}, ArgumentError);
	}

	public function testExceptionOnInvalidArrayTooSmallSelectionLocation2():Void {
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		Assert.raises(() -> {
			this._listView.selectedLocation = [];
		}, ArgumentError);
	}

	public function testSelectionPropertiesAfterSetSelectedLocation():Void {
		var collection = new ArrayHierarchicalCollection(([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}] : Array<Dynamic>),
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		Assert.isNull(this._listView.selectedLocation);
		Assert.isNull(this._listView.selectedItem);
		this._listView.selectedLocation = [0, 1];
		Assert.notNull(this._listView.selectedLocation);
		Assert.equals(2, this._listView.selectedLocation.length);
		Assert.equals(0, this._listView.selectedLocation[0]);
		Assert.equals(1, this._listView.selectedLocation[1]);
		Assert.equals(collection.get([0, 1]), this._listView.selectedItem);

		var itemStateG = this._listView.itemToItemState(collection.get([0]));
		Assert.notNull(itemStateG);
		Assert.equals(0, CompareLocations.compareLocations([0], itemStateG.location));
		Assert.equals(collection.get([0]), itemStateG.data);
		Assert.isFalse(itemStateG.selected);
		var itemState0 = this._listView.itemToItemState(collection.get([0, 0]));
		Assert.notNull(itemState0);
		Assert.equals(0, CompareLocations.compareLocations([0, 0], itemState0.location));
		Assert.equals(collection.get([0, 0]), itemState0.data);
		Assert.isFalse(itemState0.selected);
		var itemState1 = this._listView.itemToItemState(collection.get([0, 1]));
		Assert.notNull(itemState1);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], itemState1.location));
		Assert.equals(collection.get([0, 1]), itemState1.data);
		Assert.isTrue(itemState1.selected);
		var itemState2 = this._listView.itemToItemState(collection.get([0, 2]));
		Assert.notNull(itemState2);
		Assert.equals(0, CompareLocations.compareLocations([0, 2], itemState2.location));
		Assert.equals(collection.get([0, 2]), itemState2.data);
		Assert.isFalse(itemState2.selected);
	}

	public function testSelectionPropertiesAfterSetSelectedItem():Void {
		var collection = new ArrayHierarchicalCollection(([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}] : Array<Dynamic>),
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		Assert.isNull(this._listView.selectedLocation);
		Assert.isNull(this._listView.selectedItem);
		this._listView.selectedItem = collection.get([0, 1]);
		Assert.notNull(this._listView.selectedLocation);
		Assert.equals(2, this._listView.selectedLocation.length);
		Assert.equals(0, this._listView.selectedLocation[0]);
		Assert.equals(1, this._listView.selectedLocation[1]);
		Assert.equals(collection.get([0, 1]), this._listView.selectedItem);

		var itemStateG = this._listView.itemToItemState(collection.get([0]));
		Assert.notNull(itemStateG);
		Assert.equals(0, CompareLocations.compareLocations([0], itemStateG.location));
		Assert.equals(collection.get([0]), itemStateG.data);
		Assert.isFalse(itemStateG.selected);
		var itemState0 = this._listView.itemToItemState(collection.get([0, 0]));
		Assert.notNull(itemState0);
		Assert.equals(0, CompareLocations.compareLocations([0, 0], itemState0.location));
		Assert.equals(collection.get([0, 0]), itemState0.data);
		Assert.isFalse(itemState0.selected);
		var itemState1 = this._listView.itemToItemState(collection.get([0, 1]));
		Assert.notNull(itemState1);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], itemState1.location));
		Assert.equals(collection.get([0, 1]), itemState1.data);
		Assert.isTrue(itemState1.selected);
		var itemState2 = this._listView.itemToItemState(collection.get([0, 2]));
		Assert.notNull(itemState2);
		Assert.equals(0, CompareLocations.compareLocations([0, 2], itemState2.location));
		Assert.equals(collection.get([0, 2]), itemState2.data);
		Assert.isFalse(itemState2.selected);
	}

	public function testItemToItemRenderer():Void {
		var collection = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.dataProvider = collection;
		this._listView.validateNow();
		var itemRenderer0 = this._listView.itemToItemRenderer(collection.get([0]));
		Assert.notNull(itemRenderer0);
		Assert.isOfType(itemRenderer0, ItemRenderer);
		var itemRenderer1 = this._listView.itemToItemRenderer(collection.get([1]));
		Assert.notNull(itemRenderer1);
		Assert.isOfType(itemRenderer1, ItemRenderer);
		Assert.notEquals(itemRenderer0, itemRenderer1);
		var itemRenderer2 = this._listView.itemToItemRenderer(collection.get([2]));
		Assert.notNull(itemRenderer2);
		Assert.isOfType(itemRenderer2, ItemRenderer);
		Assert.notEquals(itemRenderer0, itemRenderer2);
		Assert.notEquals(itemRenderer1, itemRenderer2);
		var itemRendererNull = this._listView.itemToItemRenderer(null);
		Assert.isNull(itemRendererNull);
	}

	public function testItemToText():Void {
		var collection = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.dataProvider = collection;
		this._listView.itemToHeaderText = item -> item.text;
		this._listView.itemToText = item -> item.text;
		this._listView.validateNow();
		var itemRenderer0 = this._listView.itemToItemRenderer(collection.get([0]));
		Assert.notNull(itemRenderer0);
		Assert.isOfType(itemRenderer0, ItemRenderer);
		Assert.equals("One", cast(itemRenderer0, ItemRenderer).text);
		var itemRenderer1 = this._listView.itemToItemRenderer(collection.get([1]));
		Assert.notNull(itemRenderer1);
		Assert.isOfType(itemRenderer1, ItemRenderer);
		Assert.equals("Two", cast(itemRenderer1, ItemRenderer).text);
		var itemRenderer2 = this._listView.itemToItemRenderer(collection.get([2]));
		Assert.notNull(itemRenderer2);
		Assert.isOfType(itemRenderer2, ItemRenderer);
		Assert.equals("Three", cast(itemRenderer2, ItemRenderer).text);
	}

	public function testItemToEnabled():Void {
		var collection = new ArrayHierarchicalCollection([
			{text: "One", disable: false},
			{text: "Two", disable: true},
			{text: "Three", disable: false}
		]);
		this._listView.dataProvider = collection;
		this._listView.itemToEnabled = item -> !item.disable;
		this._listView.validateNow();
		var itemRenderer0 = this._listView.itemToItemRenderer(collection.get([0]));
		Assert.notNull(itemRenderer0);
		Assert.isOfType(itemRenderer0, ItemRenderer);
		Assert.isTrue(cast(itemRenderer0, ItemRenderer).enabled);
		var itemRenderer1 = this._listView.itemToItemRenderer(collection.get([1]));
		Assert.notNull(itemRenderer1);
		Assert.isOfType(itemRenderer1, ItemRenderer);
		Assert.isFalse(cast(itemRenderer1, ItemRenderer).enabled);
		var itemRenderer2 = this._listView.itemToItemRenderer(collection.get([2]));
		Assert.notNull(itemRenderer2);
		Assert.isOfType(itemRenderer2, ItemRenderer);
		Assert.isTrue(cast(itemRenderer2, ItemRenderer).enabled);
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
		this._listView.validateNow();

		Assert.equals(sampleItemRenderer, cast(this._listView.itemToItemRenderer(item), CustomRendererWithInterfaces));

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
		Assert.equals(0, CompareLocations.compareLocations(itemLocation, setLocationValues[0]));
		Assert.isNull(setLocationValues[1]);
		Assert.equals(0, CompareLocations.compareLocations(itemLocation, setLocationValues[2]));

		Assert.equals(3, setGroupListViewOwnerValues.length);
		Assert.equals(this._listView, setGroupListViewOwnerValues[0]);
		Assert.isNull(setGroupListViewOwnerValues[1]);
		Assert.equals(this._listView, setGroupListViewOwnerValues[2]);
	}

	public function testDefaultItemStateUpdate():Void {
		var updatedLocations:Array<Array<Int>> = [];
		this._listView.dataProvider = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.itemToText = item -> item.text;
		this._listView.itemToHeaderText = item -> item.text;
		this._listView.headerRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.validateNow();
		Assert.equals(4, updatedLocations.length);
		Assert.equals(0, CompareLocations.compareLocations([0], updatedLocations[0]));
		Assert.equals(0, CompareLocations.compareLocations([0, 0], updatedLocations[1]));
		Assert.equals(0, CompareLocations.compareLocations([0, 1], updatedLocations[2]));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], updatedLocations[3]));
		this._listView.setInvalid(DATA);
		this._listView.validateNow();
		Assert.equals(4, updatedLocations.length);
	}

	public function testForceItemStateUpdate():Void {
		var updatedLocations:Array<Array<Int>> = [];
		this._listView.dataProvider = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.itemToText = item -> item.text;
		this._listView.itemToHeaderText = item -> item.text;
		this._listView.headerRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.forceItemStateUpdate = true;
		this._listView.validateNow();
		// the exactly number of updates on the first pass isn't checked
		// GroupListView is currently not as strict as ListView
		var prevLength = updatedLocations.length;
		this._listView.setInvalid(DATA);
		this._listView.validateNow();
		Assert.equals(prevLength + 4, updatedLocations.length);
		Assert.equals(0, CompareLocations.compareLocations([0], updatedLocations[prevLength + 0]));
		Assert.equals(0, CompareLocations.compareLocations([0, 0], updatedLocations[prevLength + 1]));
		Assert.equals(0, CompareLocations.compareLocations([0, 1], updatedLocations[prevLength + 2]));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], updatedLocations[prevLength + 3]));
	}

	public function testUpdateItemCallsDisplayObjectRecyclerUpdate():Void {
		var updatedLocations:Array<Array<Int>> = [];
		this._listView.dataProvider = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.itemToText = item -> item.text;
		this._listView.itemToHeaderText = item -> item.text;
		this._listView.headerRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.validateNow();
		Assert.equals(4, updatedLocations.length);
		Assert.equals(0, CompareLocations.compareLocations([0], updatedLocations[0]));
		Assert.equals(0, CompareLocations.compareLocations([0, 0], updatedLocations[1]));
		Assert.equals(0, CompareLocations.compareLocations([0, 1], updatedLocations[2]));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], updatedLocations[3]));
		this._listView.dataProvider.updateAt([0, 1]);
		this._listView.validateNow();
		Assert.equals(5, updatedLocations.length);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], updatedLocations[4]));
	}

	public function testUpdateAllCallsDisplayObjectRecyclerUpdate():Void {
		var updatedLocations:Array<Array<Int>> = [];
		this._listView.dataProvider = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.itemToText = item -> item.text;
		this._listView.itemToHeaderText = item -> item.text;
		this._listView.headerRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GroupListViewItemState) -> {
			updatedLocations.push(state.location);
		});
		this._listView.validateNow();
		Assert.equals(4, updatedLocations.length);
		Assert.equals(0, CompareLocations.compareLocations([0], updatedLocations[0]));
		Assert.equals(0, CompareLocations.compareLocations([0, 0], updatedLocations[1]));
		Assert.equals(0, CompareLocations.compareLocations([0, 1], updatedLocations[2]));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], updatedLocations[3]));
		this._listView.dataProvider.updateAll();
		this._listView.validateNow();
		Assert.equals(8, updatedLocations.length);
		Assert.equals(0, CompareLocations.compareLocations([0], updatedLocations[4]));
		Assert.equals(0, CompareLocations.compareLocations([0, 0], updatedLocations[5]));
		Assert.equals(0, CompareLocations.compareLocations([0, 1], updatedLocations[6]));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], updatedLocations[7]));
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, [0, 0]);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 2], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], this._listView.selectedLocation));
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, [0, 1]);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 2], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], this._listView.selectedLocation));
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.addAt(item3, [0, 2]);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.isNull(eventItem);
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt([0, 0]);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 0], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 0], this._listView.selectedLocation));
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt([0, 1]);
		Assert.isTrue(changed);
		Assert.isNull(eventLocation);
		Assert.isNull(this._listView.selectedLocation);
		Assert.isNull(eventItem);
		Assert.isNull(this._listView.selectedItem);
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.removeAt([0, 2]);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.isNull(eventItem);
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set([0, 0], item4);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.isNull(eventItem);
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set([0, 1], item4);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._listView.selectedItem);
	}

	public function testReplaceParentOfSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._listView.dataProvider = new ArrayHierarchicalCollection(([branch] : Array<Dynamic>), (item:Dynamic) -> item.children);
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set([0], item4);
		Assert.isTrue(changed);
		Assert.isNull(eventLocation);
		Assert.isNull(this._listView.selectedLocation);
		Assert.isNull(eventItem);
		Assert.isNull(this._listView.selectedItem);
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
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.equals(item2, this._listView.selectedItem);
		this._listView.dataProvider.set([0, 2], item4);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._listView.selectedLocation));
		Assert.isNull(eventItem);
		Assert.equals(item2, this._listView.selectedItem);
	}

	public function testDefaultTextUpdateForAdditionalRecyclers():Void {
		var branch = {text: "Branch", children: [{text: "One"}]};
		this._listView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._listView.itemToText = item -> item.text;
		this._listView.setItemRendererRecycler("other", DisplayObjectRecycler.withClass(ItemRenderer));
		this._listView.itemRendererRecyclerIDFunction = (state) -> {
			return "other";
		};
		this._listView.validateNow();
		var itemRenderer = cast(this._listView.itemToItemRenderer(this._listView.dataProvider.get([0, 0])), ItemRenderer);
		Assert.notNull(itemRenderer);
		Assert.equals("One", itemRenderer.text);
	}

	public function testItemRendererDefaultVariant():Void {
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0, 0]);
		Assert.notNull(itemRenderer);
		Assert.equals(GroupListView.CHILD_VARIANT_ITEM_RENDERER, itemRenderer.variant);
	}

	public function testItemRendererCustomVariant1():Void {
		final customVariant = "custom";
		this._listView.customItemRendererVariant = customVariant;
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0, 0]);
		Assert.notNull(itemRenderer);
		Assert.equals(customVariant, itemRenderer.variant);
	}

	public function testItemRendererCustomVariant2():Void {
		final customVariant = "custom";
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.variant = customVariant;
			return itemRenderer;
		});
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0, 0]);
		Assert.notNull(itemRenderer);
		Assert.equals(customVariant, itemRenderer.variant);
	}

	public function testItemRendererCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._listView.customItemRendererVariant = customVariant1;
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		this._listView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.variant = customVariant2;
			return itemRenderer;
		});
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0, 0]);
		Assert.notNull(itemRenderer);
		Assert.equals(customVariant2, itemRenderer.variant);
	}

	public function testHeaderRendererDefaultVariant():Void {
		var collection = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.dataProvider = collection;
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0]);
		Assert.notNull(itemRenderer);
		Assert.equals(GroupListView.CHILD_VARIANT_HEADER_RENDERER, itemRenderer.variant);
	}

	public function testHeaderRendererCustomVariant1():Void {
		final customVariant = "custom";
		this._listView.customHeaderRendererVariant = customVariant;
		var collection = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.dataProvider = collection;
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0]);
		Assert.notNull(itemRenderer);
		Assert.equals(customVariant, itemRenderer.variant);
	}

	public function testHeaderRendererCustomVariant2():Void {
		final customVariant = "custom";
		var collection = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.dataProvider = collection;
		this._listView.headerRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.variant = customVariant;
			return itemRenderer;
		});
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0]);
		Assert.notNull(itemRenderer);
		Assert.equals(customVariant, itemRenderer.variant);
	}

	public function testHeaderRendererCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._listView.customHeaderRendererVariant = customVariant1;
		var collection = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._listView.dataProvider = collection;
		this._listView.headerRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.variant = customVariant2;
			return itemRenderer;
		});
		this._listView.validateNow();
		var itemRenderer:IVariantStyleObject = cast this._listView.locationToItemRenderer([0]);
		Assert.notNull(itemRenderer);
		Assert.equals(customVariant2, itemRenderer.variant);
	}

	private function testDispatchItemTriggerFromMouseClick():Void {
		this._listView.dataProvider = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		var item = this._listView.dataProvider.get([0, 1]);
		this._listView.validateNow();
		var itemRenderer = cast(this._listView.itemToItemRenderer(item), ItemRenderer);
		var dispatchedTriggerCount = 0;
		this._listView.addEventListener(GroupListViewEvent.ITEM_TRIGGER, event -> {
			dispatchedTriggerCount++;
			Assert.equals(2, event.state.location.length);
			Assert.equals(0, event.state.location[0]);
			Assert.equals(1, event.state.location[1]);
		});
		Assert.equals(0, dispatchedTriggerCount);
		TriggerEvent.dispatchFromMouseEvent(itemRenderer, new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, dispatchedTriggerCount);
	}

	private function testDispatchItemTriggerFromTouchTap():Void {
		this._listView.dataProvider = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		var item = this._listView.dataProvider.get([0, 1]);
		this._listView.validateNow();
		var itemRenderer = cast(this._listView.itemToItemRenderer(item), ItemRenderer);
		var dispatchedTriggerCount = 0;
		this._listView.addEventListener(GroupListViewEvent.ITEM_TRIGGER, event -> {
			dispatchedTriggerCount++;
			Assert.equals(2, event.state.location.length);
			Assert.equals(0, event.state.location[0]);
			Assert.equals(1, event.state.location[1]);
		});
		Assert.equals(0, dispatchedTriggerCount);
		TriggerEvent.dispatchFromTouchEvent(itemRenderer, new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.equals(1, dispatchedTriggerCount);
	}

	private function testItemRecyclerIDFunction():Void {
		var collection = new ArrayHierarchicalCollection([{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]}],
			(item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		this._listView.setItemRendererRecycler("alternate", DisplayObjectRecycler.withClass(ItemRenderer));
		this._listView.setItemRendererRecycler("alternate2", DisplayObjectRecycler.withClass(ItemRenderer));
		this._listView.itemRendererRecyclerIDFunction = (state) -> {
			if (state.location[0] == 0 && state.location[1] == 1) {
				return "alternate";
			} else if (state.location[0] == 0 && state.location[1] == 2) {
				return "alternate2";
			}
			return null;
		};
		this._listView.validateNow();
		var state0 = this._listView.itemToItemState(collection.get([0, 0]));
		Assert.notNull(state0);
		Assert.isNull(state0.recyclerID);
		var state1 = this._listView.itemToItemState(collection.get([0, 1]));
		Assert.notNull(state1);
		Assert.equals("alternate", state1.recyclerID);
		var state2 = this._listView.itemToItemState(collection.get([0, 2]));
		Assert.notNull(state2);
		Assert.equals("alternate2", state2.recyclerID);
	}

	private function testHeaderRecyclerIDFunction():Void {
		var collection = new ArrayHierarchicalCollection(([
			{text: "A", children: [{text: "One"}, {text: "Two"}, {text: "Three"}]},
			{text: "B"},
			{text: "C"}
		] : Array<Dynamic>), (item:Dynamic) -> item.children);
		this._listView.dataProvider = collection;
		this._listView.setHeaderRendererRecycler("alternate", DisplayObjectRecycler.withClass(ItemRenderer));
		this._listView.setHeaderRendererRecycler("alternate2", DisplayObjectRecycler.withClass(ItemRenderer));
		this._listView.headerRendererRecyclerIDFunction = (state) -> {
			if (state.location[0] == 1) {
				return "alternate";
			} else if (state.location[0] == 2) {
				return "alternate2";
			}
			return null;
		};
		this._listView.validateNow();
		var state0 = this._listView.itemToItemState(collection.get([0]));
		Assert.notNull(state0);
		Assert.isNull(state0.recyclerID);
		var state1 = this._listView.itemToItemState(collection.get([1]));
		Assert.notNull(state1);
		Assert.equals("alternate", state1.recyclerID);
		var state2 = this._listView.itemToItemState(collection.get([2]));
		Assert.notNull(state2);
		Assert.equals("alternate2", state2.recyclerID);
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

	override private function update():Void {
		saveMeasurements(1.0, 1.0);
	}
}

private class CompareLocations {
	public static function compareLocations(location1:Array<Int>, location2:Array<Int>):Int {
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
}
