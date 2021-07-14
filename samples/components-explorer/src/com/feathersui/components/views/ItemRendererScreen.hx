package com.feathersui.components.views;

import feathers.controls.ToggleSwitch;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ItemRendererScreen extends Panel {
	private var itemRenderer:ItemRenderer;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.itemRenderer = new ItemRenderer();
		this.itemRenderer.text = "Primary Text";
		this.itemRenderer.secondaryText = "Optional Secondary Text";
		this.itemRenderer.layoutData = AnchorLayoutData.center();
		this.itemRenderer.width = 390.0;
		this.addChild(this.itemRenderer);

		var accessoryView = new ToggleSwitch();
		this.itemRenderer.accessoryView = accessoryView;
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Item Renderer";
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
