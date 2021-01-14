/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	Types of item displayed by a `GroupListView` component.

	@see `feathers.controls.GroupListView`
	@see `feathers.data.GroupListViewItemState`

	@since 1.0.0
**/
enum GroupListViewItemType {
	/**
		The item is not a header, but a standard item.

		@since 1.0.0
	**/
	STANDARD;

	/**
		The item is a header.

		@since 1.0.0
	**/
	HEADER;
}
