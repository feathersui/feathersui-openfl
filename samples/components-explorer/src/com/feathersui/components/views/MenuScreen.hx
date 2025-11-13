package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Menu;
import feathers.controls.Panel;
import feathers.data.ArrayHierarchicalCollection;
import feathers.events.MenuEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class MenuScreen extends Panel {
	private var button:Button;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.button = new Button();
		this.button.text = "Click to Show Menu";
		this.button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
		this.button.layoutData = AnchorLayoutData.topCenter(10.0);
		this.addChild(this.button);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Menu";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function button_triggerHandler(event:TriggerEvent):Void {
		// data containers may display any type of data. in this case, we're
		// defining a custom typedef at the end of this file that we've named
		// MenuItemData. a custom class could be used instead, if preferred.
		// you could also skip creating a custom type and use Dynamic or Any.
		var items:Array<MenuItemData> = [
			// @formatter:off
			{
				text: "A",
				children: [
					{text: "A1"},
					{text: "A2"},
					{separator: true},
					{
						text: "A3",
						children: [
							{text: "A3-x"},
							{text: "A3-y"},
							{text: "A3-z"},
						]
					},
				]
			},
			{
				text: "B",
				children: [
					{text: "B1"},
					{separator: true},
					{text: "B2"},
					{text: "B3"}
				]
			},
			{
				text: "C",
				children: [
					{text: "C1"},
					{text: "C2"}
				]
			}
			// @formatter:on
		];

		var menu = new Menu();
		menu.dataProvider = new ArrayHierarchicalCollection<MenuItemData>(items, (item:MenuItemData) -> item.children);
		menu.itemToText = (item:MenuItemData) -> {
			return item.text;
		};
		menu.itemToSeparator = (item:MenuItemData) -> {
			return item.separator != null && item.separator == true;
		}
		menu.addEventListener(MenuEvent.ITEM_TRIGGER, menu_itemTriggerHandler);
		menu.showAtOrigin(this.button);
	}

	private function menu_itemTriggerHandler(event:MenuEvent):Void {
		trace("Menu itemTrigger: " + event.state.text);
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
