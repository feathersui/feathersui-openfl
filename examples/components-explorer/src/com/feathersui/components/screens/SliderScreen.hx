package com.feathersui.components.screens;

import feathers.controls.Label;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.HSlider;
import feathers.controls.VSlider;
import feathers.controls.LayoutGroup;

class SliderScreen extends LayoutGroup {
	private var horizontalSlider:HSlider;
	private var verticalSlider:VSlider;
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
		this.headerTitle.text = "Slider";
		this.headerTitle.layoutData = AnchorLayoutData.center();
		this.header.addChild(this.headerTitle);

		this.backButton = new Button();
		this.backButton.text = "Back";
		this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
		this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
		this.header.addChild(this.backButton);

		this.horizontalSlider = new HSlider();
		this.horizontalSlider.minimum = 0.0;
		this.horizontalSlider.maximum = 1.0;
		this.horizontalSlider.value = 0.4;
		this.horizontalSlider.layoutData = AnchorLayoutData.center(-40);
		this.addChild(this.horizontalSlider);

		this.verticalSlider = new VSlider();
		this.verticalSlider.minimum = 0.0;
		this.verticalSlider.maximum = 1.0;
		this.verticalSlider.value = 0.5;
		this.verticalSlider.layoutData = AnchorLayoutData.center(120);
		this.addChild(this.verticalSlider);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
