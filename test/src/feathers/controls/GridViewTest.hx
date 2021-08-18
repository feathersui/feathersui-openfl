/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.layout.ILayoutIndexObject;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.IGridViewCellRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.events.ScrollEvent;
import openfl.events.Event;
import feathers.data.ArrayCollection;
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
		TestMain.openfl_root.addChild(this._gridView);
	}

	public function teardown():Void {
		if (this._gridView.parent != null) {
			this._gridView.parent.removeChild(this._gridView);
		}
		this._gridView = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._gridView.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._gridView.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._gridView.validateNow();
		this._gridView.dataProvider = null;
		this._gridView.validateNow();
		Assert.pass();
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
		Assert.equals(null, this._gridView.selectedItem);
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
		Assert.equals(null, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.addAt(item3, 0);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._gridView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.addAt(item3, 1);
		Assert.isTrue(changed);
		Assert.equals(2, eventIndex);
		Assert.equals(2, this._gridView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.addAt(item3, 2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.removeAt(0);
		Assert.isTrue(changed);
		Assert.equals(0, eventIndex);
		Assert.equals(0, this._gridView.selectedIndex);
		Assert.equals(item2, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.removeAt(1);
		Assert.isTrue(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(-1, this._gridView.selectedIndex);
		Assert.equals(null, eventItem);
		Assert.equals(null, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.removeAt(2);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.set(0, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.set(1, item4);
		Assert.isTrue(changed);
		Assert.equals(1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item4, eventItem);
		Assert.equals(item4, this._gridView.selectedItem);
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
		this._gridView.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
			eventIndex = this._gridView.selectedIndex;
			eventItem = this._gridView.selectedItem;
		});
		Assert.isFalse(changed);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(item2, this._gridView.selectedItem);
		this._gridView.dataProvider.set(2, item4);
		Assert.isFalse(changed);
		Assert.equals(-1, eventIndex);
		Assert.equals(1, this._gridView.selectedIndex);
		Assert.equals(null, eventItem);
		Assert.equals(item2, this._gridView.selectedItem);
	}
}

private class CustomRendererWithInterfaces extends LayoutGroup implements IToggle implements IDataRenderer implements ILayoutIndexObject
		implements IGridViewCellRenderer {
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

	public var setRowIndexValues:Array<Int> = [];

	private var _rowIndex:Int = -1;

	@:flash.property
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

	@:flash.property
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

	@:flash.property
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

	@:flash.property
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
}
