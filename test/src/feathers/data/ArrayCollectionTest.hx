/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.errors.RangeError;
import haxe.io.Error;
import utest.Assert;
import utest.Test;
import feathers.events.FlatCollectionEvent;
import openfl.events.Event;

@:keep
class ArrayCollectionTest extends Test {
	private static final TEXT_FILTER_ME = "__FILTER_ME__";

	private var _collection:ArrayCollection<MockItem>;
	private var _a:MockItem;
	private var _b:MockItem;
	private var _c:MockItem;
	private var _d:MockItem;

	public function new() {
		super();
	}

	public function setup():Void {
		this._a = new MockItem("A", 0);
		this._b = new MockItem("B", 2);
		this._c = new MockItem("C", 3);
		this._d = new MockItem("D", 1);
		this._collection = new ArrayCollection([this._a, this._b, this._c, this._d]);
	}

	public function teardown():Void {
		this._collection = null;
	}

	private function filterFunction(item:MockItem):Bool {
		if (item == this._a || item == this._c || item.text == TEXT_FILTER_ME) {
			return false;
		}
		return true;
	}

	private function sortCompareFunction(a:MockItem, b:MockItem):Int {
		var valueA = a.value;
		var valueB = b.value;
		if (valueA < valueB) {
			return -1;
		}
		if (valueA > valueB) {
			return 1;
		}
		return 0;
	}

	public function testIndexOf():Void {
		Assert.equals(0, this._collection.indexOf(this._a), "Collection indexOf() returns wrong index");
		Assert.equals(1, this._collection.indexOf(this._b), "Collection indexOf() returns wrong index");
		Assert.equals(2, this._collection.indexOf(this._c), "Collection indexOf() returns wrong index");
		Assert.equals(3, this._collection.indexOf(this._d), "Collection indexOf() returns wrong index");
		Assert.equals(-1, this._collection.indexOf(new MockItem("Not in collection", -1)), "Collection indexOf() must return -1 for items not in collection");
	}

	public function testContains():Void {
		Assert.isTrue(this._collection.contains(this._a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._b), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._d), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._d), "Collection contains() returns wrong result for item in collection");
		Assert.isFalse(this._collection.contains(new MockItem("Not in collection", -1)),
			"Collection contains() returns wrong result for item not in collection");
	}

	public function testGet():Void {
		Assert.equals(this._a, this._collection.get(0), "Collection get() returns wrong item");
		Assert.equals(this._b, this._collection.get(1), "Collection get() returns wrong item");
		Assert.equals(this._c, this._collection.get(2), "Collection get() returns wrong item");
		Assert.equals(this._d, this._collection.get(3), "Collection get() returns wrong item");
		Assert.raises(function() {
			this._collection.get(100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.get(-1);
		}, RangeError);
	}

	public function testAdd():Void {
		var itemToAdd = new MockItem("New Item", 100);
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
		Assert.equals(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");
	}

	public function testAddAt():Void {
		var itemToAdd = new MockItem("New Item", 100);
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
		Assert.equals(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");

		Assert.raises(function() {
			this._collection.addAt(itemToAdd, 100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.addAt(itemToAdd, -1);
		}, RangeError);
	}

	public function testSetReplace():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.set(expectedIndex, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isFalse(addItemEvent, "FlatCollectionEvent.ADD_ITEM must not be dispatched after replacing in collection");
		Assert.isTrue(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.equals(originalLength, this._collection.length, "Collection length must not change after replacing in collection");
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Replacing item in collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Replacing item in collection returns incorrect index in event");

		Assert.raises(function() {
			this._collection.set(100, itemToAdd);
		}, RangeError);
		Assert.raises(function() {
			this._collection.set(-1, itemToAdd);
		}, RangeError);
	}

	public function testSetAfterEnd():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var originalLength = this._collection.length;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.set(originalLength, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after setting item after end of collection");
		Assert.isTrue(addItemEvent, "FlatCollectionEvent.ADD_ITEM must be dispatched after setting item after end of collection");
		Assert.isFalse(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must not be dispatched after setting item after end of collection");
		Assert.equals(originalLength + 1, this._collection.length, "Collection length must change after setting item after end of collection");
		Assert.equals(originalLength, this._collection.indexOf(itemToAdd), "Setting item after end of collection returns incorrect index");
		Assert.equals(originalLength, indexFromEvent, "Setting item after end of collection returns incorrect index in event");
	}

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
		Assert.equals(originalLength - 1, this._collection.length, "Collection length must change after removing from collection");
		Assert.equals(-1, this._collection.indexOf(itemToRemove), "Removing item from collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Removing item from collection returns incorrect index in event");
	}

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
		Assert.equals(originalLength - 1, this._collection.length, "Collection length must change after removing from collection");
		Assert.equals(-1, this._collection.indexOf(itemToRemove), "Removing item from collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Removing item from collection returns incorrect index in event");

		Assert.raises(function() {
			this._collection.removeAt(100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.removeAt(-1);
		}, RangeError);
	}

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
		Assert.equals(0, this._collection.length, "Collection length must change after removing all from collection");
	}

	public function testRemoveAllWithEmptyCollection():Void {
		this._collection = new ArrayCollection();
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ALL, function(event:FlatCollectionEvent):Void {
			removeAllEvent = true;
		});
		this._collection.removeAll();
		Assert.isFalse(changeEvent, "Event.CHANGE must not be dispatched after removing all from empty collection");
		Assert.isFalse(removeAllEvent, "FlatCollectionEvent.REMOVE_ALL must not be dispatched after removing all from empty collection");
	}

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
		Assert.equals(newArray.length, this._collection.length, "Collection length must change after resetting collection with data of new size");
	}

	public function testResetArrayToNull():Void {
		this._collection.array = null;
		Assert.isOfType(this._collection.array, Array, "Setting collection source to null should replace with an empty value.");
		Assert.equals(0, this._collection.length, "Collection length must change after resetting collection source with empty valee");
	}

	public function testUpdateAt():Void {
		var updateItemEvent = false;
		var updateItemIndex = -1;
		this._collection.addEventListener(FlatCollectionEvent.UPDATE_ITEM, function(event:FlatCollectionEvent):Void {
			updateItemEvent = true;
			updateItemIndex = event.index;
		});
		this._collection.updateAt(1);
		Assert.isTrue(updateItemEvent, "FlatCollectionEvent.UPDATE_ITEM must be dispatched after calling updateAt()");
		Assert.equals(1, updateItemIndex, "FlatCollectionEvent.UPDATE_ITEM must be dispatched with correct index");

		Assert.raises(function():Void {
			this._collection.updateAt(100);
		}, RangeError);
		Assert.raises(function():Void {
			this._collection.updateAt(-1);
		}, RangeError);
	}

	public function testUpdateAll():Void {
		var updateAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.UPDATE_ALL, function(event:FlatCollectionEvent):Void {
			updateAllEvent = true;
		});
		this._collection.updateAll();
		Assert.isTrue(updateAllEvent, "FlatCollectionEvent.UPDATE_ALL must be dispatched after calling updateAll()");
	}

	//--- filterFunction

	public function testFilterFunction():Void {
		Assert.equals(this._collection.array.length, this._collection.length, "Collection length must match source length if unfiltered");
		this._collection.filterFunction = filterFunction;
		Assert.notEquals(this._collection.array.length, this._collection.length, "Collection length must not match source length if items are filtered");
		Assert.equals(this._collection.array.length - 2, this._collection.length, "Collection length must account for filterFunction");
		Assert.equals(this._b, this._collection.get(0), "Collection with filterFunction must filter items");
		Assert.equals(this._d, this._collection.get(1), "Collection with filterFunction must filter items");
		Assert.raises(function():Void {
			this._collection.get(2);
		}, RangeError);
	}

	public function testSetFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		// get an item so that we know the filtering was applied
		Assert.equals(this._b, this._collection.get(0), "Collection with filterFunction must filter items");

		this._collection.filterFunction = null;
		Assert.equals(this._collection.array.length, this._collection.length,
			"Collection length must match source length after setting filterFunction to null");
		Assert.equals(this._a, this._collection.get(0), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._b, this._collection.get(1), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._c, this._collection.get(2), "Collection order is incorrect after setting filterFunction to null");
		Assert.equals(this._d, this._collection.get(3), "Collection order is incorrect after setting filterFunction to null");
	}

	public function testContainsWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		Assert.isFalse(this._collection.contains(this._a), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._b), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._c), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._d), "Collection with filterFunction must contain unfiltered item");
	}

	public function testIndexOfWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		Assert.equals(-1, this._collection.indexOf(this._a), "Collection with filterFunction must return -1 for index of filtered item");
		Assert.equals(0, this._collection.indexOf(this._b), "Collection with filterFunction must return index of unfiltered item");
		Assert.equals(-1, this._collection.indexOf(this._c), "Collection with filterFunction must return -1 for index of filtered item");
		Assert.equals(1, this._collection.indexOf(this._d), "Collection with filterFunction must return index of unfiltered item");
	}

	public function testSetReplaceWithFilterFunction():Void {
		var preFilteredLength = this._collection.length;

		this._collection.filterFunction = filterFunction;

		var itemToAdd = new MockItem("New Item", 100);
		var originalFilteredLength = this._collection.length;
		var expectedIndex = 1;
		var expectedUnfilteredIndex = 3;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		var replacedItem = this._collection.get(expectedIndex);
		this._collection.set(expectedIndex, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isFalse(addItemEvent, "FlatCollectionEvent.ADD_ITEM must not be dispatched after replacing in collection");
		Assert.isTrue(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.equals(originalFilteredLength, this._collection.length, "Collection length must not change after replacing in collection");
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Replacing item in collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Replacing item in collection returns incorrect index in event");

		this._collection.filterFunction = null;

		Assert.equals(preFilteredLength, this._collection.length, "Collection length must change after replacing item");
		Assert.equals(expectedUnfilteredIndex, this._collection.indexOf(itemToAdd), "Replacing item returns incorrect index of new item");
	}

	public function testSetAfterEndWithFilterFunction():Void {
		var preFilteredLength = this._collection.length;

		this._collection.filterFunction = filterFunction;

		var itemToAdd = new MockItem("New Item", 100);
		var originalFilteredLength = this._collection.length;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.set(originalFilteredLength, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after setting item after end of collection");
		Assert.isTrue(addItemEvent, "FlatCollectionEvent.ADD_ITEM must be dispatched after setting item after end of collection");
		Assert.isFalse(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must not be dispatched after setting item after end of collection");
		Assert.equals(originalFilteredLength + 1, this._collection.length, "Collection length must change after setting item after end of collection");
		Assert.equals(originalFilteredLength, this._collection.indexOf(itemToAdd), "Setting item after end of collection returns incorrect index");
		Assert.equals(originalFilteredLength, indexFromEvent, "Setting item after end of collection returns incorrect index in event");

		this._collection.filterFunction = null;

		Assert.equals(preFilteredLength + 1, this._collection.length,
			"Collection length must change after setting item after end of collection (and filter is removed)");
		Assert.equals(preFilteredLength, this._collection.indexOf(itemToAdd), "Setting item after end of collection returns incorrect index");
	}

	public function testSetWithFilterFunctionAndNoMatch():Void {
		var preFilteredLength = this._collection.length;

		this._collection.filterFunction = filterFunction;

		var itemToAdd = new MockItem(TEXT_FILTER_ME, 100);
		var originalFilteredLength = this._collection.length;
		var expectedIndex = 1;
		var expectedUnfilteredIndex = 3;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var removeItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ITEM, function(event:FlatCollectionEvent):Void {
			removeItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.set(expectedIndex, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after setting item that is filtered");
		Assert.isFalse(addItemEvent, "FlatCollectionEvent.ADD_ITEM must not be dispatched after setting item that is filtered");
		Assert.isFalse(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must not be dispatched after setting item after end of collection");
		Assert.isTrue(removeItemEvent, "FlatCollectionEvent.REMOVE_ITEM must be dispatched after setting item that is filtered");
		Assert.equals(originalFilteredLength - 1, this._collection.length, "Collection length must change after setting item that is filtered");
		Assert.equals(-1, this._collection.indexOf(itemToAdd), "Setting item that is filtered returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Setting item that is filtered returns incorrect index in event");

		this._collection.filterFunction = null;

		Assert.equals(preFilteredLength, this._collection.length,
			"Collection length must not change after setting item that is filtered (and filter is removed)");
		Assert.equals(expectedUnfilteredIndex, this._collection.indexOf(itemToAdd), "Setting item that is filtered returns incorrect index");
	}

	//--- sortCompareFunction

	public function testSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.equals(this._collection.array.length, this._collection.length, "Collection length must not change if sorted");
		Assert.equals(this._a, this._collection.get(0), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._d, this._collection.get(1), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._b, this._collection.get(2), "Collection order is incorrect with sortCompareFunction");
		Assert.equals(this._c, this._collection.get(3), "Collection order is incorrect with sortCompareFunction");
	}

	public function testSetSortCompareFunctionToNull():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		// get an item so that we know the sorting was applied
		Assert.equals(this._d, this._collection.get(1), "Collection order is incorrect with sortCompareFunction");

		this._collection.sortCompareFunction = null;
		Assert.equals(this._a, this._collection.get(0), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._b, this._collection.get(1), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._c, this._collection.get(2), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.equals(this._d, this._collection.get(3), "Collection order is incorrect after setting sortCompareFunction to null");
	}

	public function testContainsWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.isTrue(this._collection.contains(this._a), "Collection with sortCompareFunction must contain all items");
		Assert.isTrue(this._collection.contains(this._b), "Collection with sortCompareFunction must contain all items");
		Assert.isTrue(this._collection.contains(this._c), "Collection with sortCompareFunction must contain all items");
		Assert.isTrue(this._collection.contains(this._d), "Collection with sortCompareFunction must contain all items");
	}

	public function testIndexOfWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.equals(0, this._collection.indexOf(this._a), "Collection with sortCompareFunction must return correct index for item");
		Assert.equals(2, this._collection.indexOf(this._b), "Collection with sortCompareFunction must return correct index for item");
		Assert.equals(3, this._collection.indexOf(this._c), "Collection with sortCompareFunction must return correct index for item");
		Assert.equals(1, this._collection.indexOf(this._d), "Collection with sortCompareFunction must return correct index for item");
	}

	public function testAddWithSortCompareFunction():Void {
		var newItem = new MockItem("New Item", 1.5);
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.add(newItem);

		Assert.equals(newItem, this._collection.get(2), "Collection with sortCompareFunction and add() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.equals(newItem, this._collection.get(4), "Collection with sortCompareFunction and add() did not return correct item for unsorted index");
	}

	public function testAddAtWithSortCompareFunction():Void {
		var newItem = new MockItem("New Item", 1.5);
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.addAt(newItem, 1);

		// the index we passed in isn't necessarily the same while sorted
		Assert.equals(newItem, this._collection.get(2), "Collection with sortCompareFunction and addAt() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		// and it might not even be the same while unsorted!
		// that's because, in the unsorted data, it will be placed relative to
		// the item in the sorted data that was at the index passed to addAt().
		// it may be confusing, but it's consistent with set() on filtered
		// collections
		Assert.equals(newItem, this._collection.get(3), "Collection with sortCompareFunction and addAt() did not return correct item for unsorted index");
	}

	public function testRemoveWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.remove(this._b);

		Assert.equals(this._a, this._collection.get(0), "Collection with sortCompareFunction and remove() did not return correct item for sorted index");
		Assert.equals(this._d, this._collection.get(1), "Collection with sortCompareFunction and remove() did not return correct item for sorted index");
		Assert.equals(this._c, this._collection.get(2), "Collection with sortCompareFunction and remove() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.equals(this._a, this._collection.get(0), "Collection with sortCompareFunction and remove() did not return correct item for unsorted index");
		Assert.equals(this._c, this._collection.get(1), "Collection with sortCompareFunction and remove() did not return correct item for unsorted index");
		Assert.equals(this._d, this._collection.get(2), "Collection with sortCompareFunction and remove() did not return correct item for unsorted index");
	}

	public function testRemoveAtWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.removeAt(2);

		Assert.equals(this._a, this._collection.get(0), "Collection with sortCompareFunction and removeAt() did not return correct item for sorted index");
		Assert.equals(this._d, this._collection.get(1), "Collection with sortCompareFunction and removeAt() did not return correct item for sorted index");
		Assert.equals(this._c, this._collection.get(2), "Collection with sortCompareFunction and removeAt() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.equals(this._a, this._collection.get(0), "Collection with sortCompareFunction and removeAt() did not return correct item for unsorted index");
		Assert.equals(this._c, this._collection.get(1), "Collection with sortCompareFunction and removeAt() did not return correct item for unsorted index");
		Assert.equals(this._d, this._collection.get(2), "Collection with sortCompareFunction and removeAt() did not return correct item for unsorted index");
	}

	public function testSetWithSortCompareFunction():Void {
		var newItem = new MockItem("New Item", 1.5);
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.set(1, newItem);

		// the index we passed in isn't necessarily the same while sorted
		Assert.equals(newItem, this._collection.get(1), "Collection with sortCompareFunction and set() did not return correct item for sorted index");
		Assert.isFalse(this._collection.contains(this._d), "Collection with sortCompareFunction and set() did not remove correct item for sorted index");

		this._collection.sortCompareFunction = null;

		// and it might not even be the same while unsorted!
		// that's because, in the unsorted data, it will replace the item in the
		// the sorted data that was at the index passed to set().
		// it may be confusing, but it's consistent with set() on filtered
		// collections
		Assert.equals(newItem, this._collection.get(3), "Collection with sortCompareFunction and add() did not return correct item for unsorted index");
	}

	//--- sortCompareFunction AND filterFunction

	public function testSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.notEquals(this._collection.array.length, this._collection.length, "Collection length must not match source length if items are filtered");
		Assert.equals(2, this._collection.length, "Collection length must account for filterFunction");
		Assert.equals(this._d, this._collection.get(0), "Items must be filtered and sorted");
		Assert.equals(this._b, this._collection.get(1), "Items must be filtered and sorted");
	}

	public function testSetSortCompareFunctionAndFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		// get an item so that we know the sorting was applied
		Assert.equals(this._d, this._collection.get(0), "Collection with filterFunction must filter items");

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		Assert.equals(this._collection.array.length, this._collection.length,
			"Collection length must match source length after setting sortCompareFunction and filterFunction to null");
		Assert.equals(this._a, this._collection.get(0), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
		Assert.equals(this._b, this._collection.get(1), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
		Assert.equals(this._c, this._collection.get(2), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
		Assert.equals(this._d, this._collection.get(3), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
	}

	public function testContainsWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.filterFunction = filterFunction;
		Assert.isFalse(this._collection.contains(this._a), "Collection with sortCompareFunction and filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._b), "Collection with sortCompareFunction and filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._c), "Collection with sortCompareFunction and filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._d), "Collection with sortCompareFunction and filterFunction must contain unfiltered item");
	}

	public function testIndexOfWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.equals(-1, this._collection.indexOf(this._a),
			"Collection with sortCompareFunction and filterFunction must return -1 for index of filtered item");
		Assert.equals(1, this._collection.indexOf(this._b), "Collection with sortCompareFunction and filterFunction must return index of unfiltered item");
		Assert.equals(-1, this._collection.indexOf(this._c),
			"Collection with sortCompareFunction and filterFunction must return -1 for index of filtered item");
		Assert.equals(0, this._collection.indexOf(this._d), "Collection with sortCompareFunction and filterFunction must return index of unfiltered item");
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
