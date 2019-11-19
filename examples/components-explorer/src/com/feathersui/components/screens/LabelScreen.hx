package com.feathersui.components.screens;

import feathers.events.FeathersEvent;
import feathers.layout.VerticalAlign;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;

class LabelScreen extends Panel {
	private var label:Label;
	private var headingLabel:Label;
	private var detailLabel:Label;

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20;
		this.layout = layout;

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Label";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(FeathersEvent.TRIGGERED, backButton_triggeredHandler);
			header.addChild(backButton);

			return header;
		};

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

	private function backButton_triggeredHandler(event:FeathersEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
