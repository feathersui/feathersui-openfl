/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

/**
	A view displayed in a navigator.

	@see `feathers.controls.navigators.StackNavigator`

	@since 1.0.0
**/
interface INavigatorView {
	/**
		The identifier for the navigator item. This value is passed in by the
		navigator when the view is displayed.

		@since 1.0.0
	**/
	var navigatorItemID(default, set):String;

	/**
		The navigator that is currently displaying this view.

		@since 1.0.0
	**/
	var navigatorOwner(default, set):BaseNavigator;
}
