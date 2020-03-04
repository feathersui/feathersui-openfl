package com.feathersui.components.views;

import feathers.controls.GridViewColumn;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.GridView;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class GridViewScreen extends Panel {
	private var gridView:GridView;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.gridView = new GridView();
		this.gridView.dataProvider = new ArrayCollection([
			{item: "Chicken breast", dept: "Meat", price: "5.90"},
			{item: "Bacon", dept: "Meat", price: "4.49"},
			{item: "2% Milk", dept: "Dairy", price: "2.49"},
			{item: "Butter", dept: "Dairy", price: "4.69"},
			{item: "Lettuce", dept: "Produce", price: "1.29"},
			{item: "Broccoli", dept: "Produce", price: "2.99"},
			{item: "Whole Wheat Bread", dept: "Bakery", price: "2.49"},
			{item: "English Muffins", dept: "Bakery", price: "2.99"},
		]);
		this.gridView.columns = new ArrayCollection([
			new GridViewColumn("Item", (data) -> data.item),
			new GridViewColumn("Department", (data) -> data.dept),
			new GridViewColumn("Unit Price", (data) -> data.price)
		]);
		this.gridView.layoutData = AnchorLayoutData.fill();
		this.gridView.addEventListener(Event.CHANGE, gridView_changeHandler);
		this.addChild(this.gridView);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Grid View";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function gridView_changeHandler(event:Event):Void {
		trace("GridView selectedIndex change: " + this.gridView.selectedIndex);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
