/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.HierarchicalCollectionEvent;
import haxe.PosInfos;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class IHierarchicalCollectionTest<Item:MockItem> extends Test {
	private static final TEXT_FILTER_ME = "__FILTER_ME__";

	private var _collection:IHierarchicalCollection<Item>;
	private var _1:Item;
	private var _2:Item;
	private var _3:Item;
	private var _4:Item;
	private var _5:Item;
	private var _1a:Item;
	private var _1b:Item;
	private var _1bi:Item;
	private var _1c:Item;
	private var _2a:Item;
	private var _4a:Item;
	private var _4b:Item;

	private var _events:Array<Event> = null;

	public function new() {
		super();
	}

	private function createCollection(?data:Array<Item>):IHierarchicalCollection<Item> {
		throw new IllegalOperationError("Missing override of IHierarchicalCollectionTest.createCollection()");
	}

	private function createItem(text:String, value:Float, ?children:Array<Item>):Item {
		throw new IllegalOperationError("Missing override of IHierarchicalCollectionTest.createItem()");
	}

	public function setup():Void {
		this._1a = createItem("1-A", 2);
		this._1bi = createItem("1-B-I", 1);
		this._1b = createItem("1-B", 1, [this._1bi]);
		this._1c = createItem("1-C", 3);
		this._1 = createItem("1", 0, [this._1a, this._1b, this._1c]);
		this._2a = createItem("2-A", 2);
		this._2 = createItem("2", 2, [this._2a]);
		this._3 = createItem("3", 3);
		this._4a = createItem("4-A", 1);
		this._4b = createItem("4-B", 0);
		this._4 = createItem("4", 1, [this._4a, this._4b]);
		this._5 = createItem("5", 4, []);
		this._collection = createCollection([this._1, this._2, this._3, this._4, this._5]);

		this._events = [];
		this.addCollectionEventListeners(this._collection, this._events);
	}

	public function teardown():Void {
		this._collection = null;

		this._events = null;
	}

	private function addCollectionEventListeners(?collection:IHierarchicalCollection<Item>, ?events:Array<Event>):Void {
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
		collection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.RESET, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.FILTER_CHANGE, recordEvent);
		collection.addEventListener(HierarchicalCollectionEvent.SORT_CHANGE, recordEvent);
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
		Asserts that the given branch of `collection` has the same items as
		`items`, in the same order, and that both have the same length.
		@return True if all tests passed, false if any failed.
	**/
	private function assertBranchMatches(items:Array<Item>, ?collection:IHierarchicalCollection<Item>, ?location:Array<Int>, ?pos:PosInfos):Bool {
		if (collection == null) {
			collection = this._collection;
		}
		if (location == null) {
			location = [];
		} else if (location.length > 0 && !collection.isBranch(collection.get(location))) {
			Assert.fail('Collection should have a branch at location $location', pos);
			return false;
		}
		if (items.length == collection.getLength(location)) {
			Assert.pass();
		} else {
			Assert.fail('Branch should have length ${items.length}, got ${collection.getLength(location)}', pos);
			return false;
		}
		var result:Bool = true;
		for (i in 0...items.length) {
			location.push(i);
			var expected:Item = items[i];
			var actual:Item = collection.get(location);
			if (expected == actual) {
				Assert.pass();
			} else {
				result = false;
				Assert.fail('Expected $expected at $location, got $actual', pos);
			}
			location.pop();
		}
		return result;
	}

	/**
		Asserts that the collection dispatched the given events in the given
		order with the given fields, and no other events. Fields named
		"location" will be compared using `Assert.same()`, so they'll match as
		long as they contain the same values.
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

		for (i in 0...expectedEvents.length) {
			var expected = expectedEvents[i];
			if (i >= actualEvents.length) {
				Assert.fail('Collection must dispatch ${expected.type} as event #$i', pos);
				allTestsPassed = false;
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
				if (field == "location") {
					allTestsPassed = Assert.same(expectedField, actualField,
						'${actual.type} event (#$i) must have location $expectedField, got $actualField', pos)
						&& allTestsPassed;
				} else {
					allTestsPassed = Assert.equals(expectedField, actualField,
						'${actual.type} event (#$i) must have $field == $expectedField, got $field == $actualField', pos)
						&& allTestsPassed;
				}
			}
		}

		for (i in expectedEvents.length...actualEvents.length) {
			var actual = actualEvents[i];
			Assert.fail('Collection must not dispatch ${actual.type} event (#$i)', pos);
			allTestsPassed = false;
		}

		return allTestsPassed;
	}

	private function filterFunction(item:Item):Bool {
		if (item == this._2 || item == this._1b || item.text == TEXT_FILTER_ME) {
			return false;
		}
		return true;
	}

	private function sortCompareFunction(a:Item, b:Item):Int {
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

	public function testLength():Void {
		Assert.equals(5, this._collection.getLength(), "Collection getLength() returns wrong length");
		Assert.equals(5, this._collection.getLength([]), "Collection getLength() returns wrong length");
		Assert.equals(3, this._collection.getLength([0]), "Collection getLength() returns wrong length");
		Assert.equals(1, this._collection.getLength([1]), "Collection getLength() returns wrong length");
		Assert.equals(0, this._collection.getLength([4]), "Collection getLength() returns wrong length");
		Assert.equals(1, this._collection.getLength([0, 1]), "Collection getLength() returns wrong length");
	}

	public function testLocationOf():Void {
		Assert.same([0], this._collection.locationOf(this._1), "Collection locationOf() returns wrong location");
		Assert.same([1], this._collection.locationOf(this._2), "Collection locationOf() returns wrong location");
		Assert.same([2], this._collection.locationOf(this._3), "Collection locationOf() returns wrong location");
		Assert.same([3], this._collection.locationOf(this._4), "Collection locationOf() returns wrong location");
		Assert.same([4], this._collection.locationOf(this._5), "Collection locationOf() returns wrong location");
		Assert.same([0, 0], this._collection.locationOf(this._1a), "Collection locationOf() returns wrong location");
		Assert.same([0, 1], this._collection.locationOf(this._1b), "Collection locationOf() returns wrong location");
		Assert.same([0, 2], this._collection.locationOf(this._1c), "Collection locationOf() returns wrong location");
		Assert.same([1, 0], this._collection.locationOf(this._2a), "Collection locationOf() returns wrong location");
		Assert.same([3, 0], this._collection.locationOf(this._4a), "Collection locationOf() returns wrong location");
		Assert.same([3, 1], this._collection.locationOf(this._4b), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(createItem("Not in collection", -1)),
			"Collection locationOf() must return null for items not in collection");
	}

	public function testContains():Void {
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
		Assert.isFalse(this._collection.contains(createItem("Not in collection", -1)),
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
		var itemToAdd = createItem("New Item", 100);
		this._collection.addAt(itemToAdd, [0, 1]);
		this.assertBranchMatches([this._1a, itemToAdd, this._1b, this._1c], [0]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [0, 1], addedItem: itemToAdd},
			{type: Event.CHANGE}
		]);
		Assert.same([0, 1], this._collection.locationOf(itemToAdd), "Adding item to collection returns incorrect location");

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
		var itemToAdd = createItem("New Item", 100);
		var originalLength = this._collection.getLength([0]);
		this._collection.addAt(itemToAdd, [0, originalLength]);
		this.assertBranchMatches([this._1a, this._1b, this._1c, itemToAdd], [0]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [0, originalLength], addedItem: itemToAdd},
			{type: Event.CHANGE}
		]);
		Assert.same([0, originalLength], this._collection.locationOf(itemToAdd), "Adding item to collection returns incorrect location");
	}

	public function testSetReplace():Void {
		var itemToAdd = createItem("New Item", 100);
		this._collection.set([0, 1], itemToAdd);
		this.assertBranchMatches([this._1a, itemToAdd, this._1c], [0]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REPLACE_ITEM, location: [0, 1], addedItem: itemToAdd, removedItem: this._1b},
			{type: Event.CHANGE}
		]);
		Assert.same([0, 1], this._collection.locationOf(itemToAdd), "Replacing item in collection returns incorrect location");

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
		var itemToAdd = createItem("New Item", 100);
		var originalLength = this._collection.getLength([0]);
		this._collection.set([0, originalLength], itemToAdd);
		this.assertBranchMatches([this._1a, this._1b, this._1c, itemToAdd], [0]);
		this.assertEventsDispatched([
			// hierarchical collections dispatch REPLACE_ITEM here, bug?
			{type: HierarchicalCollectionEvent.REPLACE_ITEM, location: [0, originalLength], addedItem: itemToAdd},
			{type: Event.CHANGE}
		]);
		Assert.same([0, originalLength], this._collection.locationOf(itemToAdd),
			"Setting item after end of collection returns incorrect location");
	}

	public function testRemove():Void {
		this._collection.remove(this._1b);
		this.assertBranchMatches([this._1a, this._1c], [0]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [0, 1], removedItem: this._1b},
			{type: Event.CHANGE}
		]);
		Assert.isNull(this._collection.locationOf(this._1b), "Removing item from collection returns incorrect location");
	}

	public function testRemoveAt():Void {
		this._collection.removeAt([0, 1]);
		this.assertBranchMatches([this._1a, this._1c], [0]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [0, 1], removedItem: this._1b},
			{type: Event.CHANGE}
		]);
		Assert.isNull(this._collection.locationOf(this._1b), "Removing item from collection returns incorrect location");

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
		this._collection.removeAll();
		this.assertBranchMatches([]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ALL, location: null},
			{type: Event.CHANGE}
		]);
	}

	public function testRemoveAllWithEmptyCollection():Void {
		this._collection = createCollection();
		this.assertBranchMatches([]);
		this._collection.removeAll();
		this.assertBranchMatches([]);
		this.assertEventsDispatched([]);
	}

	public function testRemoveAllWithLocation():Void {
		this._collection.removeAll([1]);
		this.assertBranchMatches([this._1, this._2, this._3, this._4, this._5]);
		this.assertBranchMatches([this._1a, this._1b, this._1c], [0]);
		this.assertBranchMatches([], [1]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ALL, location: [1]},
			{type: Event.CHANGE}
		]);
	}

	public function testUpdateAt():Void {
		this._collection.updateAt([0, 1, 0]);
		this.assertBranchMatches([this._1bi], [0, 1]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.UPDATE_ITEM, location: [0, 1, 0]},
			{type: Event.CHANGE}
		]);

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
		this._collection.updateAll();
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.UPDATE_ALL, location: null},
			{type: Event.CHANGE}
		]);
	}

	//--- filterFunction

	public function testFilterFunction():Void {
		this.assertBranchMatches([this._1, this._2, this._3, this._4, this._5]);
		this.assertBranchMatches([this._1a, this._1b, this._1c], [0]);
		this.assertBranchMatches([this._4a, this._4b], [3]);

		this._collection.filterFunction = filterFunction;
		this.assertBranchMatches([this._1, this._3, this._4, this._5]);
		this.assertBranchMatches([this._1a, this._1c], [0]);
		this.assertBranchMatches([this._4a, this._4b], [2]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE}
		]);

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
		this.assertBranchMatches([this._1, this._3, this._4, this._5]);
		this.assertBranchMatches([this._1a, this._1c], [0]);
		this.assertBranchMatches([this._4a, this._4b], [2]);

		this._collection.filterFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, this._4, this._5]);
		this.assertBranchMatches([this._1a, this._1b, this._1c], [0]);
		this.assertBranchMatches([this._2a], [1]);
		this.assertBranchMatches([this._4a, this._4b], [3]);

		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE},
			{type: HierarchicalCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE}
		]);
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
		Assert.same([0], this._collection.locationOf(this._1), "Collection with filterFunction must contain unfiltered item");
		Assert.same([0, 0], this._collection.locationOf(this._1a), "Collection with filterFunction must contain unfiltered item");
		Assert.isNull(this._collection.locationOf(this._1b), "Collection with filterFunction must not contain filtered item");
		Assert.same([0, 1], this._collection.locationOf(this._1c), "Collection with filterFunction must contain unfiltered item");
		Assert.isNull(this._collection.locationOf(this._2), "Collection with filterFunction must contain unfiltered item");
		Assert.isNull(this._collection.locationOf(this._2a), "Collection with filterFunction must contain unfiltered item");
		Assert.same([1], this._collection.locationOf(this._3), "Collection with filterFunction must contain unfiltered item");
		Assert.same([2], this._collection.locationOf(this._4), "Collection with filterFunction must not contain filtered item");
		Assert.same([2, 0], this._collection.locationOf(this._4a), "Collection with filterFunction must not contain filtered item");
		Assert.same([2, 1], this._collection.locationOf(this._4b), "Collection with filterFunction must not contain filtered item");
		Assert.same([3], this._collection.locationOf(this._5), "Collection with filterFunction must contain unfiltered item");
	}

	public function testSetReplaceWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this.assertBranchMatches([this._1, this._3, this._4, this._5]);
		this.clearDispatchedEvents();

		var itemToAdd = createItem("New Item", 100);
		this._collection.set([3], itemToAdd);
		this.assertBranchMatches([this._1, this._3, this._4, itemToAdd]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REPLACE_ITEM, location: [3], addedItem: itemToAdd, removedItem: this._5},
			{type: Event.CHANGE}
		]);
		Assert.same([3], this._collection.locationOf(itemToAdd), "Replacing item in collection returns incorrect location");

		this._collection.filterFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, this._4, itemToAdd]);
		Assert.same([4], this._collection.locationOf(itemToAdd),
			"Replacing item returns incorrect location of new item");
	}

	public function testSetAfterEndWithFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this.assertBranchMatches([this._1, this._3, this._4, this._5]);
		this.clearDispatchedEvents();

		var itemToAdd = createItem("New Item", 100);
		this._collection.set([4], itemToAdd);
		this.assertBranchMatches([this._1, this._3, this._4, this._5, itemToAdd]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [4], addedItem: itemToAdd},
			{type: Event.CHANGE}
		]);
		Assert.same([4], this._collection.locationOf(itemToAdd),
			"Setting item after end of collection returns incorrect location");

		this._collection.filterFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, this._4, this._5, itemToAdd]);
		Assert.same([5], this._collection.locationOf(itemToAdd),
			"Setting item after end of collection returns incorrect location");
	}

	public function testSetWithFilterFunctionAndNoMatch():Void {
		this._collection.filterFunction = filterFunction;
		this.assertBranchMatches([this._1, this._3, this._4, this._5]);
		this.clearDispatchedEvents();

		var itemToAdd = createItem(TEXT_FILTER_ME, 100);
		this._collection.set([3], itemToAdd);
		this.assertBranchMatches([this._1, this._3, this._4]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [3], addedItem: null, removedItem: this._5},
			{type: Event.CHANGE}
		]);
		Assert.isNull(this._collection.locationOf(itemToAdd), "Setting item that is filtered returns incorrect location");

		this._collection.filterFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, this._4, itemToAdd]);
		Assert.same([4], this._collection.locationOf(itemToAdd),
			"Setting item after end of collection returns incorrect location");
	}

	public function testLocationOfInsideSecondFilterFunction():Void {
		this._collection.filterFunction = (item:Item) -> {
			var location = this._collection.locationOf(item);
			if (location.length > 1) {
				return true;
			}
			return location[0] % 2 == 0;
		};
		this.assertBranchMatches([this._1, this._3, this._5]);
		this._collection.filterFunction = (item:Item) -> {
			var location = this._collection.locationOf(item);
			Assert.notNull(location, "Collection with filterFunction must not return null for location during filtering");
			if (location.length > 1) {
				return true;
			}
			return location[0] % 2 == 0;
		};
		this.assertBranchMatches([this._1, this._3, this._5]);
	}

	public function testUpdateAtWithFilterFunction():Void {
		this._collection.filterFunction = (item:Item) -> {
			return item.value > 1 && item.value < 5;
		};
		this.assertBranchMatches([this._2, this._3, this._5]);

		this._3.value = 100;
		this._collection.updateAt([1]);
		this.assertBranchMatches([this._2, this._5]);
	}

	public function testUpdateAllWithFilterFunction():Void {
		this._collection.filterFunction = (item:Item) -> {
			return item.value > 1 && item.value < 5;
		};
		this.assertBranchMatches([this._2, this._3, this._5]);

		this._1.value = 4;
		this._3.value = 100;
		this._collection.updateAll();
		this.assertBranchMatches([this._1, this._2, this._5]);
	}

	//--- sortCompareFunction

	public function testSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._2, this._3, this._5]);
		this.assertBranchMatches([this._1b, this._1a, this._1c], [0]);
		this.assertBranchMatches([this._1bi], [0, 0]);
		this.assertBranchMatches([this._4b, this._4a], [1]);
		this.assertBranchMatches([this._2a], [2]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.SORT_CHANGE},
			{type: Event.CHANGE}
		]);
	}

	public function testSetSortCompareFunctionToNull():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._2, this._3, this._5]);

		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, this._4, this._5]);
		this.assertBranchMatches([this._1a, this._1b, this._1c], [0]);
		this.assertBranchMatches([this._2a], [1]);
		this.assertBranchMatches([this._4a, this._4b], [3]);
	}

	public function testLocationOfWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		Assert.same([0], this._collection.locationOf(this._1), "Collection locationOf() returns wrong location");
		Assert.same([1], this._collection.locationOf(this._4), "Collection locationOf() returns wrong location");
		Assert.same([2], this._collection.locationOf(this._2), "Collection locationOf() returns wrong location");
		Assert.same([3], this._collection.locationOf(this._3), "Collection locationOf() returns wrong location");
		Assert.same([4], this._collection.locationOf(this._5), "Collection locationOf() returns wrong location");
		Assert.same([0, 0], this._collection.locationOf(this._1b), "Collection locationOf() returns wrong location");
		Assert.same([0, 1], this._collection.locationOf(this._1a), "Collection locationOf() returns wrong location");
		Assert.same([0, 2], this._collection.locationOf(this._1c), "Collection locationOf() returns wrong location");
		Assert.same([2, 0], this._collection.locationOf(this._2a), "Collection locationOf() returns wrong location");
		Assert.same([1, 0], this._collection.locationOf(this._4b), "Collection locationOf() returns wrong location");
		Assert.same([1, 1], this._collection.locationOf(this._4a), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(createItem("Not in collection", -1)),
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
		Assert.isFalse(this._collection.contains(createItem("Not in collection", -1)),
			"Collection contains() returns wrong result for item not in collection");
	}

	public function testAddAtWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._2, this._3, this._5]);
		this.clearDispatchedEvents();

		var newItem = createItem("New Item", 1.5);
		this._collection.addAt(newItem, [1]);
		this.assertBranchMatches([this._1, this._4, newItem, this._2, this._3, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [2], addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		// newItem was inserted before this._4 because this._4 was at [1]
		this.assertBranchMatches([this._1, this._2, this._3, newItem, this._4, this._5]);
	}

	public function testRemoveWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._2, this._3, this._5]);
		this.clearDispatchedEvents();

		this._collection.remove(this._2);
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [2], removedItem: this._2},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._3, this._4, this._5]);
	}

	public function testRemoveAtWithSortCompareFunction():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._2, this._3, this._5]);
		this.clearDispatchedEvents();

		this._collection.removeAt([2]);
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [2], removedItem: this._2},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._3, this._4, this._5]);
	}

	public function testSetWithSortCompareFunction_sortedLocationUnchanged():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._2, this._3, this._5]);
		this.clearDispatchedEvents();

		var newItem = createItem("New Item", 1.5);
		this._collection.set([1], newItem);
		this.assertBranchMatches([this._1, newItem, this._2, this._3, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REPLACE_ITEM, location: [1], addedItem: newItem, removedItem: this._4},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, newItem, this._5]);
	}

	public function testSetWithSortCompareFunction_sortedLocationChanged():Void {
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._2, this._3, this._5]);
		this.clearDispatchedEvents();

		var newItem = createItem("New Item", 1.5);
		this._collection.set([3], newItem);
		this.assertBranchMatches([this._1, this._4, newItem, this._2, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [3], removedItem: this._3},
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [2], addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, newItem, this._4, this._5]);
	}

	//--- sortCompareFunction AND filterFunction

	public function testSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.assertBranchMatches([this._1a, this._1c], [0]);
		this.assertBranchMatches([this._4b, this._4a], [1]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE},
			{type: HierarchicalCollectionEvent.SORT_CHANGE},
			{type: Event.CHANGE}
		]);
	}

	public function testSetSortCompareFunctionAndFilterFunctionToNull():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, this._4, this._5]);
		this.assertBranchMatches([this._1a, this._1b, this._1c], [0]);
		this.assertBranchMatches([this._2a], [1]);
		this.assertBranchMatches([this._4a, this._4b], [3]);

		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE},
			{type: HierarchicalCollectionEvent.SORT_CHANGE},
			{type: Event.CHANGE},
			{type: HierarchicalCollectionEvent.FILTER_CHANGE},
			{type: Event.CHANGE},
			{type: HierarchicalCollectionEvent.SORT_CHANGE},
			{type: Event.CHANGE}
		]);
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
		Assert.same([0], this._collection.locationOf(this._1), "Collection locationOf() returns wrong location");
		Assert.same([1], this._collection.locationOf(this._4), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(this._2), "Collection locationOf() returns wrong location");
		Assert.same([2], this._collection.locationOf(this._3), "Collection locationOf() returns wrong location");
		Assert.same([3], this._collection.locationOf(this._5), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(this._1b), "Collection locationOf() returns wrong location");
		Assert.same([0, 0], this._collection.locationOf(this._1a), "Collection locationOf() returns wrong location");
		Assert.same([0, 1], this._collection.locationOf(this._1c), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(this._2a), "Collection locationOf() returns wrong location");
		Assert.same([1, 0], this._collection.locationOf(this._4b), "Collection locationOf() returns wrong location");
		Assert.same([1, 1], this._collection.locationOf(this._4a), "Collection locationOf() returns wrong location");
		Assert.isNull(this._collection.locationOf(createItem("Not in collection", -1)),
			"Collection locationOf() must return null for items not in collection");
	}

	public function testAddAtWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.clearDispatchedEvents();

		var newItem = createItem("New Item", 1.5);
		this._collection.addAt(newItem, [1]);
		this.assertBranchMatches([this._1, this._4, newItem, this._3, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [2], addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		// newItem was inserted before this._4 because this._4 was at [1]
		this.assertBranchMatches([this._1, this._2, this._3, newItem, this._4, this._5]);
	}

	public function testRemoveWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.clearDispatchedEvents();

		this._collection.remove(this._3);
		this.assertBranchMatches([this._1, this._4, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [2], removedItem: this._3},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, this._4, this._5]);
	}

	public function testRemoveAtWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.clearDispatchedEvents();

		this._collection.removeAt([2]);
		this.assertBranchMatches([this._1, this._4, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [2], removedItem: this._3},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, this._4, this._5]);
	}

	public function testSetWithSortCompareFunctionAndFilterFunction():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.clearDispatchedEvents();

		var newItem = createItem("New Item", 0.5);
		this._collection.set([2], newItem);
		this.assertBranchMatches([this._1, newItem, this._4, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.REMOVE_ITEM, location: [2], removedItem: this._3},
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [1], addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, newItem, this._4, this._5]);
	}

	public function testSetWithSortCompareFunctionAndFilterFunctionAfterLast():Void {
		this._collection.filterFunction = filterFunction;
		this._collection.sortCompareFunction = sortCompareFunction;
		this.assertBranchMatches([this._1, this._4, this._3, this._5]);
		this.clearDispatchedEvents();

		var newItem = createItem("New Item", 0.5);
		this._collection.set([4], newItem);
		this.assertBranchMatches([this._1, newItem, this._4, this._3, this._5]);
		this.assertEventsDispatched([
			{type: HierarchicalCollectionEvent.ADD_ITEM, location: [1], addedItem: newItem},
			{type: Event.CHANGE}
		]);

		this._collection.filterFunction = null;
		this._collection.sortCompareFunction = null;
		this.assertBranchMatches([this._1, this._2, this._3, this._4, this._5, newItem]);
	}
}
