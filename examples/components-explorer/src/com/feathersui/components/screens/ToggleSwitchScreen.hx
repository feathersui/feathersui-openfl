package com.feathersui.components.screens;

import feathers.layout.VerticalAlign;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.controls.Label;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.ToggleSwitch;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;

class ToggleSwitchScreen extends Panel {
	private var toggle:ToggleSwitch;
	private var selectedToggle:ToggleSwitch;
	private var headerTitle:Label;
	private var backButton:Button;

	override private function initialize():Void {
		super.initialize();

		var layout = new HorizontalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.gap = 20;
		this.layout = layout;

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			this.headerTitle = new Label();
			this.headerTitle.variant = Label.VARIANT_HEADING;
			this.headerTitle.text = "Toggle Switch";
			this.headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(this.headerTitle);

			this.backButton = new Button();
			this.backButton.text = "Back";
			this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
			header.addChild(this.backButton);

			return header;
		};

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
