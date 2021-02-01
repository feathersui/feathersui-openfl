package com.feathersui.components.views;

import feathers.controls.Header;
import feathers.controls.Button;
import feathers.controls.HProgressBar;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.VProgressBar;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ProgressBarScreen extends Panel {
	private var horizontalProgress:HProgressBar;
	private var verticalProgress:VProgressBar;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.horizontalProgress = new HProgressBar();
		this.horizontalProgress.minimum = 0.0;
		this.horizontalProgress.maximum = 100.0;
		this.horizontalProgress.value = 45.0;
		this.horizontalProgress.layoutData = AnchorLayoutData.center(-40.0);
		this.addChild(this.horizontalProgress);

		this.verticalProgress = new VProgressBar();
		this.verticalProgress.minimum = 0.0;
		this.verticalProgress.maximum = 100.0;
		this.verticalProgress.value = 45.0;
		this.verticalProgress.layoutData = AnchorLayoutData.center(120.0);
		this.addChild(this.verticalProgress);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Progress Bar";
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
