package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.PopUpList;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class PopUpListScreen extends Panel {
	private var popUpList:PopUpList;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var arrayItems = [
			{text: "Aardvark"}, {text: "Badger"}, {text: "Cheetah"}, {text: "Dolphin"}, {text: "Elephant"}, {text: "Flamingo"}, {text: "Gecko"},
			{text: "Hedgehog"}, {text: "Iguana"}, {text: "Jaguar"}, {text: "Kangaroo"}, {text: "Lobster"}, {text: "Moose"}, {text: "Newt"}, {text: "Octopus"},
			{text: "Penguin"}, {text: "Quokka"}, {text: "Raccoon"}, {text: "Starling"}, {text: "Toucan"}, {text: "Urchin"}, {text: "Vulture"},
			{text: "Warthog"}, {text: "X-Ray Tetra"}, {text: "Yak"}, {text: "Zebra"},
		];

		this.popUpList = new PopUpList();
		this.popUpList.dataProvider = new ArrayCollection(arrayItems);
		this.popUpList.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		this.popUpList.layoutData = AnchorLayoutData.center();
		this.popUpList.addEventListener(Event.CHANGE, popUpList_changeHandler);
		this.addChild(this.popUpList);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Pop Up List";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = new AnchorLayoutData(null, null, null, 10.0, null, 0.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function popUpList_changeHandler(event:Event):Void {
		trace("PopUpList selectedIndex change: " + this.popUpList.selectedIndex);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
