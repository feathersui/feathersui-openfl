package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.RectangleSkin;
import feathers.text.TextFormat;
import openfl.display.DisplayObject;
import openfl.events.Event;

class HDividedBoxScreen extends Panel {
	private var dividedBox:HDividedBox;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.dividedBox = new HDividedBox();
		this.dividedBox.layoutData = AnchorLayoutData.fill();
		this.addChild(this.dividedBox);

		var leftContainer = this.createContainer("Left", 0x993333);
		leftContainer.minWidth = 50.0;
		this.dividedBox.addChild(leftContainer);

		var rightContainer = this.createContainer("Right", 0x333399);
		rightContainer.minWidth = 50.0;
		dividedBox.addChild(rightContainer);
	}

	private function createContainer(text:String, color:UInt):ScrollContainer {
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
		header.text = "HDividedBox";
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
