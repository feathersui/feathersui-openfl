/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.IGroupedToggle;
import feathers.controls.IToggle;
import feathers.events.FeathersEvent;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Controls the selection of two or more IToggle instances where only one may
	be selected at a time.

	@event openfl.events.Event.CHANGE Dispatched when `ToggleGroup.selectedItem`
	or `ToggleGroup.selectedIndex` changes.

	@see `feathers.controls.IToggle`
	@see `feathers.controls.IGroupedToggle`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
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
	public var numItems(get, never):Int;

	private function get_numItems():Int {
		return this._items.length;
	}

	private var _ignoreChanges:Bool = false;

	private var _selectedIndex:Int = -1;

	/**
		The index of the currently selected toggle.

		When the value of the `selectedIndex` property changes, the component
		will dispatch an event of type `Event.CHANGE`.

		In the following example, the selected index is changed:

		```haxe
		group.selectedIndex = 2;
		```

		@default -1

		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	public var selectedIndex(get, set):Int;

	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		var itemCount = this._items.length;
		if (value < -1 || value > itemCount) {
			throw new RangeError("Index " + value + " is out of range " + itemCount + " for ToggleGroup.");
		}

		var hasChanged = this._selectedIndex != value;
		this._selectedIndex = value;

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
		return this._selectedIndex;
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

		```haxe
		group.selectedItem = radio;
		```

		@default null

		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	public var selectedItem(get, set):#if flash Dynamic #else IToggle #end;

	private function get_selectedItem():#if flash Dynamic #else IToggle #end {
		if (this._selectedIndex == -1) {
			return null;
		}
		return this._items[this._selectedIndex];
	}

	private function set_selectedItem(value:#if flash Dynamic #else IToggle #end):#if flash Dynamic #else IToggle #end {
		// use the setter
		this.selectedIndex = this._items.indexOf(value);
		return this.selectedItem;
	}

	private var _requireSelection:Bool = true;

	/**
		Determines if the user can deselect the currently selected item or not.
		The selection may always be cleared programmatically by setting the
		selected index to `-1` or the selected item to `null`.

		If `requireSelection` is set to `true`, the toggle group has items that
		were added previously, and there is no currently selected item, the item
		at index `0` will be selected automatically.

		In the following example, selection is not required:

		```haxe
		group.requireSelection = false;
		```

		@default true

		@since 1.0.0
	**/
	public var requireSelection(get, set):Bool;

	private function get_requireSelection():Bool {
		return this._requireSelection;
	}

	private function set_requireSelection(value:Bool):Bool {
		if (this._requireSelection == value) {
			return this._requireSelection;
		}
		this._requireSelection = value;
		if (this._requireSelection && this._selectedIndex == -1 && this._items.length > 0) {
			// use the setter
			this.selectedIndex = 0;
		}
		return this._requireSelection;
	}

	/**
		Adds a toggle to the group. If it is the first item added to the group,
		and `requireSelection` is `true`, it will be selected automatically.

		In the following example, an item is added to the toggle group:

		```haxe
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
		} else if (this._selectedIndex < 0 && this._requireSelection) {
			this.selectedItem = item;
		} else {
			item.selected = false;
		}
		item.addEventListener(Event.CHANGE, item_changeHandler, false, 0, true);

		if ((item is IGroupedToggle)) {
			cast(item, IGroupedToggle).toggleGroup = this;
		}
	}

	/**
		Removes a toggle from the group. If the item being removed is selected
		and `requireSelection` is `true`, the final item will be selected. If
		`requireSelection` is `false` instead, no item will be selected.

		In the following example, an item is removed from the toggle group:

		```haxe
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
		if ((item is IGroupedToggle)) {
			cast(item, IGroupedToggle).toggleGroup = null;
		}
		if (this._selectedIndex > index) {
			// the same item is selected, but its index has changed.
			this.selectedIndex -= 1; // use the setter
		} else if (this.selectedIndex == index) {
			if (this._requireSelection) {
				var maxSelectedIndex = this._items.length - 1;
				if (this._selectedIndex > maxSelectedIndex) {
					// we want to keep the same index, if possible, but if
					// we can't because it is too high, we should select the
					// next highest item.
					this.selectedIndex = maxSelectedIndex; // use the setter
				} else {
					// we need to manually dispatch the change event because
					// the selected index hasn't changed, but the selected
					// item has changed.
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			} else {
				// selection isn't required, and we just removed the selected
				// item, so no item should be selected.
				this.selectedIndex = -1; // use the setter
			}
		}
	}

	/**
		Removes all toggles from the group. No item will be selected.

		In the following example, all items are removed from the toggle group:

		```haxe
		group.removeAllItems();
		```

		@since 1.0.0
	**/
	public function removeAllItems():Void {
		for (item in this._items) {
			item.removeEventListener(Event.CHANGE, item_changeHandler);
			if ((item is IGroupedToggle)) {
				cast(item, IGroupedToggle).toggleGroup = null;
			}
		}
		#if hl
		this._items.splice(0, this._items.length);
		#else
		this._items.resize(0);
		#end
		// use the setter
		this.selectedIndex = -1;
	}

	/**
		Determines if the group includes the specified item.

		In the following example, we check if an item is in the toggle group:

		```haxe
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

		```haxe
		var item:IToggle = group.getItemAt(2);
		```

		@see `ToggleGroup.numItems`

		@since 1.0.0
	**/
	public function getItemAt(index:Int):IToggle {
		if (index < 0 || index >= this._items.length) {
			throw new RangeError("The supplied index is out of bounds.");
		}
		return this._items[index];
	}

	/**
		Returns the index of the specified item. Result will be `-1` if the item
		has not been added to the group.

		In the following example, an item's index is calculated:

		```haxe
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

		```haxe
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
		if (this._selectedIndex >= 0) {
			if (this._selectedIndex == oldIndex) {
				// use the setter
				this.selectedIndex = index;
			} else if (oldIndex < this._selectedIndex && index > this._selectedIndex) {
				// use the setter
				this.selectedIndex--;
			} else if (oldIndex > this._selectedIndex && index < this._selectedIndex) {
				// use the setter
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
		if (item.selected || (this._requireSelection && this._selectedIndex == index)) {
			// don't let it deselect the item
			this.selectedIndex = index; // use the setter
		} else if (!item.selected) {
			// use the setter
			this.selectedIndex = -1;
		}
	}
}
