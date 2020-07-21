/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.layout.ILayoutIndexObject;
import openfl.events.Event;
import feathers.events.FeathersEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.ITextControl;
import feathers.core.InvalidationFlag;
import feathers.data.GridViewCellState;
import feathers.data.IFlatCollection;
import feathers.layout.GridViewRowLayout;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
#if air
import openfl.ui.Multitouch;
#end

/**
	Renders a row of data in the `GridView` component.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.data.GridViewCellState)
class GridViewRowRenderer extends LayoutGroup implements IToggle implements IDataRenderer {
	private static final INVALIDATION_FLAG_CELL_RENDERER_FACTORY = "cellRendererFactory";

	private static function defaultUpdateCellRenderer(cellRenderer:DisplayObject, state:GridViewCellState):Void {
		if (Std.is(cellRenderer, ITextControl)) {
			var textControl = cast(cellRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetCellRenderer(cellRenderer:DisplayObject, state:GridViewCellState):Void {
		if (Std.is(cellRenderer, ITextControl)) {
			var textControl = cast(cellRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `GridViewRowRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _defaultStorage:CellRendererStorage = new CellRendererStorage();
	private var _unrenderedData:Array<Int> = [];
	private var _currentCellState:GridViewCellState = new GridViewCellState();
	private var _columnToCellRenderer = new ObjectMap<GridViewColumn, DisplayObject>();
	private var _cellRendererToColumn = new ObjectMap<DisplayObject, GridViewColumn>();

	private var _selected:Bool = false;

	/**
		Indicates if the row is selected or not.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	@:flash.property
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return this._selected;
	}

	private function set_selected(value:Bool):Bool {
		if (this._selected == value) {
			return this._selected;
		}
		this._selected = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selected;
	}

	public var selectable:Bool = true;

	private var _rowIndex:Int = -1;

	/**
		The vertical position of the row within the `GridView`.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	@:flash.property
	public var rowIndex(get, set):Int;

	private function get_rowIndex():Int {
		return this._rowIndex;
	}

	private function set_rowIndex(value:Int):Int {
		if (this._rowIndex == value) {
			return this._rowIndex;
		}
		this._rowIndex = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._rowIndex;
	}

	private var _data:Dynamic = null;

	/**
		The item from the data provider that is rendered by this row.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	@:flash.property
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (this._data == value) {
			return this._data;
		}
		this._data = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._data;
	}

	private var _columns:IFlatCollection<GridViewColumn> = null;

	/**
		The columns displayed in this row.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	@:flash.property
	public var columns(get, set):IFlatCollection<GridViewColumn>;

	private function get_columns():IFlatCollection<GridViewColumn> {
		return this._columns;
	}

	private function set_columns(value:IFlatCollection<GridViewColumn>):IFlatCollection<GridViewColumn> {
		if (this._columns == value) {
			return this._columns;
		}
		this._columns = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._columns;
	}

	private var _cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;

	/**
		Manages cell renderers used by the column.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	@:flash.property
	public var cellRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;

	private function get_cellRendererRecycler():DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> {
		return this._cellRendererRecycler;
	}

	private function set_cellRendererRecycler(value:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GridViewCellState, DisplayObject> {
		if (this._cellRendererRecycler == value) {
			return this._cellRendererRecycler;
		}
		this._cellRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_CELL_RENDERER_FACTORY);
		return this._cellRendererRecycler;
	}

	private var _rowLayout:GridViewRowLayout;

	override private function initialize():Void {
		super.initialize();

		if (this.layout == null) {
			this._rowLayout = new GridViewRowLayout();
			this.layout = this._rowLayout;
		}
	}

	override private function update():Void {
		// children are allowed to change during update() in a subclass up
		// until it calls super.update().
		this._ignoreChildChangesButSetFlags = false;

		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this.preLayout();
		this._ignoreChildChanges = oldIgnoreChildChanges;

		super.update();
	}

	private function preLayout():Void {
		this._rowLayout.columns = this._columns;

		if (this._cellRendererRecycler.update == null) {
			this._cellRendererRecycler.update = defaultUpdateCellRenderer;
			if (this._cellRendererRecycler.reset == null) {
				this._cellRendererRecycler.reset = defaultResetCellRenderer;
			}
		}

		this.refreshInactiveCellRenderers(this._defaultStorage, false);
		if (this._data == null) {
			return;
		}

		this.findUnrenderedData();
		this.recoverInactiveCellRenderers(this._defaultStorage);
		this.renderUnrenderedData();
		this.freeInactiveCellRenderers(this._defaultStorage);
	}

	private function refreshInactiveCellRenderers(storage:CellRendererStorage, forceCleanup:Bool):Void {
		var temp = storage.inactiveCellRenderers;
		storage.inactiveCellRenderers = storage.activeCellRenderers;
		storage.activeCellRenderers = temp;
		if (storage.activeCellRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active cell renderers should be empty before updating.");
		}
		if (forceCleanup) {
			this.recoverInactiveCellRenderers(storage);
			this.freeInactiveCellRenderers(storage);
		}
	}

	private function findUnrenderedData():Void {
		for (i in 0...this._columns.length) {
			var column = this._columns.get(i);
			var cellRenderer = this._columnToCellRenderer.get(column);
			if (cellRenderer != null) {
				var storage = this._defaultStorage;
				this.refreshCellRendererProperties(cellRenderer, i, column);
				this.setChildIndex(cellRenderer, i);
				var removed = storage.inactiveCellRenderers.remove(cellRenderer);
				if (!removed) {
					throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
						+ ": cell renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
				storage.activeCellRenderers.push(cellRenderer);
			} else {
				this._unrenderedData.push(i);
			}
		}
	}

	private function recoverInactiveCellRenderers(storage:CellRendererStorage):Void {
		for (cellRenderer in storage.inactiveCellRenderers) {
			if (cellRenderer == null) {
				continue;
			}
			var column = this._cellRendererToColumn.get(cellRenderer);
			if (column == null) {
				return;
			}
			this._cellRendererToColumn.remove(cellRenderer);
			this._columnToCellRenderer.remove(column);
			this._currentCellState.data = null;
			this._currentCellState.rowIndex = -1;
			this._currentCellState.columnIndex = -1;
			this._currentCellState.column = null;
			this._currentCellState.selected = false;
			this._currentCellState.text = null;
			var cellRendererRecycler = storage.cellRendererRecycler != null ? storage.cellRendererRecycler : this._cellRendererRecycler;
			if (cellRendererRecycler.reset != null) {
				cellRendererRecycler.reset(cellRenderer, this._currentCellState);
			}
			if (Std.is(cellRenderer, IToggle)) {
				var toggle = cast(cellRenderer, IToggle);
				toggle.selected = false;
			}
			if (Std.is(cellRenderer, IDataRenderer)) {
				var dataRenderer = cast(cellRenderer, IDataRenderer);
				dataRenderer.data = null;
			}
			if (Std.is(cellRenderer, IGridViewCellRenderer)) {
				var gridCell = cast(cellRenderer, IGridViewCellRenderer);
				gridCell.column = null;
				gridCell.columnIndex = -1;
			}
			if (Std.is(cellRenderer, ILayoutIndexObject)) {
				var layoutIndexObject = cast(cellRenderer, ILayoutIndexObject);
				layoutIndexObject.layoutIndex = -1;
			}
			cellRenderer.removeEventListener(MouseEvent.CLICK, cellRenderer_clickHandler);
			cellRenderer.removeEventListener(TouchEvent.TOUCH_TAP, cellRenderer_touchTapHandler);
		}
	}

	private function renderUnrenderedData():Void {
		for (columnIndex in this._unrenderedData) {
			var column = this._columns.get(columnIndex);
			var cellRenderer = this.createCellRenderer(columnIndex, column);
			this.addChild(cellRenderer);
		}
		this._unrenderedData.resize(0);
	}

	private function freeInactiveCellRenderers(storage:CellRendererStorage):Void {
		for (cellRenderer in storage.inactiveCellRenderers) {
			if (cellRenderer == null) {
				continue;
			}
			this.destroyCellRenderer(cellRenderer, storage);
		}
		storage.inactiveCellRenderers.resize(0);
	}

	private function createCellRenderer(columnIndex:Int, column:GridViewColumn):DisplayObject {
		var cellRenderer:DisplayObject = null;
		var storage = this._defaultStorage;
		var cellRendererRecycler = storage.cellRendererRecycler != null ? storage.cellRendererRecycler : this._cellRendererRecycler;
		if (storage.inactiveCellRenderers.length == 0) {
			cellRenderer = cellRendererRecycler.create();
		} else {
			cellRenderer = storage.inactiveCellRenderers.shift();
		}
		this.refreshCellRendererProperties(cellRenderer, columnIndex, column);
		cellRenderer.addEventListener(MouseEvent.CLICK, cellRenderer_clickHandler);
		cellRenderer.addEventListener(TouchEvent.TOUCH_TAP, cellRenderer_touchTapHandler);
		this._cellRendererToColumn.set(cellRenderer, column);
		this._columnToCellRenderer.set(column, cellRenderer);
		storage.activeCellRenderers.push(cellRenderer);
		return cellRenderer;
	}

	private function destroyCellRenderer(cellRenderer:DisplayObject, storage:CellRendererStorage):Void {
		this.removeChild(cellRenderer);
		var cellRendererRecycler = storage.cellRendererRecycler != null ? storage.cellRendererRecycler : this._cellRendererRecycler;
		if (cellRendererRecycler.destroy != null) {
			cellRendererRecycler.destroy(cellRenderer);
		}
	}

	private function refreshCellRendererProperties(cellRenderer:DisplayObject, columnIndex:Int, column:GridViewColumn):Void {
		var storage = this._defaultStorage;
		var cellRendererRecycler = storage.cellRendererRecycler != null ? storage.cellRendererRecycler : this._cellRendererRecycler;
		this._currentCellState.data = this._data;
		this._currentCellState.rowIndex = this._rowIndex;
		this._currentCellState.columnIndex = columnIndex;
		this._currentCellState.column = column;
		this._currentCellState.selected = this._selected;
		this._currentCellState.text = column.itemToText(this._data);
		if (cellRendererRecycler.update != null) {
			cellRendererRecycler.update(cellRenderer, this._currentCellState);
		}
		if (Std.is(cellRenderer, IDataRenderer)) {
			var dataRenderer = cast(cellRenderer, IDataRenderer);
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = this._data;
		}
		if (Std.is(cellRenderer, IToggle)) {
			var toggle = cast(cellRenderer, IToggle);
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = this._currentCellState.selected;
		}
		if (Std.is(cellRenderer, IGridViewCellRenderer)) {
			var gridCell = cast(cellRenderer, IGridViewCellRenderer);
			gridCell.column = this._currentCellState.column;
			gridCell.columnIndex = this._currentCellState.columnIndex;
		}
		if (Std.is(cellRenderer, ILayoutIndexObject)) {
			var layoutIndexObject = cast(cellRenderer, ILayoutIndexObject);
			layoutIndexObject.layoutIndex = this._currentCellState.rowIndex;
		}
	}

	private function cellRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this.selectable) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		// use the setter
		this.selected = true;
	}

	private function cellRenderer_clickHandler(event:MouseEvent):Void {
		if (!this.selectable) {
			return;
		}
		// use the setter
		this.selected = true;
	}
}

private class CellRendererStorage {
	public function new(cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> = null) {}

	public var cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;
	public var activeCellRenderers:Array<DisplayObject> = [];
	public var inactiveCellRenderers:Array<DisplayObject> = [];
}
