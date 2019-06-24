package com.feathersui.components.screens;

import feathers.controls.Radio;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;

class RadioScreen extends LayoutGroup {
	private var radio:Radio;
	private var selectedRadio:Radio;
	private var disabledRadio:Radio;
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
		this.headerTitle.text = "Radio";
		this.headerTitle.layoutData = AnchorLayoutData.center();
		this.header.addChild(this.headerTitle);

		this.backButton = new Button();
		this.backButton.text = "Back";
		this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
		this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
		this.header.addChild(this.backButton);

		this.radio = new Radio();
		this.radio.text = "Radio";
		this.radio.layoutData = AnchorLayoutData.center(0, -50);
		this.addChild(this.radio);

		this.selectedRadio = new Radio();
		this.selectedRadio.text = "Selected Radio";
		this.selectedRadio.selected = true;
		this.selectedRadio.layoutData = AnchorLayoutData.center();
		this.addChild(this.selectedRadio);

		this.disabledRadio = new Radio();
		this.disabledRadio.text = "Disabled Radio";
		this.disabledRadio.enabled = false;
		this.disabledRadio.layoutData = AnchorLayoutData.center(0, 50);
		this.addChild(this.disabledRadio);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
