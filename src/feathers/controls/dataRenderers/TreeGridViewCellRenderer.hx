/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

/**
	A branch and leaf renderer for `TreeGridView`.

	@event openfl.events.Event.OPEN Dispatched when a branch item renderer
	opens. Does not get dispatched for leaf item renderers.

	@event openfl.events.Event.CLOSE Dispatched when a branch item renderer
	closes. Does not get dispatched for leaf item renderers.

	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:deprecated('TreeGridViewCellRenderer is deprecated. Use HierarchicalItemRenderer instead.')
class TreeGridViewCellRenderer extends HierarchicalItemRenderer implements ITreeGridViewCellRenderer {
	/**
		Creates a new `TreeGridViewCellRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _rowLocation:Array<Int>;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.rowLocation`
	**/
	@:flash.property
	public var rowLocation(get, set):Array<Int>;

	private function get_rowLocation():Array<Int> {
		return this._rowLocation;
	}

	private function set_rowLocation(value:Array<Int>):Array<Int> {
		if (this._rowLocation == value) {
			return this._rowLocation;
		}
		this._rowLocation = value;
		this.setInvalid(DATA);
		return this._rowLocation;
	}

	private var _columnIndex:Int = -1;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.columnIndex`
	**/
	@:flash.property
	public var columnIndex(get, set):Int;

	private function get_columnIndex():Int {
		return this._columnIndex;
	}

	private function set_columnIndex(value:Int):Int {
		if (this._columnIndex == value) {
			return this._columnIndex;
		}
		this._columnIndex = value;
		this.setInvalid(DATA);
		return this._columnIndex;
	}

	private var _column:TreeGridViewColumn = null;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.column`
	**/
	@:flash.property
	public var column(get, set):TreeGridViewColumn;

	private function get_column():TreeGridViewColumn {
		return this._column;
	}

	private function set_column(value:TreeGridViewColumn):TreeGridViewColumn {
		if (this._column == value) {
			return this._column;
		}
		this._column = value;
		this.setInvalid(DATA);
		return this._column;
	}

	private var _treeGridViewOwner:TreeGridView;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.treeGridViewOwner`
	**/
	@:flash.property
	public var treeGridViewOwner(get, set):TreeGridView;

	private function get_treeGridViewOwner():TreeGridView {
		return this._treeGridViewOwner;
	}

	private function set_treeGridViewOwner(value:TreeGridView):TreeGridView {
		if (this._treeGridViewOwner == value) {
			return this._treeGridViewOwner;
		}
		this._treeGridViewOwner = value;
		this.setInvalid(DATA);
		return this._treeGridViewOwner;
	}
}
