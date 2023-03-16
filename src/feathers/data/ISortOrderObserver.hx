/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	An observer of `feathers.data.SortOrder`.

	@see `feathers.controls.GridView.sortableColumns`

	@since 1.0.0
**/
interface ISortOrderObserver {
	/**
		The current sort order of the target.

		@since 1.0.0
	**/
	public var sortOrder(get, set):SortOrder;
}
