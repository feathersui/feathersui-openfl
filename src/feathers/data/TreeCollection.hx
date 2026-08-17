/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	Wraps an `Array<TreeNode<T>>` data source with a common API for use with UI
	controls that support hierarchical data, such as `TreeView` or
	`TreeGridView`.

	**Deprecation Warning!** This API will be removed in a future version. Use
	`ArrayHierarchicalCollection` instead.

	@event openfl.events.Event.CHANGE Dispatched when the collection changes.

	@event feathers.events.HierarchicalCollectionEvent.ADD_ITEM Dispatched when
	an item is added to the collection.

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ITEM Dispatched
	when an item is removed from the collection.

	@event feathers.events.HierarchicalCollectionEvent.REPLACE_ITEM Dispatched
	when an item is replaced in the collection.

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ALL Dispatched
	when all items are removed from the collection.

	@event feathers.events.HierarchicalCollectionEvent.RESET Dispatched
	when the source of the collection is changed.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ITEM Dispatched
	when `IHierarchicalCollection.updateItem()` is called.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ALL Dispatched
	when `IHierarchicalCollection.updateAll()` is called.

	@event feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE Dispatched
	when `IHierarchicalCollection.filterFunction` is changed.

	@event feathers.events.HierarchicalCollectionEvent.SORT_CHANGE Dispatched
	when `IHierarchicalCollection.sortCompareFunction` is changed.

	@see `feathers.controls.TreeView`
	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
@:deprecated("Replaced by ArrayHierarchicalCollection")
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.HierarchicalCollectionEvent.ADD_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REMOVE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REPLACE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REMOVE_ALL)
@:event(feathers.events.HierarchicalCollectionEvent.RESET)
@:event(feathers.events.HierarchicalCollectionEvent.UPDATE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.UPDATE_ALL)
@:event(feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE)
@:event(feathers.events.HierarchicalCollectionEvent.SORT_CHANGE)
@defaultXmlProperty("array")
@:forward
abstract TreeCollection<T>(ArrayHierarchicalCollection<TreeNode<T>>) to IHierarchicalCollection<TreeNode<T>> {
	/**
		Creates a new `TreeCollection` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?array:Array<TreeNode<T>>) {
		this = new ArrayHierarchicalCollection<TreeNode<T>>(array, treeNodeItemToChildren);
	}

	private static function treeNodeItemToChildren<T>(item:TreeNode<T>):Array<TreeNode<T>> {
		return item.children;
	}
}
