/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.IMeasureObject;
import feathers.core.IPointerDelegate;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.data.GridViewCellState;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.events.GridViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.GridViewRowLayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.Measurements;
import feathers.style.IVariantStyleObject;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.DisplayObjectRecycler;
import feathers.utils.KeyToState;
import feathers.utils.PointerToState;
import feathers.utils.PointerTrigger;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end

/**
	Renders a row of data in the `GridView` component.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
@:styleContext
class GridViewRowRenderer extends LayoutGroup implements ITriggerView implements IToggle implements IDataRenderer implements IStateContext<ToggleButtonState> {
	private static final INVALIDATION_FLAG_CELL_RENDERER_FACTORY = InvalidationFlag.CUSTOM("cellRendererFactory");

	private static final RESET_CELL_STATE = new GridViewCellState();

	private static function defaultUpdateCellRenderer(cellRenderer:DisplayObject, state:GridViewCellState):Void {
		if ((cellRenderer is ITextControl)) {
			var textControl = cast(cellRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetCellRenderer(cellRenderer:DisplayObject, state:GridViewCellState):Void {
		if ((cellRenderer is ITextControl)) {
			var textControl = cast(cellRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `GridViewRowRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeGridViewRowRendererTheme();
		super();
	}

	private var _defaultStorage:CellRendererStorage = new CellRendererStorage();
	private var _additionalStorage:Array<CellRendererStorage> = null;
	private var _unrenderedData:Array<Int> = [];
	private var _columnToCellRenderer = new ObjectMap<GridViewColumn, DisplayObject>();
	private var _cellRendererToCellState = new ObjectMap<DisplayObject, GridViewCellState>();
	private var cellStatePool = new ObjectPool(() -> new GridViewCellState());

	private var _currentState:ToggleButtonState = UP(false);

	/**
		The current state of the row renderer.

		When the value of the `currentState` property changes, the button will
		dispatch an event of type `FeathersEvent.STATE_CHANGE`.

		@see `feathers.controls.ToggleButtonState`
		@see `feathers.events.FeathersEvent.STATE_CHANGE`

		@since 1.3.0
	**/
	public var currentState(get, never):#if flash Dynamic #else ToggleButtonState #end;

	private function get_currentState():#if flash Dynamic #else ToggleButtonState #end {
		return this._currentState;
	}

	override private function set_enabled(value:Bool):Bool {
		super.enabled = value;
		if (this._enabled) {
			switch (this._currentState) {
				case DISABLED(selected):
					this.changeState(UP(selected));
				default: // do nothing
			}
		} else {
			this.changeState(DISABLED(this._selected));
		}
		return this._enabled;
	}

	private var _gridView:GridView;

	/**
		The `GridView` component that contains this row.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	public var gridView(get, set):GridView;

	private function get_gridView():GridView {
		return this._gridView;
	}

	private function set_gridView(value:GridView):GridView {
		if (this._gridView == value) {
			return this._gridView;
		}
		if (this._gridView != null) {
			this._gridView.removeEventListener(KeyboardEvent.KEY_DOWN, gridViewRowRenderer_gridView_keyDownHandler);
		}
		this._gridView = value;
		if (this._gridView != null) {
			this._gridView.addEventListener(KeyboardEvent.KEY_DOWN, gridViewRowRenderer_gridView_keyDownHandler, false, 0, true);
		} else {
			// clean up any existing cell renderers when the row is cleaned up
			this.refreshInactiveCellRenderers(this._defaultStorage, true);
			if (this._additionalStorage != null) {
				for (i in 0...this._additionalStorage.length) {
					var storage = this._additionalStorage[i];
					this.refreshInactiveCellRenderers(storage, true);
				}
			}
		}
		this.setInvalid(DATA);
		return this._gridView;
	}

	private var _selected:Bool = false;

	/**
		Indicates if the row is selected or not.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	@:bindable("change")
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return this._selected;
	}

	private function set_selected(value:Bool):Bool {
		if (this._selected == value) {
			return this._selected;
		}
		this._selected = value;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selected;
	}

	private var _ignoreSelectionChange = false;

	private var _rowIndex:Int = -1;

	/**
		The vertical position of the row within the `GridView`.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	public var rowIndex(get, set):Int;

	private function get_rowIndex():Int {
		return this._rowIndex;
	}

	private function set_rowIndex(value:Int):Int {
		if (this._rowIndex == value) {
			return this._rowIndex;
		}
		this._rowIndex = value;
		this.setInvalid(DATA);
		return this._rowIndex;
	}

	private var _data:Dynamic = null;

	/**
		The item from the data provider that is rendered by this row.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (this._data == value) {
			return this._data;
		}
		this._data = value;
		this.setInvalid(DATA);
		return this._data;
	}

	private var _columns:IFlatCollection<GridViewColumn> = null;

	/**
		The columns displayed in this row.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	public var columns(get, set):IFlatCollection<GridViewColumn>;

	private function get_columns():IFlatCollection<GridViewColumn> {
		return this._columns;
	}

	private function set_columns(value:IFlatCollection<GridViewColumn>):IFlatCollection<GridViewColumn> {
		if (this._columns == value) {
			return this._columns;
		}
		if (this._columns != null) {
			this._columns.removeEventListener(Event.CHANGE, gridViewRowRenderer_columns_changeHandler);
		}
		this._columns = value;
		if (this._columns != null) {
			this._columns.addEventListener(Event.CHANGE, gridViewRowRenderer_columns_changeHandler, false, 0, true);
		}
		this.setInvalid(DATA);
		return this._columns;
	}

	/**
		Manages cell renderers used by the row.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	public var cellRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;

	private function get_cellRendererRecycler():DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> {
		return this._defaultStorage.cellRendererRecycler;
	}

	private function set_cellRendererRecycler(value:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GridViewCellState, DisplayObject> {
		if (this._defaultStorage.cellRendererRecycler == value) {
			return this._defaultStorage.cellRendererRecycler;
		}
		this._defaultStorage.oldCellRendererRecycler = this._defaultStorage.cellRendererRecycler;
		this._defaultStorage.cellRendererRecycler = value;
		this._defaultStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_CELL_RENDERER_FACTORY);
		return this._defaultStorage.cellRendererRecycler;
	}

	private var _forceCellStateUpdate:Bool = false;

	/**
		Manages cell state updates for the column.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@see `feathers.controls.GridView.forceItemStateUpdate`

		@since 1.2.0
	**/
	public var forceCellStateUpdate(get, set):Bool;

	private function get_forceCellStateUpdate():Bool {
		return this._forceCellStateUpdate;
	}

	private function set_forceCellStateUpdate(value:Bool):Bool {
		if (this._forceCellStateUpdate == value) {
			return this._forceCellStateUpdate;
		}
		this._forceCellStateUpdate = value;
		this.setInvalid(DATA);
		return this._forceCellStateUpdate;
	}

	private var _customCellRendererVariant:String = null;

	/**
		Manages cell renderer variants for the column.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@see `feathers.controls.GridView.customCellRendererVariant`

		@since 1.0.0
	**/
	public var customCellRendererVariant(get, set):String;

	private function get_customCellRendererVariant():String {
		return this._customCellRendererVariant;
	}

	private function set_customCellRendererVariant(value:String):String {
		if (this._customCellRendererVariant == value) {
			return this._customCellRendererVariant;
		}
		this._customCellRendererVariant = value;
		this.setInvalid(INVALIDATION_FLAG_CELL_RENDERER_FACTORY);
		return this._customCellRendererVariant;
	}

	private var _customColumnWidths:Array<Float>;

	/**
		Manages custom column width values used by the row.

		_This special property must be set by the `GridView`, and it should not
		be modified externally._

		@since 1.0.0
	**/
	public var customColumnWidths(get, set):Array<Float>;

	private function get_customColumnWidths():Array<Float> {
		return this._customColumnWidths;
	}

	private function set_customColumnWidths(value:Array<Float>):Array<Float> {
		if (this._customColumnWidths == value) {
			return this._customColumnWidths;
		}
		this._customColumnWidths = value;
		this.setInvalid(DATA);
		return this._customColumnWidths;
	}

	private var _rowLayout:GridViewRowLayout;

	private var _pointerToState:PointerToState<ToggleButtonState>;
	private var _keyToState:KeyToState<ToggleButtonState>;
	private var _pointerTrigger:PointerTrigger;

	override public function dispose():Void {
		this.refreshInactiveCellRenderers(this._defaultStorage, true);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveCellRenderers(storage, true);
			}
		}
		super.dispose();
	}

	/**
		Returns the current cell renderer used to render a specific column from
		this row. May return `null` if a column doesn't currently have a cell
		renderer.

		@see `feathers.controls.GridView.itemAndColumnToCellRenderer`

		@since 1.0.0
	**/
	public function columnToCellRenderer(column:GridViewColumn):DisplayObject {
		if (column == null) {
			return null;
		}
		return this._columnToCellRenderer.get(column);
	}

	private function initializeGridViewRowRendererTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelGridViewRowRendererStyles.initialize();
		#end
	}

	override private function initialize():Void {
		super.initialize();

		if (this._pointerToState == null) {
			this._pointerToState = new PointerToState(this, this.changeState, UP(false), DOWN(false), HOVER(false));
		}

		if (this._keyToState == null) {
			this._keyToState = new KeyToState(this, this.changeState, UP(false), DOWN(false));
		}

		if (this._pointerTrigger == null) {
			this._pointerTrigger = new PointerTrigger(this);
		}

		if (this.layout == null) {
			this._rowLayout = new GridViewRowLayout();
			this.layout = this._rowLayout;
		}
	}

	private function changeState(state:ToggleButtonState):Void {
		var toggleState = cast(state, ToggleButtonState);
		if (!this._enabled) {
			toggleState = DISABLED(this._selected);
		}
		switch (toggleState) {
			case UP(selected):
				if (this._selected != selected) {
					toggleState = UP(this._selected);
				}
			case DOWN(selected):
				if (this._selected != selected) {
					toggleState = DOWN(this._selected);
				}
			case HOVER(selected):
				if (this._selected != selected) {
					toggleState = HOVER(this._selected);
				}
			case DISABLED(selected):
				if (this._selected != selected) {
					toggleState = DISABLED(this._selected);
				}
			default: // do nothing
		}
		if (this._currentState == toggleState) {
			return;
		}
		this._currentState = toggleState;
		this.setInvalid(STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}

	override private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			super.addCurrentBackgroundSkin(skin);
			return;
		}
		if ((skin is IStateObserver)) {
			cast(skin, IStateObserver).stateContext = this;
		}
		super.addCurrentBackgroundSkin(skin);
	}

	override private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			super.removeCurrentBackgroundSkin(skin);
			return;
		}
		if ((skin is IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		super.removeCurrentBackgroundSkin(skin);
	}

	private function updateCells():Void {
		for (i in 0...this._columns.length) {
			this.updateCellRendererForColumnIndex(i);
		}
	}

	override private function update():Void {
		this.preLayout();
		super.update();
	}

	private function preLayout():Void {
		this._rowLayout.columns = cast this._columns;
		this._rowLayout.customColumnWidths = this._customColumnWidths;

		if (this._defaultStorage.cellRendererRecycler.update == null) {
			this._defaultStorage.cellRendererRecycler.update = defaultUpdateCellRenderer;
			if (this._defaultStorage.cellRendererRecycler.reset == null) {
				this._defaultStorage.cellRendererRecycler.reset = defaultResetCellRenderer;
			}
		}
		for (column in this._columns) {
			if (column.cellRendererRecycler != null) {
				if (column.cellRendererRecycler.update == null) {
					column.cellRendererRecycler.update = defaultUpdateCellRenderer;
					// don't replace reset if we didn't replace update too
					if (column.cellRendererRecycler.reset == null) {
						column.cellRendererRecycler.reset = defaultResetCellRenderer;
					}
				}
			}
		}

		this.refreshInactiveCellRenderers(this._defaultStorage, false);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveCellRenderers(storage, false);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveCellRenderers(this._defaultStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.recoverInactiveCellRenderers(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveCellRenderers(this._defaultStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.freeInactiveCellRenderers(storage);
			}
		}
		if (this._defaultStorage.inactiveCellRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive cell renderers should be empty after updating.');
		}
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				if (storage.inactiveCellRenderers.length > 0) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive cell renderers should be empty after updating.');
				}
			}
		}
	}

	private function refreshInactiveCellRenderers(storage:CellRendererStorage, forceCleanup:Bool):Void {
		var temp = storage.inactiveCellRenderers;
		storage.inactiveCellRenderers = storage.activeCellRenderers;
		storage.activeCellRenderers = temp;
		if (storage.activeCellRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active cell renderers should be empty before updating.');
		}
		if (forceCleanup) {
			this.recoverInactiveCellRenderers(storage);
			this.freeInactiveCellRenderers(storage);
			storage.oldCellRendererRecycler = null;
		}
	}

	private function findUnrenderedData():Void {
		var currentChildIndex = 0;
		for (i in 0...this._columns.length) {
			var column = this._columns.get(i);
			var cellRenderer = this._columnToCellRenderer.get(column);
			if (cellRenderer != null) {
				var storage = this.cellRendererRecyclerToStorage(column.cellRendererRecycler);
				var state = this._cellRendererToCellState.get(cellRenderer);
				var changed = this.populateCurrentItemState(column, i, state, this._forceCellStateUpdate);
				if (changed) {
					this.updateCellRenderer(cellRenderer, state, storage);
				}
				// we can't set the child index to i here because we may need to
				// skip columns that don't have cell renderers yet
				// this can result in a range error if i > numChildren
				// when we insert the skipped columns later, this cell renderer
				// will be moved to the correct index
				this.setChildIndex(cellRenderer, currentChildIndex);
				var removed = storage.inactiveCellRenderers.remove(cellRenderer);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: cell renderer map contains bad data for item at row index ${this._rowIndex} and column index ${i}. This may be caused by duplicate items in the data provider, which is not allowed.');
				}
				storage.activeCellRenderers.push(cellRenderer);
				currentChildIndex++;
			} else {
				this._unrenderedData.push(i);
			}
		}
	}

	private function cellRendererRecyclerToStorage(recycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>):CellRendererStorage {
		if (recycler == null) {
			return this._defaultStorage;
		}
		if (this._additionalStorage == null) {
			this._additionalStorage = [];
		}
		for (i in 0...this._additionalStorage.length) {
			var storage = this._additionalStorage[i];
			if (storage.cellRendererRecycler == recycler) {
				return storage;
			}
		}
		var storage = new CellRendererStorage(recycler);
		this._additionalStorage.push(storage);
		return storage;
	}

	private function recoverInactiveCellRenderers(storage:CellRendererStorage):Void {
		for (cellRenderer in storage.inactiveCellRenderers) {
			if (cellRenderer == null) {
				continue;
			}
			var state = this._cellRendererToCellState.get(cellRenderer);
			if (state == null) {
				continue;
			}
			var column = state.column;
			this._cellRendererToCellState.remove(cellRenderer);
			this._columnToCellRenderer.remove(column);
			cellRenderer.removeEventListener(MouseEvent.CLICK, gridViewRowRenderer_cellRenderer_clickHandler);
			cellRenderer.removeEventListener(TouchEvent.TOUCH_TAP, gridViewRowRenderer_cellRenderer_touchTapHandler);
			cellRenderer.removeEventListener(TriggerEvent.TRIGGER, gridViewRowRenderer_cellRenderer_triggerHandler);
			cellRenderer.removeEventListener(Event.CHANGE, gridViewRowRenderer_cellRenderer_changeHandler);
			this.resetCellRenderer(cellRenderer, state, storage);
			if (storage.measurements != null) {
				storage.measurements.restore(cellRenderer);
			}
			this.cellStatePool.release(state);
		}
	}

	private function renderUnrenderedData():Void {
		for (columnIndex in this._unrenderedData) {
			var column = this._columns.get(columnIndex);
			var state = this.cellStatePool.get();
			this.populateCurrentItemState(column, columnIndex, state, true);
			var cellRenderer = this.createCellRenderer(state);
			this.addChildAt(cellRenderer, columnIndex);
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedData.splice(0, this._unrenderedData.length);
		#else
		this._unrenderedData.resize(0);
		#end
	}

	private function freeInactiveCellRenderers(storage:CellRendererStorage):Void {
		var cellRendererRecycler = storage.oldCellRendererRecycler != null ? storage.oldCellRendererRecycler : storage.cellRendererRecycler;
		for (cellRenderer in storage.inactiveCellRenderers) {
			if (cellRenderer == null) {
				continue;
			}
			this.destroyCellRenderer(cellRenderer, cellRendererRecycler);
		}
		#if (hl && haxe_ver < 4.3)
		storage.inactiveCellRenderers.splice(0, storage.inactiveCellRenderers.length);
		#else
		storage.inactiveCellRenderers.resize(0);
		#end
	}

	private function createCellRenderer(state:GridViewCellState):DisplayObject {
		var column = state.column;
		var cellRenderer:DisplayObject = null;
		var storage = this.cellRendererRecyclerToStorage(column.cellRendererRecycler);
		if (storage.inactiveCellRenderers.length == 0) {
			cellRenderer = storage.cellRendererRecycler.create();
			if ((cellRenderer is IVariantStyleObject)) {
				var variantCellRenderer = cast(cellRenderer, IVariantStyleObject);
				if (variantCellRenderer.variant == null) {
					var variant = (this.customCellRendererVariant != null) ? this.customCellRendererVariant : GridView.CHILD_VARIANT_CELL_RENDERER;
					variantCellRenderer.variant = variant;
				}
			}
			// for consistency, initialize before passing to the recycler's
			// update function. plus, this ensures that custom item renderers
			// correctly handle property changes in update() instead of trying
			// to access them too early in initialize().
			if ((cellRenderer is IUIControl)) {
				cast(cellRenderer, IUIControl).initializeNow();
			}
			// save measurements after initialize, because width/height could be
			// set explicitly there, and we want to restore those values
			if (storage.measurements == null) {
				storage.measurements = new Measurements(cellRenderer);
			}
		} else {
			cellRenderer = storage.inactiveCellRenderers.shift();
		}
		var storage = this.cellRendererRecyclerToStorage(column.cellRendererRecycler);
		this.updateCellRenderer(cellRenderer, state, storage);
		if ((cellRenderer is ITriggerView)) {
			// prefer TriggerEvent.TRIGGER
			cellRenderer.addEventListener(TriggerEvent.TRIGGER, gridViewRowRenderer_cellRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			cellRenderer.addEventListener(MouseEvent.CLICK, gridViewRowRenderer_cellRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			cellRenderer.addEventListener(TouchEvent.TOUCH_TAP, gridViewRowRenderer_cellRenderer_touchTapHandler);
			#end
		}
		if ((cellRenderer is IToggle)) {
			cellRenderer.addEventListener(Event.CHANGE, gridViewRowRenderer_cellRenderer_changeHandler);
		}
		if ((cellRenderer is IMeasureObject)) {
			cellRenderer.addEventListener(Event.RESIZE, gridViewRowRenderer_cellRenderer_resizeHandler);
		}
		this._cellRendererToCellState.set(cellRenderer, state);
		this._columnToCellRenderer.set(column, cellRenderer);
		storage.activeCellRenderers.push(cellRenderer);
		return cellRenderer;
	}

	private function destroyCellRenderer(cellRenderer:DisplayObject,
			cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>):Void {
		this.removeChild(cellRenderer);
		if (cellRendererRecycler != null && cellRendererRecycler.destroy != null) {
			cellRendererRecycler.destroy(cellRenderer);
		}
	}

	private function updateCellRendererForColumnIndex(columnIndex:Int):Void {
		var column = this._columns.get(columnIndex);
		var cellRenderer = this._columnToCellRenderer.get(column);
		if (cellRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var storage = this.cellRendererRecyclerToStorage(column.cellRendererRecycler);
		var state = this._cellRendererToCellState.get(cellRenderer);
		if (state.owner == null) {
			// a previous update is already pending
			return;
		}
		this.populateCurrentItemState(column, columnIndex, state, true);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetCellRenderer(cellRenderer, state, storage);
		// ensures that the change is detected when we validate later
		state.owner = null;
		this.setInvalid(DATA);
	}

	private function populateCurrentItemState(column:GridViewColumn, columnIndex:Int, state:GridViewCellState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this._gridView) {
			state.owner = this._gridView;
			changed = true;
		}
		if (force || state.data != this._data) {
			state.data = this._data;
			changed = true;
		}
		if (force || state.rowIndex != this._rowIndex) {
			state.rowIndex = this._rowIndex;
			changed = true;
		}
		if (force || state.columnIndex != columnIndex) {
			state.columnIndex = columnIndex;
			changed = true;
		}
		if (force || state.column != column) {
			state.column = column;
			changed = true;
		}
		if (force || state.selected != this._selected) {
			state.selected = this._selected;
			changed = true;
		}
		if (force || state.enabled != this._enabled) {
			state.enabled = this._enabled;
			changed = true;
		}
		var text = (this._rowIndex != -1) ? column.itemToText(this._data) : null;
		if (force || state.text != text) {
			state.text = text;
			changed = true;
		}
		return changed;
	}

	private function updateCellRenderer(cellRenderer:DisplayObject, state:GridViewCellState, storage:CellRendererStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (storage.cellRendererRecycler.update != null) {
			storage.cellRendererRecycler.update(cellRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshCellRendererProperties(cellRenderer, state);
	}

	private function resetCellRenderer(cellRenderer:DisplayObject, state:GridViewCellState, storage:CellRendererStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var recycler = storage.oldCellRendererRecycler != null ? storage.oldCellRendererRecycler : storage.cellRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(cellRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshCellRendererProperties(cellRenderer, RESET_CELL_STATE);
	}

	private function refreshCellRendererProperties(cellRenderer:DisplayObject, state:GridViewCellState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if ((cellRenderer is IUIControl)) {
			var uiControl = cast(cellRenderer, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if ((cellRenderer is IDataRenderer)) {
			var dataRenderer = cast(cellRenderer, IDataRenderer);
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((cellRenderer is IToggle)) {
			var toggle = cast(cellRenderer, IToggle);
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = state.selected;
		}
		if ((cellRenderer is IGridViewCellRenderer)) {
			var gridCell = cast(cellRenderer, IGridViewCellRenderer);
			gridCell.column = state.column;
			gridCell.columnIndex = state.columnIndex;
			gridCell.rowIndex = state.rowIndex;
			gridCell.gridViewOwner = state.owner;
		}
		if ((cellRenderer is ILayoutIndexObject)) {
			var layoutIndexObject = cast(cellRenderer, ILayoutIndexObject);
			layoutIndexObject.layoutIndex = state.rowIndex;
		}
		if ((cellRenderer is IPointerDelegate)) {
			var pointerDelgate = cast(cellRenderer, IPointerDelegate);
			pointerDelgate.pointerTarget = state.rowIndex == -1 ? null : this;
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function gridViewRowRenderer_cellRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		var cellRenderer = cast(event.currentTarget, DisplayObject);
		var state = this._cellRendererToCellState.get(cellRenderer);
		GridViewEvent.dispatchForCell(this, GridViewEvent.CELL_TRIGGER, state);
	}

	private function gridViewRowRenderer_cellRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		var cellRenderer = cast(event.currentTarget, DisplayObject);
		var state = this._cellRendererToCellState.get(cellRenderer);
		GridViewEvent.dispatchForCell(this, GridViewEvent.CELL_TRIGGER, state);
	}

	private function gridViewRowRenderer_cellRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}
		var cellRenderer = cast(event.currentTarget, DisplayObject);
		var state = this._cellRendererToCellState.get(cellRenderer);
		GridViewEvent.dispatchForCell(this, GridViewEvent.CELL_TRIGGER, state);
	}

	private function gridViewRowRenderer_cellRenderer_resizeHandler(event:Event):Void {
		if (this._validating) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function gridViewRowRenderer_cellRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var cellRenderer = cast(event.currentTarget, DisplayObject);
		var toggleCellRenderer = cast(cellRenderer, IToggle);
		var state = this._cellRendererToCellState.get(cellRenderer);
		if (toggleCellRenderer.selected == state.selected) {
			// nothing has changed
			return;
		}
		// if we get here, the selected property of the renderer changed
		// unexpectedly, and we need to restore its proper state
		this.setInvalid(SELECTION);
	}

	private function gridViewRowRenderer_gridView_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode == Keyboard.SPACE || event.keyCode == Keyboard.ENTER) {
			if (this._selected) {
				var column = this._columns.get(0);
				var cellRenderer = this.columnToCellRenderer(column);
				var state:GridViewCellState = null;
				if (cellRenderer != null) {
					state = this._cellRendererToCellState.get(cellRenderer);
				}
				var isTemporary = false;
				if (state == null) {
					// if there is no existing state, use a temporary object
					isTemporary = true;
					state = this.cellStatePool.get();
				}
				this.populateCurrentItemState(column, 0, state, true);
				GridViewEvent.dispatchForCell(this, GridViewEvent.CELL_TRIGGER, state);
				if (isTemporary) {
					this.cellStatePool.release(state);
				}
			}
		}
	}

	private function gridViewRowRenderer_columns_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}
}

private class CellRendererStorage {
	public function new(?recycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>) {
		this.cellRendererRecycler = recycler;
	}

	public var oldCellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;
	public var cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;
	public var activeCellRenderers:Array<DisplayObject> = [];
	public var inactiveCellRenderers:Array<DisplayObject> = [];
	public var measurements:Measurements;
}
