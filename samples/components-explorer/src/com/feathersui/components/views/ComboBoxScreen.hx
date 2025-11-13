package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ComboBoxScreen extends Panel {
	private var comboBox:ComboBox;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		// data containers may display any type of data. in this case, we're
		// defining a custom typedef at the end of this file that we've named
		// SimpleTextItem. a custom class could be used instead, if preferred.
		// you could also skip creating a custom type and use Dynamic or Any.
		var items:Array<SimpleTextItem> = [
			{text: "Aardvark"},
			{text: "Badger"},
			{text: "Cheetah"},
			{text: "Dolphin"},
			{text: "Elephant"},
			{text: "Flamingo"},
			{text: "Gecko"},
			{text: "Hedgehog"},
			{text: "Iguana"},
			{text: "Jaguar"},
			{text: "Kangaroo"},
			{text: "Lobster"},
			{text: "Moose"},
			{text: "Newt"},
			{text: "Octopus"},
			{text: "Penguin"},
			{text: "Quokka"},
			{text: "Raccoon"},
			{text: "Starling"},
			{text: "Toucan"},
			{text: "Urchin"},
			{text: "Vulture"},
			{text: "Warthog"},
			{text: "X-Ray Tetra"},
			{text: "Yak"},
			{text: "Zebra"},
		];

		this.comboBox = new ComboBox();
		this.comboBox.dataProvider = new ArrayCollection(items);
		this.comboBox.itemToText = (item:SimpleTextItem) -> {
			return item.text;
		};
		this.comboBox.layoutData = AnchorLayoutData.center();
		this.comboBox.addEventListener(Event.CHANGE, comboBox_changeHandler);
		this.addChild(this.comboBox);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Combo Box";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function comboBox_changeHandler(event:Event):Void {
		trace("ComboBox selectedIndex change: " + this.comboBox.selectedIndex);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

private typedef SimpleTextItem = {
	text:String
}
