package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.HSlider;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.VSlider;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class SliderScreen extends Panel {
	private var horizontalSlider:HSlider;
	private var verticalSlider:VSlider;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.horizontalSlider = new HSlider();
		this.horizontalSlider.minimum = 0.0;
		this.horizontalSlider.maximum = 1.0;
		this.horizontalSlider.value = 0.4;
		this.horizontalSlider.layoutData = AnchorLayoutData.center(-40.0);
		this.horizontalSlider.addEventListener(Event.CHANGE, horizontalSlider_changeHandler);
		this.addChild(this.horizontalSlider);

		this.verticalSlider = new VSlider();
		this.verticalSlider.minimum = 0.0;
		this.verticalSlider.maximum = 1.0;
		this.verticalSlider.value = 0.5;
		this.verticalSlider.layoutData = AnchorLayoutData.center(120.0);
		this.addChild(this.verticalSlider);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Slider";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function horizontalSlider_changeHandler(event:Event):Void {
		trace("HSlider value change: " + this.horizontalSlider.value);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
