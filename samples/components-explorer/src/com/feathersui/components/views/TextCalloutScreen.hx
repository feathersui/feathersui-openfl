package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.TextCallout;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.RelativePosition;
import openfl.events.Event;

class TextCalloutScreen extends Panel {
	private var topButton:Button;
	private var rightButton:Button;
	private var bottomButton:Button;
	private var leftButton:Button;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.topButton = new Button();
		this.topButton.text = "Open Top";
		this.topButton.addEventListener(TriggerEvent.TRIGGER, topButton_triggerHandler);
		this.topButton.layoutData = AnchorLayoutData.bottomRight(10.0, 10.0);
		this.addChild(this.topButton);

		this.rightButton = new Button();
		this.rightButton.text = "Open Right";
		this.rightButton.addEventListener(TriggerEvent.TRIGGER, rightButton_triggerHandler);
		this.rightButton.layoutData = AnchorLayoutData.bottomLeft(10.0, 10.0);
		this.addChild(this.rightButton);

		this.bottomButton = new Button();
		this.bottomButton.text = "Open Bottom";
		this.bottomButton.addEventListener(TriggerEvent.TRIGGER, bottomButton_triggerHandler);
		this.bottomButton.layoutData = AnchorLayoutData.topLeft(10.0, 10.0);
		this.addChild(this.bottomButton);

		this.leftButton = new Button();
		this.leftButton.text = "Open Left";
		this.leftButton.addEventListener(TriggerEvent.TRIGGER, leftButton_triggerHandler);
		this.leftButton.layoutData = AnchorLayoutData.topRight(10.0, 10.0);
		this.addChild(this.leftButton);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Text Callout";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function topButton_triggerHandler(event:TriggerEvent):Void {
		TextCallout.show("Hello, Feathers UI", this.topButton, RelativePosition.TOP);
	}

	private function rightButton_triggerHandler(event:TriggerEvent):Void {
		TextCallout.show("Hello, Feathers UI", this.rightButton, RelativePosition.RIGHT);
	}

	private function bottomButton_triggerHandler(event:TriggerEvent):Void {
		TextCallout.show("Hello, Feathers UI", this.bottomButton, RelativePosition.BOTTOM);
	}

	private function leftButton_triggerHandler(event:TriggerEvent):Void {
		TextCallout.show("Hello, Feathers UI", this.leftButton, RelativePosition.LEFT);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
