/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.data.RouteState;
import openfl.display.DisplayObject;
import openfl.events.Event;

/**
	An individual item that will be displayed by a `RouterNavigator` component.
	Provides the URL path pattern, the view, and an optional list of events to
	map to actions (like push or pop navigation) performed by the
	`RouterNavigator`.

	To determine which `Route` to use, the `RouterNavigator` matches the current
	URL against the path patterns defined by the `Route` objects.

	Path patterns must start with a forward slash `/` character. Do not include
	the host/domain part of the URL.

	Path patterns support _named parameters_ that start with a `:` colon
	character. For example, the path pattern `/:foo/:bar` has named parameters
	with the names "foo" and "bar". If the display object returned by the `Route` implements
	the `IRouteView` interface, the name parameters are passsed to the view
	for additional parsing.

	Named parameters may be made optional by appending a `?` question mark
	character. For example, the "foo" parameter is optional in the path pattern
	`/baz/:foo?`, and it will also match "/baz" without the parameter.

	If the path pattern is `null` or an empty string, it will always match.

	If the `RouterNavigator` defines a `basePath`, path patterns should not
	include the base path. It will be handled automatically.

	@see [Tutorial: How to use the RouterNavigator component](https://feathersui.com/learn/haxe-openfl/router-navigator/)
	@see `feathers.controls.RouterNavigator`

	@since 1.0.0
**/
class Route {
	/**
		Creates a `Route` that instantiates a view from a class that extends
		`DisplayObject` when the `RouterNavigator` requests the item's view.
	**/
	public static function withClass<T:DisplayObject>(path:String, viewClass:Class<T>, ?actions:Map<String, RouterAction>,
			?updateState:(view:T, state:RouteState) -> Void, ?saveData:(view:T) -> Dynamic, ?restoreData:(view:T, data:Dynamic) -> Void):Route {
		var item = new Route();
		item.path = path;
		item.viewClass = cast viewClass;
		item.actions = actions;
		item.updateState = updateState;
		item.saveData = saveData;
		item.restoreData = restoreData;
		return item;
	}

	/**
		Creates a `Route` that calls a function that returns a
		`DisplayObject` when the `RouterNavigator` requests the item's view.
	**/
	public static function withFunction<T:DisplayObject>(path:String, viewFunction:() -> T, ?actions:Map<String, RouterAction>,
			?updateState:(view:T, state:RouteState) -> Void, ?saveData:(view:T) -> Dynamic, ?restoreData:(view:T, data:Dynamic) -> Void):Route {
		var item = new Route();
		item.path = path;
		item.viewFunction = viewFunction;
		item.actions = actions;
		item.updateState = updateState;
		item.saveData = saveData;
		item.restoreData = restoreData;
		return item;
	}

	/**
		Creates a `Route` that always returns the same `DisplayObject`
		instance when the `RouterNavigator` requests the item's view.
	**/
	public static function withDisplayObject<T:DisplayObject>(path:String, viewInstance:T, ?actions:Map<String, RouterAction>,
			?updateState:(view:T, state:RouteState) -> Void, ?saveData:(view:T) -> Dynamic, ?restoreData:(view:T, data:Dynamic) -> Void):Route {
		var item = new Route();
		item.path = path;
		item.viewInstance = viewInstance;
		item.actions = actions;
		item.updateState = updateState;
		item.saveData = saveData;
		item.restoreData = restoreData;
		return item;
	}

	private function new() {}

	/**
		The URL path associated with this route.

		@since 1.0.0
	**/
	public var path:String;

	/**
		An optional function to parse the current history state when a view is
		shown.

		This function must be able to handle `null` state.

		@since 1.0.0
	**/
	@:deprecated('Route.injectState is deprecated. Use Route.updateState() and RouteState.historyState instead.')
	public dynamic function injectState(view:Dynamic, routeState:RouteState):Void {}

	/**
		An optional function to customize the view before it is shown.

		@since 1.0.0
	**/
	public dynamic function updateState(view:Dynamic, routeState:RouteState):Void {}

	/**
		An optional function to save the view's data before navigating away.

		@since 1.0.0
	**/
	public dynamic function saveData(view:Dynamic):Dynamic {
		return null;
	}

	/**
		An optional function to restore the view's data before navigating away.

		This function must be able to handle `null` data.

		@since 1.0.0
	**/
	@:deprecated('Route.restoreData is deprecated. Use Route.updateState() and RouteState.data instead.')
	public dynamic function restoreData(view:Dynamic, data:Dynamic):Void {}

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
			case Push(url, newHistoryState, transition):
				{
					navigator.push(url, newHistoryState, transition);
				}
			case Replace(url, newHistoryState, transition):
				{
					navigator.replace(url, newHistoryState, transition);
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
