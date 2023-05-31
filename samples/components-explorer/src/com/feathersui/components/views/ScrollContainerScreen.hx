package com.feathersui.components.views;

import feathers.data.ArrayCollection;
import feathers.layout.HorizontalLayout;
import feathers.controls.PopUpListView;
import feathers.layout.VerticalLayout;
import feathers.skins.RectangleSkin;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class ScrollContainerScreen extends Panel {
	private var container:ScrollContainer;
	private var layoutListView:PopUpListView;
	private var verticalLayout:VerticalLayout;
	private var horizontalLayout:HorizontalLayout;

	override private function initialize():Void {
		super.initialize();

		this.verticalLayout = new VerticalLayout();
		this.verticalLayout.gap = 10.0;
		this.verticalLayout.setPadding(10.0);
		this.verticalLayout.horizontalAlign = CENTER;

		this.horizontalLayout = new HorizontalLayout();
		this.horizontalLayout.gap = 10.0;
		this.horizontalLayout.setPadding(10.0);
		this.horizontalLayout.horizontalAlign = CENTER;

		this.createHeader();

		this.layout = new AnchorLayout();

		var containerLayout = new VerticalLayout();
		containerLayout.gap = 10.0;
		containerLayout.setPadding(10.0);
		containerLayout.horizontalAlign = CENTER;

		this.container = new ScrollContainer();
		this.container.layout = containerLayout;
		this.container.layoutData = AnchorLayoutData.fill();
		this.addChild(this.container);

		for (i in 0...10) {
			var child = new RectangleSkin(SolidColor(0xff0000));
			child.width = 50.0 + Std.int(Math.random() * 50.0);
			child.height = 50.0 + Std.int(Math.random() * 50.0);
			this.container.addChild(child);
		}
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Scroll Container";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;

		this.layoutListView = new PopUpListView();
		this.layoutListView.dataProvider = new ArrayCollection([
			{text: "Vertical", layout: this.verticalLayout},
			{text: "Horizontal", layout: this.horizontalLayout},
		]);
		this.layoutListView.itemToText = item -> item.text;
		this.layoutListView.addEventListener(Event.CHANGE, layoutListView_changeHandler);
		header.rightView = this.layoutListView;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function layoutListView_changeHandler(event:Event):Void {
		this.container.layout = this.layoutListView.selectedItem.layout;
	}
}
