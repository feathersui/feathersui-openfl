/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.motion.effects.IEffectContext;
import openfl.display.DisplayObject;
import feathers.events.FeathersEvent;

/**
	A "view stack"-like container that supports navigation between items with
	history. New items are pushed to the top of a stack, and popping the active
	item will navigate to the previous item.

	The following example creates a stack navigator, adds an item, and displays
	it as the root of the history:

	```hx
	var navigator:StackNavigator = new StackNavigator();
	navigator.addItem( "mainMenu", new StackNavigatorItem( MainMenuScreen ) );
	this.addChild( navigator );

	navigator.rootItemID = "mainMenu";
	```

	@see [How to use the Feathers `StackNavigator` component](../../../help/stack-navigator.html)
	@see [Transitions for Feathers navigators](../../../help/transitions.html)
	@see `feathers.controls.navigators.StackNavigatorItem`
	@see `feathers.controls.navigators.TabNavigator`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.StackNavigatorItem)
class StackNavigator extends BaseNavigator {
	public function new() {
		super();
		this.addEventListener(FeathersEvent.INITIALIZE, stackNavigator_initializeHandler);
	}

	/**

		@see `popTransition`

		@since 1.0.0

	**/
	public var pushTransition(default, default):DisplayObject->DisplayObject->IEffectContext;

	/**

		@see `popToRootTransition`
		@see `pushTransition`

		@since 1.0.0
	**/
	public var popTransition(default, default):DisplayObject->DisplayObject->IEffectContext;

	/**

		@see `popTransition`

		@since 1.0.0
	**/
	public var popToRootTransition(default, default):DisplayObject->DisplayObject->IEffectContext;

	/**

		@see `pushTransition`
		@see `popTransition`

		@since 1.0.0
	**/
	public var replaceTransition(default, default):DisplayObject->DisplayObject->IEffectContext;

	private var _stack:Array<StackItem> = [];
	private var _poppedStackItemInTransition:StackItem;
	private var _tempRootItemID:String;

	/**
		The number of items that appear in the history stack, including the
		root item and the currently active item.

		@since 1.0.0
	**/
	public var stackSize(get, null):Int;

	private function get_stackSize():Int {
		return this._stack.length;
	}

	/**
		Sets the first item at the bottom of the history stack, known as the
		root item. When this item is shown, there will be no transition.

		If the history stack currently contains items when you set this
		property, they will all be popped from the stack without a transition.
		In other words, setting this property will completely erase the current
		history.

		In the following example, the root item ID is set:

		```hx
		navigator.rootItemID = "my-item-id";
		```

		@see `popToRootItem()`

		@since 1.0.0
	**/
	public var rootItemID(get, set):String;

	private function get_rootItemID():String {
		if (this._tempRootItemID != null) {
			return this._tempRootItemID;
		}
		return this._stack[0].id;
	}

	private function set_rootItemID(value:String):String {
		if (!this.initialized) {
			this._tempRootItemID = value;
			return this._tempRootItemID;
		}
		// we may have delayed showing the root view until after
		// initialization, but this property could be set between when
		// initialized is set to true and when the item is actually
		// displayed, so we need to clear this variable, just in case.
		this._tempRootItemID = null;

		while (this._stack.length > 0) {
			this._stack.pop();
		}

		if (value == null) {
			this.clearActiveItemInternal(null);
			return null;
		}

		// show without a transition because we're not navigating.
		// we're forcibly replacing the root item.
		this._stack.push(new StackItem(value, null));
		this.showItemInternal(value, null, null);
		return value;
	}

	/**
		Registers a new item with a string identifier that can be used to
		reference the same item in other calls, like `removeItem()` or
		`pushItem()`.

		@see `removeItem()`

		@since 1.0.0
	**/
	public function addItem(id:String, item:StackNavigatorItem):Void {
		this.addItemInternal(id, item);
	}

	/**
		Removes an existing item using the identifier assigned to it in the call
		to `addItem()`.

		@see `addItem()`

		@since 1.0.0
	**/
	public function removeItem(id:String):StackNavigatorItem {
		for (item in this._stack) {
			if (item.id == id) {
				this._stack.remove(item);
				// don't break here because there might be multiple items with
				// this ID in the history stack. we need to look at the entire
				// stack and remove all duplicates
			}
		}
		var item = this.removeItemInternal(id);
		return cast(item, StackNavigatorItem);
	}

	override public function removeAllItems():Void {
		while (this._stack.length > 0) {
			this._stack.pop();
		}
		super.removeAllItems();
	}

	/**
		Returns the `StackNavigatorItem` that was registered by passing the
		specified identifier to `addItem()`.

		@since 1.0.0
	**/
	public function getItem(id:String):StackNavigatorItem {
		var item = this._addedItems.get(id);
		if (item == null) {
			return null;
		}
		return cast(item, StackNavigatorItem);
	}

	/**
		Pushes an item onto the top of the history stack to become the new
		active item.

		Note: Multiple instances of the same item are allowed to be added to the
		history stack, if desired.

		An optional transition may be specified. If `null`, the value of the
		`pushTransition` property will be used instead.

		Returns a reference to the new view, unless a transition is already
		active when `pushItem()` is called. In that case, the new item will be
		queued until the previous transition has completed, and `pushItem()`
		will return `null`.

		@see `pushTransition`

		@since 1.0.0
	**/
	public function pushItem(id:String, ?properties:Map<String, Dynamic>,
			?transition:DisplayObject->DisplayObject->IEffectContext):DisplayObject {
		if (transition == null) {
			var item = this.getItem(id);
			if (item != null && item.pushTransition != null) {
				transition = item.pushTransition;
			} else {
				transition = this.pushTransition;
			}
		}
		this._stack.push(new StackItem(id, properties));
		return this.showItemInternal(id, transition, properties);
	}

	/**
		Pops the current item from the top of the history stack, restoring the
		previous item from the history as the new active item. If the "root"
		item is visible, popping has no effect and the root item will remain
		visible. To remove all items from the history stack, including the root
		item, use `popAll()` instead.

		An optional transition may be specified. If `null`, the value of the
		`popTransition` property will be used instead.

		Returns a reference to the new view, unless a transition is already
		active when `popItem()` is called. In that case, the new item will be
		queued until the previous transition has completed, and `popItem()`
		will return `null`.

		@see `popTransition`
		@see `popToRootItem()`
		@see `popAll()`
		@see `popToRootItemAndReplace()`

		@since 1.0.0
	**/
	public function popItem(?transition:DisplayObject->DisplayObject->IEffectContext):DisplayObject {
		if (this._stack.length <= 1) {
			// we're already at the root of the history stack, and popping has
			// no effect.
			return this.activeItemView;
		}
		if (transition == null) {
			var item = this.getItem(this.activeItemID);
			if (item != null && item.popTransition != null) {
				transition = item.popTransition;
			} else {
				transition = this.popTransition;
			}
		}
		this._stack.pop();
		this._poppedStackItemInTransition = this._stack[this._stack.length - 1];
		return this.showItemInternal(this._poppedStackItemInTransition.id, transition, this._poppedStackItemInTransition.properties);
	}

	/**
		Pops all items from the history stack, except the root item. The root
		item will become the new active item.

		An optional transition may be specified. If `null`, the value of the
		`popToRootTransition` (or `popTransition`) property will be used
		instead.

		Returns a reference to the new view, unless a transition is already
		active when `popToRootItem()` is called. In that case, the new item will
		be queued until the previous transition has completed, and
		`popToRootItem()` will return `null`.

		@see `popToRootTransition`
		@see `popTransition`
		@see `popToRootItemAndReplace()`
		@see `popAll()`
		@see `popItem()`

		@since 1.0.0
	**/
	public function popToRootItem(?transition:DisplayObject->DisplayObject->IEffectContext):DisplayObject {
		if (this._stack.length <= 1) {
			// we're already at the root of the history stack, and popping has
			// no effect.
			return this.activeItemView;
		}
		if (transition == null) {
			transition = this.popToRootTransition;
			if (transition == null) {
				transition = this.popTransition;
			}
		}
		while (this._stack.length > 1) {
			this._stack.pop();
		}
		var item = this._stack[0];
		return this.showItemInternal(item.id, transition, item.properties);
	}

	/**
		Pops all items from the history stack, leaving the `StackNavigator`
		completely empty, with no active item.

		An optional transition may be specified. If `null`, the value of the
		`popTransition` property will be used instead.

		@see `popTransition`
		@see `popToRootItem()`

		@since 1.0.0
	**/
	public function popAll(?transition:DisplayObject->DisplayObject->IEffectContext):Void {
		if (this._stack.length == 0) {
			// the history stack is empty, and there isn't even a root item
			return;
		}
		if (transition == null) {
			transition = this.popTransition;
		}
	}

	/**
		Replaces the current item on the top of the history stack with a new
		item, making the new item the active item. May be used in the case where
		you want to navigate from item A to item B and then to item C, but when
		popping item C, you want to skip item B and return to item A instead.

		An optional transition may be specified. If `null`, the value of the
		`replaceTransition` property will be used instead.

		Returns a reference to the new view, unless a transition is already
		active when `replaceItem()` is called. In that case, the new item will
		be queued until the previous transition has completed, and
		`replaceItem()` will return `null`.

		@see `replaceTransition`

		@since 1.0.0
	**/
	public function replaceItem(id:String, ?properties:Map<String, Dynamic>,
			?transition:DisplayObject->DisplayObject->IEffectContext):DisplayObject {
		if (transition == null) {
			transition = this.replaceTransition;
		}
		return this.showItemInternal(id, transition, properties);
	}

	/**
		Returns to the root of the history stack, but replaces the root item
		with a different item instead.

		An optional transition may be specified. If `null`, the value of the
		`popToRootTransition` (or `popTransition`) property will be used
		instead.

		Returns a reference to the new view, unless a transition is already
		active when `popToRootItemAndReplace()` is called. In that case, the new
		item will be queued until the previous transition has completed, and
		`popToRootItemAndReplace()` will return `null`.

		@see `popToRootTransition`
		@see `popTransition`
		@see `popToRootItem()`
		@see `popAll()`
		@see `popItem()`

		@since 1.0.0
	**/
	public function popToRootItemAndReplace(id:String, ?transition:DisplayObject->DisplayObject->IEffectContext):DisplayObject {
		if (transition == null) {
			transition = this.popToRootTransition;
			if (transition == null) {
				transition = this.popTransition;
			}
		}
		while (this._stack.length > 1) {
			this._stack.pop();
		}
		var item = this._stack[0];
		return this.showItemInternal(item.id, transition, item.properties);
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), StackNavigatorItem);
		return item.getView(this);
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		var item = cast(this._addedItems.get(id), StackNavigatorItem);
		item.returnView(view);
	}

	private function stackNavigator_initializeHandler(event:FeathersEvent):Void {
		if (this._tempRootItemID != null) {
			// we don't show the root item until after initialization because
			// we don't want to start any transitions if it changes before that
			var id = this._tempRootItemID;
			this._tempRootItemID = null;
			this.showItemInternal(id, null);
		}
	}
}

private class StackItem {
	public function new(id:String, properties:Map<String, Dynamic>) {
		this.id = id;
		this.properties = properties;
	}

	public var id(default, null):String;
	public var properties(default, null):Map<String, Dynamic>;
}
