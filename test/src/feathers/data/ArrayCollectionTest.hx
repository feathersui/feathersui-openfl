/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import massive.munit.Assert;
import feathers.events.FlatCollectionEvent;
import openfl.events.Event;

class ArrayCollectionTest {
	private var _collection:ArrayCollection<MockItem>;
	private var _a:MockItem;
	private var _b:MockItem;
	private var _c:MockItem;
	private var _d:MockItem;

	@Before
	public function prepare():Void {
		this._a = new MockItem("A");
		this._b = new MockItem("B");
		this._c = new MockItem("C");
		this._d = new MockItem("D");
		this._collection = new ArrayCollection([this._a, this._b, this._c, this._d]);
	}

	@After
	public function cleanup():Void {
		this._collection = null;
	}

	@Test
	public function testIndexOf():Void {
		Assert.areEqual(2, this._collection.indexOf(this._c), "Collection indexOf() returns wrong index");
		Assert.areEqual(0, this._collection.indexOf(this._a), "Collection indexOf() returns wrong index");
		Assert.areEqual(-1, this._collection.indexOf(new MockItem("Not in collection")), "Collection indexOf() must return -1 for items not in collection");
	}

	@Test
	public function testContains():Void {
		Assert.isTrue(this._collection.contains(this._c), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._a), "Collection contains() returns wrong result for item in collection");
		Assert.isFalse(this._collection.contains(new MockItem("Not in collection")), "Collection contains() returns wrong result for item not in collection");
	}

	@Test
	public function testGet():Void {
		Assert.areEqual(this._c, this._collection.get(2), "Collection get() returns wrong item");
		Assert.areEqual(this._a, this._collection.get(0), "Collection get() returns wrong item");
	}

	@Test
	public function testAdd():Void {
		var itemToAdd = new MockItem("New Item");
		var originalLength = this._collection.length;
		var expectedIndex = originalLength;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.add(itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(addItemEvent, "FlatCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.areEqual(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.areEqual(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.areEqual(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");
	}

	@Test
	public function testAddAt():Void {
		var itemToAdd = new MockItem("New Item");
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addAt(itemToAdd, expectedIndex);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(addItemEvent, "FlatCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.areEqual(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.areEqual(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.areEqual(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");
	}

	@Test
	public function testSet():Void {
		var itemToAdd = new MockItem("New Item");
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var replaceItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.set(expectedIndex, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isTrue(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.areEqual(originalLength, this._collection.length, "Collection length must not change after replacing in collection");
		Assert.areEqual(expectedIndex, this._collection.indexOf(itemToAdd), "Replacing item in collection returns incorrect index");
		Assert.areEqual(expectedIndex, indexFromEvent, "Replacing item in collection returns incorrect index in event");
	}

	@Test
	public function testRemove():Void {
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var itemToRemove = this._collection.get(expectedIndex);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ITEM, function(event:FlatCollectionEvent):Void {
			removeItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.remove(itemToRemove);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(removeItemEvent, "FlatCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.areEqual(originalLength - 1, this._collection.length, "Collection length must change after removing from collection");
		Assert.areEqual(-1, this._collection.indexOf(itemToRemove), "Removing item from collection returns incorrect index");
		Assert.areEqual(expectedIndex, indexFromEvent, "Removing item from collection returns incorrect index in event");
	}

	@Test
	public function testRemoveAt():Void {
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var itemToRemove = this._collection.get(expectedIndex);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ITEM, function(event:FlatCollectionEvent):Void {
			removeItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.removeAt(expectedIndex);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(removeItemEvent, "FlatCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.areEqual(originalLength - 1, this._collection.length, "Collection length must change after removing from collection");
		Assert.areEqual(-1, this._collection.indexOf(itemToRemove), "Removing item from collection returns incorrect index");
		Assert.areEqual(expectedIndex, indexFromEvent, "Removing item from collection returns incorrect index in event");
	}

	@Test
	public function testRemoveAll():Void {
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ALL, function(event:FlatCollectionEvent):Void {
			removeAllEvent = true;
		});
		var resetEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.RESET, function(event:FlatCollectionEvent):Void {
			resetEvent = true;
		});
		this._collection.removeAll();
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing all from collection");
		Assert.isTrue(removeAllEvent, "FlatCollectionEvent.REMOVE_ALL must be dispatched after removing all from collection");
		Assert.isFalse(resetEvent, "FlatCollectionEvent.RESET must not be dispatched after removing all from collection");
		Assert.areEqual(0, this._collection.length, "Collection length must change after removing all from collection");
	}

	@Test
	public function testResetArray():Void {
		var newArray = [this._c, this._b, this._a];
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ALL, function(event:FlatCollectionEvent):Void {
			removeAllEvent = true;
		});
		var resetEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.RESET, function(event:FlatCollectionEvent):Void {
			resetEvent = true;
		});
		this._collection.array = newArray;
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after resetting collection");
		Assert.isTrue(resetEvent, "FlatCollectionEvent.RESET must be dispatched after resetting collection");
		Assert.isFalse(removeAllEvent, "FlatCollectionEvent.REMOVE_ALL must not be dispatched after resetting from collection");
		Assert.areEqual(newArray.length, this._collection.length, "Collection length must change after resetting collection with data of new size");
	}
}

class MockItem {
	public function new(text:String) {
		this.text = text;
	}

	public var text:String;
}
