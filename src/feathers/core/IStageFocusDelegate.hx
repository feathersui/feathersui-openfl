package feathers.core;

import openfl.display.InteractiveObject;

/**
	Allows a different interactive display object to receive stage focus when
	this object receives focus from a focus manager.
**/
interface IStageFocusDelegate extends IFocusObject {
	/**
		The interactive display object to use for stage focus.

		@since 1.0.0
	**/
	public var stageFocusTarget(get, never):InteractiveObject;
}
