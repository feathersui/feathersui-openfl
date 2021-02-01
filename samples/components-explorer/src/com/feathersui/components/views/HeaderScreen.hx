package com.feathersui.components.views;

import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.Header;
import feathers.controls.Button;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import openfl.events.Event;

class HeaderScreen extends Panel {
	private var sampleHeader:Header;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.sampleHeader = new Header();
		this.sampleHeader.text = "The Header Title";
		this.sampleHeader.layoutData = AnchorLayoutData.center();
		this.addChild(this.sampleHeader);

		var leftView = new Button();
		leftView.text = "Left View";
		this.sampleHeader.leftView = leftView;

		var rightView = new Button();
		rightView.text = "Right View";
		this.sampleHeader.rightView = rightView;
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Header";
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
