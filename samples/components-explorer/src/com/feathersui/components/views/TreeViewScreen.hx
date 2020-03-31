package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
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

		var items = [];
		for (i in 0...30) {
			items[i] = {text: "Tree Item " + (i + 1)};
		}

		this.treeView = new TreeView();
		this.treeView.dataProvider = new ArrayCollection(items);
		this.treeView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.addEventListener(Event.CHANGE, treeView_changeHandler);
		this.addChild(this.treeView);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Tree View";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function treeView_changeHandler(event:Event):Void {
		var selectedItem = this.treeView.selectedItem;
		trace("TreeView selectedItem change: " + this.treeView.itemToText(selectedItem));
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
