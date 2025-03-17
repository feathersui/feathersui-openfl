/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.IEventDispatcher;

/**
	An object with multiple states.

	@event feathers.events.FeathersEvent.STATE_CHANGE Dispatched when
	`IStateContext.currentState` changes

	@since 1.0.0
**/
interface IStateContext<T> extends IEventDispatcher {
	/**
		The object's current state.

		@since 1.0.0
	**/
	public var currentState(get, never):#if flash Dynamic #else T #end;
}
