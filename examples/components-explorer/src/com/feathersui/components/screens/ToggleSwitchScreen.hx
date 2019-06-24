package com.feathersui.components.screens;

import feathers.controls.Label;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.ToggleSwitch;
import feathers.controls.LayoutGroup;

class ToggleSwitchScreen extends LayoutGroup {
	private var toggle:ToggleSwitch;
	private var selectedToggle:ToggleSwitch;
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
		this.headerTitle.text = "Toggle Switch";
		this.headerTitle.layoutData = AnchorLayoutData.center();
		this.header.addChild(this.headerTitle);

		this.backButton = new Button();
		this.backButton.text = "Back";
		this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
		this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
		this.header.addChild(this.backButton);

		this.toggle = new ToggleSwitch();
		this.toggle.layoutData = AnchorLayoutData.center(-50);
		this.addChild(this.toggle);

		this.selectedToggle = new ToggleSwitch();
		this.selectedToggle.selected = true;
		this.selectedToggle.layoutData = AnchorLayoutData.center(50);
		this.addChild(this.selectedToggle);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
