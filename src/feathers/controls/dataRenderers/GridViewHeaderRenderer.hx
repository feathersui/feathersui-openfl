/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

/**
	A header renderer for `GridView`.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
@:deprecated('GridViewHeaderRenderer is deprecated. Use SortOrderHeaderRenderer instead.')
class GridViewHeaderRenderer extends SortOrderHeaderRenderer implements IGridViewHeaderRenderer {
	/**
		Creates a new `GridViewHeaderRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _column:GridViewColumn;

	/**
		@see `feathers.controls.dataRenderers.IGridViewHeaderRenderer.column`
	**/
	public var column(get, set):GridViewColumn;

	private function get_column():GridViewColumn {
		return this._column;
	}

	private function set_column(value:GridViewColumn):GridViewColumn {
		if (this._column == value) {
			return this._column;
		}
		this._column = value;
		this.setInvalid(DATA);
		return this._column;
	}

	private var _columnIndex:Int = -1;

	/**
		@see `feathers.controls.dataRenderers.IGridViewHeaderRenderer.columnIndex`
	**/
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

	private var _gridViewOwner:GridView;

	/**
		@see `feathers.controls.dataRenderers.IGridViewHeaderRenderer.gridViewOwner`
	**/
	public var gridViewOwner(get, set):GridView;

	private function get_gridViewOwner():GridView {
		return this._gridViewOwner;
	}

	private function set_gridViewOwner(value:GridView):GridView {
		if (this._gridViewOwner == value) {
			return this._gridViewOwner;
		}
		this._gridViewOwner = value;
		this.setInvalid(DATA);
		return this._gridViewOwner;
	}
}
