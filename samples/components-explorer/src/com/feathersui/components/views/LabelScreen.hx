package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class LabelScreen extends Panel {
	private var label:Label;
	private var headingLabel:Label;
	private var detailLabel:Label;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20.0;
		this.layout = layout;

		this.label = new Label();
		this.label.text = "Label";
		this.addChild(this.label);

		this.headingLabel = new Label();
		this.headingLabel.variant = Label.VARIANT_HEADING;
		this.headingLabel.text = "A heading label displays larger text";
		this.addChild(this.headingLabel);

		this.detailLabel = new Label();
		this.detailLabel.variant = Label.VARIANT_DETAIL;
		this.detailLabel.text = "A detail label displays smaller text";
		this.addChild(this.detailLabel);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Label";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = new AnchorLayoutData(null, null, null, 10.0, null, 0.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
