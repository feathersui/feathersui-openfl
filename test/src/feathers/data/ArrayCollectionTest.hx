/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FlatCollectionEvent;
import openfl.events.Event;
import utest.Assert;

@:keep
class ArrayCollectionTest extends IFlatCollectionTest {
	private var _arrayCollection:ArrayCollection<MockItem>;

	override private function createCollection(?data:Array<MockItem>):IFlatCollection<MockItem> {
		return new ArrayCollection<MockItem>(data);
	}

	override public function setup():Void {
		super.setup();

		// Cast type parameters must be Dynamic
		this._arrayCollection = cast cast(this._collection, ArrayCollection<Dynamic>);
	}

	public function testResetArray():Void {
		var newArray = [this._c, this._b, this._a];
		this._arrayCollection.array = newArray;
		this.assertCollectionMatches([this._c, this._b, this._a]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.RESET},
			{type: Event.CHANGE}
		]);
	}

	public function testResetArrayToNull():Void {
		this._arrayCollection.array = null;
		this.assertCollectionMatches([]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.RESET},
			{type: Event.CHANGE}
		]);
	}

	public function testChangeSourceWithFilterFunction():Void {
		this._collection.filterFunction = (item:MockItem) -> {
			var index = this._collection.indexOf(item);
			return index % 2 == 0;
		};
		this.assertCollectionMatches([this._a, this._c]);

		var new1 = new MockItem("New Item 1", 101);
		var new2 = new MockItem("New Item 2", 102);
		this._arrayCollection.array = [new1, new2];
		this.assertCollectionMatches([new1]);
	}
}
