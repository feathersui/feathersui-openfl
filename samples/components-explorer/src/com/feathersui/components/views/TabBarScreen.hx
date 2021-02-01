package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.TabBar;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class TabBarScreen extends Panel {
	private var tabBar:TabBar;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var items = [];
		for (i in 0...3) {
			items[i] = {text: "Tab " + (i + 1)};
		}

		this.tabBar = new TabBar();
		this.tabBar.dataProvider = new ArrayCollection(items);
		this.tabBar.itemToText = (data:Dynamic) -> {
			return data.text;
		};
		this.tabBar.layoutData = AnchorLayoutData.center();
		this.tabBar.addEventListener(Event.CHANGE, tabBar_changeHandler);
		this.addChild(this.tabBar);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Tab Bar";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function tabBar_changeHandler(event:Event):Void {
		trace("TabBar selectedIndex change: " + this.tabBar.selectedIndex);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
