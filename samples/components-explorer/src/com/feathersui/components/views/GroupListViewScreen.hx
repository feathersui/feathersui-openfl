package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.GroupListView;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
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

		var data = [
			// @formatter:off
			new TreeNode({text: "A"}, [
				new TreeNode({text: "Aardvark"}),
				new TreeNode({text: "Alligator"}),
				new TreeNode({text: "Antelope"})
			]),
			new TreeNode({text: "B"}, [
				new TreeNode({text: "Badger"}),
				new TreeNode({text: "Bear"}),
				new TreeNode({text: "Beaver"}),
				new TreeNode({text: "Buffalo"})
			]),
			new TreeNode({text: "C"}, [
				new TreeNode({text: "Cheetah"}),
				new TreeNode({text: "Chimpanzee"})
			]),
			new TreeNode({text: "D"}, [
				new TreeNode({text: "Dolphin"}),
				new TreeNode({text: "Donkey"}),
				new TreeNode({text: "Duck"}),
			]),
			new TreeNode({text: "E"}, [
				new TreeNode({text: "Eagle"}),
				new TreeNode({text: "Earthworm"}),
				new TreeNode({text: "Elephant"}),
				new TreeNode({text: "Elk"}),
			]),
			new TreeNode({text: "F"}, [
				new TreeNode({text: "Flamingo"}),
				new TreeNode({text: "Fox"})
			]),
			new TreeNode({text: "G"}, [
				new TreeNode({text: "Gecko"}),
				new TreeNode({text: "Goat"}),
				new TreeNode({text: "Goose"})
			]),
			new TreeNode({text: "H"}, [
				new TreeNode({text: "Hedgehog"}),
				new TreeNode({text: "Horse"})
			]),
			new TreeNode({text: "I"}, [
				new TreeNode({text: "Igunana"}),
			]),
			new TreeNode({text: "J"}, [
				new TreeNode({text: "Jaguar"}),
				new TreeNode({text: "Jellyfish"})
			]),
			new TreeNode({text: "K"}, [
				new TreeNode({text: "Kangaroo"})
			]),
			new TreeNode({text: "L"}, [
				new TreeNode({text: "Lobster"}),
				new TreeNode({text: "Lynx"})
			]),
			new TreeNode({text: "M"}, [
				new TreeNode({text: "Monkey"}),
				new TreeNode({text: "Moose"}),
				new TreeNode({text: "Mule"})
			]),
			new TreeNode({text: "N"}, [
				new TreeNode({text: "Newt"})
			]),
			new TreeNode({text: "O"}, [
				new TreeNode({text: "Ocelot"}),
				new TreeNode({text: "Octopus"}),
				new TreeNode({text: "Ostrich"})
			]),
			new TreeNode({text: "P"}, [
				new TreeNode({text: "Panther"}),
				new TreeNode({text: "Penguin"}),
				new TreeNode({text: "Pig"}),
				new TreeNode({text: "Platypus"}),
			]),
			new TreeNode({text: "Q"}, [
				new TreeNode({text: "Quokka"})
			]),
			new TreeNode({text: "R"}, [
				new TreeNode({text: "Rabbit"}),
				new TreeNode({text: "Raccoon"}),
				new TreeNode({text: "Rat"})
			]),
			new TreeNode({text: "S"}, [
				new TreeNode({text: "Scorpion"}),
				new TreeNode({text: "Seal"}),
				new TreeNode({text: "Sloth"}),
				new TreeNode({text: "Snake"}),
				new TreeNode({text: "Squid"}),
				new TreeNode({text: "Squirrel"}),
				new TreeNode({text: "Starling"})
			]),
			new TreeNode({text: "T"}, [
				new TreeNode({text: "Tiger"}),
				new TreeNode({text: "Toucan"}),
				new TreeNode({text: "Turkey"})
			]),
			new TreeNode({text: "U"}, [
				new TreeNode({text: "Urchin"})
			]),
			new TreeNode({text: "V"}, [
				new TreeNode({text: "Vulture"})
			]),
			new TreeNode({text: "W"}, [
				new TreeNode({text: "Wallaby"}),
				new TreeNode({text: "Warthog"}),
				new TreeNode({text: "Wolf"}),
				new TreeNode({text: "Wombat"})
			]),
			new TreeNode({text: "X"}, [
				new TreeNode({text: "X-Ray Tetra"})
			]),
			new TreeNode({text: "Y"}, [
				new TreeNode({text: "Yak"})
			]),
			new TreeNode({text: "Z"}, [
				new TreeNode({text: "Zebra"})
			]),
			// @formatter:on
		];

		this.groupListView = new GroupListView();
		this.groupListView.variant = GroupListView.VARIANT_BORDERLESS;
		this.groupListView.dataProvider = new TreeCollection(data);
		this.groupListView.itemToText = (item:TreeNode<Dynamic>) -> {
			return item.data.text;
		};
		this.groupListView.itemToHeaderText = (item:TreeNode<Dynamic>) -> {
			return item.data.text;
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
