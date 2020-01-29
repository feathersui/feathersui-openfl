package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Callout;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class CalloutScreen extends Panel {
	private var callout:Callout;
	private var content:Panel;
	private var belowButton:Button;
	private var aboveButton:Button;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.belowButton = new Button();
		this.belowButton.text = "Open Below";
		this.belowButton.addEventListener(TriggerEvent.TRIGGER, belowButton_triggerHandler);
		var belowButtonLayoutData = new AnchorLayoutData();
		belowButtonLayoutData.horizontalCenter = 0.0;
		belowButtonLayoutData.top = 10.0;
		this.belowButton.layoutData = belowButtonLayoutData;
		this.addChild(this.belowButton);

		this.aboveButton = new Button();
		this.aboveButton.text = "Open Above";
		this.aboveButton.addEventListener(TriggerEvent.TRIGGER, aboveButton_triggerHandler);
		var aboveButtonLayoutData = new AnchorLayoutData();
		aboveButtonLayoutData.horizontalCenter = 0.0;
		aboveButtonLayoutData.bottom = 10.0;
		this.aboveButton.layoutData = aboveButtonLayoutData;
		this.addChild(this.aboveButton);

		this.content = new Panel();
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Callout Content";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);
		this.content.header = header;

		this.content.layout = new AnchorLayout();
		var description = new Label();
		description.text = "A callout displays content in a pop-up container, with an arrow that points to its origin.\n\nTap anywhere outside of the callout to close it.";
		description.layoutData = AnchorLayoutData.fill();
		this.content.addChild(description);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Callout";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = new AnchorLayoutData(null, null, null, 10.0, null, 0.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function belowButton_triggerHandler(event:TriggerEvent):Void {
		Callout.show(this.content, this.belowButton);
	}

	private function aboveButton_triggerHandler(event:TriggerEvent):Void {
		Callout.show(this.content, this.aboveButton);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
