package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.Radio;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class RadioScreen extends Panel {
	private var radio:Radio;
	private var selectedRadio:Radio;
	private var disabledRadio:Radio;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20.0;
		this.layout = layout;

		this.radio = new Radio();
		this.radio.text = "Radio";
		this.addChild(this.radio);

		this.selectedRadio = new Radio();
		this.selectedRadio.text = "Selected Radio";
		this.selectedRadio.selected = true;
		this.addChild(this.selectedRadio);

		this.disabledRadio = new Radio();
		this.disabledRadio.text = "Disabled Radio";
		this.disabledRadio.enabled = false;
		this.addChild(this.disabledRadio);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Radio";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
