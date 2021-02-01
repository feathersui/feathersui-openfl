package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class PanelScreen extends Panel {
	private var panel:Panel;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.panel = new Panel();
		this.panel.layoutData = AnchorLayoutData.center();

		var header = new Header();
		header.text = "Header";
		this.panel.header = header;

		var footer = new LayoutGroup();
		footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
		var footerTitle = new Label();
		footerTitle.text = "Footer";
		footer.addChild(footerTitle);
		this.panel.footer = footer;

		this.panel.layout = new AnchorLayout();
		var message = new Label();
		message.text = "I'm a Panel container";
		message.layoutData = AnchorLayoutData.fill(10.0);
		this.panel.addChild(message);
		this.addChild(this.panel);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Panel";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
