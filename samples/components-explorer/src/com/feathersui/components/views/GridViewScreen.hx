package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Header;
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

		// data containers may display any type of data. in this case, we're
		// defining a custom typedef at the end of this file that we've named
		// ProductData. a custom class could be used instead, if preferred.
		// you could also skip creating a custom type and use Dynamic or Any.
		var items:Array<ProductData> = [
			{item: "Chicken breast", dept: "Meat", price: 5.90},
			{item: "Bacon", dept: "Meat", price: 4.49},
			{item: "2% Milk", dept: "Dairy", price: 2.49},
			{item: "Butter", dept: "Dairy", price: 4.00},
			{item: "Lettuce", dept: "Produce", price: 1.29},
			{item: "Broccoli", dept: "Produce", price: 2.99},
			{item: "Whole Wheat Bread", dept: "Bakery", price: 2.49},
			{item: "English Muffins", dept: "Bakery", price: 2.99},
		];

		this.gridView = new GridView();
		this.gridView.variant = GridView.VARIANT_BORDERLESS;
		this.gridView.dataProvider = new ArrayCollection<ProductData>(items);
		this.gridView.columns = new ArrayCollection([
			new GridViewColumn("Item", (data:ProductData) -> data.item),
			new GridViewColumn("Department", (data:ProductData) -> data.dept),
			new GridViewColumn("Unit Price", (data:ProductData) -> {
				var priceParts = Std.string(data.price).split(".");
				var dollar = priceParts[0];
				var cents = priceParts[1];
				if (cents == null) {
					cents = "";
				}
				// ensure that cents renders with exactly two digits, by
				// removing excess digits or adding zeroes, if necessary
				cents = StringTools.rpad(cents.substr(0, 2), "0", 2);
				return '${dollar}.${cents}';
			})
		]);
		this.gridView.layoutData = AnchorLayoutData.fill();
		this.gridView.addEventListener(Event.CHANGE, gridView_changeHandler);
		this.addChild(this.gridView);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Grid View";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function gridView_changeHandler(event:Event):Void {
		trace("GridView selectedIndex change: " + this.gridView.selectedIndex);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

// items aren't required to be typedefs. they may be classes too!
private typedef ProductData = {
	item:String,
	dept:String,
	price:Float
}
