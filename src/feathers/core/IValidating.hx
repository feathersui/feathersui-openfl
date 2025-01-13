/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A display object that supports validation. Display objects of this type will
	delay updating after property changes until just before OpenFL renders the
	display list to avoid running redundant code.

	@since 1.0.0
**/
interface IValidating {
	/**
		The component's depth in the display list, relative to the stage. If the
		component isn't on the stage, its depth will be `-1`.

		Used by the validation system to validate components from the top down.

		@since 1.0.0
	**/
	public var depth(get, never):Int;

	/**
		Immediately validates the display object, if it is invalid. The
		validation system exists to postpone updating a display object after
		properties are changed until until the last possible moment the display
		object is rendered. This allows multiple properties to be changed at a
		time without requiring a full update every time.

		@since 1.0.0

		@see [The Feathers UI Component Lifecycle](https://feathersui.com/learn/haxe-openfl/ui-component-lifecycle/)
	**/
	public function validateNow():Void;
}
