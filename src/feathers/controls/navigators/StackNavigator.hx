/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.ui.Keyboard;
import lime.ui.KeyCode;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import feathers.motion.effects.IEffectContext;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;

/**
	A "view stack"-like container that supports navigation between items with
	history. New items are pushed to the top of a stack, and popping the active
	item will navigate to the previous item.

	This component is designed for use in native apps. For web browser apps,
	consider using `RouterNavigator` instead.

	The following example creates a stack navigator, adds an item, and displays
	it as the root of the history:

	```hx
	var navigator = new StackNavigator();
	navigator.addItem("mainMenu", new StackItem(MainMenuScreen));
	this.addChild(navigator);

	navigator.rootItemID = "mainMenu";
	```

	@see [Tutorial: How to use the StackNavigator component](https://feathersui.com/learn/haxe-openfl/stack-navigator/)
	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)
	@see `feathers.controls.navigators.StackItem`
	@see `feathers.controls.navigators.StackAction`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.StackItem)
@:styleContext
class StackNavigator extends BaseNavigator {
	/**
		Creates a new `StackNavigator` object.

		@since 1.0.0
	**/
	public function new() {
		super();
		this.addEventListener(FeathersEvent.INITIALIZE, stackNavigator_initializeHandler);
		this.addEventListener(Event.ADDED_TO_STAGE, stackNavigator_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, stackNavigator_removedFromStageHandler);
	}

	/**
		The default transition to use for push actions, if not overridden in the
		call to `pushItem()`.

		@see `StackNavigator.pushItem()`
		@see `StackNavigator.popTransition`

		@since 1.0.0

	**/
	public var pushTransition(default, default):(DisplayObject, DisplayObject) -> IEffectContext;

	/**
		The default transition to use for pop actions, if not overridden in the
		call to `popItem()`.

		@see `StackNavigator.popItem()`
		@see `StackNavigator.popToRootItem()`
		@see `StackNavigator.popToRootItemAndReplace()`
		@see `StackNavigator.pushTransition`

		@since 1.0.0
	**/
	public var popTransition(default, default):(DisplayObject, DisplayObject) -> IEffectContext;

	/**
		The default transition to use for replace actions, if not overridden in
		the call to `replaceItem()`.

		@see `StackNavigator.replaceItem()`
		@see `StackNavigator.pushTransition`
		@see `StackNavigator.popTransition`

		@since 1.0.0
	**/
	public var replaceTransition(default, default):(DisplayObject, DisplayObject) -> IEffectContext;

	private var _history:Array<HistoryItem> = [];
	private var _tempRootItemID:String;

	/**
		The number of items that appear in the history stack, including the
		root item and the currently active item.

		@since 1.0.0
	**/
	public var stackSize(get, null):Int;

	private function get_stackSize():Int {
		return this._history.length;
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

		@see `StackNavigator.popToRootItem()`

		@since 1.0.0
	**/
	public var rootItemID(get, set):String;

	private function get_rootItemID():String {
		if (this._history.length > 0) {
			return this._history[0].id;
		}
		return this._tempRootItemID;
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

		this._history.resize(0);

		if (value == null) {
			this.clearActiveItemInternal(null);
			return null;
		}

		// show without a transition because we're not navigating.
		// we're forcibly replacing the root item.
		var historyItem = new HistoryItem(value, null, null);
		this._history.push(historyItem);
		this.showItemWithInjectAndReturnedObject(value, null, null, null, false);
		return value;
	}

	private var savedInject:(Dynamic) -> Void;
	private var savedReturnedObject:Dynamic;
	private var savedIsPop:Bool = false;

	/**
		Registers a new item. The `id` property of the item should be used to
		reference the same item in other method calls, like `pushItem()` or
		`removeItem()`.

		@see `StackNavigator.removeItem()`

		@since 1.0.0
	**/
	public function addItem(item:StackItem):Void {
		this.addItemInternal(item.id, item);
	}

	/**
		Removes an existing item using the identifier assigned to it in the call
		to `addItem()`.

		@see `StackNavigator.addItem()`

		@since 1.0.0
	**/
	public function removeItem(id:String):StackItem {
		for (item in this._history) {
			if (item.id == id) {
				this._history.remove(item);
				// don't break here because there might be multiple items with
				// this ID in the history stack. we need to look at the entire
				// stack and remove all duplicates
			}
		}
		var item = this.removeItemInternal(id);
		return cast(item, StackItem);
	}

	override public function removeAllItems():Void {
		this._history.resize(0);
		super.removeAllItems();
	}

	/**
		Returns the `StackItem` that was registered by passing the specified
		identifier to `addItem()`.

		@since 1.0.0
	**/
	public function getItem(id:String):StackItem {
		var item = this._addedItems.get(id);
		if (item == null) {
			return null;
		}
		return cast(item, StackItem);
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

		@see `StackNavigator.pushTransition`
		@see `StackNavigator.popItem()`
		@see `StackNavigator.replaceItem()`

		@since 1.0.0
	**/
	public function pushItem(id:String, ?inject:(Dynamic) -> Void, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (transition == null) {
			var item = this.getItem(id);
			if (item != null && item.pushTransition != null) {
				transition = item.pushTransition;
			} else {
				transition = this.pushTransition;
			}
		}
		var historyItem = new HistoryItem(id, inject, transition);
		this._history.push(historyItem);
		return this.showItemWithInjectAndReturnedObject(id, transition, inject, null, false);
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

		@see `StackNavigator.popTransition`
		@see `StackNavigator.popToRootItem()`
		@see `StackNavigator.popAll()`
		@see `StackNavigator.popToRootItemAndReplace()`

		@since 1.0.0
	**/
	public function popItem(?returnedObject:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (this._history.length <= 1) {
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
		this._history.pop();
		var item = this._history[this._history.length - 1];
		return this.showItemWithInjectAndReturnedObject(item.id, transition, item.inject, returnedObject, true);
	}

	/**
		Pops all items from the history stack, except the root item. The root
		item will become the new active item.

		An optional transition may be specified. If `null`, the value of the
		`popTransition` property will be used instead.

		Returns a reference to the new view, unless a transition is already
		active when `popToRootItem()` is called. In that case, the new item will
		be queued until the previous transition has completed, and
		`popToRootItem()` will return `null`.

		@see `StackNavigator.popTransition`
		@see `StackNavigator.popToRootItemAndReplace()`
		@see `StackNavigator.popAll()`
		@see `StackNavigator.popItem()`

		@since 1.0.0
	**/
	public function popToRootItem(?returnedObject:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (this._history.length <= 1) {
			// we're already at the root of the history stack, and popping has
			// no effect.
			return this.activeItemView;
		}
		if (transition == null) {
			transition = this.popTransition;
		}
		this._history.resize(1);
		var item = this._history[0];
		return this.showItemWithInjectAndReturnedObject(item.id, transition, item.inject, returnedObject, true);
	}

	/**
		Pops all items from the history stack, leaving the `StackNavigator`
		completely empty, with no active item.

		An optional transition may be specified. If `null`, the value of the
		`popTransition` property will be used instead.

		@see `StackNavigator.popTransition`
		@see `StackNavigator.popToRootItem()`

		@since 1.0.0
	**/
	public function popAll(?transition:(DisplayObject, DisplayObject) -> IEffectContext):Void {
		if (this._history.length == 0) {
			// the history stack is empty, and there isn't even a root item
			return;
		}
		if (transition == null) {
			transition = this.popTransition;
		}
		this._history.resize(0);
		this.clearActiveItemInternal(transition);
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

		@see `StackNavigator.replaceTransition`

		@since 1.0.0
	**/
	public function replaceItem(id:String, ?inject:(Dynamic) -> Void, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (transition == null) {
			transition = this.replaceTransition;
		}
		var historyItem = new HistoryItem(id, inject, transition);
		this._history[this._history.length - 1] = historyItem;
		return this.showItemWithInjectAndReturnedObject(id, transition, inject, null, false);
	}

	/**
		Returns to the root of the history stack, but replaces the root item
		with a different item instead.

		An optional transition may be specified. If `null`, the value of the
		`popTransition` property will be used instead.

		Returns a reference to the new view, unless a transition is already
		active when `popToRootItemAndReplace()` is called. In that case, the new
		item will be queued until the previous transition has completed, and
		`popToRootItemAndReplace()` will return `null`.

		@see `StackNavigator.popTransition`
		@see `StackNavigator.popToRootItem()`
		@see `StackNavigator.popAll()`
		@see `StackNavigator.popItem()`

		@since 1.0.0
	**/
	public function popToRootItemAndReplace(id:String, ?inject:(Dynamic) -> Void, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (transition == null) {
			transition = this.popTransition;
		}
		this._history.resize(1);
		this._history[0] = new HistoryItem(id, inject, transition);
		return this.showItemWithInjectAndReturnedObject(id, transition, inject, null, false);
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), StackItem);
		return item.getView(this);
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		var item = cast(this._addedItems.get(id), StackItem);
		item.returnView(view);
	}

	override private function prepareActiveItemView():Void {
		if (this.savedInject != null) {
			this.savedInject(this.activeItemView);
		}

		if (this.savedIsPop) {
			var item = this.getItem(this.activeItemID);
			var returnHandlers = item.returnHandlers;
			if (returnHandlers != null && returnHandlers.exists(this._previousViewInTransitionID)) {
				returnHandlers.get(this._previousViewInTransitionID)(this.activeItemView, this.savedReturnedObject);
			}
		}
	}

	private function showItemWithInjectAndReturnedObject(id:String, ?transition:(DisplayObject, DisplayObject) -> IEffectContext, ?inject:(Dynamic) -> Void,
			returnedObject:Dynamic, isPop:Bool):DisplayObject {
		this.savedInject = inject;
		this.savedReturnedObject = returnedObject;
		this.savedIsPop = isPop;
		var result = this.showItemInternal(id, transition);
		this.savedInject = null;
		this.savedReturnedObject = null;
		this.savedIsPop = false;
		return result;
	}

	private function stackNavigator_initializeHandler(event:FeathersEvent):Void {
		if (this._tempRootItemID != null) {
			// we don't show the root item until after initialization because
			// we don't want to start any transitions if it changes before that
			var id = this._tempRootItemID;
			this._tempRootItemID = null;
			this.showItemWithInjectAndReturnedObject(id, null, null, null, false);
		}
	}

	private function stackNavigator_addedToStageHandler(event:Event):Void {
		this.stage.addEventListener(KeyboardEvent.KEY_UP, stackNavigator_stage_keyUpHandler, false, 0, true);
	}

	private function stackNavigator_removedFromStageHandler(event:Event):Void {
		this.stage.removeEventListener(KeyboardEvent.KEY_UP, stackNavigator_stage_keyUpHandler);
	}

	private function stackNavigator_stage_backKeyUpHandler(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._history.length <= 1) {
			// can't go back
			return;
		}
		event.preventDefault();
		this.popItem();
	}

	private function stackNavigator_stage_keyUpHandler(event:KeyboardEvent):Void {
		if (!this.enabled) {
			return;
		}
		switch (event.keyCode) {
			#if flash
			case Keyboard.BACK:
				this.stackNavigator_stage_backKeyUpHandler(event);
			#end
			case KeyCode.APP_CONTROL_BACK:
				this.stackNavigator_stage_backKeyUpHandler(event);
		}
	}
}

private class HistoryItem {
	public function new(id:String, inject:(Dynamic) -> Void, transition:(DisplayObject, DisplayObject) -> IEffectContext) {
		this.id = id;
		this.inject = inject;
		this.transition = transition;
	}

	public var id(default, null):String;
	public var inject(default, null):(Dynamic) -> Void;
	public var transition(default, null):(DisplayObject, DisplayObject) -> IEffectContext;
}
