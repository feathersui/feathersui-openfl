/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.ToggleButton;
import openfl.Lib;
import openfl.errors.RangeError;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class ToggleGroupTest extends Test {
	private var _group:ToggleGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._group = new ToggleGroup();
	}

	public function teardown():Void {
		this._group = null;
	}

	public function testDefaultSelectedIndexIsNegativeOne():Void {
		Assert.equals(-1, this._group.selectedIndex);
	}

	public function testUpdatesSelectedIndexWhenAddingFirstItem():Void {
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		Assert.equals(-1, this._group.selectedIndex);
		this._group.addItem(new ToggleButton());
		Assert.isTrue(changed);
		Assert.equals(0, this._group.selectedIndex);
	}

	public function testSettingSelectedIndexDispatchesChangeEvent():Void {
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.selectedIndex = 1;
		Assert.isTrue(changed);
	}

	public function testSettingSelectedIndexToSameValueDispatchesNoEvent():Void {
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.selectedIndex = 0;
		Assert.isFalse(changed);
	}

	public function testChangingItemSelectionDispatchesChangeEvent():Void {
		var itemAtIndex1 = new ToggleButton();
		this._group.addItem(new ToggleButton());
		this._group.addItem(itemAtIndex1);
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		itemAtIndex1.selected = true;
		Assert.isTrue(changed);
	}

	public function testRemoveItemBeforeSelectedItem():Void {
		var itemAtIndex0 = new ToggleButton();
		this._group.addItem(itemAtIndex0);
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		this._group.selectedIndex = 1;
		var beforeSelectedIndex = this._group.selectedIndex;
		var beforeSelectedItem = this._group.selectedItem;
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.removeItem(itemAtIndex0);
		Assert.isTrue(changed);
		Assert.equals(beforeSelectedIndex - 1, this._group.selectedIndex);
		Assert.equals(beforeSelectedItem, this._group.selectedItem);
	}

	public function testRemoveAfterSelectedIndex():Void {
		var itemAtIndex2 = new ToggleButton();
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		this._group.addItem(itemAtIndex2);
		this._group.selectedIndex = 1;
		var beforeSelectedIndex = this._group.selectedIndex;
		var beforeSelectedItem = this._group.selectedItem;
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.removeItem(itemAtIndex2);
		Assert.isFalse(changed);
		Assert.equals(beforeSelectedIndex, this._group.selectedIndex);
		Assert.equals(beforeSelectedItem, this._group.selectedItem);
	}

	public function testRemoveSelectedItem():Void {
		var itemAtIndex1 = new ToggleButton();
		this._group.addItem(new ToggleButton());
		this._group.addItem(itemAtIndex1);
		this._group.addItem(new ToggleButton());
		this._group.selectedIndex = 1;
		var beforeSelectedIndex = this._group.selectedIndex;
		var beforeSelectedItem = this._group.selectedItem;
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.removeItem(itemAtIndex1);
		Assert.isTrue(changed);
		Assert.equals(beforeSelectedIndex, this._group.selectedIndex);
		Assert.notEquals(beforeSelectedItem, this._group.selectedItem);
	}

	public function testDeselectAllOnRemoveAllItems():Void {
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.removeAllItems();
		Assert.isTrue(changed);
		Assert.equals(-1, this._group.selectedIndex);
		Assert.isNull(this._group.selectedItem);
	}

	public function testSetSelectedItemIndex():Void {
		var itemAtIndex1 = new ToggleButton();
		this._group.addItem(new ToggleButton());
		this._group.addItem(itemAtIndex1);
		this._group.addItem(new ToggleButton());
		this._group.selectedIndex = 1;
		var beforeSelectedIndex = this._group.selectedIndex;
		var beforeSelectedItem = this._group.selectedItem;
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.setItemIndex(itemAtIndex1, 2);
		Assert.isTrue(changed);
		Assert.notEquals(beforeSelectedIndex, this._group.selectedIndex);
		Assert.equals(beforeSelectedItem, this._group.selectedItem);
	}

	public function testSetItemIndexBeforeSelectedItem():Void {
		var itemAtIndex0 = new ToggleButton();
		this._group.addItem(itemAtIndex0);
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		this._group.selectedIndex = 1;
		var beforeSelectedIndex = this._group.selectedIndex;
		var beforeSelectedItem = this._group.selectedItem;
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.setItemIndex(itemAtIndex0, 2);
		Assert.isTrue(changed);
		Assert.notEquals(beforeSelectedIndex, this._group.selectedIndex);
		Assert.equals(beforeSelectedItem, this._group.selectedItem);
	}

	public function testSetItemIndexAfterSelectedItem():Void {
		var itemAtIndex2 = new ToggleButton();
		this._group.addItem(new ToggleButton());
		this._group.addItem(new ToggleButton());
		this._group.addItem(itemAtIndex2);
		this._group.selectedIndex = 1;
		var beforeSelectedIndex = this._group.selectedIndex;
		var beforeSelectedItem = this._group.selectedItem;
		var changed = false;
		this._group.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._group.setItemIndex(itemAtIndex2, 0);
		Assert.isTrue(changed);
		Assert.notEquals(beforeSelectedIndex, this._group.selectedIndex);
		Assert.equals(beforeSelectedItem, this._group.selectedItem);
	}

	public function testHasItem():Void {
		var item = new ToggleButton();
		Assert.isFalse(this._group.hasItem(item));
		this._group.addItem(item);
		Assert.isTrue(this._group.hasItem(item));
		this._group.removeItem(item);
		Assert.isFalse(this._group.hasItem(item));
	}

	public function testDefaultNumItems():Void {
		Assert.equals(0, this._group.numItems);
	}

	public function testNumItemsAfterAddItem():Void {
		this._group.addItem(new ToggleButton());
		Assert.equals(1, this._group.numItems);
	}

	public function testGetItemAtWhenEmpty():Void {
		Assert.raises(() -> {
			this._group.getItemAt(0);
		}, RangeError);
	}

	public function testGetItemAt():Void {
		var item = new ToggleButton();
		this._group.addItem(item);
		Assert.equals(item, this._group.getItemAt(0));
	}
}
