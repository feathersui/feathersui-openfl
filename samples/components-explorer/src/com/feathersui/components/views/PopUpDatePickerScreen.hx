package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.PopUpDatePicker;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class PopUpDatePickerScreen extends Panel {
	private var datePicker:PopUpDatePicker;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.datePicker = new PopUpDatePicker();
		this.datePicker.layoutData = AnchorLayoutData.center();
		this.datePicker.addEventListener(Event.CHANGE, datePicker_changeHandler);
		this.addChild(this.datePicker);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Pop Up Date Picker";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function datePicker_changeHandler(event:Event):Void {
		trace("PopUpDatePicker selectedDate change: " + this.datePicker.selectedDate);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
