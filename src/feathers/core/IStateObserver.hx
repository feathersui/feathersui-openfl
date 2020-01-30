/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	Watches an `IStateContext` for state changes

	@since 1.0.0

	@see `feathers.core.IStateContext`
**/
interface IStateObserver {
	/**
		The current state context that is being observed.

		@since 1.0.0
	**/
	public var stateContext(default, set):IStateContext<Dynamic>;
}
