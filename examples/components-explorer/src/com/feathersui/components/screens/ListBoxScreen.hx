package com.feathersui.components.screens;

import feathers.controls.ListBox;
import feathers.controls.Label;
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;

class ListBoxScreen extends Panel {
	private var listBox:ListBox;
	private var headerTitle:Label;
	private var backButton:Button;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			this.headerTitle = new Label();
			this.headerTitle.variant = Label.VARIANT_HEADING;
			this.headerTitle.text = "List Box";
			this.headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(this.headerTitle);

			this.backButton = new Button();
			this.backButton.text = "Back";
			this.backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			this.backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
			header.addChild(this.backButton);

			return header;
		};

		var items = [];
		for (i in 0...30) {
			items[i] = {text: "List Item " + (i + 1)};
		}

		this.listBox = new ListBox();
		this.listBox.dataProvider = new ArrayCollection(items);
		this.listBox.layoutData = AnchorLayoutData.fill();
		this.addChild(this.listBox);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
