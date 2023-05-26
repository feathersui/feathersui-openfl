/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.data.RouteState;
import feathers.motion.effects.IEffectContext;
import feathers.utils.Path2EReg;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.net.URLVariables;
#if html5
import js.Lib;
import js.html.Window;
#else
#if lime
import lime.ui.KeyCode;
#end
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
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
		initializeRouterNavigatorTheme();
		super();
		#if !html5
		if (this._history.length == 0) {
			this._history.push(new HistoryItem(new Location("/"), {state: null, viewData: null}));
		}
		#end
		this.addEventListener(Event.ADDED_TO_STAGE, routerNavigator_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, routerNavigator_removedFromStageHandler);
	}

	#if html5
	private var htmlWindow:Window;
	private var historyDepth:Int = 0;
	#else
	private var _history:Array<HistoryItem> = [];
	private var _forwardHistory:Array<HistoryItem> = [];
	#end

	/**
		The base URL path where the project will be deployed.

		For example, if your project will be deployed to
		`https://www.example.com/my-project/`, the base path will be
		`/my-project`.

		@since 1.0.0
	**/
	public var basePath:String = null;

	/**
		The default transition to use for forward navigation actions.

		@see `StackNavigator.backTransition`

		@since 1.0.0
	**/
	@:style
	public var forwardTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	/**
		The default transition to use for back navigation actions.

		@see `StackNavigator.forwardTransition`

		@since 1.0.0
	**/
	@:style
	public var backTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	/**
		The default transition to use for replace navigation actions.

		@since 1.0.0
	**/
	@:style
	public var replaceTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	private var _savedGoTransition:(DisplayObject, DisplayObject) -> IEffectContext = null;

	private var _preferHashRouting:Bool = false;

	/**
		Indicates if hash routing should be preferred for the default pathname
		routing.

		This property is used only on HTML/JS targets, and is ignored on other
		targets.

		@since 1.0.0
	**/
	public var preferHashRouting(get, set):Bool;

	private function get_preferHashRouting():Bool {
		return this._preferHashRouting;
	}

	private function set_preferHashRouting(value:Bool):Bool {
		if (this._preferHashRouting == value) {
			return this._preferHashRouting;
		}
		if (this._activeItemView != null) {
			throw new ArgumentError("Must set preferHashRouting before a view is displayed");
		}
		this._preferHashRouting = value;
		return this._preferHashRouting;
	}

	private function initializeRouterNavigatorTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelRouterNavigatorStyles.initialize();
		#end
	}

	/**
		Adds a route to the navigator.

		The following example adds a new route for the "/settings" URL path:

		```haxe
		var route = Route.withClass("/settings", SettingsView);
		navigator.addRoute(route);
		```

		@since 1.0.0
	**/
	public function addRoute(route:Route):Void {
		if (route.path == null) {
			route.path = "";
		}
		this.addItemInternal(route.path, route);
		if (this.stage != null && this.activeItemView == null) {
			var matched = this.matchRoute();
			if (matched == route) {
				if (route.redirectTo != null) {
					this.redirect(route);
				} else {
					this.showItemInternal(matched.path, null);
				}
			}
		}
	}

	/**
		Pushes a new entry onto the history stack. The route to display will be
		determined automatically.

		The following example navigates to the "/settings" URL path:

		```haxe
		navigator.push("/settings");
		```

		@see `feathers.controls.navigators.Route.path`

		@since 1.0.0
	**/
	public function push(path:String, ?newHistoryState:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (this._activeItemView != null) {
			var viewData:Dynamic = null;
			var oldItem = this._addedItems.get(this._activeItemID);
			if (oldItem.saveData != null) {
				viewData = oldItem.saveData(this._activeItemView);
			}
			#if html5
			var historyState:HistoryState = this.htmlWindow.history.state;
			if (historyState == null) {
				historyState = {depth: this.historyDepth, state: null, viewData: viewData};
			} else {
				historyState.viewData = viewData;
			}
			var oldPathname = this.getPathname();
			var oldURL = oldPathname + location.search;
			if (this.basePath != null && !StringTools.startsWith(oldPathname, this.basePath + "/")) {
				var needsSlash = !StringTools.startsWith(oldPathname, "/");
				oldPathname = this.basePath + (needsSlash ? "/" : "") + oldPathname;
				oldURL = oldPathname + location.search;
			}
			if (this._preferHashRouting || this.htmlWindow.location.protocol == "file:") {
				oldURL = this.htmlWindow.location.pathname + location.search + "#" + oldPathname;
			}
			this.htmlWindow.history.replaceState(historyState, null, oldURL);
			#else
			var historyItem = this._history[this._history.length - 1];
			var location = historyItem.location;
			var historyState = historyItem.state;
			if (historyState == null) {
				historyState = {state: null, viewData: viewData};
			} else {
				historyState.viewData = viewData;
			}
			this._history[this._history.length - 1] = new HistoryItem(location, historyState);
			#end
		}
		#if html5
		var newPathParts = path.split("?");
		var newPathname = newPathParts[0];
		var newSearch = "";
		if (newPathParts.length > 1) {
			newSearch = "?" + newPathParts[1];
		}
		var newURL = newPathname + newSearch;
		if (this.basePath != null && !StringTools.startsWith(newPathname, this.basePath + "/")) {
			var needsSlash = !StringTools.startsWith(newPathname, "/");
			newPathname = this.basePath + (needsSlash ? "/" : "") + newPathname;
			newURL = newPathname + newSearch;
		}
		if (this._preferHashRouting || this.htmlWindow.location.protocol == "file:") {
			newURL = this.htmlWindow.location.pathname + newSearch + "#" + newPathname;
		}
		this.historyDepth++;
		this.htmlWindow.history.pushState({
			depth: this.historyDepth,
			state: newHistoryState,
			viewData: null
		}, null, newURL);
		#else
		this._history.push(new HistoryItem(Location.fromString(path), {
			state: newHistoryState,
			viewData: null
		}));
		#if hl
		this._forwardHistory.splice(0, this._forwardHistory.length);
		#else
		this._forwardHistory.resize(0);
		#end
		#end
		if (transition == null) {
			transition = this.forwardTransition;
		}
		return this.matchRouteAndShow(transition);
	}

	/**
		Replaces the current entry onto the history stack. The route to display
		will be determined automatically.

		The following example navigates to the "/settings" URL path without
		adding a new history entry:

		```haxe
		navigator.replace("/settings");
		```

		@see `feathers.controls.navigators.Route.path`

		@since 1.0.0
	**/
	public function replace(path:String, ?newHistoryState:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		#if html5
		var newPathParts = path.split("?");
		var newPathname = newPathParts[0];
		var newSearch = "";
		if (newPathParts.length > 1) {
			newSearch = "?" + newPathParts[1];
		}
		var newURL = newPathname + newSearch;
		if (this.basePath != null && !StringTools.startsWith(newPathname, this.basePath + "/")) {
			var needsSlash = !StringTools.startsWith(newPathname, "/");
			newPathname = this.basePath + (needsSlash ? "/" : "") + newPathname;
			newURL = newPathname + newSearch;
		}
		if (this._preferHashRouting || this.htmlWindow.location.protocol == "file:") {
			newURL = this.htmlWindow.location.pathname + newSearch + "#" + newPathname;
		}
		this.htmlWindow.history.replaceState({
			depth: this.historyDepth,
			state: newHistoryState,
			viewData: null
		}, null, newURL);
		#else
		this._history[this._history.length - 1] = new HistoryItem(Location.fromString(path), {
			state: newHistoryState,
			viewData: null
		});
		#if hl
		this._forwardHistory.splice(0, this._forwardHistory.length);
		#else
		this._forwardHistory.resize(0);
		#end
		#end
		if (transition == null) {
			transition = this.replaceTransition;
		}
		return this.matchRouteAndShow(transition);
	}

	/**
		Moves the pointer in the history stack by _n_ entries.

		The following examples goes back 2 entries in the history stack.

		```haxe
		navigator.go(-2);
		```

		@since 1.0.0
	**/
	public function go(n:Int, ?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		if (n == 0) {
			return this.activeItemView;
		}
		#if !html5
		if (n < 0 && this._history.length == 1) {
			// can't go any further back
			return this.activeItemView;
		}
		#end
		if (transition == null) {
			transition = (n < 0) ? this.backTransition : this.forwardTransition;
		}
		#if html5
		this._savedGoTransition = transition;
		this.htmlWindow.history.go(n);
		// the view is not restored until popstate is dispatched
		return null;
		#else
		if (n > 0) {
			for (i in 0...Std.int(Math.min(n, this._forwardHistory.length))) {
				var item = this._forwardHistory.shift();
				this._history.push(item);
			}
		} else {
			for (i in 0...Std.int(Math.min(-n, this._history.length - 1))) {
				var item = this._history.pop();
				this._forwardHistory.unshift(item);
			}
		}
		return this.matchRouteAndShow(transition);
		#end
	}

	/**
		Navigates to the previous item on the history stack.

		The following examples goes back in history by 1 entry.

		```haxe
		navigator.goBack();
		```

		@since 1.0.0
	**/
	public function goBack(?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		return this.go(-1, transition);
	}

	/**
		Navigates to the next item on the history stack.

		The following examples goes forward in history by 1 entry.

		```haxe
		navigator.goForward();
		```

		@since 1.0.0
	**/
	public function goForward(?transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		return this.go(1, transition);
	}

	private function routerNavigator_addedToStageHandler(event:Event):Void {
		#if html5
		this.htmlWindow = cast(Lib.global, js.html.Window);
		this.htmlWindow.addEventListener("popstate", htmlWindow_popstateHandler);
		#else
		this.stage.addEventListener(KeyboardEvent.KEY_UP, routerNavigator_stage_keyUpHandler, false, 0, true);
		#end
		this.matchRouteAndShow(null);
	}

	/**
		Returns the current location.

		@since 1.0.0
	**/
	public var location(get, never):#if html5 js.html.Location #else Location #end;

	private function get_location():#if html5 js.html.Location #else Location #end {
		#if html5
		return this.htmlWindow.location;
		#else
		return this._history[this._history.length - 1].location;
		#end
	}

	/**
		Returns the current pathname. If a `basePath` is defined, it will not be
		included in the returned value.

		@since 1.0.0
	**/
	public var pathname(get, never):String;

	private function get_pathname():String {
		return this.getPathname();
	}

	private var _cachedPaths:Map<String, {
		ereg:EReg,
		keys:Array<Key>
	}> = [];

	private function getURLVariables():URLVariables {
		var search = location.search;
		if (search.length > 0) {
			search = search.substr(1);
		}
		try {
			return new URLVariables(search);
		} catch (e:Dynamic) {
			return new URLVariables();
		}
	}

	private function getPathname():String {
		var pathname:String = null;
		#if html5
		if (this._preferHashRouting || this.htmlWindow.location.protocol == "file:") {
			pathname = this.htmlWindow.location.hash;
			if (pathname.length == 0) {
				pathname = "/";
			} else {
				pathname = pathname.substr(1);
			}
		} else {
			pathname = this.htmlWindow.location.pathname;
		}
		if (this.basePath != null && StringTools.startsWith(pathname, this.basePath + "/")) {
			pathname = pathname.substr(this.basePath.length);
		}
		#else
		if (this._history.length > 0) {
			var item = this._history[this._history.length - 1];
			pathname = item.location.pathname;
		}
		#end
		return pathname;
	}

	private function redirect(route:Route):Void {
		var newURL = route.redirectTo;

		var itemPath = route.path;
		var params:Map<String, String> = [];
		if (itemPath != null && itemPath.length > 0) {
			var matcher = getMatcher(itemPath);
			for (i in 0...matcher.keys.length) {
				var key = matcher.keys[i];
				params.set(key.name, matcher.ereg.matched(i + 1));
			}
		}

		for (name => value in params) {
			newURL = StringTools.replace(newURL, ":name", value);
		}

		this.replace(newURL);
	}

	private function getMatcher(path:String):{
		ereg:EReg,
		keys:Array<Key>
	} {
		var matcher = this._cachedPaths.get(path);
		if (matcher == null) {
			matcher = feathers.utils.Path2EReg.toEReg(path, {
				end: true
			});
			this._cachedPaths.set(path, matcher);
		}
		return matcher;
	}

	private function matchRoute():Route {
		var pathname = this.getPathname();
		// order matters, so loop through the ids array
		for (path in this._addedItemIDs) {
			if (path == null || path.length == 0) {
				// always match
				return this._addedItems.get(path);
			}
			var matcher = getMatcher(path);
			if (matcher.ereg.match(pathname)) {
				return this._addedItems.get(path);
			}
		}
		return null;
	}

	private function matchRouteAndShow(transition:(DisplayObject, DisplayObject) -> IEffectContext):DisplayObject {
		var matched = this.matchRoute();
		if (matched != null) {
			if (matched.redirectTo != null) {
				this.redirect(matched);
				return null;
			}
			return this.showItemInternal(matched.path, transition);
		}
		this.clearActiveItemInternal(null);
		return null;
	}

	override private function getView(id:String):DisplayObject {
		var item = cast(this._addedItems.get(id), Route);
		var itemPath = item.path;
		var params:Map<String, String> = [];
		if (itemPath != null && itemPath.length > 0) {
			var matcher = getMatcher(itemPath);
			for (i in 0...matcher.keys.length) {
				var key = matcher.keys[i];
				params.set(key.name, matcher.ereg.matched(i + 1));
			}
		}
		var routeState = new RouteState(item.path, this.getPathname(), params);
		var view = item.getView(this);
		#if html5
		var historyState:HistoryState = this.htmlWindow.history.state;
		#else
		var historyItem = this._history[this._history.length - 1];
		var historyState = historyItem.state;
		#end
		routeState.historyState = (historyState != null) ? historyState.state : null;
		routeState.data = (historyState != null) ? historyState.viewData : null;
		routeState.urlVariables = this.getURLVariables();
		if (item.updateState != null) {
			item.updateState(view, routeState);
		}
		view.addEventListener(TextEvent.LINK, routerNavigator_activeView_linkHandler);
		return view;
	}

	override private function disposeView(id:String, view:DisplayObject):Void {
		view.removeEventListener(TextEvent.LINK, routerNavigator_activeView_linkHandler);
		var item = cast(this._addedItems.get(id), Route);
		item.returnView(view);
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

	private function routerNavigator_activeView_linkHandler(event:TextEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (!StringTools.startsWith(event.text, "router:")) {
			return;
		}
		event.preventDefault();
		var url = event.text.substr(7);
		this.push(url);
	}

	#if html5
	private function htmlWindow_popstateHandler(event:js.html.PopStateEvent):Void {
		event.preventDefault();
		var newDepth = this.historyDepth;
		var historyState:HistoryState = this.htmlWindow.history.state;
		if (historyState != null && historyState.depth != null) {
			newDepth = historyState.depth;
		}
		var transition = this._savedGoTransition;
		this._savedGoTransition = null;
		if (this._activeItemView != null && transition == null) {
			if (this.historyDepth > newDepth) {
				transition = this.backTransition;
			} else if (this.historyDepth < newDepth) {
				transition = this.forwardTransition;
			}
		}
		this.historyDepth = newDepth;
		this.matchRouteAndShow(transition);
	}
	#else
	private function routerNavigator_stage_keyUpHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		switch (event.keyCode) {
			#if flash
			case Keyboard.BACK:
				{
					this.routerNavigator_stage_backKeyUpHandler(event);
				}
			#end
			#if lime
			case KeyCode.APP_CONTROL_BACK:
				{
					this.routerNavigator_stage_backKeyUpHandler(event);
				}
			#end
		}
	}

	private function routerNavigator_stage_backKeyUpHandler(event:Event):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._history.length <= 1) {
			// can't go back
			return;
		}
		event.preventDefault();
		var item = this._history.pop();
		this._forwardHistory.unshift(item);
		this.matchRouteAndShow(this.backTransition);
	}
	#end
}

typedef HistoryState = {
	#if html5
	depth:Int,
	#end
	state:Any,
	viewData:Any
};

#if !html5
private class HistoryItem {
	public function new(location:Location, state:HistoryState) {
		this.location = location;
		this.state = state;
	}

	public var location:Location;
	public var state:HistoryState;
}

/**
	Used by all targets except html5 to represent the current location.

	@since 1.0.0
**/
class Location {
	/**
		Creates a `Location` object from a URL.

		@since 1.0.0
	**/
	public static function fromString(value:String):Location {
		var pathname = value;
		var search = "";
		var hash = "";
		var splitWithHash = pathname.split("#");
		pathname = splitWithHash[0];
		if (splitWithHash.length > 1) {
			hash = "#" + splitWithHash[1];
		}
		var splitWithSearch = pathname.split("?");
		pathname = splitWithSearch[0];
		if (splitWithSearch.length > 1) {
			search = "?" + splitWithSearch[1];
		}
		return new Location(pathname, search, hash);
	}

	/**
		Creates a new `Location` object.

		@since 1.0.0
	**/
	public function new(pathname:String, search:String = "", hash:String = "") {
		this._pathname = pathname;
		this._search = search;
		this._hash = hash;
	}

	private var _protocol:String = "file:";

	/**
		@see https://api.haxe.org/js/html/Location.html#protocol
	**/
	public var protocol(get, never):String;

	public function get_protocol():String {
		return this._protocol;
	}

	private var _hostname:String = "";

	/**
		@see https://api.haxe.org/js/html/Location.html#hostname
	**/
	public var hostname(get, never):String;

	public function get_hostname():String {
		return this._hostname;
	}

	/**
		@see https://api.haxe.org/js/html/Location.html#host
	**/
	public var host(get, never):String;

	public function get_host():String {
		if (this._hostname.length > 0 && this._port.length > 0) {
			return this._hostname + ":" + this._port;
		}
		return this._hostname;
	}

	private var _port:String = "";

	/**
		@see https://api.haxe.org/js/html/Location.html#port
	**/
	public var port(get, never):String;

	public function get_port():String {
		return this._port;
	}

	/**
		@see https://api.haxe.org/js/html/Location.html#origin
	**/
	public var origin(get, never):String;

	public function get_origin():String {
		return this._protocol + "//" + this.host;
	}

	private var _pathname:String = "/";

	/**
		@see https://api.haxe.org/js/html/Location.html#pathname
	**/
	public var pathname(get, never):String;

	public function get_pathname():String {
		return this._pathname;
	}

	private var _search:String = "";

	/**
		@see https://api.haxe.org/js/html/Location.html#search
	**/
	public var search(get, never):String;

	public function get_search():String {
		return this._search;
	}

	private var _hash:String = "";

	/**
		@see https://api.haxe.org/js/html/Location.html#hash
	**/
	public var hash(get, never):String;

	public function get_hash():String {
		return this._hash;
	}

	/**
		@see https://api.haxe.org/js/html/Location.html#href
	**/
	public var href(get, never):String;

	public function get_href():String {
		return this.origin + this.pathname + this.search + this.hash;
	}

	@:dox(hide)
	public function toString():String {
		return this.href;
	}
}
#end
