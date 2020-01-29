package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ToggleButton;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.events.Event;

class ButtonScreen extends Panel {
	private var button:Button;
	private var iconButton:Button;
	private var toggleButton:ToggleButton;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20.0;
		this.layout = layout;

		this.button = new Button();
		this.button.text = "Push Button";
		this.button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
		this.addChild(this.button);

		this.iconButton = new Button();
		this.iconButton.text = "Button with Icon";
		this.iconButton.icon = new Bitmap(Assets.getBitmapData("favicon"));
		this.addChild(this.iconButton);

		this.toggleButton = new ToggleButton();
		this.toggleButton.text = "Toggled Button";
		this.toggleButton.selected = true;
		this.toggleButton.addEventListener(Event.CHANGE, toggleButton_changeHandler);
		this.addChild(this.toggleButton);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Button";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function button_triggerHandler(event:TriggerEvent):Void {
		trace("Button triggered");
	}

	private function toggleButton_changeHandler(event:Event):Void {
		trace("ToggleButton selected change: " + this.toggleButton.selected);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
