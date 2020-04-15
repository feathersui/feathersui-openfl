/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	A node in a `TreeCollection` object.

	@see `feathers.data.TreeCollection`

	@since 1.0.0
**/
class TreeNode<T> {
	/**
		Creates a new `TreeNode` object with the given arguments.

		@since 1.0.0
	**/
	public function new(data:T, ?children:Array<TreeNode<T>>) {
		this.data = data;
		this.children = children;
	}

	/**
		The data associated with this tree node.

		@since 1.0.0
	**/
	public var data:T;

	/**
		The children of this tree node. If this property is `null`, then this
		node is not a branch and has no children. If this property is an empty
		array, then this node is a branch with no children.

		@since 1.0.0
	**/
	public var children:Array<TreeNode<T>>;

	/**
		Indicates if this node is a branch or a leaf. A branch may contain
		zero or more children. If the `children` is not `null`, then this node
		is a branch.

		@since 1.0.0
	**/
	public function isBranch():Bool {
		return this.children != null;
	}
}
