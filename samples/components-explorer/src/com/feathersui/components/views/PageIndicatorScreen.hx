package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.PageIndicator;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class PageIndicatorScreen extends Panel {
	private var pages:PageIndicator;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.pages = new PageIndicator();
		this.pages.maxSelectedIndex = 5;
		this.pages.layoutData = AnchorLayoutData.center();
		this.pages.addEventListener(Event.CHANGE, pageIndicator_changeHandler);
		this.addChild(this.pages);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Page Indicator";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function pageIndicator_changeHandler(event:Event):Void {
		trace("PageIndicator selectedIndex change: " + this.pages.selectedIndex);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
