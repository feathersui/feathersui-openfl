package com.feathersui.components.screens;

import feathers.controls.Label;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.HProgressBar;
import feathers.controls.LayoutGroup;

class ProgressBarScreen extends LayoutGroup {
	private var horizontalProgress:HProgressBar;
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
		this.headerTitle.text = "Progress Bar";
		this.headerTitle.layoutData = AnchorLayoutData.center();
		this.header.addChild(this.headerTitle);

		this.backButton = new Button();
		this.backButton.text = "Back";
		this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
		this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
		this.header.addChild(this.backButton);

		this.horizontalProgress = new HProgressBar();
		this.horizontalProgress.minimum = 0.0;
		this.horizontalProgress.maximum = 100.0;
		this.horizontalProgress.value = 45.0;
		this.horizontalProgress.layoutData = AnchorLayoutData.center(-40);
		this.addChild(this.horizontalProgress);

		/*this.verticalProgress = new VProgressBar();
			this.verticalProgress.layoutData = AnchorLayoutData.center(120);
			this.addChild(this.verticalProgress); */
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
