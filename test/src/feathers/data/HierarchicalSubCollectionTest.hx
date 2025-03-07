/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.events.Event;
import openfl.errors.RangeError;
import feathers.events.HierarchicalCollectionEvent;
import haxe.io.Error;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class HierarchicalSubCollectionTest extends Test {
	private var _parentCollection:ArrayHierarchicalCollection<MockItem>;
	private var _subCollection:HierarchicalSubCollection<MockItem>;
	private var _1:MockItem;
	private var _2:MockItem;
	private var _3:MockItem;
	private var _4:MockItem;
	private var _1a:MockItem;
	private var _2a:MockItem;
	private var _2b:MockItem;
	private var _2c:MockItem;
	private var _3a:MockItem;
	private var _2bi:MockItem;

	public function new() {
		super();
	}

	public function setup():Void {
		this._1a = new MockItem("1-A", 1);
		this._1 = new MockItem("1", 0, [this._1a]);
		this._2a = new MockItem("2-A", 3);
		this._2bi = new MockItem("2-B-I", 4);
		this._2b = new MockItem("2-B", 5, [this._2bi]);
		this._2c = new MockItem("2-C", 6);
		this._2 = new MockItem("2", 2, [this._2a, this._2b, this._2c]);
		this._3 = new MockItem("3", 7);
		this._3 = new MockItem("4", 8);
		this._parentCollection = new ArrayHierarchicalCollection([this._1, this._2, this._3], (item:MockItem) -> item.children);
		this._subCollection = new HierarchicalSubCollection(this._parentCollection, [1]);
	}

	public function teardown():Void {
		this._parentCollection = null;
		this._subCollection = null;
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

	public function testLength():Void {
		Assert.equals(3, this._parentCollection.getLength());

		Assert.equals(3, this._subCollection.getLength());
		Assert.equals(3, this._subCollection.getLength([]));
		Assert.equals(1, this._subCollection.getLength([1]));
	}

	public function testLocationOf():Void {
		Assert.isTrue(locationsMatch([0], this._subCollection.locationOf(this._2a)));
		Assert.isTrue(locationsMatch([1], this._subCollection.locationOf(this._2b)));
		Assert.isTrue(locationsMatch([2], this._subCollection.locationOf(this._2c)));
		Assert.isTrue(locationsMatch([1, 0], this._subCollection.locationOf(this._2bi)));
		Assert.isNull(this._subCollection.locationOf(this._1));
		Assert.isNull(this._subCollection.locationOf(this._2));
		Assert.isNull(this._subCollection.locationOf(this._3));
		Assert.isNull(this._subCollection.locationOf(new MockItem("Not in collection", -1)));
	}

	public function testContains():Void {
		Assert.isTrue(this._subCollection.contains(this._2a));
		Assert.isTrue(this._subCollection.contains(this._2b));
		Assert.isTrue(this._subCollection.contains(this._2c));
		Assert.isTrue(this._subCollection.contains(this._2bi));
		Assert.isFalse(this._subCollection.contains(this._1));
		Assert.isFalse(this._subCollection.contains(this._2));
		Assert.isFalse(this._subCollection.contains(this._3));
		Assert.isFalse(this._subCollection.contains(new MockItem("Not in collection", -1)));
	}

	public function testGet():Void {
		Assert.equals(this._2a, this._subCollection.get([0]));
		Assert.equals(this._2b, this._subCollection.get([1]));
		Assert.equals(this._2bi, this._subCollection.get([1, 0]));
		Assert.equals(this._2c, this._subCollection.get([2]));
		Assert.raises(function() {
			this._subCollection.get(null);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.get([100]);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.get([-1]);
		}, RangeError);
	}

	public function testAddAt():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var parentOriginalLength = this._parentCollection.getLength([1, 1]);
		var subOriginalLength = this._subCollection.getLength([1]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentAddItemEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subAddItemEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			parentAddItemEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			subAddItemEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.addAt(itemToAdd, [1, 1]);
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(parentAddItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.isTrue(subAddItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.equals(parentOriginalLength + 1, this._parentCollection.getLength([1, 1]));
		Assert.equals(subOriginalLength + 1, this._subCollection.getLength([1]));
		Assert.isTrue(locationsMatch([1, 1, 1], this._parentCollection.locationOf(itemToAdd)), "Adding item to collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1], this._subCollection.locationOf(itemToAdd)), "Adding item to collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1, 1], parentLocationFromEvent), "Adding item to collection returns incorrect location in event");
		Assert.isTrue(locationsMatch([1, 1], subLocationFromEvent), "Adding item to collection returns incorrect location in event");

		Assert.raises(function() {
			this._subCollection.addAt(itemToAdd, null);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.addAt(itemToAdd, [100]);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.addAt(itemToAdd, [-1]);
		}, RangeError);
	}

	public function testAddAtEndOfBranch():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var parentOriginalLength = this._parentCollection.getLength([1, 1]);
		var subOriginalLength = this._subCollection.getLength([1]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentAddItemEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subAddItemEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			parentAddItemEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, function(event:HierarchicalCollectionEvent):Void {
			subAddItemEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.addAt(itemToAdd, [1, subOriginalLength]);
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(parentAddItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.isTrue(subAddItemEvent, "HierarchicalCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.equals(parentOriginalLength + 1, this._parentCollection.getLength([1, 1]));
		Assert.equals(subOriginalLength + 1, this._subCollection.getLength([1]));
		Assert.isTrue(locationsMatch([1, 1, subOriginalLength], this._parentCollection.locationOf(itemToAdd)),
			"Adding item to collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, subOriginalLength], this._subCollection.locationOf(itemToAdd)),
			"Adding item to collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1, subOriginalLength], parentLocationFromEvent), "Adding item to collection returns incorrect location in event");
		Assert.isTrue(locationsMatch([1, subOriginalLength], subLocationFromEvent), "Adding item to collection returns incorrect location in event");
	}

	public function testSetReplace():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var parentOriginalLength = this._parentCollection.getLength([1, 1]);
		var subOriginalLength = this._subCollection.getLength([1]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentReplaceItemEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subReplaceItemEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			parentReplaceItemEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			subReplaceItemEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.set([1, 0], itemToAdd);
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isTrue(parentReplaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.isTrue(subReplaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.equals(parentOriginalLength, this._parentCollection.getLength([1, 1]));
		Assert.equals(subOriginalLength, this._subCollection.getLength([1]));
		Assert.isTrue(locationsMatch([1, 1, 0], this._parentCollection.locationOf(itemToAdd)), "Replacing item in collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 0], this._subCollection.locationOf(itemToAdd)), "Replacing item in collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1, 0], parentLocationFromEvent), "Replacing item in collection returns incorrect location in event");
		Assert.isTrue(locationsMatch([1, 0], subLocationFromEvent), "Replacing item in collection returns incorrect location in event");

		Assert.raises(function() {
			this._subCollection.set(null, itemToAdd);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.set([100], itemToAdd);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.set([-1], itemToAdd);
		}, RangeError);
	}

	public function testSetAfterEndOfBranch():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var parentOriginalLength = this._parentCollection.getLength([1, 1]);
		var subOriginalLength = this._subCollection.getLength([1]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentReplaceItemEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subReplaceItemEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			parentReplaceItemEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			subReplaceItemEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.set([1, 1], itemToAdd);
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isTrue(parentReplaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.isTrue(subReplaceItemEvent, "HierarchicalCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.equals(parentOriginalLength + 1, this._parentCollection.getLength([1, 1]));
		Assert.equals(subOriginalLength + 1, this._subCollection.getLength([1]));
		Assert.isTrue(locationsMatch([1, 1, 1], this._parentCollection.locationOf(itemToAdd)), "Replacing item in collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1], this._subCollection.locationOf(itemToAdd)), "Replacing item in collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1, 1], parentLocationFromEvent), "Replacing item in collection returns incorrect location in event");
		Assert.isTrue(locationsMatch([1, 1], subLocationFromEvent), "Replacing item in collection returns incorrect location in event");
	}

	public function testRemove():Void {
		var parentOriginalLength = this._parentCollection.getLength([1, 1]);
		var subOriginalLength = this._subCollection.getLength([1]);
		var itemToRemove = this._subCollection.get([1, 0]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentRemoveItemEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subRemoveItemEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			parentRemoveItemEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			subRemoveItemEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.remove(itemToRemove);
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(parentRemoveItemEvent, "HierarchicalCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.isTrue(subRemoveItemEvent, "HierarchicalCollectionEvent.REMOVE_ITEM must be dispatched after removing in from");
		Assert.equals(parentOriginalLength - 1, this._parentCollection.getLength([1, 1]));
		Assert.equals(subOriginalLength - 1, this._subCollection.getLength([1]));
		Assert.isNull(this._parentCollection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.isNull(this._subCollection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1, 0], parentLocationFromEvent), "Removing item from collection returns incorrect location in event");
		Assert.isTrue(locationsMatch([1, 0], subLocationFromEvent), "Removing item from collection returns incorrect location in event");
	}

	public function testRemoveAt():Void {
		var parentOriginalLength = this._parentCollection.getLength([1, 1]);
		var subOriginalLength = this._subCollection.getLength([1]);
		var itemToRemove = this._subCollection.get([1, 0]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentRemoveItemEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subRemoveItemEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			parentRemoveItemEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			subRemoveItemEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.removeAt([1, 0]);
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after removing to collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(parentRemoveItemEvent, "HierarchicalCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.isTrue(subRemoveItemEvent, "HierarchicalCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.equals(parentOriginalLength - 1, this._parentCollection.getLength([1, 1]));
		Assert.equals(subOriginalLength - 1, this._subCollection.getLength([1]));
		Assert.isNull(this._parentCollection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.isNull(this._subCollection.locationOf(itemToRemove), "Removing item from collection returns incorrect location");
		Assert.isTrue(locationsMatch([1, 1, 0], parentLocationFromEvent), "Removing item from collection returns incorrect location in event");
		Assert.isTrue(locationsMatch([1, 0], subLocationFromEvent), "Removing item from collection returns incorrect location in event");

		Assert.raises(function() {
			this._subCollection.removeAt(null);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.removeAt([100]);
		}, RangeError);
		Assert.raises(function() {
			this._subCollection.removeAt([-1]);
		}, RangeError);
	}

	public function testRemoveAll():Void {
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentRemoveAllEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subRemoveAllEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			parentRemoveAllEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			subRemoveAllEvent = true;
			subLocationFromEvent = event.location;
		});
		var parentResetEvent = false;
		var subResetEvent = false;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.RESET, function(event:HierarchicalCollectionEvent):Void {
			parentResetEvent = true;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.RESET, function(event:HierarchicalCollectionEvent):Void {
			subResetEvent = true;
		});
		this._subCollection.removeAll();
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after removing all from collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after removing all from collection");
		Assert.isTrue(parentRemoveAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must be dispatched after removing all from collection");
		Assert.isTrue(subRemoveAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must be dispatched after removing all from collection");
		Assert.isFalse(parentResetEvent, "HierarchicalCollectionEvent.RESET must not be dispatched after removing all from collection");
		Assert.isFalse(subResetEvent, "HierarchicalCollectionEvent.RESET must not be dispatched after removing all from collection");
		Assert.isTrue(locationsMatch([1], parentLocationFromEvent));
		Assert.isNull(subLocationFromEvent);
		Assert.equals(3, this._parentCollection.getLength());
		Assert.equals(0, this._subCollection.getLength());
	}

	public function testRemoveAllWithEmptyCollection():Void {
		this._parentCollection = new ArrayHierarchicalCollection([new MockItem("Empty Branch", 1, [])], (item:MockItem) -> item.children);
		this._subCollection = new HierarchicalSubCollection(this._parentCollection, [0]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentRemoveAllEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subRemoveAllEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			parentRemoveAllEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			subRemoveAllEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.removeAll();
		Assert.isFalse(parentChangeEvent, "Event.CHANGE must not be dispatched after removing all from empty collection");
		Assert.isFalse(subChangeEvent, "Event.CHANGE must not be dispatched after removing all from empty collection");
		Assert.isFalse(parentRemoveAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must not be dispatched after removing all from empty collection");
		Assert.isFalse(subRemoveAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must not be dispatched after removing all from empty collection");
		Assert.isNull(parentLocationFromEvent, "HierarchicalCollectionEvent.REMOVE_ALL location be be null if no location passed as argument");
		Assert.isNull(subLocationFromEvent, "HierarchicalCollectionEvent.REMOVE_ALL location be be null if no location passed as argument");
	}

	public function testRemoveAllWithLocation():Void {
		var parentOriginalLength1 = this._parentCollection.getLength([1]);
		var parentOriginalLength2 = this._parentCollection.getLength([1, 1]);
		var subOriginalLength1 = this._subCollection.getLength([]);
		var subOriginalLength2 = this._subCollection.getLength([1]);
		var parentChangeEvent = false;
		var subChangeEvent = false;
		this._parentCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			parentChangeEvent = true;
		});
		this._subCollection.addEventListener(Event.CHANGE, function(event:Event):Void {
			subChangeEvent = true;
		});
		var parentRemoveAllEvent = false;
		var parentLocationFromEvent:Array<Int> = null;
		var subRemoveAllEvent = false;
		var subLocationFromEvent:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			parentRemoveAllEvent = true;
			parentLocationFromEvent = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, function(event:HierarchicalCollectionEvent):Void {
			subRemoveAllEvent = true;
			subLocationFromEvent = event.location;
		});
		this._subCollection.removeAll([1]);
		Assert.isTrue(parentChangeEvent, "Event.CHANGE must be dispatched after removing all from collection");
		Assert.isTrue(subChangeEvent, "Event.CHANGE must be dispatched after removing all from collection");
		Assert.isTrue(parentRemoveAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must be dispatched after removing all from collection");
		Assert.isTrue(subRemoveAllEvent, "HierarchicalCollectionEvent.REMOVE_ALL must be dispatched after removing all from collection");
		Assert.isTrue(locationsMatch([1, 1], parentLocationFromEvent), "Removing all from collection returns incorrect location in event");
		Assert.isTrue(locationsMatch([1], subLocationFromEvent), "Removing all from collection returns incorrect location in event");
		Assert.equals(parentOriginalLength1, this._parentCollection.getLength([1]), "Collection length must change after removing all from collection");
		Assert.equals(subOriginalLength1, this._subCollection.getLength(), "Collection length must change after removing all from collection");
		Assert.equals(0, this._parentCollection.getLength([1, 1]), "Collection branch length must change after removing all from branch");
		Assert.equals(0, this._subCollection.getLength([1]), "Collection branch length must change after removing all from branch");
	}

	public function testUpdateAt():Void {
		var parentUpdateItemEvent = false;
		var parentUpdateItemLocation:Array<Int> = null;
		var subUpdateItemEvent = false;
		var subUpdateItemLocation:Array<Int> = null;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			parentUpdateItemEvent = true;
			parentUpdateItemLocation = event.location;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, function(event:HierarchicalCollectionEvent):Void {
			subUpdateItemEvent = true;
			subUpdateItemLocation = event.location;
		});
		this._subCollection.updateAt([1, 0]);
		Assert.isTrue(parentUpdateItemEvent, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched after calling updateAt()");
		Assert.isTrue(subUpdateItemEvent, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched after calling updateAt()");
		Assert.equals(3, parentUpdateItemLocation.length, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(1, parentUpdateItemLocation[0], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(1, parentUpdateItemLocation[1], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(0, parentUpdateItemLocation[2], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(2, subUpdateItemLocation.length, "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(1, subUpdateItemLocation[0], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");
		Assert.equals(0, subUpdateItemLocation[1], "HierarchicalCollectionEvent.UPDATE_ITEM must be dispatched with correct location");

		Assert.raises(function():Void {
			this._subCollection.updateAt(null);
		}, RangeError);
		Assert.raises(function():Void {
			this._subCollection.updateAt([100]);
		}, RangeError);
		Assert.raises(function():Void {
			this._subCollection.updateAt([-1]);
		}, RangeError);
	}

	public function testUpdateAll():Void {
		var parentUpdateAllEvent = false;
		var subUpdateAllEvent = false;
		this._parentCollection.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, function(event:HierarchicalCollectionEvent):Void {
			parentUpdateAllEvent = true;
		});
		this._subCollection.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, function(event:HierarchicalCollectionEvent):Void {
			subUpdateAllEvent = true;
		});
		this._subCollection.updateAll();
		Assert.isFalse(parentUpdateAllEvent, "HierarchicalCollectionEvent.UPDATE_ALL must not be dispatched for parent collection after calling updateAll()");
		Assert.isTrue(subUpdateAllEvent, "HierarchicalCollectionEvent.UPDATE_ALL must be dispatched after calling updateAll()");
	}
}

private class MockItem {
	public function new(text:String, value:Float, ?children:Array<MockItem>) {
		this.text = text;
		this.value = value;
		this.children = children;
	}

	public var text:String;
	public var children:Array<MockItem>;
	public var value:Float;
}
