package com.feathersui.components.screens;

import feathers.events.FeathersEvent;
import feathers.controls.Label;
import openfl.events.Event;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.HSlider;
import feathers.controls.VSlider;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;

class SliderScreen extends Panel {
	private var horizontalSlider:HSlider;
	private var verticalSlider:VSlider;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Slider";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(FeathersEvent.TRIGGERED, backButton_triggeredHandler);
			header.addChild(backButton);

			return header;
		};

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

	private function backButton_triggeredHandler(event:FeathersEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
