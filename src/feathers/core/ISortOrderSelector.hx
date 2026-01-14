/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.data.SortOrder;

/**
	Provides a sort order for a data container that displays a collection of
	items.

	@since 1.4.0
**/
@:event(feathers.events.FeathersEvent.SORT_ORDER_CHANGE)
interface ISortOrderSelector {
	/**
		The currently selected sort order.

		When the value of the `sortOrder` property changes, the component
		will dispatch an event of type `FeathersEvent.SORT_ORDER_CHANGE`.

		The following example changes the sort order:

		```haxe
		gridView.sortOrder = SortOrder.ASCENDING;
		```

		The following example listens for when the sort order of a `GridView`
		component changes, and it requests the new sort order:

		```haxe
		var gridView = new GridView();
		function sortOrderChangeHandler(event:FeathersEvent):Void
		{
			var gridView = cast(event.currentTarget, GridView);
			trace("sort order change: " + gridView.sortOrder);
		}
		gridView.addEventListener(FeathersEvent.SORT_ORDER_CHANGE, sortOrderChangeHandler);
		```

		@since 1.4.0
	**/
	public var sortOrder(get, set):SortOrder;
}
