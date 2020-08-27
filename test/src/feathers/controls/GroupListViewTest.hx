/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import massive.munit.Assert;

@:keep
class GroupListViewTest {
	private var _listView:GroupListView;

	@Before
	public function prepare():Void {
		this._listView = new GroupListView();
		TestMain.openfl_root.addChild(this._listView);
	}

	@After
	public function cleanup():Void {
		if (this._listView.parent != null) {
			this._listView.parent.removeChild(this._listView);
		}
		this._listView = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testValidateWithNullDataProvider():Void {
		this._listView.validateNow();
	}

	@Test
	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._listView.dataProvider = new TreeCollection([
			new TreeNode({text: "Group A"},
				[
					new TreeNode({text: "Node A1"}),
					new TreeNode({text: "Node A2"}),
					new TreeNode({text: "Node A3"}),
				]),
			new TreeNode({text: "Group B"}, [new TreeNode({text: "Node B1"}), new TreeNode({text: "Node B2"}),]),
			new TreeNode({text: "Group C"}, [new TreeNode({text: "Node C1"})])
		]);
		this._listView.validateNow();
		this._listView.dataProvider = null;
		this._listView.validateNow();
	}
}
