/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.events.Event;

/**
	Events dispatched by the active view in `RouterNavigator` may triggered
	actions, such as navigation.

	@see `feathers.controls.navigators.RouterNavigator`
	@see `feathers.controls.navigators.Route`

	@since 1.0.0
**/
enum RouterAction {
	/**
		Navigate to a new item that is added to the history stack.

		@since 1.0.0
	**/
	Push(url:String, ?state:Dynamic);

	/**
		Navigate to a new item that replaces the current item in the history stack.

		@since 1.0.0
	**/
	Replace(url:String, ?state:Dynamic);

	/**
		Navigate to the previous item on the history stack.

		@since 1.0.0
	**/
	GoBack();

	/**
		Navigate to the next item on the history stack.

		@since 1.0.0
	**/
	GoForward();

	/**
		Navigate to back or forward by _n_ entries in the history stack.

		@since 1.0.0
	**/
	Go(n:Int);

	/**
		Call an event listener. Does not navigate to a different view.

		@since 1.0.0
	**/
	Listener(callback:(Event) -> Void);

	/**
		Call a function that creates a new action. The new action will be
		triggered instead.

		@since 1.0.0
	**/
	NewAction(callback:(Event) -> RouterAction);
}
