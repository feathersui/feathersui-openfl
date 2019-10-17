package com.feathersui.components.screens;

import feathers.controls.dataRenderers.ItemRenderer;
import feathers.events.FeathersEvent;
import feathers.controls.ListBox;
import feathers.controls.Label;
import openfl.events.Event;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.data.ListBoxItemState;

class ListBoxScreen extends Panel {
	private var listBox:ListBox;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "List Box";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(FeathersEvent.TRIGGERED, backButton_triggeredHandler);
			header.addChild(backButton);

			return header;
		};

		var items = [];
		for (i in 0...30) {
			items[i] = {text: "List Item " + (i + 1)};
		}

		this.listBox = new ListBox();
		this.listBox.dataProvider = new ArrayCollection(items);
		this.listBox.updateItemRenderer = (itemRenderer:ItemRenderer, state:ListBoxItemState) -> {
			itemRenderer.text = state.data.text;
			itemRenderer.selected = state.selected;
		};
		this.listBox.layoutData = AnchorLayoutData.fill();
		this.listBox.addEventListener(Event.CHANGE, listBox_changeHandler);
		this.addChild(this.listBox);
	}

	private function listBox_changeHandler(event:Event):Void {
		trace("ListBox selectedIndex change: " + this.listBox.selectedIndex);
	}

	private function backButton_triggeredHandler(event:FeathersEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
