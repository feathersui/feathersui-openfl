package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.TreeGridView;
import feathers.controls.TreeGridViewColumn;
import feathers.data.ArrayCollection;
import feathers.data.ArrayHierarchicalCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class TreeGridViewScreen extends Panel {
	private var treeGridView:TreeGridView;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.treeGridView = new TreeGridView();
		this.treeGridView.variant = TreeGridView.VARIANT_BORDERLESS;
		this.treeGridView.dataProvider = new ArrayHierarchicalCollection<TreeItemData>([
			{
				dept: "Bakery",
				children: [
					{item: "Whole Wheat Bread", dept: "Bakery", price: "2.49"},
					{item: "English Muffins", dept: "Bakery", price: "2.99"},
				]
			},
			{
				dept: "Dairy",
				children: [
					{item: "2% Milk", dept: "Dairy", price: "2.49"},
					{item: "Butter", dept: "Dairy", price: "4.69"},
				]
			},
			{
				dept: "Meat",
				children: [
					{item: "Chicken breast", dept: "Meat", price: "5.90"},
					{item: "Bacon", dept: "Meat", price: "4.49"},
				]
			},
			{
				dept: "Produce",
				children: [
					{item: "Lettuce", dept: "Produce", price: "1.29"},
					{item: "Broccoli", dept: "Produce", price: "2.99"},
				]
			},
		], (item:TreeItemData) -> item.children);
		this.treeGridView.columns = new ArrayCollection([
			new TreeGridViewColumn("Department", (data:TreeItemData) -> data.dept),
			new TreeGridViewColumn("Item", (data:TreeItemData) -> data.item),
			new TreeGridViewColumn("Unit Price", (data:TreeItemData) -> data.price)
		]);
		this.treeGridView.layoutData = AnchorLayoutData.fill();
		this.treeGridView.addEventListener(Event.CHANGE, treeGridView_changeHandler);
		this.addChild(this.treeGridView);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Tree Grid View";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function treeGridView_changeHandler(event:Event):Void {
		trace("TreeGridView selectedLocation change: " + this.treeGridView.selectedLocation);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

private typedef TreeItemData = {
	dept:String,
	?item:String,
	?price:String,
	?children:Array<TreeItemData>
};
