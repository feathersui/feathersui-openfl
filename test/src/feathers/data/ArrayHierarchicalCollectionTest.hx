/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.HierarchicalCollectionEvent;
import openfl.events.Event;
import utest.Assert;

@:keep class ArrayHierarchicalCollectionTest extends IHierarchicalCollectionTest<MockHierarchicalItem> {
	private var _arrayHierarchicalCollection:ArrayHierarchicalCollection<MockHierarchicalItem>;

	override private function createCollection(?data:Array<MockHierarchicalItem>):IHierarchicalCollection<MockHierarchicalItem> {
		return new ArrayHierarchicalCollection<MockHierarchicalItem>(data, (item:MockHierarchicalItem) -> item.children);
	}

	override private function createItem(text:String, value:Float, ?children:Array<MockHierarchicalItem>):MockHierarchicalItem {
		return new MockHierarchicalItem(text, value, children);
	}

	override public function setup():Void {
		super.setup();

		// Cast type parameters must be Dynamic
		this._arrayHierarchicalCollection = cast cast(this._collection, ArrayHierarchicalCollection<Dynamic>);
	}

	public function testResetArray():Void {
		var newArray = [this._5, this._4, this._3];
		this._arrayHierarchicalCollection.array = newArray;
		this.assertBranchMatches([this._5, this._4, this._3]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.RESET, location: null},
			{type: Event.CHANGE}
		]);
	}

	public function testResetArrayToNull():Void {
		this._arrayHierarchicalCollection.array = null;
		Assert.isOfType(this._arrayHierarchicalCollection.array, Array, "Setting collection source to null should replace with an empty value.");
		this.assertBranchMatches([]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.RESET, location: null},
			{type: Event.CHANGE}
		]);
	}

	public function testChangeSourceWithFilterFunction():Void {
		this._collection.filterFunction = (item:MockHierarchicalItem) -> {
			var location = this._collection.locationOf(item);
			if (location.length > 1) {
				return true;
			}
			return location[0] % 2 == 0;
		};
		this.assertBranchMatches([this._1, this._3, this._5]);

		var new1 = new MockHierarchicalItem("New Item 1", 101);
		var new2 = new MockHierarchicalItem("New Item 2", 102);
		this._arrayHierarchicalCollection.array = [new1, new2];
		this.assertBranchMatches([new1]);
	}
}

private class MockHierarchicalItem extends MockItem {
	public function new(text:String, value:Float, ?children:Array<MockHierarchicalItem>) {
		super(text, value);
		this.children = children;
	}

	public var children:Array<MockHierarchicalItem>;
}
