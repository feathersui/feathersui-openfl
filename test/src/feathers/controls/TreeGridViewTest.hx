/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.TreeGridViewCellState;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.ITreeGridViewCellRenderer;
import feathers.core.IOpenCloseToggle;
import feathers.data.ArrayCollection;
import feathers.data.ArrayHierarchicalCollection;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import feathers.events.ScrollEvent;
import feathers.layout.ILayoutIndexObject;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep class TreeGridViewTest extends Test {
	private var _treeGridView:TreeGridView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._treeGridView = new TreeGridView();
		Lib.current.addChild(this._treeGridView);
	}

	public function teardown():Void {
		if (this._treeGridView.parent != null) {
			this._treeGridView.parent.removeChild(this._treeGridView);
		}
		this._treeGridView = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._treeGridView.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._treeGridView.dataProvider = new TreeCollection([
			new TreeNode({text: "Node 1"},
				[
					new TreeNode({text: "Node 1A"},
						[
							new TreeNode({text: "Node 1A-I"}),
							new TreeNode({text: "Node 1A-II"}),
							new TreeNode({text: "Node 1A-III"}),
						]),
					new TreeNode({text: "Node 1B"}),
					new TreeNode({text: "Node 1C"})
				]),
			new TreeNode({text: "Node 2"}, [new TreeNode({text: "Node 2A"}),]),
			new TreeNode({text: "Node 3"}),
			new TreeNode({text: "Node 4"}, [new TreeNode({text: "Node 4A"}), new TreeNode({text: "Node 4B"}),])
		]);
		var textColumn = new TreeGridViewColumn("Text", (item:TreeNode<Dynamic>) -> item.data.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.validateNow();
		this._treeGridView.dataProvider = null;
		this._treeGridView.validateNow();
		Assert.pass();
	}

	public function testItemAndColumnToCellRenderer():Void {
		var collection = new ArrayHierarchicalCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		var columns = new ArrayCollection([
			new TreeGridViewColumn("A", item -> item.a),
			new TreeGridViewColumn("B", item -> item.b)
		]);
		this._treeGridView.columns = columns;
		this._treeGridView.dataProvider = collection;
		this._treeGridView.validateNow();
		var itemRenderer00 = this._treeGridView.itemAndColumnToCellRenderer(collection.get([0]), columns.get(0));
		Assert.notNull(itemRenderer00);
		Assert.isOfType(itemRenderer00, HierarchicalItemRenderer);
		var itemRenderer01 = this._treeGridView.itemAndColumnToCellRenderer(collection.get([0]), columns.get(1));
		Assert.notNull(itemRenderer01);
		Assert.isOfType(itemRenderer01, HierarchicalItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer01);
		var itemRenderer10 = this._treeGridView.itemAndColumnToCellRenderer(collection.get([1]), columns.get(0));
		Assert.notNull(itemRenderer10);
		Assert.isOfType(itemRenderer10, HierarchicalItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer10);
		Assert.notEquals(itemRenderer01, itemRenderer10);
		var itemRenderer11 = this._treeGridView.itemAndColumnToCellRenderer(collection.get([1]), columns.get(1));
		Assert.notNull(itemRenderer11);
		Assert.isOfType(itemRenderer11, HierarchicalItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer11);
		Assert.notEquals(itemRenderer01, itemRenderer11);
		Assert.notEquals(itemRenderer10, itemRenderer11);
		var itemRenderer20 = this._treeGridView.itemAndColumnToCellRenderer(collection.get([2]), columns.get(0));
		Assert.notNull(itemRenderer20);
		Assert.isOfType(itemRenderer20, HierarchicalItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer20);
		Assert.notEquals(itemRenderer01, itemRenderer20);
		Assert.notEquals(itemRenderer10, itemRenderer20);
		Assert.notEquals(itemRenderer11, itemRenderer20);
		var itemRenderer21 = this._treeGridView.itemAndColumnToCellRenderer(collection.get([2]), columns.get(1));
		Assert.notNull(itemRenderer21);
		Assert.isOfType(itemRenderer21, HierarchicalItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer21);
		Assert.notEquals(itemRenderer01, itemRenderer21);
		Assert.notEquals(itemRenderer10, itemRenderer21);
		Assert.notEquals(itemRenderer11, itemRenderer21);
		Assert.notEquals(itemRenderer20, itemRenderer21);
		var itemRendererNull = this._treeGridView.itemAndColumnToCellRenderer(null, columns.get(0));
		Assert.isNull(itemRendererNull);
	}

	public function testValidateWithAutoPopulatedColumns():Void {
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([
			{
				a: "Node 1",
				b: 123.4
			},
			{
				a: "Node 2",
				b: 567.8
			},
			{
				a: "Node 3",
				b: 901.2
			},
			{
				a: "Node 4",
				b: 345.6
			}
		]);
		this._treeGridView.validateNow();
		Assert.equals(2, this._treeGridView.columns.length);
		var column0 = this._treeGridView.columns.get(0);
		var column1 = this._treeGridView.columns.get(1);
		// order is not guaranteed
		if (column0.headerText == "a") {
			Assert.equals("a", column0.headerText);
			Assert.equals("b", column1.headerText);
		} else {
			Assert.equals("b", column0.headerText);
			Assert.equals("a", column1.headerText);
		}
	}

	public function testValidateWithNoColumnsAndComplexData():Void {
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection(([
			{
				complex: {text: "Node 1"},
				children: ([
					{complex: {text: "Node 1A"}},
					{complex: {text: "Node 1B"}},
					{complex: {text: "Node 1C"}}
				] : Array<Dynamic>)
			},
			{
				complex: {text: "Node 2"},
				children: ([{complex: {text: "Node 2A"}}] : Array<Dynamic>)
			},
			{
				complex: {text: "Node 3"}
			},
			{
				complex: {text: "Node 4"},
				children: ([{complex: {text: "Node 4A"}}, {complex: {text: "Node 4B"}}] : Array<Dynamic>)
			}
		] : Array<Dynamic>));
		this._treeGridView.validateNow();
		Assert.pass();
	}

	public function testDeselectAllOnNullDataProvider():Void {
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [1];
		var changed = false;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._treeGridView.dataProvider = null;
		Assert.isTrue(changed);
		Assert.equals(null, this._treeGridView.selectedLocation);
		Assert.isNull(this._treeGridView.selectedItem);
	}

	public function testResetScrollOnNullDataProvider():Void {
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.scrollX = 10.0;
		this._treeGridView.scrollY = 10.0;
		var scrolled = false;
		this._treeGridView.addEventListener(ScrollEvent.SCROLL, function(event:ScrollEvent):Void {
			scrolled = true;
		});
		Assert.isFalse(scrolled);
		this._treeGridView.dataProvider = null;
		Assert.isTrue(scrolled);
		Assert.equals(0.0, this._treeGridView.scrollX);
		Assert.equals(0.0, this._treeGridView.scrollY);
	}

	public function testDeselectAllOnDataProviderRemoveAll():Void {
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [1];
		var changed = false;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._treeGridView.dataProvider.removeAll();
		Assert.isTrue(changed);
		Assert.equals(null, this._treeGridView.selectedLocation);
		Assert.isNull(this._treeGridView.selectedItem);
	}

	public function testDeselectAllOnNewDataProvider():Void {
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [1];
		var changed = false;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		Assert.isTrue(changed);
		Assert.equals(null, this._treeGridView.selectedLocation);
		Assert.isNull(this._treeGridView.selectedItem);
	}

	public function testUpdateItemSetsInterfaceProperties():Void {
		var children:Array<Dynamic> = [{text: "One"}, {text: "Two", children: []}, {text: "Three"}];
		var items:Array<Dynamic> = [{text: "A", children: children}];
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection(items, (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		var itemLocation = [0, 1];
		var item = this._treeGridView.dataProvider.get(itemLocation);
		this._treeGridView.selectedLocation = itemLocation;
		this._treeGridView.toggleBranch(this._treeGridView.dataProvider.get([0]), true);
		this._treeGridView.toggleBranch(item, true);
		this._treeGridView.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._treeGridView.validateNow();
		var sampleItemRenderer = cast(this._treeGridView.itemAndColumnToCellRenderer(item, textColumn), CustomRendererWithInterfaces);
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		var setColumnValues = sampleItemRenderer.setColumnValues;
		var setColumnIndexValues = sampleItemRenderer.setColumnIndexValues;
		var setSelectedValues = sampleItemRenderer.setSelectedValues;
		var setRowLocationValues = sampleItemRenderer.setRowLocationValues;
		var setOpenedValues = sampleItemRenderer.setOpenedValues;
		var setBranchValues = sampleItemRenderer.setBranchValues;
		var setTreeGridViewOwnerValues = sampleItemRenderer.setTreeGridViewOwnerValues;
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);
		Assert.equals(1, setColumnValues.length);
		Assert.equals(1, setColumnIndexValues.length);
		Assert.equals(1, setSelectedValues.length);
		Assert.equals(1, setRowLocationValues.length);
		Assert.equals(1, setOpenedValues.length);
		Assert.equals(1, setBranchValues.length);
		Assert.equals(1, setTreeGridViewOwnerValues.length);

		this._treeGridView.dataProvider.updateAt(itemLocation);

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

		Assert.equals(3, setRowLocationValues.length);
		Assert.equals(0, CompareLocations.compareLocations(itemLocation, setRowLocationValues[0]));
		Assert.isNull(setRowLocationValues[1]);
		Assert.equals(0, CompareLocations.compareLocations(itemLocation, setRowLocationValues[2]));

		Assert.equals(3, setBranchValues.length);
		Assert.equals(true, setBranchValues[0]);
		Assert.equals(false, setBranchValues[1]);
		Assert.equals(true, setBranchValues[2]);

		Assert.equals(3, setOpenedValues.length);
		Assert.equals(true, setOpenedValues[0]);
		Assert.equals(false, setOpenedValues[1]);
		Assert.equals(true, setOpenedValues[2]);

		Assert.equals(3, setTreeGridViewOwnerValues.length);
		Assert.equals(this._treeGridView, setTreeGridViewOwnerValues[0]);
		Assert.isNull(setTreeGridViewOwnerValues[1]);
		Assert.equals(this._treeGridView, setTreeGridViewOwnerValues[2]);
	}

	public function testDefaultItemStateUpdate():Void {
		var updatedLocations:Array<Array<Int>> = [];
		var updatedColumns:Array<Int> = [];
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._treeGridView.cellRendererRecycler = DisplayObjectRecycler.withClass(HierarchicalItemRenderer, (target, state:TreeGridViewCellState) -> {
			updatedLocations.push(state.rowLocation);
			updatedColumns.push(state.columnIndex);
		});
		this._treeGridView.columns = new ArrayCollection([
			new TreeGridViewColumn("A", item -> item.a),
			new TreeGridViewColumn("B", item -> item.b),
		]);
		this._treeGridView.validateNow();
		Assert.equals(6, updatedLocations.length);
		Assert.equals(0, CompareLocations.compareLocations([0], updatedLocations[0]));
		Assert.equals(0, CompareLocations.compareLocations([0], updatedLocations[1]));
		Assert.equals(0, CompareLocations.compareLocations([1], updatedLocations[2]));
		Assert.equals(0, CompareLocations.compareLocations([1], updatedLocations[3]));
		Assert.equals(0, CompareLocations.compareLocations([2], updatedLocations[4]));
		Assert.equals(0, CompareLocations.compareLocations([2], updatedLocations[5]));
		Assert.equals(6, updatedColumns.length);
		Assert.equals(0, updatedColumns[0]);
		Assert.equals(1, updatedColumns[1]);
		Assert.equals(0, updatedColumns[2]);
		Assert.equals(1, updatedColumns[3]);
		Assert.equals(0, updatedColumns[4]);
		Assert.equals(1, updatedColumns[5]);
		this._treeGridView.setInvalid(DATA);
		this._treeGridView.validateNow();
		Assert.equals(6, updatedLocations.length);
		Assert.equals(6, updatedColumns.length);
	}

	public function testAddItemToDataProviderCreatesNewItemRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([item1]);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.validateNow();
		Assert.notNull(this._treeGridView.itemAndColumnToCellRenderer(item1, textColumn));
		Assert.isNull(this._treeGridView.itemAndColumnToCellRenderer(item2, textColumn));
		this._treeGridView.dataProvider.addAt(item2, [1]);
		this._treeGridView.validateNow();
		Assert.notNull(this._treeGridView.itemAndColumnToCellRenderer(item1, textColumn));
		Assert.notNull(this._treeGridView.itemAndColumnToCellRenderer(item2, textColumn));
	}

	public function testRemoveItemFromDataProviderDestroysItemRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([item1, item2]);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.validateNow();
		Assert.notNull(this._treeGridView.itemAndColumnToCellRenderer(item1, textColumn));
		Assert.notNull(this._treeGridView.itemAndColumnToCellRenderer(item2, textColumn));
		this._treeGridView.dataProvider.remove(item2);
		this._treeGridView.validateNow();
		Assert.notNull(this._treeGridView.itemAndColumnToCellRenderer(item1, textColumn));
		Assert.isNull(this._treeGridView.itemAndColumnToCellRenderer(item2, textColumn));
	}

	public function testAddItemBeforeSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.addAt(item3, [0, 0]);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 2], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], this._treeGridView.selectedLocation));
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._treeGridView.selectedItem);
	}

	public function testAddItemAtSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.addAt(item3, [0, 1]);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 2], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 2], this._treeGridView.selectedLocation));
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._treeGridView.selectedItem);
	}

	public function testAddItemAfterSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.addAt(item3, [0, 2]);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.isNull(eventItem);
		Assert.equals(item2, this._treeGridView.selectedItem);
	}

	public function testRemoveItemBeforeSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.removeAt([0, 0]);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 0], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 0], this._treeGridView.selectedLocation));
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._treeGridView.selectedItem);
	}

	public function testRemoveItemAtSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.removeAt([0, 1]);
		Assert.isTrue(changed);
		Assert.isNull(eventLocation);
		Assert.isNull(this._treeGridView.selectedLocation);
		Assert.isNull(eventItem);
		Assert.isNull(this._treeGridView.selectedItem);
	}

	public function testRemoveItemAfterSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.removeAt([0, 2]);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.isNull(eventItem);
		Assert.equals(item2, this._treeGridView.selectedItem);
	}

	public function testReplaceItemBeforeSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.set([0, 0], item4);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.isNull(eventItem);
		Assert.equals(item2, this._treeGridView.selectedItem);
	}

	public function testReplaceItemAtSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.set([0, 1], item4);
		Assert.isTrue(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], eventLocation));
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._treeGridView.selectedItem);
	}

	public function testReplaceParentOfSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection(([branch] : Array<Dynamic>), (item:Dynamic) -> item.children);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.set([0], item4);
		Assert.isTrue(changed);
		Assert.isNull(eventLocation);
		Assert.isNull(this._treeGridView.selectedLocation);
		Assert.isNull(eventItem);
		Assert.isNull(this._treeGridView.selectedItem);
	}

	public function testReplaceItemAfterSelectedLocation():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		var textColumn = new TreeGridViewColumn("Text", item -> item.text);
		this._treeGridView.columns = new ArrayCollection([textColumn]);
		this._treeGridView.selectedLocation = [0, 1];
		this._treeGridView.validateNow();
		var changed = false;
		var eventLocation:Array<Int> = null;
		var eventItem = null;
		this._treeGridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventLocation = this._treeGridView.selectedLocation;
			eventItem = this._treeGridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.equals(item2, this._treeGridView.selectedItem);
		this._treeGridView.dataProvider.set([0, 2], item4);
		Assert.isFalse(changed);
		Assert.isNull(eventLocation);
		Assert.equals(0, CompareLocations.compareLocations([0, 1], this._treeGridView.selectedLocation));
		Assert.isNull(eventItem);
		Assert.equals(item2, this._treeGridView.selectedItem);
	}

	public function testRemoveItemAtOpenedBranch():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		var dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._treeGridView.dataProvider = dataProvider;
		this._treeGridView.toggleBranch(branch, true);
		Assert.isTrue(this._treeGridView.isBranchOpen(branch));
		dataProvider.remove(branch);
		Assert.isFalse(this._treeGridView.isBranchOpen(branch));
	}

	public function testRemoveParentOfOpenedBranch():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var childBranch = {text: "Child Branch", children: [item2, item3]}
		var branch = {text: "Branch", children: ([item1, childBranch] : Array<Dynamic>)};
		var dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._treeGridView.dataProvider = dataProvider;
		this._treeGridView.toggleBranch(branch, true);
		this._treeGridView.toggleBranch(childBranch, true);
		Assert.isTrue(this._treeGridView.isBranchOpen(branch));
		Assert.isTrue(this._treeGridView.isBranchOpen(childBranch));
		dataProvider.remove(branch);
		Assert.isFalse(this._treeGridView.isBranchOpen(branch));
		Assert.isFalse(this._treeGridView.isBranchOpen(childBranch));
	}

	public function testRemoveAllWithOpenedBranch():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		var dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._treeGridView.dataProvider = dataProvider;
		this._treeGridView.toggleBranch(branch, true);
		Assert.isTrue(this._treeGridView.isBranchOpen(branch));
		dataProvider.removeAll();
		Assert.isFalse(this._treeGridView.isBranchOpen(branch));
	}

	public function testResetWithOpenedBranch():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		var dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._treeGridView.dataProvider = dataProvider;
		this._treeGridView.toggleBranch(branch, true);
		Assert.isTrue(this._treeGridView.isBranchOpen(branch));
		dataProvider.array = [];
		Assert.isFalse(this._treeGridView.isBranchOpen(branch));
	}

	public function testNewDataProviderWithOpenedBranch():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var branch = {text: "Branch", children: [item1, item2, item3]};
		var dataProvider = new ArrayHierarchicalCollection([branch], (item:Dynamic) -> item.children);
		this._treeGridView.dataProvider = dataProvider;
		this._treeGridView.toggleBranch(branch, true);
		Assert.isTrue(this._treeGridView.isBranchOpen(branch));
		this._treeGridView.dataProvider = new ArrayHierarchicalCollection([], (item:Dynamic) -> item.children);
		Assert.isFalse(this._treeGridView.isBranchOpen(branch));
	}
}

private class CustomRendererWithInterfaces extends LayoutGroup implements IToggle implements IOpenCloseToggle implements IDataRenderer
		implements ILayoutIndexObject implements ITreeGridViewCellRenderer {
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

	public var setRowLocationValues:Array<Array<Int>> = [];

	private var _rowLocation:Array<Int> = null;

	public var rowLocation(get, set):Array<Int>;

	private function get_rowLocation():Array<Int> {
		return _rowLocation;
	}

	private function set_rowLocation(value:Array<Int>):Array<Int> {
		if (CompareLocations.compareLocations(_rowLocation, value) == 0) {
			return _rowLocation;
		}
		_rowLocation = value;
		setRowLocationValues.push(value);
		return _rowLocation;
	}

	public var setColumnIndexValues:Array<Int> = [];

	private var _columnIndex:Int = -1;

	public var columnIndex(get, set):Int;

	private function get_columnIndex():Int {
		return _columnIndex;
	}

	private function set_columnIndex(value:Int):Int {
		if (_columnIndex == value) {
			return _columnIndex;
		}
		_columnIndex = value;
		setColumnIndexValues.push(value);
		return _columnIndex;
	}

	public var setColumnValues:Array<TreeGridViewColumn> = [];

	private var _column:TreeGridViewColumn;

	public var column(get, set):TreeGridViewColumn;

	private function get_column():TreeGridViewColumn {
		return _column;
	}

	private function set_column(value:TreeGridViewColumn):TreeGridViewColumn {
		if (_column == value) {
			return _column;
		}
		_column = value;
		setColumnValues.push(value);
		return _column;
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

	public var setBranchValues:Array<Bool> = [];

	private var _branch:Bool;

	public var branch(get, set):Bool;

	private function get_branch():Bool {
		return _branch;
	}

	private function set_branch(value:Bool):Bool {
		if (_branch == value) {
			return _branch;
		}
		_branch = value;
		setBranchValues.push(value);
		return _branch;
	}

	public var setOpenedValues:Array<Bool> = [];

	private var _opened:Bool;

	public var opened(get, set):Bool;

	private function get_opened():Bool {
		return _opened;
	}

	private function set_opened(value:Bool):Bool {
		if (_opened == value) {
			return _opened;
		}
		_opened = value;
		setOpenedValues.push(value);
		return _opened;
	}

	public var setTreeGridViewOwnerValues:Array<TreeGridView> = [];

	private var _treeGridViewOwner:TreeGridView;

	public var treeGridViewOwner(get, set):TreeGridView;

	private function get_treeGridViewOwner():TreeGridView {
		return _treeGridViewOwner;
	}

	private function set_treeGridViewOwner(value:TreeGridView):TreeGridView {
		if (_treeGridViewOwner == value) {
			return _treeGridViewOwner;
		}
		_treeGridViewOwner = value;
		setTreeGridViewOwnerValues.push(value);
		return _treeGridViewOwner;
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
