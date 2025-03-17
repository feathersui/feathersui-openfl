/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import feathers.events.TriggerEvent;
import feathers.events.GridViewEvent;
import openfl.errors.RangeError;
import feathers.skins.RectangleSkin;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.IGridViewCellRenderer;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.events.ScrollEvent;
import feathers.layout.ILayoutIndexObject;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class GridViewTest extends Test {
	private var _gridView:GridView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._gridView = new GridView();
		Lib.current.addChild(this._gridView);
	}

	public function teardown():Void {
		if (this._gridView.parent != null) {
			this._gridView.parent.removeChild(this._gridView);
		}
		this._gridView = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._gridView.validateNow();
		Assert.pass();
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._gridView.validateNow();
		this._gridView.dispose();
		this._gridView.dispose();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.validateNow();
		this._gridView.dataProvider = null;
		this._gridView.validateNow();
		Assert.pass();
	}

	public function testItemAndColumnToCellRenderer():Void {
		var collection = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		var columns = new ArrayCollection([new GridViewColumn("A", item -> item.a), new GridViewColumn("B", item -> item.b)]);
		this._gridView.columns = columns;
		this._gridView.dataProvider = collection;
		this._gridView.validateNow();
		var itemRenderer00 = this._gridView.itemAndColumnToCellRenderer(collection.get(0), columns.get(0));
		Assert.notNull(itemRenderer00);
		Assert.isOfType(itemRenderer00, ItemRenderer);
		var itemRenderer01 = this._gridView.itemAndColumnToCellRenderer(collection.get(0), columns.get(1));
		Assert.notNull(itemRenderer01);
		Assert.isOfType(itemRenderer01, ItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer01);
		var itemRenderer10 = this._gridView.itemAndColumnToCellRenderer(collection.get(1), columns.get(0));
		Assert.notNull(itemRenderer10);
		Assert.isOfType(itemRenderer10, ItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer10);
		Assert.notEquals(itemRenderer01, itemRenderer10);
		var itemRenderer11 = this._gridView.itemAndColumnToCellRenderer(collection.get(1), columns.get(1));
		Assert.notNull(itemRenderer11);
		Assert.isOfType(itemRenderer11, ItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer11);
		Assert.notEquals(itemRenderer01, itemRenderer11);
		Assert.notEquals(itemRenderer10, itemRenderer11);
		var itemRenderer20 = this._gridView.itemAndColumnToCellRenderer(collection.get(2), columns.get(0));
		Assert.notNull(itemRenderer20);
		Assert.isOfType(itemRenderer20, ItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer20);
		Assert.notEquals(itemRenderer01, itemRenderer20);
		Assert.notEquals(itemRenderer10, itemRenderer20);
		Assert.notEquals(itemRenderer11, itemRenderer20);
		var itemRenderer21 = this._gridView.itemAndColumnToCellRenderer(collection.get(2), columns.get(1));
		Assert.notNull(itemRenderer21);
		Assert.isOfType(itemRenderer21, ItemRenderer);
		Assert.notEquals(itemRenderer00, itemRenderer21);
		Assert.notEquals(itemRenderer01, itemRenderer21);
		Assert.notEquals(itemRenderer10, itemRenderer21);
		Assert.notEquals(itemRenderer11, itemRenderer21);
		Assert.notEquals(itemRenderer20, itemRenderer21);
	}

	public function testItemToText():Void {
		var collection = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		var columns = new ArrayCollection([new GridViewColumn("A", item -> item.a), new GridViewColumn("B", item -> item.b)]);
		this._gridView.columns = columns;
		this._gridView.dataProvider = collection;
		this._gridView.validateNow();
		var itemRenderer00 = this._gridView.itemAndColumnToCellRenderer(collection.get(0), columns.get(0));
		Assert.notNull(itemRenderer00);
		Assert.isOfType(itemRenderer00, ItemRenderer);
		Assert.equals("A0", cast(itemRenderer00, ItemRenderer).text);
		var itemRenderer01 = this._gridView.itemAndColumnToCellRenderer(collection.get(0), columns.get(1));
		Assert.notNull(itemRenderer01);
		Assert.isOfType(itemRenderer01, ItemRenderer);
		Assert.equals("B0", cast(itemRenderer01, ItemRenderer).text);
		var itemRenderer10 = this._gridView.itemAndColumnToCellRenderer(collection.get(1), columns.get(0));
		Assert.notNull(itemRenderer10);
		Assert.isOfType(itemRenderer10, ItemRenderer);
		Assert.equals("A1", cast(itemRenderer10, ItemRenderer).text);
		var itemRenderer11 = this._gridView.itemAndColumnToCellRenderer(collection.get(1), columns.get(1));
		Assert.notNull(itemRenderer11);
		Assert.isOfType(itemRenderer11, ItemRenderer);
		Assert.equals("B1", cast(itemRenderer11, ItemRenderer).text);
		var itemRenderer20 = this._gridView.itemAndColumnToCellRenderer(collection.get(2), columns.get(0));
		Assert.notNull(itemRenderer20);
		Assert.isOfType(itemRenderer20, ItemRenderer);
		Assert.equals("A2", cast(itemRenderer20, ItemRenderer).text);
		var itemRenderer21 = this._gridView.itemAndColumnToCellRenderer(collection.get(2), columns.get(1));
		Assert.notNull(itemRenderer21);
		Assert.isOfType(itemRenderer21, ItemRenderer);
		Assert.equals("B2", cast(itemRenderer21, ItemRenderer).text);
		var itemRendererNull = this._gridView.itemAndColumnToCellRenderer(null, columns.get(0));
		Assert.isNull(itemRendererNull);
	}

	public function testCellRendererRecycler():Void {
		var createCount = 0;
		var updateCount = 0;
		var resetCount = 0;
		var destroyCount = 0;
		this._gridView.cellRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			createCount++;
			return new ItemRenderer();
		}, (target:ItemRenderer, state:GridViewCellState) -> {
			updateCount++;
		}, (target:ItemRenderer, state:GridViewCellState) -> {
			resetCount++;
		}, (target:ItemRenderer) -> {
			destroyCount++;
		});
		var collection = new ArrayCollection([{a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		var columns = new ArrayCollection([new GridViewColumn("A", data -> data.a), new GridViewColumn("B", data -> data.b)]);
		this._gridView.dataProvider = collection;
		this._gridView.columns = columns;
		this._gridView.validateNow();
		Assert.equals(4, createCount);
		Assert.equals(4, updateCount);
		Assert.equals(0, resetCount);
		Assert.equals(0, destroyCount);
		collection.removeAt(1);
		this._gridView.validateNow();
		Assert.equals(4, createCount);
		Assert.equals(4, updateCount);
		Assert.equals(2, resetCount);
		Assert.equals(2, destroyCount);
		collection.add({a: "New A1", b: "New B1"});
		this._gridView.validateNow();
		Assert.equals(6, createCount);
		Assert.equals(6, updateCount);
		Assert.equals(2, resetCount);
		Assert.equals(2, destroyCount);
		collection.set(1, {a: "New A2", b: "New B2"});
		this._gridView.validateNow();
		Assert.equals(6, createCount);
		Assert.equals(8, updateCount);
		Assert.equals(2, resetCount);
		Assert.equals(2, destroyCount);
		this._gridView.dataProvider = null;
		this._gridView.validateNow();
		Assert.equals(6, createCount);
		Assert.equals(8, updateCount);
		Assert.equals(6, resetCount);
		Assert.equals(6, destroyCount);
	}

	public function testValidateWithAutoPopulatedColumns():Void {
		this._gridView.dataProvider = new ArrayCollection([
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
		this._gridView.validateNow();
		Assert.equals(2, this._gridView.columns.length);
		var column0 = this._gridView.columns.get(0);
		var column1 = this._gridView.columns.get(1);
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
		this._gridView.dataProvider = new ArrayCollection(([
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
		this._gridView.validateNow();
		Assert.pass();
	}

	public function testExceptionOnInvalidNegativeSelectedIndex():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.raises(() -> {
			this._gridView.selectedIndex = -2;
		}, RangeError);
	}

	public function testExceptionOnInvalidTooLargeSelectedIndex():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.raises(() -> {
			this._gridView.selectedIndex = 3;
		}, RangeError);
	}

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

	public function testSelectedItemAfterSetSelectedIndex():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.isNull(this._gridView.selectedItem);
		this._gridView.selectedIndex = 1;
		Assert.equals(this._gridView.dataProvider.get(1), this._gridView.selectedItem);
	}

	public function testSelectedIndexAfterSetSelectedItem():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		Assert.equals(-1, this._gridView.selectedIndex);
		this._gridView.selectedItem = this._gridView.dataProvider.get(1);
		Assert.equals(1, this._gridView.selectedIndex);
	}

	public function testDeselectAllOnNullDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.selectedIndex = 1;
		var changed = false;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._gridView.dataProvider = null;
		Assert.isTrue(changed);
		Assert.equals(-1, this._gridView.selectedIndex);
		Assert.isNull(this._gridView.selectedItem);
	}

	public function testResetScrollOnNullDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.scrollX = 10.0;
		this._gridView.scrollY = 10.0;
		var scrolled = false;
		this._gridView.addEventListener(ScrollEvent.SCROLL, function(event:ScrollEvent):Void {
			scrolled = true;
		});
		Assert.isFalse(scrolled);
		this._gridView.dataProvider = null;
		Assert.isTrue(scrolled);
		Assert.equals(0.0, this._gridView.scrollX);
		Assert.equals(0.0, this._gridView.scrollY);
	}

	public function testDeselectAllOnDataProviderRemoveAll():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.selectedIndex = 1;
		var changed = false;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._gridView.dataProvider.removeAll();
		Assert.isTrue(changed);
		Assert.equals(-1, this._gridView.selectedIndex);
		Assert.isNull(this._gridView.selectedItem);
	}

	public function testDeselectAllOnNewDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.selectedIndex = 1;
		var changed = false;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._gridView.dataProvider = new ArrayCollection([{text: "Three"}, {text: "Four"}, {text: "Five"}]);
		Assert.isTrue(changed);
		Assert.equals(-1, this._gridView.selectedIndex);
		Assert.isNull(this._gridView.selectedItem);
	}

	public function testUpdateItemSetsInterfaceProperties():Void {
		this._gridView.width = 300;
		this._gridView.height = 300;
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.columns = new ArrayCollection([new GridViewColumn("Text", item -> item.text)]);
		var rowIndex = 1;
		var columnIndex = 0;
		var item = this._gridView.dataProvider.get(rowIndex);
		var column = this._gridView.columns.get(columnIndex);
		this._gridView.selectedIndex = rowIndex;
		this._gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._gridView.validateNow();
		var sampleItemRenderer = cast(this._gridView.itemAndColumnToCellRenderer(item, column), CustomRendererWithInterfaces);
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		var setSelectedValues = sampleItemRenderer.setSelectedValues;
		var setRowIndexValues = sampleItemRenderer.setRowIndexValues;
		var setColumnIndexValues = sampleItemRenderer.setColumnIndexValues;
		var setColumnValues = sampleItemRenderer.setColumnValues;
		var setGridViewOwnerValues = sampleItemRenderer.setGridViewOwnerValues;
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);
		Assert.equals(1, setSelectedValues.length);
		Assert.equals(1, setRowIndexValues.length);
		Assert.equals(1, setColumnIndexValues.length);
		Assert.equals(1, setColumnValues.length);
		Assert.equals(1, setGridViewOwnerValues.length);

		this._gridView.dataProvider.updateAt(rowIndex);
		this._gridView.validateNow();

		Assert.equals(3, setDataValues.length);
		Assert.equals(item, setDataValues[0]);
		Assert.isNull(setDataValues[1]);
		Assert.equals(item, setDataValues[2]);

		Assert.equals(3, setLayoutIndexValues.length);
		Assert.equals(rowIndex, setLayoutIndexValues[0]);
		Assert.equals(-1, setLayoutIndexValues[1]);
		Assert.equals(rowIndex, setLayoutIndexValues[2]);

		Assert.equals(3, setSelectedValues.length);
		Assert.equals(true, setSelectedValues[0]);
		Assert.equals(false, setSelectedValues[1]);
		Assert.equals(true, setSelectedValues[2]);

		Assert.equals(3, setRowIndexValues.length);
		Assert.equals(rowIndex, setRowIndexValues[0]);
		Assert.equals(-1, setRowIndexValues[1]);
		Assert.equals(rowIndex, setRowIndexValues[2]);

		Assert.equals(3, setColumnIndexValues.length);
		Assert.equals(columnIndex, setColumnIndexValues[0]);
		Assert.equals(-1, setColumnIndexValues[1]);
		Assert.equals(columnIndex, setColumnIndexValues[2]);

		Assert.equals(3, setColumnValues.length);
		Assert.equals(column, setColumnValues[0]);
		Assert.isNull(setColumnValues[1]);
		Assert.equals(column, setColumnValues[2]);

		Assert.equals(3, setGridViewOwnerValues.length);
		Assert.equals(this._gridView, setGridViewOwnerValues[0]);
		Assert.isNull(setGridViewOwnerValues[1]);
		Assert.equals(this._gridView, setGridViewOwnerValues[2]);
	}

	public function testDefaultItemStateUpdate():Void {
		var updatedRows:Array<Int> = [];
		var updatedColumns:Array<Int> = [];
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		this._gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			updatedRows.push(state.rowIndex);
			updatedColumns.push(state.columnIndex);
		});
		this._gridView.validateNow();
		Assert.equals(6, updatedRows.length);
		Assert.equals(0, updatedRows[0]);
		Assert.equals(0, updatedRows[1]);
		Assert.equals(1, updatedRows[2]);
		Assert.equals(1, updatedRows[3]);
		Assert.equals(2, updatedRows[4]);
		Assert.equals(2, updatedRows[5]);
		Assert.equals(6, updatedColumns.length);
		Assert.equals(0, updatedColumns[0]);
		Assert.equals(1, updatedColumns[1]);
		Assert.equals(0, updatedColumns[2]);
		Assert.equals(1, updatedColumns[3]);
		Assert.equals(0, updatedColumns[4]);
		Assert.equals(1, updatedColumns[5]);
		this._gridView.setInvalid(DATA);
		this._gridView.validateNow();
		Assert.equals(6, updatedRows.length);
		Assert.equals(6, updatedColumns.length);
	}

	public function testUpdateItemCallsDisplayObjectRecyclerUpdate():Void {
		var updatedRows:Array<Int> = [];
		var updatedColumns:Array<Int> = [];
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		this._gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			updatedRows.push(state.rowIndex);
			updatedColumns.push(state.columnIndex);
		});
		this._gridView.validateNow();
		Assert.equals(6, updatedRows.length);
		Assert.equals(0, updatedRows[0]);
		Assert.equals(0, updatedRows[1]);
		Assert.equals(1, updatedRows[2]);
		Assert.equals(1, updatedRows[3]);
		Assert.equals(2, updatedRows[4]);
		Assert.equals(2, updatedRows[5]);
		Assert.equals(6, updatedColumns.length);
		Assert.equals(0, updatedColumns[0]);
		Assert.equals(1, updatedColumns[1]);
		Assert.equals(0, updatedColumns[2]);
		Assert.equals(1, updatedColumns[3]);
		Assert.equals(0, updatedColumns[4]);
		Assert.equals(1, updatedColumns[5]);
		this._gridView.dataProvider.updateAt(1);
		this._gridView.validateNow();
		Assert.equals(8, updatedRows.length);
		Assert.equals(1, updatedRows[6]);
		Assert.equals(1, updatedRows[7]);
		Assert.equals(8, updatedColumns.length);
		Assert.equals(0, updatedColumns[6]);
		Assert.equals(1, updatedColumns[7]);
	}

	public function testUpdateAllCallsDisplayObjectRecyclerUpdate():Void {
		var updatedRows:Array<Int> = [];
		var updatedColumns:Array<Int> = [];
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		this._gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer, (target, state:GridViewCellState) -> {
			updatedRows.push(state.rowIndex);
			updatedColumns.push(state.columnIndex);
		});
		this._gridView.validateNow();
		Assert.equals(6, updatedRows.length);
		Assert.equals(0, updatedRows[0]);
		Assert.equals(0, updatedRows[1]);
		Assert.equals(1, updatedRows[2]);
		Assert.equals(1, updatedRows[3]);
		Assert.equals(2, updatedRows[4]);
		Assert.equals(2, updatedRows[5]);
		Assert.equals(6, updatedColumns.length);
		Assert.equals(0, updatedColumns[0]);
		Assert.equals(1, updatedColumns[1]);
		Assert.equals(0, updatedColumns[2]);
		Assert.equals(1, updatedColumns[3]);
		Assert.equals(0, updatedColumns[4]);
		Assert.equals(1, updatedColumns[5]);
		this._gridView.dataProvider.updateAll();
		this._gridView.validateNow();
		Assert.equals(12, updatedRows.length);
		Assert.equals(0, updatedRows[6]);
		Assert.equals(0, updatedRows[7]);
		Assert.equals(1, updatedRows[8]);
		Assert.equals(1, updatedRows[9]);
		Assert.equals(2, updatedRows[10]);
		Assert.equals(2, updatedRows[11]);
		Assert.equals(12, updatedColumns.length);
		Assert.equals(0, updatedColumns[6]);
		Assert.equals(1, updatedColumns[7]);
		Assert.equals(0, updatedColumns[8]);
		Assert.equals(1, updatedColumns[9]);
		Assert.equals(0, updatedColumns[10]);
		Assert.equals(1, updatedColumns[11]);
	}

	public function testAddItemToDataProviderCreatesNewCellRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._gridView.dataProvider = new ArrayCollection([item1]);
		var column1 = new GridViewColumn("text", item -> item.text);
		this._gridView.columns = new ArrayCollection([column1]);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.isNull(this._gridView.itemAndColumnToCellRenderer(item2, column1));
		this._gridView.dataProvider.add(item2);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item2, column1));
	}

	public function testRemoveItemFromDataProviderDestroysCellRenderer():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2]);
		var column1 = new GridViewColumn("text", item -> item.text);
		this._gridView.columns = new ArrayCollection([column1]);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item2, column1));
		this._gridView.dataProvider.remove(item2);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.isNull(this._gridView.itemAndColumnToCellRenderer(item2, column1));
	}

	public function testAddColumnCreatesNewCellRenderer():Void {
		var item1 = {text: "One", value: 1};
		this._gridView.dataProvider = new ArrayCollection([item1]);
		var column1 = new GridViewColumn("text", item -> item.text);
		var column2 = new GridViewColumn("value", item -> Std.string(item.value));
		this._gridView.columns = new ArrayCollection([column1]);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.isNull(this._gridView.itemAndColumnToCellRenderer(item1, column2));
		this._gridView.columns.add(column2);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column2));
	}

	public function testRemoveColumnDestroysCellRenderer():Void {
		var item1 = {text: "One", value: 1};
		this._gridView.dataProvider = new ArrayCollection([item1]);
		var column1 = new GridViewColumn("text", item -> item.text);
		var column2 = new GridViewColumn("value", item -> Std.string(item.value));
		this._gridView.columns = new ArrayCollection([column1, column2]);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column2));
		this._gridView.columns.remove(column2);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.itemAndColumnToCellRenderer(item1, column1));
		Assert.isNull(this._gridView.itemAndColumnToCellRenderer(item1, column2));
	}

	public function testAddColumnCreatesNewHeaderRenderer():Void {
		var item1 = {text: "One", value: 1};
		this._gridView.dataProvider = new ArrayCollection([item1]);
		var column1 = new GridViewColumn("text", item -> item.text);
		var column2 = new GridViewColumn("value", item -> Std.string(item.value));
		this._gridView.columns = new ArrayCollection([column1]);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.columnToHeaderRenderer(column1));
		Assert.isNull(this._gridView.columnToHeaderRenderer(column2));
		this._gridView.columns.add(column2);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.columnToHeaderRenderer(column1));
		Assert.notNull(this._gridView.columnToHeaderRenderer(column2));
	}

	public function testRemoveColumnDestroysHeaderRenderer():Void {
		var item1 = {text: "One", value: 1};
		this._gridView.dataProvider = new ArrayCollection([item1]);
		var column1 = new GridViewColumn("text", item -> item.text);
		var column2 = new GridViewColumn("value", item -> Std.string(item.value));
		this._gridView.columns = new ArrayCollection([column1, column2]);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.columnToHeaderRenderer(column1));
		Assert.notNull(this._gridView.columnToHeaderRenderer(column2));
		this._gridView.columns.remove(column2);
		this._gridView.validateNow();
		Assert.notNull(this._gridView.columnToHeaderRenderer(column1));
		Assert.isNull(this._gridView.columnToHeaderRenderer(column2));
	}

	public function testAddItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.addAt(item3, 0);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._gridView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(eventIndices.length == 1);
		Assert.equals(2, eventIndices[0]);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(2, this._gridView.selectedIndices[0]);
		Assert.isTrue(eventItems.length == 1);
		Assert.equals(item2, eventItems[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
	}

	public function testAddItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.addAt(item3, 1);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._gridView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(eventIndices.length == 1);
		Assert.equals(2, eventIndices[0]);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(2, this._gridView.selectedIndices[0]);
		Assert.isTrue(eventItems.length == 1);
		Assert.equals(item2, eventItems[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
	}

	public function testAddItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.addAt(item3, 2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isNull(eventIndices);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isNull(eventItems);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
	}

	public function testRemoveItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.removeAt(0);
		Assert.isTrue(changed);
		Assert.equals(0, eventIndex);
		Assert.equals(0, this._gridView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(eventIndices.length == 1);
		Assert.equals(0, eventIndices[0]);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(0, this._gridView.selectedIndices[0]);
		Assert.isTrue(eventItems.length == 1);
		Assert.equals(item2, eventItems[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
	}

	public function testRemoveItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.removeAt(1);
		Assert.isTrue(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(-1, this._gridView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.isNull(this._gridView.selectedItem);
		Assert.isTrue(eventIndices.length == 0);
		Assert.isTrue(this._gridView.selectedIndices.length == 0);
		Assert.isTrue(eventItems.length == 0);
		Assert.isTrue(this._gridView.selectedItems.length == 0);
	}

	public function testRemoveItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.removeAt(2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isNull(eventIndices);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isNull(eventItems);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
	}

	public function testReplaceItemBeforeSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.set(0, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isNull(eventIndices);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isNull(eventItems);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
	}

	public function testReplaceItemAtSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.set(1, item4);
		Assert.isTrue(changed);
		Assert.equals(1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._gridView.selectedItem);
		Assert.equals(1, eventIndices[0]);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(eventItems.length == 1);
		Assert.equals(item4, eventItems[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item4, this._gridView.selectedItems[0]);
	}

	public function testReplaceItemAfterSelectedIndex():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		var item3 = {text: "Three"};
		var item4 = {text: "Four"};
		this._gridView.dataProvider = new ArrayCollection([item1, item2, item3]);
		this._gridView.selectedIndex = 1;
		this._gridView.validateNow();
		var changed = false;
		var eventIndex:Int = -1;
		var eventItem = null;
		var eventIndices:Array<Int> = null;
		var eventItems:Array<Dynamic> = null;
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
			eventIndices = this._gridView.selectedIndices.copy();
			eventItems = this._gridView.selectedItems.copy();
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
		this._gridView.dataProvider.set(2, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.isNull(eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
		Assert.isNull(eventIndices);
		Assert.isTrue(this._gridView.selectedIndices.length == 1);
		Assert.equals(1, this._gridView.selectedIndices[0]);
		Assert.isNull(eventItems);
		Assert.isTrue(this._gridView.selectedItems.length == 1);
		Assert.equals(item2, this._gridView.selectedItems[0]);
	}

	public function testDefaultTextUpdateForColumnRecyclers():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}]);
		var column1 = new GridViewColumn("1", item -> item.text);
		column1.cellRendererRecycler = DisplayObjectRecycler.withClass(ItemRenderer);
		this._gridView.columns = new ArrayCollection([column1]);
		this._gridView.validateNow();
		var itemRenderer = cast(this._gridView.itemAndColumnToCellRenderer(this._gridView.dataProvider.get(0), column1), ItemRenderer);
		Assert.notNull(itemRenderer);
		Assert.equals("One", itemRenderer.text);
	}

	public function testDefaultTextUpdateForAdditionalColumnRecyclers():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}]);
		var column1 = new GridViewColumn("1", item -> item.text);
		column1.setCellRendererRecycler("other", DisplayObjectRecycler.withClass(ItemRenderer));
		column1.cellRendererRecyclerIDFunction = (state) -> {
			return "other";
		};
		this._gridView.columns = new ArrayCollection([column1]);
		this._gridView.validateNow();
		var itemRenderer = cast(this._gridView.itemAndColumnToCellRenderer(this._gridView.dataProvider.get(0), column1), ItemRenderer);
		Assert.notNull(itemRenderer);
		Assert.equals("One", itemRenderer.text);
	}

	// ensures that the new index of the existing column doesn't result in a range error
	// and that columns are displayed in the correct order
	public function testInsertExtraColumnAtBeginning():Void {
		this._gridView.dataProvider = new ArrayCollection([{one: "One", two: "Two"}]);
		var column1 = new GridViewColumn("1", item -> item.one);
		var column2 = new GridViewColumn("2", item -> item.two);
		this._gridView.columns = new ArrayCollection([column1]);
		this._gridView.validateNow();
		var itemRenderer1 = cast(this._gridView.itemAndColumnToCellRenderer(this._gridView.dataProvider.get(0), column1), ItemRenderer);
		Assert.notNull(itemRenderer1);
		Assert.equals("One", itemRenderer1.text);
		Assert.equals(0, itemRenderer1.parent.getChildIndex(itemRenderer1));

		this._gridView.columns.addAt(column2, 0);
		this._gridView.validateNow();
		var itemRenderer2 = cast(this._gridView.itemAndColumnToCellRenderer(this._gridView.dataProvider.get(0), column2), ItemRenderer);
		Assert.notNull(itemRenderer2);
		Assert.equals("Two", itemRenderer2.text);
		var itemRenderer1 = cast(this._gridView.itemAndColumnToCellRenderer(this._gridView.dataProvider.get(0), column1), ItemRenderer);
		Assert.notNull(itemRenderer1);
		Assert.equals("One", itemRenderer1.text);
		Assert.equals(0, itemRenderer2.parent.getChildIndex(itemRenderer2));
		Assert.equals(1, itemRenderer1.parent.getChildIndex(itemRenderer1));
	}

	public function testHeaderCornerSkinHiddenWhenNoScrollingRequired():Void {
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);

		var headerCornerSkin = new RectangleSkin();
		headerCornerSkin.width = 10;
		headerCornerSkin.height = 10;
		this._gridView.headerCornerSkin = headerCornerSkin;
		this._gridView.fixedScrollBars = true;
		this._gridView.extendedScrollBarY = false;
		this._gridView.validateNow();
		// exactly how the skin is hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(headerCornerSkin.parent == null || !headerCornerSkin.visible);
		Assert.equals(0.0, this._gridView.minScrollY);
		Assert.equals(0.0, this._gridView.maxScrollY);
	}

	public function testHeaderCornerSkinVisibleWhenVerticalScrollingRequired():Void {
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		this._gridView.height = 50.0;

		var headerCornerSkin = new RectangleSkin();
		headerCornerSkin.width = 10;
		headerCornerSkin.height = 10;
		this._gridView.headerCornerSkin = headerCornerSkin;
		this._gridView.fixedScrollBars = true;
		this._gridView.extendedScrollBarY = false;
		this._gridView.validateNow();
		Assert.notNull(headerCornerSkin.parent);
		Assert.isTrue(headerCornerSkin.visible);
		Assert.equals(0.0, this._gridView.minScrollY);
		Assert.isTrue(this._gridView.maxScrollY > 0.0);
	}

	public function testHeaderCornerSkinVisibleWhenVerticalScrollingRequiredAndScrollBarYIsExtended():Void {
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		this._gridView.height = 50.0;

		var headerCornerSkin = new RectangleSkin();
		headerCornerSkin.width = 10;
		headerCornerSkin.height = 10;
		this._gridView.headerCornerSkin = headerCornerSkin;
		this._gridView.fixedScrollBars = true;
		this._gridView.extendedScrollBarY = true;
		this._gridView.validateNow();
		// exactly how the skin is hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(headerCornerSkin.parent == null || !headerCornerSkin.visible);
		Assert.equals(0.0, this._gridView.minScrollY);
		Assert.isTrue(this._gridView.maxScrollY > 0.0);
	}

	public function testHeaderCornerSkinVisibleWhenVerticalScrollingRequiredAndScrollBarsNotFixed():Void {
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		this._gridView.height = 50.0;

		var headerCornerSkin = new RectangleSkin();
		headerCornerSkin.width = 10;
		headerCornerSkin.height = 10;
		this._gridView.headerCornerSkin = headerCornerSkin;
		this._gridView.fixedScrollBars = false;
		this._gridView.extendedScrollBarY = false;
		this._gridView.validateNow();
		// exactly how the skin is hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(headerCornerSkin.parent == null || !headerCornerSkin.visible);
		Assert.equals(0.0, this._gridView.minScrollY);
		Assert.isTrue(this._gridView.maxScrollY > 0.0);
	}

	private function testDispatchItemTriggerFromMouseClick():Void {
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		var item = this._gridView.dataProvider.get(1);
		var column = this._gridView.columns.get(0);
		this._gridView.validateNow();
		var cellRenderer = cast(this._gridView.itemAndColumnToCellRenderer(item, column), ItemRenderer);
		var dispatchedTriggerCount = 0;
		this._gridView.addEventListener(GridViewEvent.CELL_TRIGGER, event -> {
			dispatchedTriggerCount++;
			Assert.equals(event.state.rowIndex, 1);
			Assert.equals(event.state.columnIndex, 0);
		});
		Assert.equals(0, dispatchedTriggerCount);
		TriggerEvent.dispatchFromMouseEvent(cellRenderer, new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, dispatchedTriggerCount);
	}

	private function testDispatchItemTriggerFromTouchTap():Void {
		this._gridView.dataProvider = new ArrayCollection([{a: "A0", b: "B0"}, {a: "A1", b: "B1"}, {a: "A2", b: "B2"}]);
		this._gridView.columns = new ArrayCollection([
			new GridViewColumn("A", item -> item.a),
			new GridViewColumn("B", item -> item.b),
		]);
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var item = this._gridView.dataProvider.get(1);
		var column = this._gridView.columns.get(0);
		this._gridView.validateNow();
		var cellRenderer = cast(this._gridView.itemAndColumnToCellRenderer(item, column), ItemRenderer);
		var dispatchedTriggerCount = 0;
		this._gridView.addEventListener(GridViewEvent.CELL_TRIGGER, event -> {
			dispatchedTriggerCount++;
			Assert.equals(event.state.rowIndex, 1);
			Assert.equals(event.state.columnIndex, 0);
		});
		Assert.equals(0, dispatchedTriggerCount);
		TriggerEvent.dispatchFromTouchEvent(cellRenderer, new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.equals(1, dispatchedTriggerCount);
	}

	private function testColumnRecyclerIDFunction():Void {
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.dataProvider = collection;
		var column0 = new GridViewColumn("A", item -> item.text);
		column0.setCellRendererRecycler("alternate", DisplayObjectRecycler.withClass(ItemRenderer));
		column0.setCellRendererRecycler("alternate2", DisplayObjectRecycler.withClass(ItemRenderer));
		column0.cellRendererRecyclerIDFunction = (state) -> {
			if (state.rowIndex == 1) {
				return "alternate";
			} else if (state.rowIndex == 2) {
				return "alternate2";
			}
			return null;
		};
		var columns = new ArrayCollection([column0,]);
		this._gridView.columns = columns;
		this._gridView.validateNow();
		var state0 = this._gridView.itemAndColumnToCellState(collection.get(0), column0);
		Assert.notNull(state0);
		Assert.isNull(state0.recyclerID);
		var state1 = this._gridView.itemAndColumnToCellState(collection.get(1), column0);
		Assert.notNull(state1);
		Assert.equals("alternate", state1.recyclerID);
		var state2 = this._gridView.itemAndColumnToCellState(collection.get(2), column0);
		Assert.notNull(state2);
		Assert.equals("alternate2", state2.recyclerID);
	}
}

private class CustomRendererWithInterfaces extends LayoutGroup implements IToggle implements IDataRenderer implements ILayoutIndexObject
		implements IGridViewCellRenderer {
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

	public var setRowIndexValues:Array<Int> = [];

	private var _rowIndex:Int = -1;

	public var rowIndex(get, set):Int;

	private function get_rowIndex():Int {
		return _rowIndex;
	}

	private function set_rowIndex(value:Int):Int {
		if (_rowIndex == value) {
			return _rowIndex;
		}
		_rowIndex = value;
		setRowIndexValues.push(value);
		return _rowIndex;
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

	public var setColumnValues:Array<GridViewColumn> = [];

	private var _column:GridViewColumn;

	public var column(get, set):GridViewColumn;

	private function get_column():GridViewColumn {
		return _column;
	}

	private function set_column(value:GridViewColumn):GridViewColumn {
		if (_column == value) {
			return _column;
		}
		_column = value;
		setColumnValues.push(value);
		return _column;
	}

	public var setGridViewOwnerValues:Array<GridView> = [];

	private var _gridViewOwner:GridView;

	public var gridViewOwner(get, set):GridView;

	private function get_gridViewOwner():GridView {
		return _gridViewOwner;
	}

	private function set_gridViewOwner(value:GridView):GridView {
		if (_gridViewOwner == value) {
			return _gridViewOwner;
		}
		_gridViewOwner = value;
		setGridViewOwnerValues.push(value);
		return _gridViewOwner;
	}

	override private function update():Void {
		saveMeasurements(1.0, 1.0);
	}
}
