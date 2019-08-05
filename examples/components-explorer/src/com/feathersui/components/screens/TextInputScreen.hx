package com.feathersui.components.screens;

import feathers.controls.Label;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.TextInput;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;

class TextInputScreen extends Panel {
	private var textInput:TextInput;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Text Input";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
			header.addChild(backButton);

			return header;
		};

		this.textInput = new TextInput();
		this.textInput.text = "";
		this.textInput.layoutData = AnchorLayoutData.center();
		this.addChild(this.textInput);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
