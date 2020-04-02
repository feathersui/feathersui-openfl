package com.feathersui.components.views;

import feathers.controls.PageIndicator;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.TabBar;
import feathers.data.ArrayCollection;
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
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Page Indicator";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function pageIndicator_changeHandler(event:Event):Void {
		trace("PageIndicator selectedIndex change: " + this.pages.selectedIndex);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
