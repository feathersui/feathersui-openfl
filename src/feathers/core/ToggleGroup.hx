/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.IGroupedToggle;
import openfl.errors.IllegalOperationError;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import feathers.events.FeathersEvent;
import openfl.errors.RangeError;
import feathers.controls.IToggle;
import openfl.events.EventDispatcher;

/**
	Controls the selection of two or more IToggle instances where only one may
	be selected at a time.

	@see `feathers.controls.IToggle`
	@see `feathers.controls.IGroupedToggle`

	@since 1.0.0
**/
class ToggleGroup extends EventDispatcher implements IIndexSelector implements IDataSelector<IToggle> {
	/**
		Creates a new `ToggleGroup` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _items:Array<IToggle> = [];

	/**
		The number of items added to the group.

		@since 1.0.0
	**/
	public var numItems(get, null):Int;

	private function get_numItems():Int {
		return this._items.length;
	}

	private var _ignoreChanges:Bool = false;

	/**
		The index of the currently selected toggle.

		When the value of the `selectedIndex` property changes, the component
		will dispatch an event of type `Event.CHANGE`.

		In the following example, the selected index is changed:

		```hx
		group.selectedIndex = 2;
		```

		@default -1

		@see `openfl.events.Event.CHANGE`

		@since 1.0.0
	**/
	@:isVar
	public var selectedIndex(get, set):Int = -1;

	private function get_selectedIndex():Int {
		return this.selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		var itemCount = this._items.length;
		if (value < -1 || value > itemCount) {
			throw new RangeError("Index " + value + " is out of range " + itemCount + " for ToggleGroup.");
		}

		var hasChanged = this.selectedIndex != value;
		this.selectedIndex = value;

		// refresh all of the items
		var oldIgnoreChanges = this._ignoreChanges;
		this._ignoreChanges = true;
		for (i in 0...this._items.length) {
			var item = this._items[i];
			item.selected = i == value;
		}
		this._ignoreChanges = oldIgnoreChanges;

		if (hasChanged) {
			// only dispatch if there's been a change. we didn't return
			// early because this setter could be called if an item is
			// unselected. if selection is required, we need to reselect the
			// item (happens below in the item's onChange listener).
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
		return this.selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		return this._items.length - 1;
	}

	/**
		The currently selected toggle.

		When the value of the `selectedItem` property changes, the component
		will dispatch an event of type `Event.CHANGE`.

		In the following example, the selected item is changed:

		```hx
		group.selectedItem = radio;
		```

		@default null

		@see `openfl.events.Event.CHANGE`

		@since 1.0.0
	**/
	public var selectedItem(get, set):IToggle;

	private function get_selectedItem():IToggle {
		if (this.selectedIndex == -1) {
			return null;
		}
		return this._items[this.selectedIndex];
	}

	private function set_selectedItem(value:IToggle):IToggle {
		this.selectedIndex = this._items.indexOf(value);
		return this.selectedItem;
	}

	/**
		Determines if the user can deselect the currently selected item or not.
		The selection may always be cleared programmatically by setting the
		selected index to `-1` or the selected item to `null`.

		If `requireSelection` is set to `true`, the toggle group has items that
		were added previously, and there is no currently selected item, the item
		at index `0` will be selected automatically.

		In the following example, selection is not required:

		```hx
		group.requireSelection = false;
		```

		@default true

		@since 1.0.0
	**/
	public var requireSelection(default, set):Bool = true;

	private function set_requireSelection(value:Bool):Bool {
		if (this.requireSelection == value) {
			return this.requireSelection;
		}
		this.requireSelection = value;
		if (this.requireSelection && this.selectedIndex == -1 && this._items.length > 0) {
			this.selectedIndex = 0;
		}
		return this.requireSelection;
	}

	/**
		Adds a toggle to the group. If it is the first item added to the group,
		and `requireSelection` is `true`, it will be selected automatically.

		In the following example, an item is added to the toggle group:

		```hx
		group.addItem(radio);
		```

		@see `ToggleGroup.removeItem`

		@since 1.0.0
	**/
	public function addItem(item:IToggle):Void {
		if (item == null) {
			throw new ArgumentError("IToggle passed to ToggleGroup addItem() must not be null.");
		}

		var index = this._items.indexOf(item);
		if (index != -1) {
			throw new IllegalOperationError("Cannot add an item to a ToggleGroup more than once.");
		}
		this._items.push(item);
		if (item.selected) {
			this.selectedItem = item;
		} else if (this.selectedIndex < 0 && this.requireSelection) {
			this.selectedItem = item;
		} else {
			item.selected = false;
		}
		item.addEventListener(Event.CHANGE, item_changeHandler, false, 0, true);

		if (Std.is(item, IGroupedToggle)) {
			cast(item, IGroupedToggle).toggleGroup = this;
		}
	}

	/**
		Removes a toggle from the group. If the item being removed is selected
		and `requireSelection` is `true`, the final item will be selected. If
		`requireSelection` is `false` instead, no item will be selected.

		In the following example, an item is removed from the toggle group:

		```hx
		group.removeItem(radio);
		```

		@see `ToggleGroup.addItem`
		@see `ToggleGroup.removeAllItems`

		@since 1.0.0
	**/
	public function removeItem(item:IToggle):Void {
		var index = this._items.indexOf(item);
		if (index == -1) {
			return;
		}
		this._items.remove(item);
		item.removeEventListener(Event.CHANGE, item_changeHandler);
		if (Std.is(item, IGroupedToggle)) {
			cast(item, IGroupedToggle).toggleGroup = null;
		}
		if (this.selectedIndex > index) {
			// the same item is selected, but its index has changed.
			this.selectedIndex -= 1;
		} else if (this.selectedIndex == index) {
			if (this.requireSelection) {
				var maxSelectedIndex = this._items.length - 1;
				if (this.selectedIndex > maxSelectedIndex) {
					// we want to keep the same index, if possible, but if
					// we can't because it is too high, we should select the
					// next highest item.
					this.selectedIndex = maxSelectedIndex;
				} else {
					// we need to manually dispatch the change event because
					// the selected index hasn't changed, but the selected
					// item has changed.
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			} else {
				// selection isn't required, and we just removed the selected
				// item, so no item should be selected.
				this.selectedIndex = -1;
			}
		}
	}

	/**
		Removes all toggles from the group. No item will be selected.

		In the following example, all items are removed from the toggle group:

		```hx
		group.removeAllItems();
		```

		@since 1.0.0
	**/
	public function removeAllItems():Void {
		for (item in this._items) {
			item.removeEventListener(Event.CHANGE, item_changeHandler);
			if (Std.is(item, IGroupedToggle)) {
				cast(item, IGroupedToggle).toggleGroup = null;
			}
		}
		this._items.resize(0);
		this.selectedIndex = -1;
	}

	/**
		Determines if the group includes the specified item.

		In the following example, we check if an item is in the toggle group:

		```hx
		if(group.hasItem(radio))
		{
			// do something
		}
		```

		@since 1.0.0
	**/
	public function hasItem(item:IToggle):Bool {
		return this._items.indexOf(item) != -1;
	}

	/**
		Returns the item at the specified index. If the index is out of range,
		a `RangeError` will be thrown.

		In the following example, an item's at a specific index is returned:

		```hx
		var item:IToggle = group.getItemAt(2);
		```

		@see `ToggleGroup.numItems`

		@since 1.0.0
	**/
	public function getItemAt(index:Int):IToggle {
		return this._items[index];
	}

	/**
		Returns the index of the specified item. Result will be `-1` if the item
		has not been added to the group.

		In the following example, an item's index is calculated:

		```hx
		var index:Int = group.getItemIndex(radio);
		```

		@since 1.0.0
	**/
	public function getItemIndex(item:IToggle):Int {
		return this._items.indexOf(item);
	}

	/**
		Changes the index of a specified item. Throws an `ArgumentError` if the
		specified item hasn't already been added to this group.

		In the following example, an item's index is changed:

		```hx
		group.setItemIndex(radio, 2);
		```

		@since 1.0.0
	**/
	public function setItemIndex(item:IToggle, index:Int):Void {
		var oldIndex = this._items.indexOf(item);
		if (oldIndex < 0) {
			throw new ArgumentError("Attempting to set index of an item that has not been added to this ToggleGroup.");
		}
		if (oldIndex == index) {
			// no change needed
			return;
		}
		this._items.remove(item);
		this._items.insert(index, item);
		if (this.selectedIndex >= 0) {
			if (this.selectedIndex == oldIndex) {
				this.selectedIndex = index;
			} else if (oldIndex < this.selectedIndex && index > this.selectedIndex) {
				this.selectedIndex--;
			} else if (oldIndex > this.selectedIndex && index < this.selectedIndex) {
				this.selectedIndex++;
			}
		}
	}

	private function item_changeHandler(event:Event):Void {
		if (this._ignoreChanges) {
			return;
		}

		var item:IToggle = cast(event.currentTarget, IToggle);
		var index = this._items.indexOf(item);
		if (item.selected || (this.requireSelection && this.selectedIndex == index)) {
			// don't let it deselect the item
			this.selectedIndex = index;
		} else if (!item.selected) {
			this.selectedIndex = -1;
		}
	}
}
