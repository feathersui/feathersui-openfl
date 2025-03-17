/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.dragDrop;

/**
	Stores data associated with a drag and drop operation.

	@see `feathers.dragDrop.DragDropManager`

	@since 1.3.0
**/
class DragData {
	/**
		Creates a new `DragData` object.

		@since 1.3.0
	**/
	public function new() {}

	private var _data:Map<String, Dynamic> = [];

	/**
		Indicates if the data format has been specified.

		@since 1.3.0
	**/
	public function exists(dataFormat:String):Bool {
		return this._data.exists(dataFormat);
	}

	/**
		Returns the data for the specified format, or `null` if no data has been
		specified for the format.

		@since 1.3.0
	**/
	public function get(dataFormat:String):Dynamic {
		return this._data.get(dataFormat);
	}

	/**
		Sets the data for the specified format.

		@since 1.3.0
	**/
	public function set(dataFormat:String, value:Dynamic):Void {
		this._data.set(dataFormat, value);
	}

	/**
		Removes the data for the specified format.

		@since 1.3.0
	**/
	public function remove(dataFormat:String):Bool {
		return this._data.remove(dataFormat);
	}
}
