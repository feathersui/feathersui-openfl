/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.events.Event;
import feathers.motion.effects.IEffectContext;
import openfl.display.DisplayObject;

/**
	An individual item that will be displayed by a `StackNavigator` component.
	Provides the view, an optional list of properties to set, and an optional
	list of events to map to actions (like push, pop, and replace) on the
	`StackNavigator`.

	The following example creates a new `StackNavigatorItem` using the
	`SettingsView` class to instantiate the view instance. When the view is
	shown, its `settings` property will be set. When the view instance
	dispatches the `SettingsView.SHOW_ADVANCED_SETTINGS` event, the
	`StackNavigator` will push an item with the ID `"advancedSettings"` onto its
	history stack. When the view instance dispatches `Event.COMPLETE`, the
	`StackNavigator` will pop the view instance from its history stack and
	return to the previous item.

	```hx
	var item:StackNavigatorItem = new StackNavigatorItem( SettingsScreen );
	item.addProperty("settings", { volume: 0.8, difficulty: "hard" });
	item.setItemIDForPushEvent( SettingsScreen.SHOW_ADVANCED_SETTINGS, "advancedSettings" );
	item.addPopEvent( Event.COMPLETE );
	navigator.addItem( "settings", item );
	```

	@see [How to use the Feathers `StackNavigator` component](../../../help/stack-navigator.html)
	@see `feathers.controls.StackNavigator`

	@since 1.0.0
**/
class StackNavigatorItem {
	/**
		Creates a `StackNavigatorItem` that instantiates a view from a class
		that extends `DisplayObject` when the `StackNavigator` requests the
		item's view.
	**/
	public static function withClass(viewClass:Class<DisplayObject>):StackNavigatorItem {
		var item:StackNavigatorItem = new StackNavigatorItem();
		item.viewClass = viewClass;
		return item;
	}

	/**
		Creates a `StackNavigatorItem` that calls a function that returns a
		`DisplayObject` when the `StackNavigator` requests the item's view.
	**/
	public static function withFunction(viewFunction:Void->DisplayObject):StackNavigatorItem {
		var item:StackNavigatorItem = new StackNavigatorItem();
		item.viewFunction = viewFunction;
		return item;
	}

	/**
		Creates a `StackNavigatorItem` that always returns the same
		`DisplayObject` when the `StackNavigator` requests the item's view.
	**/
	public static function withDisplayObject(viewInstance:DisplayObject):StackNavigatorItem {
		var item:StackNavigatorItem = new StackNavigatorItem();
		item.viewInstance = viewInstance;
		return item;
	}

	private function new() {}

	private var viewClass:Class<DisplayObject>;
	private var viewFunction:Void->DisplayObject;
	private var viewInstance:DisplayObject;

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
		DisplayObject->DisplayObject->IEffectContext</pre>
		```

		Either of the arguments typed as `DisplayObject` may be `null`, but
		never both. The first `DisplayObject` argument will be `null` when the
		first item is displayed or when a new item is displayed after clearing
		the current item. The second `DisplayObject` argument will be null when
		clearing the current item.

		@default `null`

		@see `feathers.controls.StackNavigator.pushTransition`
		@see [Transitions for Feathers navigators](../../../help/transitions.html)

		@since 1.0.0

	**/
	public var pushTransition:DisplayObject->DisplayObject->IEffectContext;

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
		DisplayObject->DisplayObject->IEffectContext</pre>
		```

		Either of the arguments typed as `DisplayObject` may be `null`, but
		never both. The first `DisplayObject` argument will be `null` when the
		first item is displayed or when a new item is displayed after clearing
		the current item. The second `DisplayObject` argument will be null when
		clearing the current item.

		@default `null`

		@see `feathers.controls.StackNavigator.pushTransition`
		@see [Transitions for Feathers navigators](../../../help/transitions.html)

		@since 1.0.0

	**/
	public var popTransition:DisplayObject->DisplayObject->IEffectContext;

	private var _pushEventsToID:Map<String, String>;
	private var _replaceEventsToID:Map<String, String>;
	private var _popEvents:Array<String>;
	private var _viewToEvents:Map<DisplayObject, Array<ViewListener>> = [];
	private var _properties:Map<String, Dynamic>;

	/**
		Specifies another item ID to push on the history stack when an event is
		dispatched by this item's view. The other item should be specified by
		its ID that was registered with a call to `addItem()` on the
		`StackNavigator`.

		If the item is currently the active item displayed by a
		`StackNavigator`, and you call `setPushEvent()` on the
		`StackNavigatorItem`, a listener for the new event won't be added until
		the next time that the item is shown.

		To remove an event added with `setPushEvent()`, call `setPushEvent()`
		again with the same event type and a `null` identifier.

		@since 1.0.0
	**/
	public function setPushEvent(eventType:String, id:String):Void {
		if (this._pushEventsToID == null) {
			this._pushEventsToID = [];
		}
		if (id == null) {
			this._pushEventsToID.remove(id);
		} else {
			this._pushEventsToID.set(eventType, id);
		}
	}

	/**
		Specifies another item ID to push on the history stack when an event is
		dispatched by this item's view. The other item should be specified by
		its ID that was registered with a call to `addItem()` on the
		`StackNavigator`.

		If the item is currently the active item displayed by a
		`StackNavigator`, and you call `setReplaceEvent()` on the
		`StackNavigatorItem`, a listener for the new event won't be added until
		the next time that the item is shown.

		To remove an event added with `setReplaceEvent()`, call
		`setReplaceEvent()` again with the same event type and a `null`
		identifier.

		@since 1.0.0
	**/
	public function setReplaceEvent(eventType:String, id:String):Void {
		if (this._replaceEventsToID == null) {
			this._replaceEventsToID = [];
		}
		if (id == null) {
			this._replaceEventsToID.remove(id);
		} else {
			this._replaceEventsToID.set(eventType, id);
		}
	}

	/**

		@since 1.0.0
	**/
	public function addPopEvent(eventType:String):Void {
		if (this._popEvents == null) {
			this._popEvents = [];
		}
		var index = this._popEvents.indexOf(eventType);
		if (index != -1) {
			return;
		}
		this._popEvents.push(eventType);
	}

	/**

		@since 1.0.0
	**/
	public function removePopEvent(eventType:String):Void {
		if (this._popEvents == null) {
			return;
		}
		this._popEvents.remove(eventType);
	}

	/**
		Optionally sets one or more properties on the item's view before it is
		displayed by the `StackNavigator`.

		@since 1.0.0

		@see `clearProperty()`
	**/
	public function setProperty(fieldName:String, value:Dynamic):Void {
		if (this._properties == null) {
			this._properties = [];
		}
		this._properties.set(fieldName, value);
	}

	/**
		Removes a property set with `setProperty()`.

		@see `setProperty()`

		@since 1.0.0
	**/
	public function clearProperty(fieldName:String):Void {
		if (this._properties == null) {
			return;
		}
		this._properties.remove(fieldName);
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

		if (this._properties != null) {
			for (fieldName in this._properties.keys()) {
				var value = this._properties.get(fieldName);
				Reflect.setField(view, fieldName, value);
			}
		}

		var viewListeners:Array<ViewListener> = [];
		this.addPushEventsToView(view, navigator, viewListeners);
		this.addReplaceEventsToView(view, navigator, viewListeners);
		this.addPopEventsToView(view, navigator, viewListeners);

		this._viewToEvents.set(view, viewListeners);

		return view;
	}

	// called internally by StackNavigator to clean up this item's view
	private function returnView(view:DisplayObject):Void {
		var viewListeners:Array<ViewListener> = this._viewToEvents.get(view);
		this.removeEventsFromView(view, viewListeners);
		this._viewToEvents.remove(view);
	}

	private function addPushEventsToView(view:DisplayObject, navigator:StackNavigator, viewListeners:Array<ViewListener>):Void {
		if (this._pushEventsToID == null) {
			return;
		}
		for (eventType in this._pushEventsToID.keys()) {
			var id = this._pushEventsToID.get(eventType);
			var listener = this.createPushItemEventListener(id, navigator);
			view.addEventListener(eventType, listener);
			viewListeners.push(new ViewListener(eventType, listener));
		}
	}

	private function addPopEventsToView(view:DisplayObject, navigator:StackNavigator, viewListeners:Array<ViewListener>):Void {
		if (this._popEvents == null) {
			return;
		}
		for (eventType in this._popEvents) {
			var listener = this.createPopItemEventListener(navigator);
			view.addEventListener(eventType, listener);
			viewListeners.push(new ViewListener(eventType, listener));
		}
	}

	private function addReplaceEventsToView(view:DisplayObject, navigator:StackNavigator, viewListeners:Array<ViewListener>):Void {
		if (this._replaceEventsToID == null) {
			return;
		}
		for (eventType in this._replaceEventsToID.keys()) {
			var id = this._replaceEventsToID.get(eventType);
			var listener = this.createReplaceItemEventListener(id, navigator);
			view.addEventListener(eventType, listener);
			viewListeners.push(new ViewListener(eventType, listener));
		}
	}

	private function createPushItemEventListener(itemID:String, navigator:StackNavigator):Event->Void {
		var eventListener = function(event:Event):Void {
			navigator.pushItem(itemID);
		};
		return eventListener;
	}

	private function createReplaceItemEventListener(itemID:String, navigator:StackNavigator):Event->Void {
		var eventListener = function(event:Event):Void {
			navigator.replaceItem(itemID);
		};
		return eventListener;
	}

	private function createPopItemEventListener(navigator:StackNavigator):Event->Void {
		var eventListener = function(event:Event):Void {
			navigator.popItem();
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
	public function new(eventType:String, listener:Event->Void) {
		this.eventType = eventType;
		this.listener = listener;
	}

	public var eventType:String;
	public var listener:Event->Void;
}
