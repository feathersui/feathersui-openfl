/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FlatCollectionEvent;
import openfl.events.Event;
import openfl.Vector;
import utest.Assert;

@:keep
class VectorCollectionTest extends IFlatCollectionTest {
	private var _vectorCollection:VectorCollection<MockItem>;

	override private function createCollection(?data:Array<MockItem>):IFlatCollection<MockItem> {
		return new VectorCollection<MockItem>(data != null ? Vector.ofArray(data) : null);
	}

	override public function setup():Void {
		super.setup();

		#if air
		this._vectorCollection = cast this._collection;
		#else
		// Cast type parameters must be Dynamic
		this._vectorCollection = cast cast(this._collection, VectorCollection<Dynamic>);
		#end
	}

	public function testResetVector():Void {
		var newVector = Vector.ofArray([this._c, this._b, this._a]);
		this._vectorCollection.vector = newVector;
		this.assertCollectionMatches([this._c, this._b, this._a]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.RESET},
			{type: Event.CHANGE}
		]);
	}

	public function testResetVectorToNull():Void {
		this._vectorCollection.vector = null;
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
		this._vectorCollection.vector = Vector.ofArray([new1, new2]);
		this.assertCollectionMatches([new1]);
	}
}
