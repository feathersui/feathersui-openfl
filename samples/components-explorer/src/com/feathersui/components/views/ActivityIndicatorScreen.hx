package com.feathersui.components.views;

import feathers.controls.ActivityIndicator;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ActivityIndicatorScreen extends Panel {
	private var activityIndicator:ActivityIndicator;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.activityIndicator = new ActivityIndicator();
		this.activityIndicator.layoutData = AnchorLayoutData.center();
		this.addChild(this.activityIndicator);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Activity Indicator";
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
