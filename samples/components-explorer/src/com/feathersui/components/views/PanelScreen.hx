package com.feathersui.components.views;

import feathers.controls.Button;
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

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Panel";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
			header.addChild(backButton);

			return header;
		};

		this.panel = new Panel();
		this.panel.layoutData = AnchorLayoutData.center();
		this.panel.headerFactory = () -> {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			var title = new Label();
			title.text = "Header";
			header.addChild(title);
			return header;
		};
		this.panel.footerFactory = () -> {
			var footer = new LayoutGroup();
			footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
			var title = new Label();
			title.text = "Footer";
			footer.addChild(title);
			return footer;
		};
		this.panel.layout = new AnchorLayout();
		var message = new Label();
		message.text = "I'm a Panel container";
		message.layoutData = AnchorLayoutData.fill(10.0);
		this.panel.addChild(message);
		this.addChild(this.panel);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
