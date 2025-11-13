package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.PopUpListView;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.VerticalLayout;
import feathers.skins.RectangleSkin;
import openfl.events.Event;

class LayoutGroupScreen extends Panel {
	private var group:LayoutGroup;
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

		this.group = new LayoutGroup();
		this.group.layout = this.verticalLayout;
		this.group.layoutData = AnchorLayoutData.fill();
		this.addChild(this.group);

		for (i in 0...3) {
			var child = new RectangleSkin(SolidColor(0xff0000));
			child.width = 50.0 + Std.int(Math.random() * 50.0);
			child.height = 50.0 + Std.int(Math.random() * 50.0);
			this.group.addChild(child);
		}
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Layout Group";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;

		this.layoutListView = new PopUpListView();
		this.layoutListView.dataProvider = new ArrayCollection<LayoutItem>([
			{text: "Vertical", layout: this.verticalLayout},
			{text: "Horizontal", layout: this.horizontalLayout},
		]);
		this.layoutListView.itemToText = (item:LayoutItem) -> item.text;
		this.layoutListView.addEventListener(Event.CHANGE, layoutListView_changeHandler);
		header.rightView = this.layoutListView;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function layoutListView_changeHandler(event:Event):Void {
		this.group.layout = this.layoutListView.selectedItem.layout;
	}
}

private typedef LayoutItem = {
	text:String,
	layout:ILayout
}
