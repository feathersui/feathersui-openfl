package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.TreeView;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import feathers.events.TreeViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class TreeViewScreen extends Panel {
	private var treeView:TreeView;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var data = [
			new TreeNode({text: "Node 1"}, [
				new TreeNode({text: "Node 1A"}, [
					new TreeNode({text: "Node 1A-I"}),
					new TreeNode({text: "Node 1A-II"}),
					new TreeNode({text: "Node 1A-III"}),
					new TreeNode({text: "Node 1A-IV"})
				]),
				new TreeNode({text: "Node 1B"}),
				new TreeNode({text: "Node 1C"})
			]),
			new TreeNode({text: "Node 2"}, [
				new TreeNode({text: "Node 2A"}),
				new TreeNode({text: "Node 2B"}),
				new TreeNode({text: "Node 2C"})
			]),
			new TreeNode({text: "Node 3"}),
			new TreeNode({text: "Node 4"}, [
				new TreeNode({text: "Node 4A"}),
				new TreeNode({text: "Node 4B"}),
				new TreeNode({text: "Node 4C"}),
				new TreeNode({text: "Node 4D"}),
				new TreeNode({text: "Node 4E"})
			])
		];

		this.treeView = new TreeView();
		this.treeView.variant = TreeView.VARIANT_BORDERLESS;
		this.treeView.dataProvider = new TreeCollection(data);
		this.treeView.itemToText = (item) -> {
			return item.data.text;
		};
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.addEventListener(Event.CHANGE, treeView_changeHandler);
		this.treeView.addEventListener(TreeViewEvent.ITEM_TRIGGER, treeView_itemTriggerHandler);
		this.addChild(this.treeView);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Tree View";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function treeView_changeHandler(event:Event):Void {
		var selectedItem = this.treeView.selectedItem;
		trace("TreeView selectedItem change: " + this.treeView.itemToText(selectedItem));
	}

	private function treeView_itemTriggerHandler(event:TreeViewEvent):Void {
		trace("TreeView item trigger: " + event.state.text);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
