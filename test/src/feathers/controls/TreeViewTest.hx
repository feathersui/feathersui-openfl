/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import massive.munit.Assert;

@:keep
class TreeViewTest {
	private var _treeView:TreeView;

	@Before
	public function prepare():Void {
		this._treeView = new TreeView();
		TestMain.openfl_root.addChild(this._treeView);
	}

	@After
	public function cleanup():Void {
		if (this._treeView.parent != null) {
			this._treeView.parent.removeChild(this._treeView);
		}
		this._treeView = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testValidateWithNullDataProvider():Void {
		this._treeView.validateNow();
	}

	@Test
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
	}
}
