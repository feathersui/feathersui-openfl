/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.data.TreeNode;
import openfl.errors.RangeError;
import haxe.io.Error;
import utest.Assert;
import utest.Test;
import feathers.events.HierarchicalCollectionEvent;
import openfl.events.Event;

@:keep class TreeCollectionTest extends Test {
	private static final TEXT_FILTER_ME = "__FILTER_ME__";

	private var _collection:TreeCollection<MockItem>;
	private var _1:TreeNode<MockItem>;
	private var _2:TreeNode<MockItem>;
	private var _3:TreeNode<MockItem>;
	private var _4:TreeNode<MockItem>;
	private var _5:TreeNode<MockItem>;
	private var _1a:TreeNode<MockItem>;
	private var _1b:TreeNode<MockItem>;
	private var _1c:TreeNode<MockItem>;
	private var _2a:TreeNode<MockItem>;
	private var _4a:TreeNode<MockItem>;
	private var _4b:TreeNode<MockItem>;

	public function new() {
		super();
	}

	public function setup():Void {
		this._1a = new TreeNode(new MockItem("1-A", 2));
		this._1b = new TreeNode(new MockItem("1-B", 1), [new TreeNode(new MockItem("1-B-I", 1))]);
		this._1c = new TreeNode(new MockItem("1-C", 3));
		this._1 = new TreeNode(new MockItem("1", 0), [this._1a, this._1b, this._1c]);
		this._2a = new TreeNode(new MockItem("2-A", 2));
		this._2 = new TreeNode(new MockItem("2", 2), [this._2a]);
		this._3 = new TreeNode(new MockItem("3", 3));
		this._4a = new TreeNode(new MockItem("4-A", 1));
		this._4b = new TreeNode(new MockItem("4-B", 0));
		this._4 = new TreeNode(new MockItem("4", 1), [this._4a, this._4b]);
		this._5 = new TreeNode(new MockItem("5", 4), []);
		this._collection = new TreeCollection([this._1, this._2, this._3, this._4, this._5]);
	}

	public function teardown():Void {
		this._collection = null;
	}

	private function locationsMatch(location1:Array<Int>, location2:Array<Int>):Bool {
		if (location1 == null && location2 == null) {
			return true;
		}
		if (location1 == null || location2 == null) {
			return false;
		}
		if (location1.length != location2.length) {
			return false;
		}
		for (i in 0...location1.length) {
			var item1 = location1[i];
			var item2 = location2[i];
			if (item1 != item2) {
				return false;
			}
		}
		return true;
	}

	private function filterFunction(item:TreeNode<MockItem>):Bool {
		if (item == this._2 || item == this._1b || item.data.text == TEXT_FILTER_ME) {
			return false;
		}
		return true;
	}

	private function sortCompareFunction(a:TreeNode<MockItem>, b:TreeNode<MockItem>):Int {
		var valueA = a.data.value;
		var valueB = b.data.value;
		if (valueA < valueB) {
			return -1;
		}
		if (valueA > valueB) {
			return 1;
		}
		return 0;
	}

	public function testLength():Void {
		Assert.equals(5, this._collection.getLength(), "Collection getLength() returns wrong length");
		Assert.equals(5, this._collection.getLength([]), "Collection getLength() returns wrong length");
		Assert.equals(3, this._collection.getLength([0]), "Collection getLength() returns wrong length");
		Assert.equals(1, this._collection.getLength([1]), "Collection getLength() returns wrong length");
		Assert.equals(0, this._collection.getLength([4]), "Collection getLength() returns wrong length");
		Assert.equals(1, this._collection.getLength([0, 1]), "Collection getLength() returns wrong length");
	}

	public function testLocationOf():Void {
		Assert.equals(1, this._collection.locationOf(this._1).length, "Collection locationOf() returns wrong location");
		Assert.equals(0, this._collection.locationOf(this._1)[0], "Collection locationOf() returns wrong location");
		Assert.equals(2, this._collection.locationOf(this._1a).length, "Collection locationOf() returns wrong location");
		Assert.equals(0, this._collection.locationOf(this._1a)[0], "Collection locationOf() returns wrong location");
		Assert.equals(0, this._collection.locationOf(this._1a)[1], "Collection locationOf() returns wrong location");
		Assert.equals(2, this._collection.locationOf(this._1b).length, "Collection locationOf() returns wrong location");
		Assert.equals(0, this._collection.locationOf(this._1b)[0], "Collection locationOf() returns wrong location");
		Assert.equals(1, this._collection.locationOf(this._1b)[1], "Collection locationOf() returns wrong location");
		Assert.equals(2, this._collection.locationOf(this._1c).length, "Collection locationOf() returns wrong location");
		Assert.equals(0, this._collection.locationOf(this._1c)[0], "Collection locationOf() returns wrong location");
		Assert.equals(2, this._collection.locationOf(this._1c)[1], "Collection locationOf() returns wrong location");
		Assert.equals(1, this._collection.locationOf(this._2).length, "Collection locationOf() returns wrong location");
		Assert.equals(1, this._collection.locationOf(this._2)[0], "Collection locationOf() returns wrong location");
		Assert.equals(1, this._collection.locationOf(this._3).length, "Collection locationOf() returns wrong location");
		Assert.equals(2, this._collection.locationOf(this._3)[0], "Collection locationOf() returns wrong location");
		Assert.equals(1, this._collection.locationOf(this._4).length, "Collection locationOf() returns wrong location");
		Assert.equals(3, this._collection.locationOf(this._4)[0], "Collection locationOf() returns wrong location");
		Assert.equals(1, this._collection.locationOf(this._5).length, "Collection locationOf() returns wrong location");
		Assert.equals(4, this._collection.locationOf(this._5)[0], "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(new TreeNode(new MockItem("Not in collection", -1))),
			"Collection locationOf() must return null for items not in collection");
	}

	public function testContains():Void {
		Assert.isTrue(this._collection.contains(this._1), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1b), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1c), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._2), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._3), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._4), "Collection contains() returns wrong result for item in collection");
		Assert.isFalse(this._collection.contains(new TreeNode(new MockItem("Not in collection", -1))),
			"Collection contains() returns wrong result for item not in collection");
	}

	public function testGet():Void {
		Assert.equals(this._1, this._collection.get([0]), "Collection get() returns wrong item");
		Assert.equals(this._1a, this._collection.get([0, 0]), "Collection get() returns wrong item");
		Assert.equals(this._1b, this._collection.get([0, 1]), "Collection get() returns wrong item");
		Assert.equals(this._1c, this._collection.get([0, 2]), "Collection get() returns wrong item");
		Assert.equals(this._2, this._collection.get([1]), "Collection get() returns wrong item");
		Assert.equals(this._3, this._collection.get([2]), "Collection get() returns wrong item");
		Assert.equals(this._4, this._collection.get([3]), "Collection get() returns wrong item");
		Assert.equals(this._5, this._collection.get([4]), "Collection get() returns wrong item");
		Assert.raises(function() {
			this._collection.get(null);
		}, RangeError);
		Assert.raises(function() {
			this._collection.get([100]);
		}, RangeError);
		Assert.raises(function() {
			this._collection.get([-1]);
		}, RangeError);
	}

	public function testAddAt():Void {
		var itemToAdd = new TreeNode(new MockItem("New Item", 100));
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
		Assert.equals(originalLength + 1, this._collection.getLength([0]), "Collection length must change after adding to collection");
		Assert.equals(2, this._collection.locationOf(itemToAdd).length, "Adding item to collection returns incorrect location");
		Assert.equals(0, this._collection.locationOf(itemToAdd)[0], "Adding item to collection returns incorrect location");
		Assert.equals(1, this._collection.locationOf(itemToAdd)[1], "Adding item to collection returns incorrect location");
		Assert.equals(2, locationFromEvent.length, "Adding item to collection returns incorrect location in event");
		Assert.equals(0, locationFromEvent[0], "Adding item to collection returns incorrect location in event");
		Assert.equals(1, locationFromEvent[1], "Adding item to collection returns incorrect location in event");

		Assert.raises(function() {
			this._collection.addAt(itemToAdd, null);
		}, RangeError);
		Assert.raises(function() {
			this._collection.addAt(itemToAdd, [100]);
		}, RangeError);
		Assert.raises(function() {
			this._collection.addAt(itemToAdd, [-1]);
		}, RangeError);
	}

	public function testAddAtEndOfBranch():Void {
		var itemToAdd = new TreeNode(new MockItem("New Item", 100));
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
		this._collection.addAt(itemToAdd, [0, originalLength]);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(addItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.equals(originalLength + 1, this._collection.getLength([0]), "Collection length must change after adding to collection");
		Assert.equals(2, this._collection.locationOf(itemToAdd).length, "Adding item to collection returns incorrect location");
		Assert.equals(0, this._collection.locationOf(itemToAdd)[0], "Adding item to collection returns incorrect location");
		Assert.equals(originalLength, this._collection.locationOf(itemToAdd)[1], "Adding item to collection returns incorrect location");
		Assert.equals(2, locationFromEvent.length, "Adding item to collection returns incorrect location in event");
		Assert.equals(0, locationFromEvent[0], "Adding item to collection returns incorrect location in event");
		Assert.equals(originalLength, locationFromEvent[1], "Adding item to collection returns incorrect location in event");
	}

	public function testSet():Void {
		var itemToAdd = new TreeNode(new MockItem("New Item", 100));
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
		Assert.equals(originalLength, this._collection.getLength([0]), "Collection length must not change after replacing in collection");
		Assert.equals(2, this._collection.locationOf(itemToAdd).length, "Replacing item in collection returns incorrect location");
		Assert.equals(0, this._collection.locationOf(itemToAdd)[0], "Replacing item in collection returns incorrect location");
		Assert.equals(1, this._collection.locationOf(itemToAdd)[1], "Replacing item in collection returns incorrect location");
		Assert.equals(2, locationFromEvent.length, "Replacing item in collection returns incorrect location in event");
		Assert.equals(0, locationFromEvent[0], "Replacing item in collection returns incorrect location in event");
		Assert.equals(1, locationFromEvent[1], "Replacing item in collection returns incorrect location in event");

		Assert.raises(function() {
			this._collection.set(null, itemToAdd);
		}, RangeError);
		Assert.raises(function() {
			this._collection.set([100], itemToAdd);
		}, RangeError);
		Assert.raises(function() {
			this._collection.set([-1], itemToAdd);
		}, RangeError);
	}

	public function testSetAfterEndOfBranch():Void {
		var itemToAdd = new TreeNode(new MockItem("New Item", 100));
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
		this._collection.set([0, originalLength], itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after setting item after end of collection");
		Assert.isTrue(replaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must be dispatched after setting item after end of collection");
		Assert.equals(originalLength + 1, this._collection.getLength([0]), "Collection length must change after setting item after end in collection");
		Assert.equals(2, this._collection.locationOf(itemToAdd).length, "Setting item after end of collection returns incorrect location");
		Assert.equals(0, this._collection.locationOf(itemToAdd)[0], "Setting item after end of collection returns incorrect location");
		Assert.equals(originalLength, this._collection.locationOf(itemToAdd)[1], "Setting item after end of collection returns incorrect location");
		Assert.equals(2, locationFromEvent.length, "Setting item after end of collection returns incorrect location in event");
		Assert.equals(0, locationFromEvent[0], "Setting item after end of collection returns incorrect location in event");
		Assert.equals(originalLength, locationFromEvent[1], "Setting item after end of collection returns incorrect location in event");
	}

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
		Assert.equals(originalLength - 1, this._collection.getLength([0]), "Collection length must change after removing from collection");
		Assert.equals(null, this._collection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.equals(2, locationFromEvent.length, "Removing item from collection returns incorrect location in event");
		Assert.equals(0, locationFromEvent[0], "Removing item from collection returns incorrect location in event");
		Assert.equals(1, locationFromEvent[1], "Removing item from collection returns incorrect location in event");
	}

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
		Assert.equals(originalLength - 1, this._collection.getLength([0]), "Collection length must change after removing from collection");
		Assert.equals(null, this._collection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.equals(2, locationFromEvent.length, "Removing item from collection returns incorrect location in event");
		Assert.equals(0, locationFromEvent[0], "Removing item from collection returns incorrect location in event");
		Assert.equals(1, locationFromEvent[1], "Removing item from collection returns incorrect location in event");

		Assert.raises(function() {
			this._collection.removeAt(null);
		}, RangeError);
		Assert.raises(function() {
			this._collection.removeAt([100]);
		}, RangeError);
		Assert.raises(function() {
			this._collection.removeAt([-1]);
		}, RangeError);
	}

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
		Assert.equals(0, this._collection.getLength(), "Collection length must change after removing all from collection");
	}

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
		Assert.equals(newArray.length, this._collection.getLength(), "Collection length must change after resetting collection with data of new size");
	}

	public function testResetArrayToNull():Void {
		this._collection.array = null;
		Assert.isOfType(this._collection.array, Array, "Setting collection source to null should replace with an empty value.");
		Assert.equals(0, this._collection.getLength(), "Collection length must change after resetting collection source with empty valee");
	}

	public function testUpdateAt():Void {
		var updateItemEvent = false;
		var updateItemLocation:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			updateItemEvent = true;
			updateItemLocation = event.location;
		});
		this._collection.updateAt([0, 1, 0]);
		Assert.isTrue(updateItemEvent, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched after calling updateAt()");
		Assert.equals(3, updateItemLocation.length, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(0, updateItemLocation[0], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(1, updateItemLocation[1], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(0, updateItemLocation[2], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");

		Assert.raises(function():Void {
			this._collection.updateAt(null);
		}, RangeError);
		Assert.raises(function():Void {
			this._collection.updateAt([100]);
		}, RangeError);
		Assert.raises(function():Void {
			this._collection.updateAt([-1]);
		}, RangeError);
	}

	public function testUpdateAll():Void {
		var updateAllEvent = false;
		this._collection.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, function(event:HierarchicalCollectionEvent):Void {
			updateAllEvent = true;
		});
		this._collection.updateAll();
		Assert.isTrue(updateAllEvent, "HierarchicalCollectionEvent.UPDATE_ALL must be dispatched after calling updateAll()");
	}

	//--- filterFunction

	public function testFilterFunction():Void {
		Assert.equals(this._collection.array.length, this._collection.getLength(), "Collection length must match source length if unfiltered");
		Assert.equals(this._collection.array[3].children.length, this._collection.getLength([3]), "Collection length must match source length if unfiltered");
		this._collection.filterFunction = filterFunction;
		Assert.notEquals(this._collection.array.length, this._collection.getLength(), "Collection length must not match source length if items are filtered");
		Assert.equals(this._collection.array.length - 1, this._collection.getLength(), "Collection length must account for filterFunction");
		Assert.equals(this._1, this._collection.get([0]), "Collection with filterFunction must filter items");
		Assert.equals(this._1a, this._collection.get([0, 0]), "Collection with filterFunction must filter items");
		Assert.equals(this._1c, this._collection.get([0, 1]), "Collection with filterFunction must filter items");
		Assert.equals(this._3, this._collection.get([1]), "Collection with filterFunction must filter items");
		Assert.equals(this._4, this._collection.get([2]), "Collection with filterFunction must filter items");
		Assert.equals(this._4a, this._collection.get([2, 0]), "Collection with filterFunction must filter items");
		Assert.equals(this._4b, this._collection.get([2, 1]), "Collection with filterFunction must filter items");
		Assert.equals(this._5, this._collection.get([3]), "Collection with filterFunction must filter items");
		Assert.notEquals(this._collection.array[3].children.length, this._collection.getLength([3]),
			"Collection length must not match source length if items are filtered");
		Assert.raises(function():Void {
			this._collection.get([4]);
		}, RangeError);
		Assert.raises(function():Void {
			this._collection.get([0, 2]);
		}, RangeError);
		Assert.raises(function():Void {
			this._collection.get([3, 0]);
		}, RangeError);
	}

	public function testSetFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		// get an item so that we know the filtering was applied
		Assert.equals(this._5, this._collection.get([3]), "Collection with filterFunction must filter items");

		this._collection.filterFunction = null;
		Assert.equals(this._collection.array.length, this._collection.getLength(),
			"Collection length must match source length after setting filterFunction to null");
		Assert.equals(this._1, this._collection.get([0]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._1a, this._collection.get([0, 0]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._1b, this._collection.get([0, 1]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._1c, this._collection.get([0, 2]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._2, this._collection.get([1]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._2a, this._collection.get([1, 0]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._3, this._collection.get([2]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._4, this._collection.get([3]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._4a, this._collection.get([3, 0]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._4b, this._collection.get([3, 1]), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._5, this._collection.get([4]), "Collection order is incorrect after setting filterFunction to null");
	}

	public function testContainsWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		Assert.isTrue(this._collection.contains(this._1), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(this._collection.contains(this._1a), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._1b), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._1c), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._2), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._2a), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(this._collection.contains(this._3), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(this._collection.contains(this._4), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._4a), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._4b), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._5), "Collection with filterFunction must contain unfiltered item");
	}

	public function testLocationOfWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		Assert.isTrue(locationsMatch([0], this._collection.locationOf(this._1)), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(locationsMatch([0, 0], this._collection.locationOf(this._1a)), "Collection with filterFunction must contain unfiltered item");
		Assert.isNull(this._collection.locationOf(this._1b), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(locationsMatch([0, 1], this._collection.locationOf(this._1c)), "Collection with filterFunction must contain unfiltered item");
		Assert.isNull(this._collection.locationOf(this._2), "Collection with filterFunction must contain unfiltered item");
		Assert.isNull(this._collection.locationOf(this._2a), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(locationsMatch([1], this._collection.locationOf(this._3)), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(locationsMatch([2], this._collection.locationOf(this._4)), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(locationsMatch([2, 0], this._collection.locationOf(this._4a)), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(locationsMatch([2, 1], this._collection.locationOf(this._4b)), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(locationsMatch([3], this._collection.locationOf(this._5)), "Collection with filterFunction must contain unfiltered item");
	}

	public function testSetReplaceWithFilterFunction():Void {
		var preFilteredLength = this._collection.getLength();

		this._collection.filterFunction = filterFunction;

		var itemToAdd = new TreeNode(new MockItem("New Item", 100));
		var originalFilteredLength = this._collection.getLength();
		var expectedIndex = 3;
		var expectedUnfilteredIndex = 4;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var locationFromEvent:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			addItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			replaceItemEvent = true;
			locationFromEvent = event.location;
		});
		var replacedItem = this._collection.get([expectedIndex]);
		this._collection.set([expectedIndex], itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isFalse(addItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must not be dispatched after replacing in collection");
		Assert.isTrue(replaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.equals(originalFilteredLength, this._collection.getLength(), "Collection length must not change after replacing in collection");
		Assert.isTrue(locationsMatch([expectedIndex], this._collection.locationOf(itemToAdd)), "Replacing item in collection returns incorrect location");
		Assert.isTrue(locationsMatch([expectedIndex], locationFromEvent), "Replacing item in collection returns incorrect location in event");

		this._collection.filterFunction = null;

		Assert.equals(preFilteredLength, this._collection.getLength(), "Collection length must change after replacing item");
		Assert.isTrue(locationsMatch([expectedUnfilteredIndex], this._collection.locationOf(itemToAdd)),
			"Replacing item returns incorrect location of new item");
	}

	public function testSetAfterEndWithFilterFunction():Void {
		var preFilteredLength = this._collection.getLength();

		this._collection.filterFunction = filterFunction;

		var itemToAdd = new TreeNode(new MockItem("New Item", 100));
		var originalFilteredLength = this._collection.getLength();
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var locationFromEvent:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			addItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			replaceItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.set([originalFilteredLength], itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after setting item after end of collection");
		Assert.isTrue(addItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must be dispatched after setting item after end of collection");
		Assert.isFalse(replaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must not be dispatched after setting item after end of collection");
		Assert.equals(originalFilteredLength + 1, this._collection.getLength(), "Collection length must change after setting item after end of collection");
		Assert.isTrue(locationsMatch([originalFilteredLength], this._collection.locationOf(itemToAdd)),
			"Setting item after end of collection returns incorrect location");
		Assert.isTrue(locationsMatch([originalFilteredLength], locationFromEvent), "Setting item after end of collection returns incorrect location in event");

		this._collection.filterFunction = null;

		Assert.equals(preFilteredLength + 1, this._collection.getLength(),
			"Collection length must change after setting item after end of collection (and filter is removed)");
		Assert.isTrue(locationsMatch([preFilteredLength], this._collection.locationOf(itemToAdd)),
			"Setting item after end of collection returns incorrect location");
	}

	public function testSetWithFilterFunctionAndNoMatch():Void {
		var preFilteredLength = this._collection.getLength();

		this._collection.filterFunction = filterFunction;

		var itemToAdd = new TreeNode(new MockItem(TEXT_FILTER_ME, 100));
		var originalFilteredLength = this._collection.getLength();
		var expectedIndex = 3;
		var expectedUnfilteredIndex = 4;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var removeItemEvent = false;
		var locationFromEvent:Array<Int> = null;
		this._collection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			addItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			replaceItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			removeItemEvent = true;
			locationFromEvent = event.location;
		});
		this._collection.set([expectedIndex], itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after setting item that is filtered");
		Assert.isFalse(addItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must not be dispatched after setting item that is filtered");
		Assert.isFalse(replaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must not be dispatched after setting item after end of collection");
		Assert.isTrue(removeItemEvent, "HierarchicalCollectionEvent.REMOVE_ITEM must be dispatched after setting item that is filtered");
		Assert.equals(originalFilteredLength - 1, this._collection.getLength(), "Collection length must change after setting item that is filtered");
		Assert.isNull(this._collection.locationOf(itemToAdd), "Setting item that is filtered returns incorrect location");
		Assert.isTrue(locationsMatch([expectedIndex], locationFromEvent), "Setting item that is filtered returns incorrect location in event");

		this._collection.filterFunction = null;

		Assert.equals(preFilteredLength, this._collection.getLength(),
			"Collection length must not change after setting item that is filtered (and filter is removed)");
		Assert.isTrue(locationsMatch([expectedUnfilteredIndex], this._collection.locationOf(itemToAdd)),
			"Setting item after end of collection returns incorrect location");
	}

	//--- sortCompareFunction

	public function testSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.equals(this._collection.array.length, this._collection.getLength(), "Collection length must not change if sorted");
		Assert.equals(this._1, this._collection.get([0]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._1b, this._collection.get([0, 0]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._1a, this._collection.get([0, 1]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._1c, this._collection.get([0, 2]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._4, this._collection.get([1]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._4b, this._collection.get([1, 0]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._4a, this._collection.get([1, 1]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._2, this._collection.get([2]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._2a, this._collection.get([2, 0]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._3, this._collection.get([3]), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._5, this._collection.get([4]), "Collection order is incorrect with sortCompareFunction");
	}

	public function testSetSortCompareFunctionToNull():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		// get an item so that we know the sorting was applied
		Assert.equals(this._4, this._collection.get([1]), "Collection order is incorrect with sortCompareFunction");

		this._collection.sortCompareFunction = null;
		Assert.equals(this._1, this._collection.get([0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._1a, this._collection.get([0, 0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._1b, this._collection.get([0, 1]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._1c, this._collection.get([0, 2]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._2, this._collection.get([1]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._2a, this._collection.get([1, 0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._3, this._collection.get([2]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._4, this._collection.get([3]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._4a, this._collection.get([3, 0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._4b, this._collection.get([3, 1]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._5, this._collection.get([4]), "Collection order is incorrect after setting sortCompareFunction to null");
	}

	public function testLocationOfWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.isTrue(locationsMatch([0], this._collection.locationOf(this._1)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([1], this._collection.locationOf(this._4)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([2], this._collection.locationOf(this._2)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([3], this._collection.locationOf(this._3)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([4], this._collection.locationOf(this._5)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([0, 0], this._collection.locationOf(this._1b)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([0, 1], this._collection.locationOf(this._1a)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([0, 2], this._collection.locationOf(this._1c)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([2, 0], this._collection.locationOf(this._2a)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([1, 0], this._collection.locationOf(this._4b)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([1, 1], this._collection.locationOf(this._4a)), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(new TreeNode(new MockItem("Not in collection", -1))),
			"Collection locationOf() must return null for items not in collection");
	}

	public function testContainsWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.isTrue(this._collection.contains(this._1), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1b), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._1c), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._2), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._2a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._3), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._4), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._4a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._4b), "Collection contains() returns wrong result for item in collection");
		Assert.isFalse(this._collection.contains(new TreeNode(new MockItem("Not in collection", -1))),
			"Collection contains() returns wrong result for item not in collection");
	}

	public function testAddAtWithSortCompareFunction():Void {
		var newItem = new TreeNode(new MockItem("New Item", 1.5));
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.addAt(newItem, [1]);

		// the index we passed in isn't necessarily the same while sorted
		Assert.equals(newItem, this._collection.get([2]), "Collection with sortCompareFunction and addAt() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		// and it might not even be the same while unsorted!
		// that's because, in the unsorted data, it will be placed relative to
		// the item in the sorted data that was at the index passed to addAt().
		// it may be confusing, but it's consistent with set() on filtered
		// collections
		Assert.equals(newItem, this._collection.get([3]), "Collection with sortCompareFunction and addAt() did not return correct item for unsorted index");
	}

	public function testRemoveWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.remove(this._2);

		Assert.equals(this._1, this._collection.get([0]), "Collection with sortCompareFunction and remove() did not return correct item for sorted index");
		Assert.equals(this._4, this._collection.get([1]), "Collection with sortCompareFunction and remove() did not return correct item for sorted index");
		Assert.equals(this._3, this._collection.get([2]), "Collection with sortCompareFunction and remove() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.equals(this._1, this._collection.get([0]), "Collection with sortCompareFunction and remove() did not return correct item for unsorted index");
		Assert.equals(this._3, this._collection.get([1]), "Collection with sortCompareFunction and remove() did not return correct item for unsorted index");
		Assert.equals(this._4, this._collection.get([2]), "Collection with sortCompareFunction and remove() did not return correct item for unsorted index");
	}

	public function testRemoveAtWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.removeAt([2]);

		Assert.equals(this._1, this._collection.get([0]), "Collection with sortCompareFunction and removeAt() did not return correct item for sorted index");
		Assert.equals(this._4, this._collection.get([1]), "Collection with sortCompareFunction and removeAt() did not return correct item for sorted index");
		Assert.equals(this._3, this._collection.get([2]), "Collection with sortCompareFunction and removeAt() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.equals(this._1, this._collection.get([0]), "Collection with sortCompareFunction and removeAt() did not return correct item for unsorted index");
		Assert.equals(this._3, this._collection.get([1]), "Collection with sortCompareFunction and removeAt() did not return correct item for unsorted index");
		Assert.equals(this._4, this._collection.get([2]), "Collection with sortCompareFunction and removeAt() did not return correct item for unsorted index");
	}

	public function testSetWithSortCompareFunction():Void {
		var newItem = new TreeNode(new MockItem("New Item", 1.5));
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.set([1], newItem);

		// the index we passed in isn't necessarily the same while sorted
		Assert.equals(newItem, this._collection.get([1]), "Collection with sortCompareFunction and set() did not return correct item for sorted index");
		Assert.isFalse(this._collection.contains(this._4), "Collection with sortCompareFunction and set() did not remove correct item for sorted index");

		this._collection.sortCompareFunction = null;

		// and it might not even be the same while unsorted!
		// that's because, in the unsorted data, it will replace the item in the
		// the sorted data that was at the index passed to set().
		// it may be confusing, but it's consistent with set() on filtered
		// collections
		Assert.equals(newItem, this._collection.get([3]), "Collection with sortCompareFunction and add() did not return correct item for unsorted index");
	}

	//--- sortCompareFunction AND filterFunction

	public function testSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.notEquals(this._collection.array.length, this._collection.getLength(), "Collection length must not match source length if items are filtered");
		Assert.equals(4, this._collection.getLength(), "Collection length must account for filterFunction");
		Assert.equals(this._1, this._collection.get([0]), "Items must be filtered and sorted");
		Assert.equals(this._1a, this._collection.get([0, 0]), "Items must be filtered and sorted");
		Assert.equals(this._1c, this._collection.get([0, 1]), "Items must be filtered and sorted");
		Assert.equals(this._4, this._collection.get([1]), "Items must be filtered and sorted");
		Assert.equals(this._4b, this._collection.get([1, 0]), "Items must be filtered and sorted");
		Assert.equals(this._4a, this._collection.get([1, 1]), "Items must be filtered and sorted");
		Assert.equals(this._3, this._collection.get([2]), "Items must be filtered and sorted");
		Assert.equals(this._5, this._collection.get([3]), "Items must be filtered and sorted");
	}

	public function testSetSortCompareFunctionAndFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		// get an item so that we know the sorting was applied
		Assert.equals(this._4, this._collection.get([1]), "Collection order is incorrect with sortCompareFunction");

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		Assert.equals(this._1, this._collection.get([0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._1a, this._collection.get([0, 0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._1b, this._collection.get([0, 1]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._1c, this._collection.get([0, 2]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._2, this._collection.get([1]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._2a, this._collection.get([1, 0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._3, this._collection.get([2]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._4, this._collection.get([3]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._4a, this._collection.get([3, 0]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._4b, this._collection.get([3, 1]), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._5, this._collection.get([4]), "Collection order is incorrect after setting sortCompareFunction to null");
	}

	public function testContainsWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.isTrue(this._collection.contains(this._1), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(this._collection.contains(this._1a), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._1b), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._1c), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._2), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._2a), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(this._collection.contains(this._3), "Collection with filterFunction must contain unfiltered item");
		Assert.isTrue(this._collection.contains(this._4), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._4a), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._4b), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._5), "Collection with filterFunction must contain unfiltered item");
	}

	public function testLocationOfWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.isTrue(locationsMatch([0], this._collection.locationOf(this._1)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([1], this._collection.locationOf(this._4)), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(this._2), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([2], this._collection.locationOf(this._3)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([3], this._collection.locationOf(this._5)), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(this._1b), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([0, 0], this._collection.locationOf(this._1a)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([0, 1], this._collection.locationOf(this._1c)), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(this._2a), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([1, 0], this._collection.locationOf(this._4b)), "Collection locationOf() returns wrong location");
		Assert.isTrue(locationsMatch([1, 1], this._collection.locationOf(this._4a)), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(new TreeNode(new MockItem("Not in collection", -1))),
			"Collection locationOf() must return null for items not in collection");
	}
}

private class MockItem {
	public function new(text:String, value:Float) {
		this.text = text;
		this.value = value;
	}

	public var text:String;
	public var value:Float;
}
