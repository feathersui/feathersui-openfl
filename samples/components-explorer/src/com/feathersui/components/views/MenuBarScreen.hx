package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.MenuBar;
import feathers.controls.Panel;
import feathers.data.ArrayHierarchicalCollection;
import feathers.events.MenuEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class MenuBarScreen extends Panel {
	private var menuBar:MenuBar;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		// data containers may display any type of data. in this case, we're
		// defining a custom typedef at the end of this file that we've named
		// MenuItemData. a custom class could be used instead, if preferred.
		// you could also skip creating a custom type and use Dynamic or Any.
		var items:Array<MenuItemData> = [
			// @formatter:off
			{
				text: "File",
				children: [
					{text: "New"},
					{text: "Open"},
					{
						text: "Open Recent",
						children: [
							{text: "Document.docx"},
							{text: "Spreadsheet.xlsx"},
							{text: "Presentation.pptx"}
						]
					},
					{separator: true},
					{text: "Save"},
					{separator: true},
					{text: "Quit"}
				]
			},
			{
				text: "Edit",
				children: [
					{text: "Undo"},
					{text: "Redo"},
					{separator: true},
					{text: "Cut"},
					{text: "Copy"},
					{text: "Paste"}
				]
			},
			{
				text: "Help",
				children: [
					{text: "Contents"},
					{text: "About"}
				]
			}
			// @formatter:on
		];

		this.menuBar = new MenuBar();
		this.menuBar.dataProvider = new ArrayHierarchicalCollection<MenuItemData>(items, (item:MenuItemData) -> item.children);
		this.menuBar.itemToText = (item:MenuItemData) -> {
			return item.text;
		};
		this.menuBar.itemToSeparator = (item:MenuItemData) -> {
			return item.separator != null && item.separator == true;
		}
		this.menuBar.layoutData = AnchorLayoutData.topCenter(10.0);
		this.menuBar.addEventListener(MenuEvent.ITEM_TRIGGER, menuBar_itemTriggerHandler);
		this.addChild(this.menuBar);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Menu Bar";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function menuBar_itemTriggerHandler(event:MenuEvent):Void {
		trace("MenuBar itemTrigger: " + event.state.text);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

private typedef MenuItemData = {
	?text:String,
	?children:Array<MenuItemData>,
	?separator:Bool
}
