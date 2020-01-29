package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class CheckScreen extends Panel {
	private var check:Check;
	private var selectedCheck:Check;
	private var disabledCheck:Check;
	private var selectedDisabledCheck:Check;

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
			headerTitle.text = "Check";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
			header.addChild(backButton);

			return header;
		};

		this.check = new Check();
		this.check.text = "Check";
		this.check.layoutData = AnchorLayoutData.center(0, -75);
		this.check.addEventListener(Event.CHANGE, check_changeHandler);
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

	private function check_changeHandler(event:Event):Void {
		trace("Check selected change: " + this.check.selected);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
