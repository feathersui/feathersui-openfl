package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.ButtonBar;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
import feathers.events.ButtonBarEvent;
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

		// data containers may display any type of data. in this case, we're
		// defining a custom typedef at the end of this file that we've named
		// SimpleTextItem. a custom class could be used instead, if preferred.
		// you could also skip creating a custom type and use Dynamic or Any.
		var items:Array<SimpleTextItem> = [];
		for (i in 0...3) {
			items[i] = {text: "Button " + (i + 1)};
		}

		this.buttonBar = new ButtonBar();
		this.buttonBar.dataProvider = new ArrayCollection(items);
		this.buttonBar.itemToText = (data:SimpleTextItem) -> {
			return data.text;
		};
		this.buttonBar.layoutData = AnchorLayoutData.center();
		this.buttonBar.addEventListener(ButtonBarEvent.ITEM_TRIGGER, buttonBar_itemTriggerHandler);
		this.addChild(this.buttonBar);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Button Bar";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function buttonBar_itemTriggerHandler(event:ButtonBarEvent):Void {
		trace("ButtonBar item trigger: " + event.state.text);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

private typedef SimpleTextItem = {
	text:String
}
