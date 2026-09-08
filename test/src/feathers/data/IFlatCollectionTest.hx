/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FlatCollectionEvent;
import haxe.PosInfos;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class IFlatCollectionTest extends Test {
	private static final TEXT_FILTER_ME = "__FILTER_ME__";

	private var _collection:IFlatCollection<MockItem>;
	private var _a:MockItem;
	private var _b:MockItem;
	private var _c:MockItem;
	private var _d:MockItem;

	private var _events:Array<Event> = null;

	public function new() {
		super();
	}

	private function createCollection(?data:Array<MockItem>):IFlatCollection<MockItem> {
		throw new IllegalOperationError("Missing override of IFlatCollectionTest.createCollection()");
	}

	public function setup():Void {
		this._a = new MockItem("A", 0);
		this._b = new MockItem("B", 2);
		this._c = new MockItem("C", 3);
		this._d = new MockItem("D", 1);
		this._collection = createCollection([this._a, this._b, this._c, this._d]);

		this._events = [];
		this.addCollectionEventListeners(this._collection, this._events);
	}

	public function teardown():Void {
		this._collection = null;

		this._events = null;
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

	private function addCollectionEventListeners(?collection:IFlatCollection<MockItem>, ?events:Array<Event>):Void {
		if (collection == null) {
			collection = this._collection;
		}
		if (events == null) {
			events = this._events;
		}
		function recordEvent(event:Event):Void {
			events.push(event.clone());
		}
		collection.addEventListener(Event.CHANGE, recordEvent);
		collection.addEventListener(FlatCollectionEvent.ADD_ITEM, recordEvent);
		collection.addEventListener(FlatCollectionEvent.REMOVE_ITEM, recordEvent);
		collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, recordEvent);
		collection.addEventListener(FlatCollectionEvent.UPDATE_ITEM, recordEvent);
		collection.addEventListener(FlatCollectionEvent.UPDATE_ALL, recordEvent);
		collection.addEventListener(FlatCollectionEvent.RESET, recordEvent);
		collection.addEventListener(FlatCollectionEvent.REMOVE_ALL, recordEvent);
		collection.addEventListener(FlatCollectionEvent.FILTER_CHANGE, recordEvent);
		collection.addEventListener(FlatCollectionEvent.SORT_CHANGE, recordEvent);
	}

	private function clearDispatchedEvents(?events:Array<Event>):Void {
		if (events == null) {
			events = this._events;
		}
		#if (hl && haxe_ver < 4.3)
		events.splice(0, events.length);
		#else
		events.resize(0);
		#end
	}

	/**
		Asserts that `collection` has the same items as `items`, in the same
		order, and that both have the same length.
		@return True if all tests passed, false if any failed.
	**/
	private function assertCollectionMatches(items:Array<MockItem>, ?collection:IFlatCollection<MockItem>, ?pos:PosInfos):Bool {
		if (collection == null) {
			collection = this._collection;
		}

		var allTestsPassed:Bool = true;
		var collectionLength:Int = collection.length;
		allTestsPassed = Assert.equals(items.length, collectionLength,
			'Expected ${items.length} items, got $collectionLength', pos);

		for (i in 0...items.length) {
			var expected:MockItem = items[i];
			if (i > collectionLength) {
				Assert.fail('Expected $expected at index $i', pos);
				continue;
			}
			var actual:MockItem = collection.get(i);
			allTestsPassed = Assert.equals(expected, actual,
				'Expected $expected at index $i, got $actual', pos)
				&& allTestsPassed;
		}

		for (i in items.length...collectionLength) {
			Assert.fail('Expected no item at index $i, got ${collection.get(i)}', pos);
		}

		return allTestsPassed;
	}

	/**
		Asserts that the collection dispatched the given events in the given
		order with the given fields, and no other events.
		@param expectedEvents The events that should have been dispatched,
		including any fields they should have.
		@param actualEvents The events that were actually dispatched. Defaults
		to events dispatched by `this._collection`.
		@return True if all tests passed, false if any failed.
	**/
	private function assertEventsDispatched(expectedEvents:Array<Dynamic>, ?actualEvents:Array<Event>, ?pos:PosInfos):Bool {
		if (actualEvents == null) {
			actualEvents = this._events;
		}

		var allTestsPassed:Bool = true;
		allTestsPassed = Assert.equals(expectedEvents.length, actualEvents.length,
			'Expected ${expectedEvents.length} events, got ${actualEvents.length}', pos);

		for (i in 0...expectedEvents.length) {
			var expected = expectedEvents[i];
			if (i >= actualEvents.length) {
				Assert.fail('Collection must dispatch ${expected.type} as event #$i', pos);
				continue;
			}

			var actual = actualEvents[i];
			if (expected.type != actual.type) {
				Assert.fail('Collection must dispatch ${expected.type} as event #$i, got ${actual.type}', pos);
				allTestsPassed = false;
				continue;
			}

			for (field in Reflect.fields(expected)) {
				if (field == "type") {
					continue;
				}
				var expectedField:Dynamic = Reflect.field(expected, field);
				var actualField:Dynamic = Reflect.field(actual, field);
				allTestsPassed = Assert.equals(expectedField, actualField,
					'${actual.type} event (#$i) must have $field == $expectedField, got $field == $actualField', pos)
					&& allTestsPassed;
			}
		}

		for (i in expectedEvents.length...actualEvents.length) {
			var actual = actualEvents[i];
			Assert.fail('Collection must not dispatch ${actual.type} event (#$i)', pos);
		}

		return allTestsPassed;
	}

	public function testLength():Void {
		Assert.equals(4, this._collection.length);
		Assert.equals(0, createCollection().length);
		Assert.equals(0, createCollection([]).length);
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
		var expectedIndex = this._collection.length;
		this._collection.add(itemToAdd);
		this.assertCollectionMatches([this._a, this._b, this._c, this._d, itemToAdd]);
		this.assertEventsDispatched([
			{type:FlatCollectionEvent.ADD_ITEM, index: expectedIndex, addedItem: itemToAdd},
			{type:Event.CHANGE}
		]);
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd));
	}

	public function testAddAt():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var expectedIndex = 1;
		this._collection.addAt(itemToAdd, expectedIndex);
		this.assertCollectionMatches([this._a, itemToAdd, this._b, this._c, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: expectedIndex, addedItem: itemToAdd},
			{type: Event.CHANGE}
		]);
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd));

		Assert.raises(function() {
			this._collection.addAt(itemToAdd, 100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.addAt(itemToAdd, -1);
		}, RangeError);
	}

	public function testSetReplace():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var expectedIndex = 1;
		this._collection.set(expectedIndex, itemToAdd);
		this.assertCollectionMatches([this._a, itemToAdd, this._c, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REPLACE_ITEM, index: expectedIndex, addedItem: itemToAdd, removedItem: this._b},
			{type: Event.CHANGE}
		]);
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd));

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
		this._collection.set(originalLength, itemToAdd);
		this.assertCollectionMatches([this._a, this._b, this._c, this._d, itemToAdd]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: originalLength, addedItem: itemToAdd},
			{type: Event.CHANGE}
		]);
		Assert.equals(originalLength, this._collection.indexOf(itemToAdd));
	}

	public function testRemove():Void {
		var expectedIndex = 1;
		var itemToRemove = this._b;
		Assert.equals(itemToRemove, this._collection.get(expectedIndex));
		this._collection.remove(itemToRemove);
		this.assertCollectionMatches([this._a, this._c, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: expectedIndex, removedItem: itemToRemove},
			{type: Event.CHANGE}
		]);
		Assert.equals(-1, this._collection.indexOf(itemToRemove));
	}

	public function testRemoveAt():Void {
		var expectedIndex = 1;
		var itemToRemove = this._b;
		Assert.equals(itemToRemove, this._collection.get(expectedIndex));
		this._collection.removeAt(expectedIndex);
		this.assertCollectionMatches([this._a, this._c, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: expectedIndex, removedItem: itemToRemove},
			{type: Event.CHANGE}
		]);
		Assert.equals(-1, this._collection.indexOf(itemToRemove));

		Assert.raises(function() {
			this._collection.removeAt(100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.removeAt(-1);
		}, RangeError);
	}

	public function testRemoveAll():Void {
		this._collection.removeAll();
		this.assertCollectionMatches([]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ALL},
			{type: Event.CHANGE}
		]);
	}

	public function testRemoveAllWithEmptyCollection():Void {
		this._collection = createCollection();
		this.addCollectionEventListeners();
		this._collection.removeAll();
		this.assertCollectionMatches([]);
		this.assertEventsDispatched([]);
	}

	public function testUpdateAt():Void {
		var expectedIndex = 1;
		this._collection.updateAt(expectedIndex);
		this.assertCollectionMatches([this._a, this._b, this._c, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.UPDATE_ITEM, index: expectedIndex},
			{type: Event.CHANGE}
		]);

		Assert.raises(function():Void {
			this._collection.updateAt(100);
		}, RangeError);
		Assert.raises(function():Void {
			this._collection.updateAt(-1);
		}, RangeError);
	}

	public function testUpdateAll():Void {
		this._collection.updateAll();
		this.assertCollectionMatches([this._a, this._b, this._c, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.UPDATE_ALL},
			{type: Event.CHANGE}
		]);
	}

	//--- filterFunction

	public function testFilterFunction():Void {
		this.assertCollectionMatches([this._a, this._b, this._c, this._d]);
		this._collection.filterFunction = filterFunction;
		this.assertCollectionMatches([this._b, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE}
		]);
		Assert.raises(function():Void {
			this._collection.get(2);
		}, RangeError);
	}

	public function testSetFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		this.assertCollectionMatches([this._b, this._d]);
		this._collection.filterFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE},
			{type: FlatCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE}
		]);
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
		this._collection.filterFunction = filterFunction;
		this.assertCollectionMatches([this._b, this._d]);
		this.clearDispatchedEvents();

		var itemToAdd = new MockItem("New Item", 100);
		var expectedIndex = 1;
		this._collection.set(expectedIndex, itemToAdd);
		this.assertCollectionMatches([this._b, itemToAdd]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REPLACE_ITEM, index: expectedIndex, addedItem: itemToAdd, removedItem: this._d},
			{type: Event.CHANGE}
		]);
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Replacing item in collection returns incorrect index");

		this._collection.filterFunction = null;

		this.assertCollectionMatches([this._a, this._b, this._c, itemToAdd]);
	}

	public function testSetAfterEndWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this.assertCollectionMatches([this._b, this._d]);
		this.clearDispatchedEvents();

		var itemToAdd = new MockItem("New Item", 100);
		var originalFilteredLength = this._collection.length;
		this._collection.set(originalFilteredLength, itemToAdd);
		this.assertCollectionMatches([this._b, this._d, itemToAdd]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: originalFilteredLength, addedItem: itemToAdd},
			{type: Event.CHANGE}
		]);
		Assert.equals(originalFilteredLength, this._collection.indexOf(itemToAdd), "Setting item after end of collection returns incorrect index");

		this._collection.filterFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, this._d, itemToAdd]);
	}

	public function testSetWithFilterFunctionAndNoMatch():Void {
		this._collection.filterFunction = filterFunction;
		this.assertCollectionMatches([this._b, this._d]);
		this.clearDispatchedEvents();

		var itemToAdd = new MockItem(TEXT_FILTER_ME, 100);
		var expectedIndex = 1;
		this._collection.set(expectedIndex, itemToAdd);
		this.assertCollectionMatches([this._b]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: expectedIndex, removedItem: this._d},
			{type: Event.CHANGE}
		]);
		Assert.equals(-1, this._collection.indexOf(itemToAdd), "Setting item that is filtered returns incorrect index");

		this._collection.filterFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, itemToAdd]);
	}

	public function testIndexOfInsideSecondFilterFunction():Void {
		this._collection.filterFunction = (item:MockItem) -> {
			var index = this._collection.indexOf(item);
			return index % 2 == 0;
		};
		this.assertCollectionMatches([this._a, this._c]);
		this._collection.filterFunction = (item:MockItem) -> {
			var index = this._collection.indexOf(item);
			Assert.notEquals(-1, index, "Collection with filterFunction must not return -1 for index during filtering");
			return index % 2 == 0;
		};
		this.assertCollectionMatches([this._a, this._c]);
	}

	public function testUpdateAtWithFilterFunction():Void {
		this._collection.filterFunction = (item:MockItem) -> {
			return item.value > 1 && item.value < 5;
		};
		this.assertCollectionMatches([this._b, this._c]);

		this._b.value = 100;
		this._collection.updateAt(0);
		this.assertCollectionMatches([this._c]);
	}

	public function testUpdateAllWithFilterFunction():Void {
		this._collection.filterFunction = (item:MockItem) -> {
			return item.value > 1 && item.value < 5;
		};
		this.assertCollectionMatches([this._b, this._c]);

		this._a.value = 4;
		this._b.value = 100;
		this._collection.updateAll();
		this.assertCollectionMatches([this._a, this._c]);
	}

	//--- sortCompareFunction

	public function testSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);
	}

	public function testSetSortCompareFunctionToNull():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);

		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, this._d]);
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
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 1.5);
		this._collection.add(newItem);
		this.assertCollectionMatches([this._a, this._d, newItem, this._b, this._c]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: 2, addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, this._d, newItem]);
	}

	public function testAddAtWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 1.5);
		this._collection.addAt(newItem, 1);
		this.assertCollectionMatches([this._a, this._d, newItem, this._b, this._c]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: 2, addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		// newItem was inserted before this._d because this._d was at [1]
		this.assertCollectionMatches([this._a, this._b, this._c, newItem, this._d]);
	}

	public function testRemoveWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);
		this.clearDispatchedEvents();

		this._collection.remove(this._b);
		this.assertCollectionMatches([this._a, this._d, this._c]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: 2, removedItem: this._b},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._c, this._d]);
	}

	public function testRemoveAtWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);
		this.clearDispatchedEvents();

		this._collection.removeAt(2);
		this.assertCollectionMatches([this._a, this._d, this._c]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: 2, removedItem: this._b},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._c, this._d]);
	}

	public function testSetWithSortCompareFunction_sortedIndexUnchanged():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 1.5);
		this._collection.set(1, newItem);
		this.assertCollectionMatches([this._a, newItem, this._b, this._c]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REPLACE_ITEM, index: 1, addedItem: newItem, removedItem: this._d},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, newItem]);
	}

	public function testSetWithSortCompareFunction_sortedIndexChanged():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._a, this._d, this._b, this._c]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 1.5);
		this._collection.set(3, newItem);
		this.assertCollectionMatches([this._a, this._d, newItem, this._b]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: 3, removedItem: this._c},
			{type: FlatCollectionEvent.ADD_ITEM, index: 2, addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		// newItem was inserted in place of this._c because this._d was at [3]
		this.assertCollectionMatches([this._a, this._b, newItem, this._d]);
	}

	//--- sortCompareFunction AND filterFunction

	public function testSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE},
			{type: FlatCollectionEvent.SORT_CHANGE},
			{type: Event.CHANGE}
		]);
	}

	public function testSetSortCompareFunctionAndFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, this._d]);
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

	public function testAddWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 1.5);
		this._collection.add(newItem);
		this.assertCollectionMatches([this._d, newItem, this._b]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: 1, addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, this._d, newItem]);
	}

	public function testAddAtWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 1.5);
		this._collection.addAt(newItem, 0);
		this.assertCollectionMatches([this._d, newItem, this._b]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: 1, addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, newItem, this._d]);
	}

	public function testRemoveWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);
		this.clearDispatchedEvents();

		this._collection.remove(this._b);
		this.assertCollectionMatches([this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: 1, removedItem: this._b},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._c, this._d]);
	}

	public function testRemoveAtWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);
		this.clearDispatchedEvents();

		this._collection.removeAt(1);
		this.assertCollectionMatches([this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: 1, removedItem: this._b},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._c, this._d]);
	}

	public function testSetWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 0.5);
		this._collection.set(1, newItem);
		this.assertCollectionMatches([newItem, this._d]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.REMOVE_ITEM, index: 1, removedItem: this._b},
			{type: FlatCollectionEvent.ADD_ITEM, index: 0, addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, newItem, this._c, this._d]);
	}

	public function testSetWithSortCompareFunctionAndFilterFunctionAfterLast():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertCollectionMatches([this._d, this._b]);
		this.clearDispatchedEvents();

		var newItem = new MockItem("New Item", 0.5);
		this._collection.set(2, newItem);
		this.assertCollectionMatches([newItem, this._d, this._b]);
		this.assertEventsDispatched([
			{type: FlatCollectionEvent.ADD_ITEM, index: 0, addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertCollectionMatches([this._a, this._b, this._c, this._d, newItem]);
	}
}
