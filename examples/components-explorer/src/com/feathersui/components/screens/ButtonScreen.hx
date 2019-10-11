package com.feathersui.components.screens;

import feathers.events.FeathersEvent;
import openfl.Assets;
import openfl.display.Bitmap;
import feathers.layout.VerticalAlign;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import feathers.controls.Label;
import openfl.events.Event;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.Panel;
import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButton;

class ButtonScreen extends Panel {
	private var button:Button;
	private var iconButton:Button;
	private var toggleButton:ToggleButton;

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.gap = 20;
		this.layout = layout;

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Button";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(FeathersEvent.TRIGGERED, backButton_triggeredHandler);
			header.addChild(backButton);

			return header;
		};

		this.button = new Button();
		this.button.text = "Push Button";
		this.button.addEventListener(FeathersEvent.TRIGGERED, button_triggeredHandler);
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

	private function backButton_triggeredHandler(event:FeathersEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function button_triggeredHandler(event:FeathersEvent):Void {
		trace("Button triggered");
	}

	private function toggleButton_changeHandler(event:Event):Void {
		trace("ToggleButton selected change: " + this.toggleButton.selected);
	}
}
