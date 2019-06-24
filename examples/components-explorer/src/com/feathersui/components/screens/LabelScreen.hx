package com.feathersui.components.screens;

import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;

class LabelScreen extends LayoutGroup {
	private var label:Label;
	private var headingLabel:Label;
	private var detailLabel:Label;
	private var header:LayoutGroup;
	private var headerTitle:Label;
	private var backButton:Button;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.header = new LayoutGroup();
		this.header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		this.header.layout = new AnchorLayout();
		this.header.layoutData = new AnchorLayoutData(0, 0, null, 0);
		this.addChild(this.header);

		this.headerTitle = new Label();
		this.headerTitle.variant = Label.VARIANT_HEADING;
		this.headerTitle.text = "Label";
		this.headerTitle.layoutData = AnchorLayoutData.center();
		this.header.addChild(this.headerTitle);

		this.backButton = new Button();
		this.backButton.text = "Back";
		this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
		this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
		this.header.addChild(this.backButton);

		this.label = new Label();
		this.label.text = "Label";
		this.label.layoutData = AnchorLayoutData.center(0, -50);
		this.addChild(this.label);

		this.headingLabel = new Label();
		this.headingLabel.variant = Label.VARIANT_HEADING;
		this.headingLabel.text = "A heading label displays larger text";
		this.headingLabel.layoutData = AnchorLayoutData.center();
		this.addChild(this.headingLabel);

		this.detailLabel = new Label();
		this.detailLabel.variant = Label.VARIANT_DETAIL;
		this.detailLabel.text = "A detail label displays smaller text";
		this.detailLabel.layoutData = AnchorLayoutData.center(0, 50);
		this.addChild(this.detailLabel);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
