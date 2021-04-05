package com.feathersui.components.views;

import feathers.layout.VerticalLayout;
import feathers.skins.RectangleSkin;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ScrollContainerScreen extends Panel {
	private var container:ScrollContainer;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var containerLayout = new VerticalLayout();
		containerLayout.gap = 10.0;
		containerLayout.setPadding(10.0);
		containerLayout.horizontalAlign = CENTER;

		this.container = new ScrollContainer();
		this.container.layout = containerLayout;
		this.container.layoutData = AnchorLayoutData.fill();
		this.addChild(this.container);

		for (i in 0...10) {
			var child = new RectangleSkin(SolidColor(0xff0000));
			child.width = 50.0 + Std.int(Math.random() * 50.0);
			child.height = 50.0 + Std.int(Math.random() * 50.0);
			this.container.addChild(child);
		}
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Scroll Container";
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
