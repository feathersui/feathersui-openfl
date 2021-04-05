package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.skins.TabSkin;
import openfl.events.Event;

class TabSkinScreen extends Panel {
	private var skin:TabSkin;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		this.layout = layout;

		this.skin = new TabSkin();
		this.skin.border = SolidColor(2.0, 0x000000);
		this.skin.fill = SolidColor(0xff0000);
		this.skin.cornerRadius = 10.0;
		this.skin.width = 100.0;
		this.skin.height = 50.0;
		this.addChild(this.skin);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Tab Skin";
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
