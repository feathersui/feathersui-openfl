package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.NumericStepper;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class NumericStepperScreen extends Panel {
	private var stepper:NumericStepper;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.stepper = new NumericStepper();
		this.stepper.minimum = 0.0;
		this.stepper.maximum = 1.0;
		this.stepper.value = 0.4;
		this.stepper.layoutData = AnchorLayoutData.center();
		this.stepper.addEventListener(Event.CHANGE, numericStepper_changeHandler);
		this.addChild(this.stepper);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Numeric Stepper";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function numericStepper_changeHandler(event:Event):Void {
		trace("NumericStepper value change: " + this.stepper.value);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
