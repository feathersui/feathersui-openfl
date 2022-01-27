/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.net.URLVariables;

/**
	Represents the current state of a `RouterNavigator` view.

	@see `feathers.controls.RouterNavigator`

	@since 1.0.0
**/
class RouteState {
	/**
		Creates a new `RouteState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(pattern:String = null, pathname:String = null, params:Map<String, String> = null, historyState:Dynamic = null, data:Dynamic = null) {
		this.pattern = pattern;
		this.pathname = pathname;
		this.params = params;
		this.historyState = historyState;
		this.data = data;
	}

	/**
		The pattern used to match this route.

		@since 1.0.0
	**/
	public var pattern:String;

	/**
		The portion of the URL that matched the `pattern`.

		@since 1.0.0
	**/
	public var pathname:String;

	/**
		A set of key/value pairs parsed from the current URL using the dynamic
		segments of the `pattern`.

		@since 1.0.0
	**/
	public var params:Map<String, String>;

	/**
		Returns an `URLVariables` object constructed from the current query
		parameters.

		If the query parameters cannot be parsed by `URLVariables`, returns an
		empty `URLVariables` object.

		@since 1.0.0
	**/
	public var urlVariables:URLVariables;

	/**
		The state data restored from the HTML history API.

		@since 1.0.0
	**/
	public var historyState:Dynamic;

	/**
		Data to restore that was saved with `Route.saveData()`.

		@since 1.0.0
	**/
	public var data:Dynamic;
}
