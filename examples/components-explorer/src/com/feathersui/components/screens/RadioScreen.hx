package com.feathersui.components.screens;

import feathers.layout.VerticalAlign;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import feathers.controls.Radio;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;

class RadioScreen extends Panel {
	private var radio:Radio;
	private var selectedRadio:Radio;
	private var disabledRadio:Radio;
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
			this.headerTitle.text = "Radio";
			this.headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(this.headerTitle);

			this.backButton = new Button();
			this.backButton.text = "Back";
			this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
			header.addChild(this.backButton);

			return header;
		};

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
