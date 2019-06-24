package com.feathersui.components.screens;

import feathers.controls.Check;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;

class CheckScreen extends LayoutGroup {
	private var check:Check;
	private var selectedCheck:Check;
	private var disabledCheck:Check;
	private var selectedDisabledCheck:Check;
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
		this.headerTitle.text = "Check";
		this.headerTitle.layoutData = AnchorLayoutData.center();
		this.header.addChild(this.headerTitle);

		this.backButton = new Button();
		this.backButton.text = "Back";
		this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
		this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
		this.header.addChild(this.backButton);

		this.check = new Check();
		this.check.text = "Check";
		this.check.layoutData = AnchorLayoutData.center(0, -75);
		this.addChild(this.check);

		this.selectedCheck = new Check();
		this.selectedCheck.text = "Selected Check";
		this.selectedCheck.selected = true;
		this.selectedCheck.layoutData = AnchorLayoutData.center(0, -25);
		this.addChild(this.selectedCheck);

		this.disabledCheck = new Check();
		this.disabledCheck.text = "Disabled Check";
		this.disabledCheck.enabled = false;
		this.disabledCheck.layoutData = AnchorLayoutData.center(0, 25);
		this.addChild(this.disabledCheck);

		this.selectedDisabledCheck = new Check();
		this.selectedDisabledCheck.text = "Selected & Disabled Check";
		this.selectedDisabledCheck.selected = true;
		this.selectedDisabledCheck.enabled = false;
		this.selectedDisabledCheck.layoutData = AnchorLayoutData.center(0, 75);
		this.addChild(this.selectedDisabledCheck);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
