package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.TreeView;
import feathers.data.ArrayHierarchicalCollection;
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

		var data:Array<ItemType> = [
			{
				text: "Node 1",
				children: [
					{
						text: "Node 1A",
						children: [
							{text: "Node 1A-I"},
							{text: "Node 1A-II"},
							{text: "Node 1A-III"},
							{text: "Node 1A-IV"}
						]
					},
					{text: "Node 1B"},
					{text: "Node 1C"}
				]
			},
			{
				text: "Node 2",
				children: [{text: "Node 2A"}, {text: "Node 2B"}, {text: "Node 2C"}]
			},
			{text: "Node 3"},
			{
				text: "Node 4",
				children: [
					{text: "Node 4A"},
					{text: "Node 4B"},
					{text: "Node 4C"},
					{text: "Node 4D"},
					{text: "Node 4E"}
				]
			}
		];

		this.treeView = new TreeView();
		this.treeView.variant = TreeView.VARIANT_BORDERLESS;
		this.treeView.dataProvider = new ArrayHierarchicalCollection(data, item -> item.children);
		this.treeView.itemToText = (item:ItemType) -> {
			return item.text;
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

private typedef ItemType = {text:String, ?children:Array<ItemType>};
