package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ListViewScreen extends Panel {
	private var listView:ListView;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		// data containers may display any type of data. in this case, we're
		// defining a custom typedef at the end of this file that we've named
		// SimpleTextItem. a custom class could be used instead, if preferred.
		// you could also skip creating a custom type and use Dynamic or Any.
		var items:Array<SimpleTextItem> = [];
		for (i in 0...30) {
			items[i] = {text: "List Item " + (i + 1)};
		}

		this.listView = new ListView();
		this.listView.variant = ListView.VARIANT_BORDERLESS;
		this.listView.dataProvider = new ArrayCollection(items);
		this.listView.itemToText = (item:SimpleTextItem) -> {
			return item.text;
		};
		this.listView.layoutData = AnchorLayoutData.fill();
		this.listView.addEventListener(Event.CHANGE, listView_changeHandler);
		this.listView.addEventListener(ListViewEvent.ITEM_TRIGGER, listView_itemTriggerHandler);
		this.addChild(this.listView);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "List View";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function listView_changeHandler(event:Event):Void {
		trace("ListView selectedIndex change: " + this.listView.selectedIndex);
	}

	private function listView_itemTriggerHandler(event:ListViewEvent):Void {
		trace("ListView item trigger: " + event.state.text);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

private typedef SimpleTextItem = {
	text:String
}
