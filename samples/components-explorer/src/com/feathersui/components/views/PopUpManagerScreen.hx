package com.feathersui.components.views;

import feathers.controls.Header;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.core.PopUpManager;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class PopUpManagerScreen extends Panel {
	private var button:Button;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.button = new Button();
		this.button.text = "Add Pop Up";
		this.button.layoutData = AnchorLayoutData.center();
		this.button.addEventListener(TriggerEvent.TRIGGER, addPopUpButton_triggerHandler);
		this.addChild(this.button);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Pop Up Manager";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function addPopUpButton_triggerHandler(event:TriggerEvent):Void {
		var popUp = new Panel();
		popUp.layout = new AnchorLayout();
		var message = new Label();
		message.text = "I'm a pop-up!";
		message.layoutData = AnchorLayoutData.center();
		popUp.addChild(message);

		var footer = new LayoutGroup();
		footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
		popUp.footer = footer;

		var closeButton = new Button();
		closeButton.text = "Close";
		closeButton.addEventListener(TriggerEvent.TRIGGER, (event:TriggerEvent) -> {
			PopUpManager.removePopUp(popUp);
		});
		footer.addChild(closeButton);

		PopUpManager.addPopUp(popUp, this);
	}
}
