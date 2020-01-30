/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.events.Event;
import openfl.display.DisplayObject;
import feathers.motion.effects.IEffectContext;

/**
	Events dispatched by the active view in `StackNavigator` may trigger
	actions, such as navigation.

	@see `feathers.controls.navigators.StackNavigator`
	@see `feathers.controls.navigators.StackItem`

	@since 1.0.0
**/
enum StackAction {
	/**
		Navigate to a new item that is added to the history stack.

		@since 1.0.0
	**/
	Push<T:DisplayObject>(id : String, ?inject : (T) -> Void, ?transition : (DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Replace the navigator's active view with a different view.

		@since 1.0.0
	**/
	Replace<T:DisplayObject>(id : String, ?inject : (T) -> Void, ?transition : (DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Pop the active view and navigate to the previous item in the history
		stack.

		@since 1.0.0
	**/
	Pop(?returnedObject:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Pop all items from the history stack, except for the first item.

		@since 1.0.0
	**/
	PopToRoot(?returnedObject:Dynamic, ?transition:(DisplayObject, DisplayObject) -> IEffectContext);

	/**
		Pop all items from the history stack, except for the first item, but
		replace the first item with a different item.

		@since 1.0.0
	**/
	PopToRootAndReplace<T:DisplayObject>(id : String, ?inject : (T) -> Void, ?transition : (DisplayObject, DisplayObject) -> IEffectContext);

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
	NewAction<E:Event>(callback : (E) -> StackAction);

}
