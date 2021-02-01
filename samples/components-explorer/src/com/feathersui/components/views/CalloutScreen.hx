package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Callout;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class CalloutScreen extends Panel {
	private var content:Panel;
	private var belowButton:Button;
	private var aboveButton:Button;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.belowButton = new Button();
		this.belowButton.text = "Open Below";
		this.belowButton.addEventListener(TriggerEvent.TRIGGER, belowButton_triggerHandler);
		this.belowButton.layoutData = AnchorLayoutData.topCenter(10.0);
		this.addChild(this.belowButton);

		this.aboveButton = new Button();
		this.aboveButton.text = "Open Above";
		this.aboveButton.addEventListener(TriggerEvent.TRIGGER, aboveButton_triggerHandler);
		this.aboveButton.layoutData = AnchorLayoutData.bottomCenter(10.0);
		this.addChild(this.aboveButton);

		this.content = new Panel();
		var header = new Header();
		header.text = "Callout Content";
		this.content.header = header;

		this.content.layout = new AnchorLayout();
		var description = new Label();
		description.text = "A callout displays content in a pop-up container, with an arrow that points to its origin.\n\nTap anywhere outside of the callout to close it.";
		description.wordWrap = true;
		description.layoutData = AnchorLayoutData.fill();
		this.content.addChild(description);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Callout";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function belowButton_triggerHandler(event:TriggerEvent):Void {
		Callout.show(this.content, this.belowButton);
	}

	private function aboveButton_triggerHandler(event:TriggerEvent):Void {
		Callout.show(this.content, this.aboveButton);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
