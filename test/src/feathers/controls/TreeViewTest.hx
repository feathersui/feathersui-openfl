/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import utest.Assert;
import utest.Test;

@:keep
class TreeViewTest extends Test {
	private var _treeView:TreeView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._treeView = new TreeView();
		TestMain.openfl_root.addChild(this._treeView);
	}

	public function teardown():Void {
		if (this._treeView.parent != null) {
			this._treeView.parent.removeChild(this._treeView);
		}
		this._treeView = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._treeView.validateNow();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._treeView.dataProvider = new TreeCollection([
			new TreeNode({text: "Node 1"},
				[
					new TreeNode({text: "Node 1A"},
						[
							new TreeNode({text: "Node 1A-I"}),
							new TreeNode({text: "Node 1A-II"}),
							new TreeNode({text: "Node 1A-III"}),
						]),
					new TreeNode({text: "Node 1B"}),
					new TreeNode({text: "Node 1C"})
				]),
			new TreeNode({text: "Node 2"}, [new TreeNode({text: "Node 2A"}),]),
			new TreeNode({text: "Node 3"}),
			new TreeNode({text: "Node 4"}, [new TreeNode({text: "Node 4A"}), new TreeNode({text: "Node 4B"}),])
		]);
		this._treeView.validateNow();
		this._treeView.dataProvider = null;
		this._treeView.validateNow();
		Assert.pass();
	}
}
