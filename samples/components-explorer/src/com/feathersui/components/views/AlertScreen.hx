package com.feathersui.components.views;

import feathers.controls.Alert;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class AlertScreen extends Panel {
	private var showAlertButton:Button;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.showAlertButton = new Button();
		this.showAlertButton.text = "Show an Alert";
		this.showAlertButton.layoutData = AnchorLayoutData.center();
		this.showAlertButton.addEventListener(TriggerEvent.TRIGGER, showAlertButton_triggerHandler);
		this.addChild(this.showAlertButton);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Alert";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function showAlertButton_triggerHandler(event:TriggerEvent):Void {
		Alert.show("Something went wrong.", "Error", ["OK", "Cancel"], (buttonState) -> {
			trace("Triggered alert button: " + buttonState.text);
		});
	}
}
