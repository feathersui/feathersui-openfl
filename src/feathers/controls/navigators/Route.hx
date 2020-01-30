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
	An individual item that will be displayed by a `RouterNavigator` component.
	Provides the URL path, the view, and an optional list of events to map to
	actions (like navigate) on the `RouterNavigator`.

	@see [Tutorial: How to use the RouterNavigator component](https://feathersui.com/learn/haxe-openfl/router-navigator/)
	@see `feathers.controls.RouterNavigator`

	@since 1.0.0
**/
class Route {
	/**
		Creates a `Route` that instantiates a view from a class that extends
		`DisplayObject` when the `RouterNavigator` requests the item's view.
	**/
	public static function withClass(path:String, viewClass:Class<DisplayObject>, ?actions:Map<String, RouterAction>):Route {
		var item = new Route();
		item.path = path;
		item.viewClass = viewClass;
		item.actions = actions;
		return item;
	}

	/**
		Creates a `Route` that calls a function that returns a
		`DisplayObject` when the `RouterNavigator` requests the item's view.
	**/
	public static function withFunction(path:String, viewFunction:() -> DisplayObject, ?actions:Map<String, RouterAction>):Route {
		var item = new Route();
		item.path = path;
		item.viewFunction = viewFunction;
		item.actions = actions;
		return item;
	}

	/**
		Creates a `Route` that always returns the same `DisplayObject`
		instance when the `RouterNavigator` requests the item's view.
	**/
	public static function withDisplayObject(path:String, viewInstance:DisplayObject, ?actions:Map<String, RouterAction>):Route {
		var item = new Route();
		item.path = path;
		item.viewInstance = viewInstance;
		item.actions = actions;
		return item;
	}

	private function new() {}

	/**
		The URL path associated with this route.

		@since 1.0.0
	**/
	public var path:String;

	private var viewClass:Class<DisplayObject>;
	private var viewFunction:() -> DisplayObject;
	private var viewInstance:DisplayObject;
	private var actions:Map<String, RouterAction>;

	private var _viewToEvents:Map<DisplayObject, Array<ViewListener>> = [];

	/**
		Sets a new action to perform when the view dispatches an event. If the
		action is `null`, removes an action that was set previously.

		@since 1.0.0
	**/
	public function setAction(eventType:String, action:RouterAction):Void {
		if (this.actions == null) {
			this.actions = [];
		}
		if (action == null) {
			this.actions.remove(eventType);
		} else {
			this.actions.set(eventType, action);
		}
	}

	// called internally by RouterNavigator to get this item's view
	private function getView(navigator:RouterNavigator):DisplayObject {
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

	// called internally by RouterNavigator to clean up this item's view
	private function returnView(view:DisplayObject):Void {
		var viewListeners:Array<ViewListener> = this._viewToEvents.get(view);
		this.removeEventsFromView(view, viewListeners);
		this._viewToEvents.remove(view);
	}

	private function addActionListeners(view:DisplayObject, navigator:RouterNavigator):Array<ViewListener> {
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

	private function performAction(action:RouterAction, event:Event, navigator:RouterNavigator):RouterAction {
		switch (action) {
			case Push(url, state, transition):
				{
					navigator.push(url, state, transition);
				}
			case Replace(url, state, transition):
				{
					navigator.replace(url, state, transition);
				}
			case Go(n, transition):
				{
					navigator.go(n);
				}
			case GoBack(transition):
				{
					navigator.goBack(transition);
				}
			case GoForward(transition):
				{
					navigator.goForward(transition);
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

	private function createActionEventListener(action:RouterAction, navigator:RouterNavigator):(Event) -> Void {
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
