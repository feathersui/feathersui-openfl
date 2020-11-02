package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.VDividedBox;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.RectangleSkin;
import feathers.text.TextFormat;
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

	private function createContainer(text:String, color:UInt):LayoutGroup {
		var content = new LayoutGroup();
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
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "VDividedBox";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
