package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.controls.VDividedBox;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.RectangleSkin;
import feathers.text.TextFormat;
import openfl.display.DisplayObject;
import openfl.events.Event;

class VDividedBoxScreen extends Panel {
	private var dividedBox:VDividedBox;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.dividedBox = new VDividedBox();
		this.dividedBox.layoutData = AnchorLayoutData.fill();
		this.addChild(this.dividedBox);

		var topContainer = this.createContainer("Top", 0x993333);
		this.dividedBox.addChild(topContainer);

		var bottomContainer = this.createContainer("Bottom", 0x333399);
		dividedBox.addChild(bottomContainer);
	}

	private function createContainer(text:String, color:UInt):DisplayObject {
		var content = new ScrollContainer();
		content.layout = new AnchorLayout();
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(color);
		content.backgroundSkin = backgroundSkin;
		var label = new Label();
		label.textFormat = new TextFormat("_sans", 20, 0xffffff);
		label.text = text;
		label.layoutData = AnchorLayoutData.center();
		content.addChild(label);
		return content;
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "VDividedBox";
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
