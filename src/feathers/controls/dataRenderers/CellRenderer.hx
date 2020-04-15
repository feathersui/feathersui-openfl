/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

/**
	A custom renderer for `GridView` that syncs up with other cell renderers
	in the same parent row.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
class CellRenderer extends ItemRenderer {
	/**
		Creates a new `CellRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();
		this._pointerToState.target = this.parent;
	}
}
