/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IOpenCloseToggle;
import feathers.utils.DisplayObjectRecycler;
import feathers.data.ArrayHierarchicalCollection;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.layout.ILayoutIndexObject;
import feathers.controls.dataRenderers.ITreeViewItemRenderer;
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

	private function compareLocations(location1:Array<Int>, location2:Array<Int>):Int {
		var null1 = location1 == null;
		var null2 = location2 == null;
		if (null1 && null2) {
			return 0;
		} else if (null1) {
			return 1;
		} else if (null2) {
			return -1;
		}
		var length1 = location1.length;
		var length2 = location2.length;
		var min = length1;
		if (length2 < min) {
			min = length2;
		}
		for (i in 0...min) {
			var index1 = location1[i];
			var index2 = location2[i];
			if (index1 < index2) {
				return -1;
			}
			if (index1 > index2) {
				return 1;
			}
		}
		if (length1 < length2) {
			return -1;
		} else if (length1 > length2) {
			return 1;
		}
		return 0;
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

	public function testUpdateItemSetsInterfaceProperties():Void {
		var children:Array<Dynamic> = [{text: "One"}, {text: "Two", children: []}, {text: "Three"}];
		var items:Array<Dynamic> = [{text: "A", children: children}];
		this._treeView.dataProvider = new ArrayHierarchicalCollection(items, (item:Dynamic) -> item.children);
		var itemLocation = [0, 1];
		var item = this._treeView.dataProvider.get(itemLocation);
		this._treeView.selectedLocation = itemLocation;
		this._treeView.toggleBranch(this._treeView.dataProvider.get([0]), true);
		this._treeView.toggleBranch(item, true);
		this._treeView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._treeView.validateNow();
		var sampleItemRenderer = cast(this._treeView.itemToItemRenderer(item), CustomRendererWithInterfaces);
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		var setSelectedValues = sampleItemRenderer.setSelectedValues;
		var setLocationValues = sampleItemRenderer.setLocationValues;
		var setOpenedValues = sampleItemRenderer.setOpenedValues;
		var setBranchValues = sampleItemRenderer.setBranchValues;
		var setTreeViewOwnerValues = sampleItemRenderer.setTreeViewOwnerValues;
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);
		Assert.equals(1, setSelectedValues.length);
		Assert.equals(1, setLocationValues.length);
		Assert.equals(1, setOpenedValues.length);
		Assert.equals(1, setBranchValues.length);
		Assert.equals(1, setTreeViewOwnerValues.length);

		this._treeView.dataProvider.updateAt(itemLocation);

		Assert.equals(3, setDataValues.length);
		Assert.equals(item, setDataValues[0]);
		Assert.isNull(setDataValues[1]);
		Assert.equals(item, setDataValues[2]);

		Assert.equals(3, setLayoutIndexValues.length);
		Assert.equals(2, setLayoutIndexValues[0]);
		Assert.equals(-1, setLayoutIndexValues[1]);
		Assert.equals(2, setLayoutIndexValues[2]);

		Assert.equals(3, setSelectedValues.length);
		Assert.equals(true, setSelectedValues[0]);
		Assert.equals(false, setSelectedValues[1]);
		Assert.equals(true, setSelectedValues[2]);

		Assert.equals(3, setLocationValues.length);
		Assert.equals(0, compareLocations(itemLocation, setLocationValues[0]));
		Assert.isNull(setLocationValues[1]);
		Assert.equals(0, compareLocations(itemLocation, setLocationValues[2]));

		Assert.equals(3, setBranchValues.length);
		Assert.equals(true, setBranchValues[0]);
		Assert.equals(false, setBranchValues[1]);
		Assert.equals(true, setBranchValues[2]);

		Assert.equals(3, setOpenedValues.length);
		Assert.equals(true, setOpenedValues[0]);
		Assert.equals(false, setOpenedValues[1]);
		Assert.equals(true, setOpenedValues[2]);

		Assert.equals(3, setTreeViewOwnerValues.length);
		Assert.equals(this._treeView, setTreeViewOwnerValues[0]);
		Assert.isNull(setTreeViewOwnerValues[1]);
		Assert.equals(this._treeView, setTreeViewOwnerValues[2]);
	}
}

private class CustomRendererWithInterfaces extends LayoutGroup implements IToggle implements IOpenCloseToggle implements IDataRenderer
		implements ILayoutIndexObject implements ITreeViewItemRenderer {
	public function new() {
		super();
	}

	public var setDataValues:Array<Dynamic> = [];

	private var _data:Dynamic;

	@:flash.property
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return _data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (_data == value) {
			return _data;
		}
		_data = value;
		setDataValues.push(value);
		return _data;
	}

	public var setLayoutIndexValues:Array<Int> = [];

	private var _layoutIndex:Int = -1;

	@:flash.property
	public var layoutIndex(get, set):Int;

	private function get_layoutIndex():Int {
		return _layoutIndex;
	}

	private function set_layoutIndex(value:Int):Int {
		if (_layoutIndex == value) {
			return _layoutIndex;
		}
		_layoutIndex = value;
		setLayoutIndexValues.push(value);
		return _layoutIndex;
	}

	public var setSelectedValues:Array<Bool> = [];

	private var _selected:Bool;

	@:flash.property
	public var selected(get, set):Bool;

	private function get_selected():Bool {
		return _selected;
	}

	private function set_selected(value:Bool):Bool {
		if (_selected == value) {
			return _selected;
		}
		_selected = value;
		setSelectedValues.push(value);
		return _selected;
	}

	public var setBranchValues:Array<Bool> = [];

	private var _branch:Bool;

	@:flash.property
	public var branch(get, set):Bool;

	private function get_branch():Bool {
		return _branch;
	}

	private function set_branch(value:Bool):Bool {
		if (_branch == value) {
			return _branch;
		}
		_branch = value;
		setBranchValues.push(value);
		return _branch;
	}

	public var setOpenedValues:Array<Bool> = [];

	private var _opened:Bool;

	@:flash.property
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		return _opened;
	}

	private function set_opened(value:Bool):Bool {
		if (_opened == value) {
			return _opened;
		}
		_opened = value;
		setOpenedValues.push(value);
		return _opened;
	}

	public var setLocationValues:Array<Array<Int>> = [];

	private var _location:Array<Int>;

	@:flash.property
	public var location(get, set):Array<Int>;

	private function get_location():Array<Int> {
		return _location;
	}

	private function set_location(value:Array<Int>):Array<Int> {
		if (_location == value) {
			return _location;
		}
		_location = value;
		setLocationValues.push(value);
		return _location;
	}

	public var setTreeViewOwnerValues:Array<TreeView> = [];

	private var _treeViewOwner:TreeView;

	@:flash.property
	public var treeViewOwner(get, set):TreeView;

	private function get_treeViewOwner():TreeView {
		return _treeViewOwner;
	}

	private function set_treeViewOwner(value:TreeView):TreeView {
		if (_treeViewOwner == value) {
			return _treeViewOwner;
		}
		_treeViewOwner = value;
		setTreeViewOwnerValues.push(value);
		return _treeViewOwner;
	}
}
