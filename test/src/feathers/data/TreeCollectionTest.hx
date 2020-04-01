/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */ package feathers.data;

import openfl.errors.RangeError;
import haxe.io.Error;
import massive.munit.Assert;
import feathers.events.HierarchicalCollectionEvent;
import openfl.events.Event;

@:keep class TreeCollectionTest {
	private var _collection:TreeCollection<MockItem>;
	private var _1:TreeNode<MockItem>;
	private var _2:TreeNode<MockItem>;
	private var _3:TreeNode<MockItem>;
	private var _4:TreeNode<MockItem>;
	private var _5:TreeNode<MockItem>;
	private var _1a:TreeNode<MockItem>;
	private var _1b:TreeNode<MockItem>;
	private var _1c:TreeNode<MockItem>;

	@Before
	public function prepare():Void {
		this._1a = new TreeNode(new MockItem("1-A"));
		this._1b = new TreeNode(new MockItem("1-B"), [new TreeNode(new MockItem("1-B-I"))]);
		this._1c = new TreeNode(new MockItem("1-C"));
		this._1 = new TreeNode(new MockItem("1"), [this._1a, this._1b, this._1c]);
		this._2 = new TreeNode(new MockItem("2"), [new TreeNode(new MockItem("2-A"))]);
		this._3 = new TreeNode(new MockItem("3"));
		this._4 = new TreeNode(new MockItem("4"), [new TreeNode(new MockItem("4-A")), new TreeNode(new MockItem("4-B"))]);
		this._5 = new TreeNode(new MockItem("5"), []);
		this._collection = new TreeCollection([this._1, this._2, this._3, this._4, this._5]);
	}

	@After
	public function cleanup():Void {
		this._collection = null;
	}

	@Test
	public function testLength():Void {
		Assert.areEqual(5, this._collection.getLength(), "Collection getLength() returns wrong length");
		Assert.areEqual(5, this._collection.getLength([]), "Collection getLength() returns wrong length");
		Assert.areEqual(3, this._collection.getLength([0]), "Collection getLength() returns wrong length");
		Assert.areEqual(1, this._collection.getLength([1]), "Collection getLength() returns wrong length");
		Assert.areEqual(0, this._collection.getLength([4]), "Collection getLength() returns wrong length");
		Assert.areEqual(1, this._collection.getLength([0, 1]), "Collection getLength() returns wrong length");
	}

	@Test
	public function testLocationOf():Void {
		Assert.areEqual(1, this._collection.locationOf(this._1).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(0, this._collection.locationOf(this._1)[0], "Collection locationOf() returns wrong location");
		Assert.areEqual(2, this._collection.locationOf(this._1a).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(0, this._collection.locationOf(this._1a)[0], "Collection locationOf() returns wrong location");
		Assert.areEqual(0, this._collection.locationOf(this._1a)[1], "Collection locationOf() returns wrong location");
		Assert.areEqual(2, this._collection.locationOf(this._1b).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(0, this._collection.locationOf(this._1b)[0], "Collection locationOf() returns wrong location");
		Assert.areEqual(1, this._collection.locationOf(this._1b)[1], "Collection locationOf() returns wrong location");
		Assert.areEqual(2, this._collection.locationOf(this._1c).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(0, this._collection.locationOf(this._1c)[0], "Collection locationOf() returns wrong location");
		Assert.areEqual(2, this._collection.locationOf(this._1c)[1], "Collection locationOf() returns wrong location");
		Assert.areEqual(1, this._collection.locationOf(this._2).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(1, this._collection.locationOf(this._2)[0], "Collection locationOf() returns wrong location");
		Assert.areEqual(1, this._collection.locationOf(this._3).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(2, this._collection.locationOf(this._3)[0], "Collection locationOf() returns wrong location");
		Assert.areEqual(1, this._collection.locationOf(this._4).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(3, this._collection.locationOf(this._4)[0], "Collection locationOf() returns wrong location");
		Assert.areEqual(1, this._collection.locationOf(this._5).length, "Collection locationOf() returns wrong location");
		Assert.areEqual(4, this._collection.locationOf(this._5)[0], "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(new TreeNode(new MockItem("Not in collection"))),
			"Collection locationOf() must return null for items not in collection");
	}

	@Test
	public function testContains():Void {
		Assert.isTrue(this._collection.contains(this._1), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1b), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1c), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._2), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._3), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._4), "Collection contains() returns wrong result for item in collection");
		Assert.isFalse(this._collection.contains(new TreeNode(new MockItem("Not in collection"))),
			"Collection contains() returns wrong result for item not in collection");
	}

	@Test
	public function testGet():Void {
		Assert.areEqual(this._1, this._collection.get([0]), "Collection get() returns wrong item");
		Assert.areEqual(this._1a, this._collection.get([0, 0]), "Collection get() returns wrong item");
		Assert.areEqual(this._1b, this._collection.get([0, 1]), "Collection get() returns wrong item");
		Assert.areEqual(this._1c, this._collection.get([0, 2]), "Collection get() returns wrong item");
		Assert.areEqual(this._2, this._collection.get([1]), "Collection get() returns wrong item");
		Assert.areEqual(this._3, this._collection.get([2]), "Collection get() returns wrong item");
		Assert.areEqual(this._4, this._collection.get([3]), "Collection get() returns wrong item");
		Assert.areEqual(this._5, this._collection.get([4]), "Collection get() returns wrong item");
		Assert.throws(RangeError, function() {
			this._collection.get(null);
		});
		Assert.throws(RangeError, function() {
			this._collection.get([100]);
		});
		Assert.throws(RangeError, function() {
			this._collection.get([-1]);
		});
	}

	@Test
	public function testAddAt():Void {
		var itemToAdd = new TreeNode(new MockItem("New Item"));
		var originalLength = this._collection.getLength([0]);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var locationFromEvent:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			addItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.addAt(itemToAdd, [0, 1]);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(addItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.areEqual(originalLength + 1, this._collection.getLength([0]), "Collection length must change after adding to collection");
		Assert.areEqual(2, this._collection.locationOf(itemToAdd).length, "Adding item to collection returns incorrect location");
		Assert.areEqual(0, this._collection.locationOf(itemToAdd)[0], "Adding item to collection returns incorrect location");
		Assert.areEqual(1, this._collection.locationOf(itemToAdd)[1], "Adding item to collection returns incorrect location");
		Assert.areEqual(2, locationFromEvent.length, "Adding item to collection returns incorrect location in event");
		Assert.areEqual(0, locationFromEvent[0], "Adding item to collection returns incorrect location in event");
		Assert.areEqual(1, locationFromEvent[1], "Adding item to collection returns incorrect location in event");

		Assert.throws(RangeError, function() {
			this._collection.addAt(itemToAdd, null);
		});
		Assert.throws(RangeError, function() {
			this._collection.addAt(itemToAdd, [100]);
		});
		Assert.throws(RangeError, function() {
			this._collection.addAt(itemToAdd, [-1]);
		});
	}

	@Test
	public function testSet():Void {
		var itemToAdd = new TreeNode(new MockItem("New Item"));
		var originalLength = this._collection.getLength([0]);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var replaceItemEvent = false;
		var locationFromEvent:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			replaceItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.set([0, 1], itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isTrue(replaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.areEqual(originalLength, this._collection.getLength([0]), "Collection length must not change after replacing in collection");
		Assert.areEqual(2, this._collection.locationOf(itemToAdd).length, "Replacing item in collection returns incorrect location");
		Assert.areEqual(0, this._collection.locationOf(itemToAdd)[0], "Replacing item in collection returns incorrect location");
		Assert.areEqual(1, this._collection.locationOf(itemToAdd)[1], "Replacing item in collection returns incorrect location");
		Assert.areEqual(2, locationFromEvent.length, "Replacing item in collection returns incorrect location in event");
		Assert.areEqual(0, locationFromEvent[0], "Replacing item in collection returns incorrect location in event");
		Assert.areEqual(1, locationFromEvent[1], "Replacing item in collection returns incorrect location in event");

		Assert.throws(RangeError, function() {
			this._collection.set(null, itemToAdd);
		});
		Assert.throws(RangeError, function() {
			this._collection.set([100], itemToAdd);
		});
		Assert.throws(RangeError, function() {
			this._collection.set([-1], itemToAdd);
		});
	}

	@Test
	public function testRemove():Void {
		var originalLength = this._collection.getLength([0]);
		var itemToRemove = this._collection.get([0, 1]);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeItemEvent = false;
		var locationFromEvent:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			removeItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.remove(itemToRemove);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(removeItemEvent, "HierarchicalCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.areEqual(originalLength - 1, this._collection.getLength([0]), "Collection length must change after removing from collection");
		Assert.areEqual(null, this._collection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.areEqual(2, locationFromEvent.length, "Removing item from collection returns incorrect location in event");
		Assert.areEqual(0, locationFromEvent[0], "Removing item from collection returns incorrect location in event");
		Assert.areEqual(1, locationFromEvent[1], "Removing item from collection returns incorrect location in event");
	}

	@Test
	public function testRemoveAt():Void {
		var originalLength = this._collection.getLength([0]);
		var itemToRemove = this._collection.get([0, 1]);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeItemEvent = false;
		var locationFromEvent:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			removeItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.removeAt([0, 1]);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(removeItemEvent, "HierarchicalCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.areEqual(originalLength - 1, this._collection.getLength([0]), "Collection length must change after removing from collection");
		Assert.areEqual(null, this._collection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.areEqual(2, locationFromEvent.length, "Removing item from collection returns incorrect location in event");
		Assert.areEqual(0, locationFromEvent[0], "Removing item from collection returns incorrect location in event");
		Assert.areEqual(1, locationFromEvent[1], "Removing item from collection returns incorrect location in event");

		Assert.throws(RangeError, function() {
			this._collection.removeAt(null);
		});
		Assert.throws(RangeError, function() {
			this._collection.removeAt([100]);
		});
		Assert.throws(RangeError, function() {
			this._collection.removeAt([-1]);
		});
	}

	@Test
	public function testRemoveAll():Void {
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			removeAllEvent = true;
		});
		var resetEvent = false;
		this._collection.addEventListener(HierarchicalCollectionEvent.RESET, function(event:HierarchicalCollectionEvent):Void {
			resetEvent = true;
		});
		this._collection.removeAll();
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing all from collection");
		Assert.isTrue(removeAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must be dispatched after removing all from collection");
		Assert.isFalse(resetEvent, "HierarchicalCollectionEvent.RESET must not be dispatched after removing all from collection");
		Assert.areEqual(0, this._collection.getLength(), "Collection length must change after removing all from collection");
	}

	@Test
	public function testRemoveAllWithEmptyCollection():Void {
		this._collection = new TreeCollection();
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			removeAllEvent = true;
		});
		this._collection.removeAll();
		Assert.isFalse(changeEvent, "Event.CHANGE must not be dispatched after removing all from empty collection");
		Assert.isFalse(removeAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must not be dispatched after removing all from empty collection");
	}

	@Test
	public function testResetArray():Void {
		var newArray = [this._5, this._4, this._3];
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			removeAllEvent = true;
		});
		var resetEvent = false;
		this._collection.addEventListener(HierarchicalCollectionEvent.RESET, function(event:HierarchicalCollectionEvent):Void {
			resetEvent = true;
		});
		this._collection.array = newArray;
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after resetting collection");
		Assert.isTrue(resetEvent, "HierarchicalCollectionEvent.RESET must be dispatched after resetting collection");
		Assert.isFalse(removeAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must not be dispatched after resetting from collection");
		Assert.areEqual(newArray.length, this._collection.getLength(), "Collection length must change after resetting collection with data of new size");
	}

	@Test
	public function testResetArrayToNull():Void {
		this._collection.array = null;
		Assert.isType(this._collection.array, Array, "Setting collection source to null should replace with an empty value.");
		Assert.areEqual(0, this._collection.getLength(), "Collection length must change after resetting collection source with empty valee");
	}

	@Test
	public function testUpdateAt():Void {
		var updateItemEvent = false;
		var updateItemLocation:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			updateItemEvent = true;
			updateItemLocation = event.location;
		});
		this._collection.updateAt([0, 1, 0]);
		Assert.isTrue(updateItemEvent, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched after calling updateAt()");
		Assert.areEqual(3, updateItemLocation.length, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.areEqual(0, updateItemLocation[0], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.areEqual(1, updateItemLocation[1], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.areEqual(0, updateItemLocation[2], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");

		Assert.throws(RangeError, function():Void {
			this._collection.updateAt(null);
		});
		Assert.throws(RangeError, function():Void {
			this._collection.updateAt([100]);
		});
		Assert.throws(RangeError, function():Void {
			this._collection.updateAt([-1]);
		});
	}

	@Test
	public function testUpdateAll():Void {
		var updateAllEvent = false;
		this._collection.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, function(event:HierarchicalCollectionEvent):Void {
			updateAllEvent = true;
		});
		this._collection.updateAll();
		Assert.isTrue(updateAllEvent, "HierarchicalCollectionEvent.UPDATE_ALL must be dispatched after calling updateAll()");
	}
}

private class MockItem {
	public function new(text:String) {
		this.text = text;
	}

	public var text:String;
}
