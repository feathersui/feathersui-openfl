package com.feathersui.components.views;

import feathers.skins.RectangleSkin;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class LayoutGroupScreen extends Panel {
	private var group:LayoutGroup;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var groupLayout = new VerticalLayout();
		groupLayout.gap = 10.0;
		groupLayout.setPadding(10.0);
		groupLayout.horizontalAlign = CENTER;

		this.group = new LayoutGroup();
		this.group.layout = groupLayout;
		this.group.layoutData = AnchorLayoutData.fill();
		this.addChild(this.group);

		for (i in 0...3) {
			var child = new RectangleSkin(SolidColor(0xff0000));
			child.width = 50.0 + Std.int(Math.random() * 50.0);
			child.height = 50.0 + Std.int(Math.random() * 50.0);
			this.group.addChild(child);
		}
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Layout Group";
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
