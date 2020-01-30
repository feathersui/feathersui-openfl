/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.events.Event;
import feathers.motion.effects.IEffectContext;
import openfl.display.DisplayObject;

/**
	An individual item that will be displayed by a `StackNavigator` component.
	Provides the view, an optional function to set properties before the view is
	displayed, and an optional list of events to map to actions (like push, pop,
	and replace) on the `StackNavigator`.

	The following example creates a new `StackItem` using the `SettingsView`
	class to instantiate the view instance. This item is given am id of
	`"settings"`. When the view dispatches the
	`SettingsView.SHOW_ADVANCED_SETTINGS` event, the `StackNavigator` will push
	a different item with the ID `"advancedSettings"` onto its history stack.
	When the view instance dispatches `Event.COMPLETE`, the `StackNavigator`
	will pop the view from its history stack and return navigate to the previous
	view.

	```hx
	var item = StackItem.withClass("settings", SettingsScreen, [
		SettingsScreen.SHOW_ADVANCED_SETTINGS => StackActions.Push("advancedSettings"),
		Event.COMPLETE => StackActions.Pop()
	]);
	navigator.addItem("settings", item);
	```

	@see [Tutorial: How to use the StackNavigator component](https://feathersui.com/learn/haxe-openfl/stack-navigator/)
	@see `feathers.controls.StackNavigator`

	@since 1.0.0
**/
class StackItem {
	/**
		Creates a `StackItem` that instantiates a view from a class that extends
		`DisplayObject` when the `StackNavigator` requests the item's view.
	**/
	public static function withClass(id:String, viewClass:Class<DisplayObject>, ?actions:Map<String, StackAction>,
			?returnHandlers:Map<String, (Dynamic, Dynamic) -> Void>):StackItem {
		var item = new StackItem();
		item.id = id;
		item.viewClass = viewClass;
		item.actions = actions;
		item.returnHandlers = returnHandlers;
		return item;
	}

	/**
		Creates a `StackItem` that calls a function that returns a
		`DisplayObject` when the `StackNavigator` requests the item's view.
	**/
	public static function withFunction(id:String, viewFunction:() -> DisplayObject, ?actions:Map<String, StackAction>,
			?returnHandlers:Map<String, (Dynamic, Dynamic) -> Void>):StackItem {
		var item = new StackItem();
		item.id = id;
		item.viewFunction = viewFunction;
		item.actions = actions;
		item.returnHandlers = returnHandlers;
		return item;
	}

	/**
		Creates a `StackItem` that always returns the same `DisplayObject`
		instance when the `StackNavigator` requests the item's view.
	**/
	public static function withDisplayObject(id:String, viewInstance:DisplayObject, ?actions:Map<String, StackAction>,
			?returnHandlers:Map<String, (Dynamic, Dynamic) -> Void>):StackItem {
		var item = new StackItem();
		item.id = id;
		item.viewInstance = viewInstance;
		item.actions = actions;
		item.returnHandlers = returnHandlers;
		return item;
	}

	private function new() {}

	/**
		The unique ID associated with this item.

		@since 1.0.0
	**/
	public var id:String;

	private var viewClass:Class<DisplayObject>;
	private var viewFunction:() -> DisplayObject;
	private var viewInstance:DisplayObject;
	private var actions:Map<String, StackAction>;
	private var returnHandlers:Map<String, (Dynamic, Dynamic) -> Void>;

	/**
		A custom "push" transition for this item only. If `null`, the default
		`pushTransition` defined by the `StackNavigator` will be used
		instead.

		In the following example, the stack navigator item is given a push
		transition:

		```hx
		item.pushTransition = Slide.createSlideLeftTransition();
		```

		A number of animated transitions may be found in the
		`feathers.motion.transitions` package. However, you are not limited to
		only these transitions. You may create custom transitions too.

		A custom transition function should have the following signature:

		```hx
		(DisplayObject, DisplayObject) -> IEffectContext
		```

		Either of the arguments typed as `DisplayObject` may be `null`, but
		never both. The first `DisplayObject` argument will be `null` when the
		first item is displayed or when a new item is displayed after clearing
		the current item. The second `DisplayObject` argument will be null when
		clearing the current item.

		@default `null`

		@see `feathers.controls.StackNavigator.pushTransition`
		@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

		@since 1.0.0

	**/
	public var pushTransition:(DisplayObject, DisplayObject) -> IEffectContext;

	/**
		A custom "pop" transition for this item only. If `null`, the default
		`popTransition` defined by the `StackNavigator` will be used
		instead.

		In the following example, the stack navigator item is given a push
		transition:

		```hx
		item.popTransition = Slide.createSlideRightTransition();
		```

		A number of animated transitions may be found in the
		`feathers.motion.transitions` package. However, you are not limited to
		only these transitions. You may create custom transitions too.

		A custom transition function should have the following signature:

		```hx
		(DisplayObject, DisplayObject) -> IEffectContext
		```

		Either of the arguments typed as `DisplayObject` may be `null`, but
		never both. The first `DisplayObject` argument will be `null` when the
		first item is displayed or when a new item is displayed after clearing
		the current item. The second `DisplayObject` argument will be null when
		clearing the current item.

		@default `null`

		@see `feathers.controls.StackNavigator.pushTransition`
		@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

		@since 1.0.0

	**/
	public var popTransition:(DisplayObject, DisplayObject) -> IEffectContext;

	private var _viewToEvents:Map<DisplayObject, Array<ViewListener>> = [];

	/**
		Sets a new action to perform when the view dispatches an event. If the
		action is `null`, removes an action that was set previously.

		@since 1.0.0
	**/
	public function setAction(eventType:String, action:StackAction):Void {
		if (this.actions == null) {
			this.actions = [];
		}
		if (action == null) {
			this.actions.remove(eventType);
		} else {
			this.actions.set(eventType, action);
		}
	}

	// called internally by StackNavigator to get this item's view
	private function getView(navigator:StackNavigator):DisplayObject {
		var view:DisplayObject = this.viewInstance;
		if (view == null && this.viewClass != null) {
			view = Type.createInstance(this.viewClass, []);
		}
		if (view == null && this.viewFunction != null) {
			view = this.viewFunction();
		}

		var listeners = this.addActionListeners(view, navigator);
		this._viewToEvents.set(view, listeners);

		return view;
	}

	// called internally by StackNavigator to clean up this item's view
	private function returnView(view:DisplayObject):Void {
		var viewListeners:Array<ViewListener> = this._viewToEvents.get(view);
		this.removeEventsFromView(view, viewListeners);
		this._viewToEvents.remove(view);
	}

	private function addActionListeners(view:DisplayObject, navigator:StackNavigator):Array<ViewListener> {
		var listeners:Array<ViewListener> = [];
		if (this.actions == null) {
			return listeners;
		}
		for (eventType in this.actions.keys()) {
			var action = this.actions.get(eventType);
			var listener = this.createActionEventListener(action, navigator);
			view.addEventListener(eventType, listener);
			listeners.push(new ViewListener(eventType, listener));
		}
		return listeners;
	}

	private function performAction(action:StackAction, event:Event, navigator:StackNavigator):StackAction {
		switch (action) {
			case Push(id, inject, transition):
				{
					navigator.pushItem(id, inject, transition);
				}
			case Replace(id, inject, transition):
				{
					navigator.replaceItem(id, inject, transition);
				}
			case Pop(returnedObject, transition):
				{
					navigator.popItem(returnedObject, transition);
				}
			case PopToRoot(returnedObject, transition):
				{
					navigator.popToRootItem(returnedObject, transition);
				}
			case PopToRootAndReplace(id, inject, transition):
				{
					navigator.popToRootItemAndReplace(id, inject, transition);
				}
			case Listener(fn):
				{
					fn(event);
				}
			case NewAction(fn):
				{
					return fn(event);
				}
		}
		return null;
	}

	private function createActionEventListener(action:StackAction, navigator:StackNavigator):(Event) -> Void {
		var eventListener = function(event:Event):Void {
			var current = action;
			while (current != null) {
				current = performAction(current, event, navigator);
			}
		};
		return eventListener;
	}

	private function removeEventsFromView(view:DisplayObject, viewListeners:Array<ViewListener>):Void {
		for (viewListener in viewListeners) {
			view.removeEventListener(viewListener.eventType, viewListener.listener);
		}
	}
}

private class ViewListener {
	public function new(eventType:String, listener:(Event) -> Void) {
		this.eventType = eventType;
		this.listener = listener;
	}

	public var eventType:String;
	public var listener:(Event) -> Void;
}
