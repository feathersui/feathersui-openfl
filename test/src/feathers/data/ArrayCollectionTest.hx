/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.errors.RangeError;
import haxe.io.Error;
import massive.munit.Assert;
import feathers.events.FlatCollectionEvent;
import openfl.events.Event;

@:keep
class ArrayCollectionTest {
	private var _collection:ArrayCollection<MockItem>;
	private var _a:MockItem;
	private var _b:MockItem;
	private var _c:MockItem;
	private var _d:MockItem;

	@Before
	public function prepare():Void {
		this._a = new MockItem("A", 0);
		this._b = new MockItem("B", 2);
		this._c = new MockItem("C", 3);
		this._d = new MockItem("D", 1);
		this._collection = new ArrayCollection([this._a, this._b, this._c, this._d]);
	}

	@After
	public function cleanup():Void {
		this._collection = null;
	}

	private function filterFunction(item:MockItem):Bool {
		if (item == this._a || item == this._c) {
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

	@Test
	public function testIndexOf():Void {
		Assert.areEqual(0, this._collection.indexOf(this._a), "Collection indexOf() returns wrong index");
		Assert.areEqual(1, this._collection.indexOf(this._b), "Collection indexOf() returns wrong index");
		Assert.areEqual(2, this._collection.indexOf(this._c), "Collection indexOf() returns wrong index");
		Assert.areEqual(3, this._collection.indexOf(this._d), "Collection indexOf() returns wrong index");
		Assert.areEqual(-1, this._collection.indexOf(new MockItem("Not in collection", -1)),
			"Collection indexOf() must return -1 for items not in collection");
	}

	@Test
	public function testContains():Void {
		Assert.isTrue(this._collection.contains(this._a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._b), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._d), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._d), "Collection contains() returns wrong result for item in collection");
		Assert.isFalse(this._collection.contains(new MockItem("Not in collection", -1)),
			"Collection contains() returns wrong result for item not in collection");
	}

	@Test
	public function testGet():Void {
		Assert.areEqual(this._a, this._collection.get(0), "Collection get() returns wrong item");
		Assert.areEqual(this._b, this._collection.get(1), "Collection get() returns wrong item");
		Assert.areEqual(this._c, this._collection.get(2), "Collection get() returns wrong item");
		Assert.areEqual(this._d, this._collection.get(3), "Collection get() returns wrong item");
		Assert.throws(RangeError, function() {
			this._collection.get(100);
		});
		Assert.throws(RangeError, function() {
			this._collection.get(-1);
		});
	}

	@Test
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
		Assert.areEqual(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.areEqual(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.areEqual(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");
	}

	@Test
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
		Assert.areEqual(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.areEqual(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.areEqual(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");

		Assert.throws(RangeError, function() {
			this._collection.addAt(itemToAdd, 100);
		});
		Assert.throws(RangeError, function() {
			this._collection.addAt(itemToAdd, -1);
		});
	}

	@Test
	public function testSet():Void {
		var itemToAdd = new MockItem("New Item", 100);
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

		Assert.throws(RangeError, function() {
			this._collection.set(100, itemToAdd);
		});
		Assert.throws(RangeError, function() {
			this._collection.set(-1, itemToAdd);
		});
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

		Assert.throws(RangeError, function() {
			this._collection.removeAt(100);
		});
		Assert.throws(RangeError, function() {
			this._collection.removeAt(-1);
		});
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

	@Test
	public function testResetArrayToNull():Void {
		this._collection.array = null;
		Assert.isType(this._collection.array, Array, "Setting collection source to null should replace with an empty value.");
		Assert.areEqual(0, this._collection.length, "Collection length must change after resetting collection source with empty valee");
	}

	@Test
	public function testUpdateAt():Void {
		var updateItemEvent = false;
		var updateItemIndex = -1;
		this._collection.addEventListener(FlatCollectionEvent.UPDATE_ITEM, function(event:FlatCollectionEvent):Void {
			updateItemEvent = true;
			updateItemIndex = event.index;
		});
		this._collection.updateAt(1);
		Assert.isTrue(updateItemEvent, "FlatCollectionEvent.UPDATE_ITEM must be dispatched after calling updateAt()");
		Assert.areEqual(1, updateItemIndex, "FlatCollectionEvent.UPDATE_ITEM must be dispatched with correct index");

		Assert.throws(RangeError, function():Void {
			this._collection.updateAt(100);
		});
		Assert.throws(RangeError, function():Void {
			this._collection.updateAt(-1);
		});
	}

	@Test
	public function testUpdateAll():Void {
		var updateAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.UPDATE_ALL, function(event:FlatCollectionEvent):Void {
			updateAllEvent = true;
		});
		this._collection.updateAll();
		Assert.isTrue(updateAllEvent, "FlatCollectionEvent.UPDATE_ALL must be dispatched after calling updateAll()");
	}

	//--- filterFunction

	@Test
	public function testFilterFunction():Void {
		Assert.areEqual(this._collection.array.length, this._collection.length, "Collection length must match source length if unfiltered");
		this._collection.filterFunction = filterFunction;
		Assert.areNotEqual(this._collection.array.length, this._collection.length, "Collection length must not match source length if items are filtered");
		Assert.areEqual(2, this._collection.length, "Collection length must account for filterFunction");
		Assert.areEqual(this._b, this._collection.get(0), "Collection with filterFunction must filter items");
		Assert.areEqual(this._d, this._collection.get(1), "Collection with filterFunction must filter items");
		Assert.throws(RangeError, function():Void {
			this._collection.get(2);
		});
	}

	@Test
	public function testSetFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		// get an item so that we know the sorting was applied
		Assert.areEqual(this._b, this._collection.get(0), "Collection with filterFunction must filter items");

		this._collection.filterFunction = null;
		Assert.areEqual(this._collection.array.length, this._collection.length,
			"Collection length must match source length after setting filterFunction to null");
		Assert.areEqual(this._a, this._collection.get(0), "Collection order is incorrect after setting filterFunction to null");
		Assert.areEqual(this._b, this._collection.get(1), "Collection order is incorrect after setting filterFunction to null");
		Assert.areEqual(this._c, this._collection.get(2), "Collection order is incorrect after setting filterFunction to null");
		Assert.areEqual(this._d, this._collection.get(3), "Collection order is incorrect after setting filterFunction to null");
	}

	@Test
	public function testContainsWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		Assert.isFalse(this._collection.contains(this._a), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._b), "Collection with filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._c), "Collection with filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._d), "Collection with filterFunction must contain unfiltered item");
	}

	@Test
	public function testIndexOfWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		Assert.areEqual(-1, this._collection.indexOf(this._a), "Collection with filterFunction must return -1 for index of filtered item");
		Assert.areEqual(0, this._collection.indexOf(this._b), "Collection with filterFunction must return index of unfiltered item");
		Assert.areEqual(-1, this._collection.indexOf(this._c), "Collection with filterFunction must return -1 for index of filtered item");
		Assert.areEqual(1, this._collection.indexOf(this._d), "Collection with filterFunction must return index of unfiltered item");
	}

	//--- sortCompareFunction

	@Test
	public function testSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.areEqual(this._collection.array.length, this._collection.length, "Collection length must not change if sorted");
		Assert.areEqual(this._a, this._collection.get(0), "Collection order is incorrect with sortCompareFunction");
		Assert.areEqual(this._d, this._collection.get(1), "Collection order is incorrect with sortCompareFunction");
		Assert.areEqual(this._b, this._collection.get(2), "Collection order is incorrect with sortCompareFunction");
		Assert.areEqual(this._c, this._collection.get(3), "Collection order is incorrect with sortCompareFunction");
	}

	@Test
	public function testSetSortCompareFunctionToNull():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		// get an item so that we know the sorting was applied
		Assert.areEqual(this._d, this._collection.get(1), "Collection order is incorrect with sortCompareFunction");

		this._collection.sortCompareFunction = null;
		Assert.areEqual(this._a, this._collection.get(0), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.areEqual(this._b, this._collection.get(1), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.areEqual(this._c, this._collection.get(2), "Collection order is incorrect after setting sortCompareFunction to null");
		Assert.areEqual(this._d, this._collection.get(3), "Collection order is incorrect after setting sortCompareFunction to null");
	}

	@Test
	public function testContainsWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.isTrue(this._collection.contains(this._a), "Collection with sortCompareFunction must contain all items");
		Assert.isTrue(this._collection.contains(this._b), "Collection with sortCompareFunction must contain all items");
		Assert.isTrue(this._collection.contains(this._c), "Collection with sortCompareFunction must contain all items");
		Assert.isTrue(this._collection.contains(this._d), "Collection with sortCompareFunction must contain all items");
	}

	@Test
	public function testIndexOfWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.areEqual(0, this._collection.indexOf(this._a), "Collection with sortCompareFunction must return correct index for item");
		Assert.areEqual(2, this._collection.indexOf(this._b), "Collection with sortCompareFunction must return correct index for item");
		Assert.areEqual(3, this._collection.indexOf(this._c), "Collection with sortCompareFunction must return correct index for item");
		Assert.areEqual(1, this._collection.indexOf(this._d), "Collection with sortCompareFunction must return correct index for item");
	}

	@Test
	public function testAddWithSortCompareFunction():Void {
		var newItem = new MockItem("New Item", 1.5);
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.add(newItem);

		Assert.areEqual(newItem, this._collection.get(2), "Collection with sortCompareFunction and add() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.areEqual(newItem, this._collection.get(4), "Collection with sortCompareFunction and add() did not return correct item for unsorted index");
	}

	@Test
	public function testAddAtWithSortCompareFunction():Void {
		var newItem = new MockItem("New Item", 1.5);
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.addAt(newItem, 1);

		// the index we passed in isn't necessarily the same while sorted
		Assert.areEqual(newItem, this._collection.get(2), "Collection with sortCompareFunction and addAt() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		// and it might not even be the same while unsorted!
		// that's because, in the unsorted data, it will be placed relative to
		// the item in the sorted data that was at the index passed to addAt().
		// it may be confusing, but it's consistent with set() on filtered
		// collections
		Assert.areEqual(newItem, this._collection.get(3), "Collection with sortCompareFunction and addAt() did not return correct item for unsorted index");
	}

	@Test
	public function testRemoveWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.remove(this._b);

		Assert.areEqual(this._a, this._collection.get(0), "Collection with sortCompareFunction and removeat() did not return correct item for sorted index");
		Assert.areEqual(this._d, this._collection.get(1), "Collection with sortCompareFunction and removeat() did not return correct item for sorted index");
		Assert.areEqual(this._c, this._collection.get(2), "Collection with sortCompareFunction and removeat() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.areEqual(this._a, this._collection.get(0), "Collection with sortCompareFunction and removeat() did not return correct item for unsorted index");
		Assert.areEqual(this._c, this._collection.get(1), "Collection with sortCompareFunction and removeat() did not return correct item for unsorted index");
		Assert.areEqual(this._d, this._collection.get(2), "Collection with sortCompareFunction and removeat() did not return correct item for unsorted index");
	}

	@Test
	public function testRemoveAtWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.removeAt(2);

		Assert.areEqual(this._a, this._collection.get(0), "Collection with sortCompareFunction and removeat() did not return correct item for sorted index");
		Assert.areEqual(this._d, this._collection.get(1), "Collection with sortCompareFunction and removeat() did not return correct item for sorted index");
		Assert.areEqual(this._c, this._collection.get(2), "Collection with sortCompareFunction and removeat() did not return correct item for sorted index");

		this._collection.sortCompareFunction = null;

		Assert.areEqual(this._a, this._collection.get(0), "Collection with sortCompareFunction and removeat() did not return correct item for unsorted index");
		Assert.areEqual(this._c, this._collection.get(1), "Collection with sortCompareFunction and removeat() did not return correct item for unsorted index");
		Assert.areEqual(this._d, this._collection.get(2), "Collection with sortCompareFunction and removeat() did not return correct item for unsorted index");
	}

	@Test
	public function testSetWithSortCompareFunction():Void {
		var newItem = new MockItem("New Item", 1.5);
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.set(1, newItem);

		// the index we passed in isn't necessarily the same while sorted
		Assert.areEqual(newItem, this._collection.get(1), "Collection with sortCompareFunction and set() did not return correct item for sorted index");
		Assert.isFalse(this._collection.contains(this._d), "Collection with sortCompareFunction and set() did not remove correct item for sorted index");

		this._collection.sortCompareFunction = null;

		// and it might not even be the same while unsorted!
		// that's because, in the unsorted data, it will replace the item in the
		// the sorted data that was at the index passed to addAt().
		// it may be confusing, but it's consistent with set() on filtered
		// collections
		Assert.areEqual(newItem, this._collection.get(3), "Collection with sortCompareFunction and add() did not return correct item for unsorted index");
	}

	//--- sortCompareFunction AND filterFunction

	@Test
	public function testSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.areNotEqual(this._collection.array.length, this._collection.length, "Collection length must not match source length if items are filtered");
		Assert.areEqual(2, this._collection.length, "Collection length must account for filterFunction");
		Assert.areEqual(this._d, this._collection.get(0), "Items must be filtered and sorted");
		Assert.areEqual(this._b, this._collection.get(1), "Items must be filtered and sorted");
	}

	@Test
	public function testSetSortCompareFunctionAndFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		// get an item so that we know the sorting was applied
		Assert.areEqual(this._d, this._collection.get(0), "Collection with filterFunction must filter items");

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		Assert.areEqual(this._collection.array.length, this._collection.length,
			"Collection length must match source length after setting sortCompareFunction and filterFunction to null");
		Assert.areEqual(this._a, this._collection.get(0), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
		Assert.areEqual(this._b, this._collection.get(1), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
		Assert.areEqual(this._c, this._collection.get(2), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
		Assert.areEqual(this._d, this._collection.get(3), "Collection order is incorrect after setting sortCompareFunction and filterFunction to null");
	}

	@Test
	public function testContainsWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this._collection.filterFunction = filterFunction;
		Assert.isFalse(this._collection.contains(this._a), "Collection with sortCompareFunction and filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._b), "Collection with sortCompareFunction and filterFunction must contain unfiltered item");
		Assert.isFalse(this._collection.contains(this._c), "Collection with sortCompareFunction and filterFunction must not contain filtered item");
		Assert.isTrue(this._collection.contains(this._d), "Collection with sortCompareFunction and filterFunction must contain unfiltered item");
	}

	@Test
	public function testIndexOfWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.areEqual(-1, this._collection.indexOf(this._a),
			"Collection with sortCompareFunction and filterFunction must return -1 for index of filtered item");
		Assert.areEqual(1, this._collection.indexOf(this._b), "Collection with sortCompareFunction and filterFunction must return index of unfiltered item");
		Assert.areEqual(-1, this._collection.indexOf(this._c),
			"Collection with sortCompareFunction and filterFunction must return -1 for index of filtered item");
		Assert.areEqual(0, this._collection.indexOf(this._d), "Collection with sortCompareFunction and filterFunction must return index of unfiltered item");
	}
}

class MockItem {
	public function new(text:String, value:Float) {
		this.text = text;
		this.value = value;
	}

	public var text:String;
	public var value:Float;
}
