/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import feathers.motion.effects.IEffectContext;
import openfl.display.DisplayObject;
import openfl.events.Event;

/**
	Events dispatched by the active view in `RouterNavigator` may trigger
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
	Push(url:String, ?state:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Navigate to a new item that replaces the current item in the history stack.

		@since 1.0.0
	**/
	Replace(url:String, ?state:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Navigate to the previous item on the history stack.

		@since 1.0.0
	**/
	GoBack(?transition:(DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Navigate to the next item on the history stack.

		@since 1.0.0
	**/
	GoForward(?transition:(DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Navigate to back or forward by _n_ entries in the history stack.

		@since 1.0.0
	**/
	Go(n:Int, ?transition:(DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Call an event listener. Does not navigate to a different view.

		@since 1.0.0
	**/
	Listener<E:Event>(callback : (E) -> Void);

	/**
		Call a function that creates a new action. The new action will be
		triggered instead.

		@since 1.0.0
	**/
	NewAction<E:Event>(callback : (E) -> RouterAction);

}
