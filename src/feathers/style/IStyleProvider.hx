/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import openfl.events.IEventDispatcher;

/**
	Sets styles on a target object. Used by themes.

	@see `feathers.style.ITheme`
**/
interface IStyleProvider extends IEventDispatcher {
	/**
		Applies styles to the target object.

		@since 1.0.0
	**/
	public function applyStyles<T>(target:IStyleObject):Void;
}
