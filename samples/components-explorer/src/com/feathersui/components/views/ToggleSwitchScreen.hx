package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.ToggleSwitch;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import openfl.events.Event;

class ToggleSwitchScreen extends Panel {
	private var toggle:ToggleSwitch;
	private var selectedToggle:ToggleSwitch;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new HorizontalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20.0;
		this.layout = layout;

		this.toggle = new ToggleSwitch();
		this.toggle.addEventListener(Event.CHANGE, toggleSwitch_changeHandler);
		this.addChild(this.toggle);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Toggle Switch";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function toggleSwitch_changeHandler(event:Event):Void {
		trace("ToggleSwitch selected change: " + this.toggle.selected);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
