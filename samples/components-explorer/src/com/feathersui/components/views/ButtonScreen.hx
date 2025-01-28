package com.feathersui.components.views;

import feathers.controls.AssetLoader;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.ToggleButton;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.events.Event;

class ButtonScreen extends Panel {
	private var button:Button;
	private var iconButton:Button;
	private var toggleButton:ToggleButton;
	private var disabledButton:Button;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20.0;
		this.layout = layout;

		this.button = new Button();
		this.button.text = "Push Button";
		this.button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
		this.addChild(this.button);

		var icon = new AssetLoader("favicon");
		icon.sourceScale = 0.5;
		this.iconButton = new Button();
		this.iconButton.text = "Button with Icon";
		this.iconButton.icon = icon;
		this.addChild(this.iconButton);

		this.toggleButton = new ToggleButton();
		this.toggleButton.text = "Toggled Button";
		this.toggleButton.selected = true;
		this.toggleButton.addEventListener(Event.CHANGE, toggleButton_changeHandler);
		this.addChild(this.toggleButton);

		this.disabledButton = new Button();
		this.disabledButton.enabled = false;
		this.disabledButton.text = "Disabled Button";
		this.addChild(this.disabledButton);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Button";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function button_triggerHandler(event:TriggerEvent):Void {
		trace("Button triggered");
	}

	private function toggleButton_changeHandler(event:Event):Void {
		trace("ToggleButton selected change: " + this.toggleButton.selected);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
