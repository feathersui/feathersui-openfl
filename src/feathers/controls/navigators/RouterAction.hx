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
	Link(url:String);

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
