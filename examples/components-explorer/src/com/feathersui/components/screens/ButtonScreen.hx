package com.feathersui.components.screens;

import feathers.layout.VerticalAlign;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import feathers.controls.Label;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.Panel;
import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButton;

class ButtonScreen extends Panel {
	private var button:Button;
	private var toggleButton:ToggleButton;
	private var headerTitle:Label;
	private var backButton:Button;

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

			this.headerTitle = new Label();
			this.headerTitle.variant = Label.VARIANT_HEADING;
			this.headerTitle.text = "Button";
			this.headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(this.headerTitle);

			this.backButton = new Button();
			this.backButton.text = "Back";
			this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
			header.addChild(this.backButton);

			return header;
		};

		this.button = new Button();
		this.button.text = "Push Button";
		this.addChild(this.button);

		this.toggleButton = new ToggleButton();
		this.toggleButton.text = "Toggled Button";
		this.toggleButton.selected = true;
		this.toggleButton.addEventListener(Event.CHANGE, toggleButton_changeHandler);
		this.addChild(this.toggleButton);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function toggleButton_changeHandler(event:Event):Void {
		trace("ToggleButton selected change: " + this.toggleButton.selected);
	}
}
