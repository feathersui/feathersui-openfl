package com.feathersui.components.views;

import feathers.layout.VerticalLayout;
import feathers.text.TextFormat;
import feathers.controls.Label;
import feathers.skins.RectangleSkin;
import feathers.controls.LayoutGroup;
import openfl.display.DisplayObject;
import feathers.controls.Button;
import feathers.controls.Collapsible;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class CollapsibleScreen extends Panel {
	private var collapsible:Collapsible;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.collapsible = new Collapsible();
		this.collapsible.text = "Click to collapse and expand";
		this.collapsible.content = this.createContent("This is the content", 0x339933);
		this.collapsible.layoutData = AnchorLayoutData.topCenter(20.0);
		this.collapsible.addEventListener(Event.OPEN, collapsible_openHandler);
		this.collapsible.addEventListener(Event.CLOSE, collapsible_closeHandler);
		this.addChild(this.collapsible);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Collapsible";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function createContent(text:String, color:UInt):DisplayObject {
		var content = new LayoutGroup();
		var contentLayout = new VerticalLayout();
		contentLayout.setPadding(50.0);
		contentLayout.horizontalAlign = CENTER;
		contentLayout.verticalAlign = MIDDLE;
		content.layout = contentLayout;
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

	private function collapsible_openHandler(event:Event):Void {
		trace("Collapsible opened");
	}

	private function collapsible_closeHandler(event:Event):Void {
		trace("Collapsible closed");
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
