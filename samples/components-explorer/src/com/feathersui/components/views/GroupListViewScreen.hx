package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.GroupListView;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.data.ArrayHierarchicalCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class GroupListViewScreen extends Panel {
	private var groupListView:GroupListView;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var data = new ArrayHierarchicalCollection([
			{
				text: "A",
				children: [
					{
						text: "Aardvark"
					},
					{text: "Alligator"},
					{text: "Antelope"}
				]
			},
			{
				text: "B",
				children: [{text: "Badger"}, {text: "Bear"}, {text: "Beaver"}, {text: "Buffalo"}]
			},
			{
				text: "C",
				children: [{text: "Cheetah"}, {text: "Chimpanzee"}]
			},
			{
				text: "D",
				children: [{text: "Dolphin"}, {text: "Donkey"}, {text: "Duck"},]
			},
			{
				text: "E",
				children: [{text: "Eagle"}, {text: "Earthworm"}, {text: "Elephant"}, {text: "Elk"},]
			},
			{
				text: "F",
				children: [{text: "Flamingo"}, {text: "Fox"}]
			},
			{
				text: "G",
				children: [{text: "Gecko"}, {text: "Goat"}, {text: "Goose"}]
			},
			{
				text: "H",
				children: [{text: "Hedgehog"}, {text: "Horse"}]
			},
			{
				text: "I",
				children: [{text: "Igunana"},]
			},
			{
				text: "J",
				children: [
					{text: "Jaguar"},
					{
						text: "Jellyfish"
					}
				]
			},
			{
				text: "K",
				children: [{text: "Kangaroo"}]
			},
			{
				text: "L",
				children: [{text: "Lobster"}, {text: "Lynx"}]
			},
			{
				text: "M",
				children: [{text: "Monkey"}, {text: "Moose"}, {text: "Mule"}]
			},
			{
				text: "N",
				children: [{text: "Newt"}]
			},
			{
				text: "O",
				children: [{text: "Ocelot"}, {text: "Octopus"}, {text: "Ostrich"}]
			},
			{
				text: "P",
				children: [{text: "Panther"}, {text: "Penguin"}, {text: "Pig"}, {text: "Platypus"},]
			},
			{
				text: "Q",
				children: [{text: "Quokka"}]
			},
			{
				text: "R",
				children: [{text: "Rabbit"}, {text: "Raccoon"}, {text: "Rat"}]
			},
			{
				text: "S",
				children: [
					{text: "Scorpion"},
					{text: "Seal"},
					{text: "Sloth"},
					{text: "Snake"},
					{text: "Squid"},
					{text: "Squirrel"},
					{text: "Starling"}
				]
			},
			{
				text: "T",
				children: [{text: "Tiger"}, {text: "Toucan"}, {text: "Turkey"}]
			},
			{
				text: "U",
				children: [{text: "Urchin"}]
			},
			{
				text: "V",
				children: [{text: "Vulture"}]
			},
			{
				text: "W",
				children: [{text: "Wallaby"}, {text: "Warthog"}, {text: "Wolf"}, {text: "Wombat"}]
			},
			{
				text: "X",
				children: [{text: "X-Ray Tetra"}]
			},
			{
				text: "Y",
				children: [{text: "Yak"}]
			},
			{
				text: "Z",
				children: [
					{
						text: "Zebra"
					}
				]
			},
		], (item:Dynamic) -> item.children);
		this.groupListView = new GroupListView();
		this.groupListView.variant = GroupListView.VARIANT_BORDERLESS;
		this.groupListView.dataProvider = data;
		this.groupListView.itemToText = (item) -> {
			return item.text;
		};
		this.groupListView.itemToHeaderText = (item) -> {
			return item.text;
		};
		this.groupListView.layoutData = AnchorLayoutData.fill();
		this.groupListView.addEventListener(Event.CHANGE, groupListView_changeHandler);
		this.addChild(this.groupListView);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Group List View";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function groupListView_changeHandler(event:Event):Void {
		var selectedItem = this.groupListView.selectedItem;
		trace("GroupListView selectedItem change: " + this.groupListView.itemToText(selectedItem));
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
