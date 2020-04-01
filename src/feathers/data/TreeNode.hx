/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

class TreeNode<T> {
	public function new(data:T, ?children:Array<TreeNode<T>>) {
		this.data = data;
		this.children = children;
	}

	public var data:T;
	public var children:Array<TreeNode<T>>;

	public function isBranch():Bool {
		return this.children != null;
	}
}
