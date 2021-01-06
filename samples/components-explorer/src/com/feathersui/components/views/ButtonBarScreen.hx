package com.feathersui.components.views;

import feathers.events.ButtonBarEvent;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ButtonBar;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ButtonBarScreen extends Panel {
	private var buttonBar:ButtonBar;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var items = [];
		for (i in 0...3) {
			items[i] = {text: "Button " + (i + 1)};
		}

		this.buttonBar = new ButtonBar();
		this.buttonBar.dataProvider = new ArrayCollection(items);
		this.buttonBar.itemToText = (data:Dynamic) -> {
			return data.text;
		};
		this.buttonBar.layoutData = AnchorLayoutData.center();
		this.buttonBar.addEventListener(ButtonBarEvent.ITEM_TRIGGER, buttonBar_itemTriggerHandler);
		this.addChild(this.buttonBar);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Button Bar";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function buttonBar_itemTriggerHandler(event:ButtonBarEvent):Void {
		trace("ButtonBar item trigger: " + event.state.text);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
