/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.ui.Keyboard;
import feathers.events.FeathersEvent;
import feathers.motion.effects.IEffectContext;
import lime.ui.KeyCode;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
#if html5
import js.Lib;
import js.html.Window;
#end

/**
	Integrates with the HTML5 history API to allow navigation between views,
	including support for the browser's native back and forward buttons.

	This component is designed for use in web browsers, but provides a decent
	implementation for native apps. Ideally, native apps should use
	`StackNavigator` instead, as it provides more advanced navigation
	capabilities that are impossible to integrate with the HTML5 history API.

	@see [Tutorial: How to use the RouterNavigator component](https://feathersui.com/learn/haxe-openfl/router-navigator/)
	@see `feathers.controls.navigators.Route`
	@see `feathers.controls.navigators.RouterAction`
	@see `feathers.controls.navigators.RouterNavigator`

	@since 1.0.0
**/
@:access(feathers.controls.navigators.Route)
@:styleContext
class RouterNavigator extends BaseNavigator {
	/**
		Creates a new `RouterNavigator` object.

		@since 1.0.0
	**/
	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, routerNavigator_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, routerNavigator_removedFromStageHandler);
	}

	#if html5
	private var htmlWindow:Window;
	#else
	private var _history:Array<String> = [];
	#end

	/**
		Adds a route to the navigator.

		The following example adds a new route for the "/settings" URL path:

		```hx
		var route = Route.withClass("/settings", SettingsView);
		navigator.addRoute(route);
		```

		@since 1.0.0
	**/
	public function addRoute(route:Route):Void {
		this.addItemInternal(route.path, route);
		if (this.stage != null) {
			var matched = this.matchRoute();
			if (matched == route) {
				this.navigateInternal(false, matched.path);
			}
		}
	}

	/**
		Navigates to the specified URL path. The route to display will be
		determined automatically.

		The following example navigates to the "/settings" URL path:

		```hx
		navigator.navigate("/settings");
		```

		@see `feathers.controls.navigators.Route.path`

		@since 1.0.0
	**/
	public function navigate(path:String):DisplayObject {
		return this.navigateInternal(true, path);
	}

	private function matchRoute():Route {
		#if html5
		var pathname = this.htmlWindow.location.pathname;
		#else
		var pathname = "/";
		if (this._history.length > 0) {
			pathname = this._history[this._history.length - 1];
		}
		#end
		for (path => route in this._addedItems) {
			if (pathname == path) {
				return cast(route, Route);
			}
			if (path == "*") {
				return cast(route, Route);
			}
		}
		return null;
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), Route);
		return item.getView(this);
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		var item = cast(this._addedItems.get(id), Route);
		item.returnView(view);
	}

	private function navigateInternal(useNativeHistory:Bool, path:String):DisplayObject {
		if (useNativeHistory) {
			#if html5
			this.htmlWindow.history.pushState(null, null, path);
			#else
			this._history.push(path);
			#end
		}
		return this.showItemInternal(path, null);
	}

	private function routerNavigator_addedToStageHandler(event:Event):Void {
		#if html5
		this.htmlWindow = cast(Lib.global, js.html.Window);
		this.htmlWindow.addEventListener("popstate", htmlWindow_popstateHandler);
		#else
		this.stage.addEventListener(KeyboardEvent.KEY_UP, routerNavigator_stage_keyUpHandler, false, 0, true);
		#end
		var matched = this.matchRoute();
		if (matched != null) {
			this.navigateInternal(false, matched.path);
		}
	}

	private function routerNavigator_removedFromStageHandler(event:Event):Void {
		#if html5
		if (this.htmlWindow != null) {
			this.htmlWindow.removeEventListener("popstate", htmlWindow_popstateHandler);
			this.htmlWindow = null;
		}
		#else
		this.stage.removeEventListener(KeyboardEvent.KEY_UP, routerNavigator_stage_keyUpHandler);
		#end
	}

	#if html5
	private function htmlWindow_popstateHandler(event:js.html.PopStateEvent):Void {
		event.preventDefault();
		var matched = this.matchRoute();
		if (matched != null) {
			this.navigateInternal(false, matched.path);
		}
	}
	#else
	private function routerNavigator_stage_keyUpHandler(event:KeyboardEvent):Void {
		if (!this.enabled) {
			return;
		}
		switch (event.keyCode) {
			#if flash
			case Keyboard.BACK:
				{
					this.routerNavigator_stage_backKeyUpHandler(event);
				}
			#end
			case KeyCode.APP_CONTROL_BACK:
				{
					this.routerNavigator_stage_backKeyUpHandler(event);
				}
		}
	}

	private function routerNavigator_stage_backKeyUpHandler(event:Event):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._history.length < 1) {
			// can't go back
			return;
		}
		event.preventDefault();
		this._history.pop();
		var matched = this.matchRoute();
		if (matched != null) {
			this.navigateInternal(false, matched.path);
		}
	}
	#end
}
