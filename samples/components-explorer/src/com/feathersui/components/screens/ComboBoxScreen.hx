package com.feathersui.components.screens;

import feathers.utils.DisplayObjectRecycler;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.events.FeathersEvent;
import feathers.data.ArrayCollection;
import feathers.controls.ComboBox;
import feathers.controls.Label;
import openfl.events.Event;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.data.ListBoxItemState;

class ComboBoxScreen extends Panel {
	private var comboBox:ComboBox;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Combo Box";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(FeathersEvent.TRIGGERED, backButton_triggeredHandler);
			header.addChild(backButton);

			return header;
		};

		var arrayItems = [
			{text: "Aardvark"}, {text: "Badger"}, {text: "Cheetah"}, {text: "Dolphin"}, {text: "Elephant"}, {text: "Flamingo"}, {text: "Gecko"},
			{text: "Hedgehog"}, {text: "Iguana"}, {text: "Jaguar"}, {text: "Kangaroo"}, {text: "Lobster"}, {text: "Moose"}, {text: "Newt"}, {text: "Octopus"},
			{text: "Penguin"}, {text: "Quokka"}, {text: "Raccoon"}, {text: "Starling"}, {text: "Toucan"}, {text: "Urchin"}, {text: "Vulture"},
			{text: "Warthog"}, {text: "X-Ray Tetra"}, {text: "Yak"}, {text: "Zebra"},
		];

		this.comboBox = new ComboBox();
		this.comboBox.dataProvider = new ArrayCollection(arrayItems);
		this.comboBox.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		this.comboBox.layoutData = AnchorLayoutData.center();
		this.comboBox.addEventListener(Event.CHANGE, comboBox_changeHandler);
		this.addChild(this.comboBox);
	}

	private function comboBox_changeHandler(event:Event):Void {
		trace("ComboBox selectedIndex change: " + this.comboBox.selectedIndex);
	}

	private function backButton_triggeredHandler(event:FeathersEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
