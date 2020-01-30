/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;

/**
	Manages pop-ups for all children of a root component (usually, all children
	of a `Stage`).

	@see `feathers.core.PopUpManager`

	@since 1.0.0
**/
interface IPopUpManager {
	/**
		A function that returns a display object to use as an overlay for modal
		pop-ups.

		@since 1.0.0
	**/
	public var overlayFactory(get, set):() -> DisplayObject;

	/**
		The container where pop-ups are added. If not set manually, defaults to
		the stage.

		@since 1.0.0
	**/
	public var root(get, set):DisplayObjectContainer;

	/**
		The current number of pop-ups.

		@since 1.0.0
	**/
	public var popUpCount(get, never):Int;

	/**
		Determines if a display object is a pop-up.

		@since 1.0.0
	**/
	public function isPopUp(target:DisplayObject):Bool;

	/**
		Determines if a display object is above the highest modal overlay. If
		there are no modals overlays, determines if a display object is a
		pop-up.

		@since 1.0.0
	**/
	public function isTopLevelPopUp(target:DisplayObject):Bool;

	/**
		Determines if a pop-up is modal.

		@since 1.0.0
	**/
	public function isModal(target:DisplayObject):Bool;

	/**
		Adds a pop-up.

		@since 1.0.0
	**/
	public function addPopUp(popUp:DisplayObject, isModal:Bool = true, isCentered:Bool = true, ?customOverlayFactory:() -> DisplayObject):DisplayObject;

	/**
		Removes a pop-up.

		@since 1.0.0
	**/
	public function removePopUp(popUp:DisplayObject):DisplayObject;

	/**
		Removes all pop-ups that have been added.

		@since 1.0.0
	**/
	public function removeAllPopUps():Void;

	/**
		Centers a pop-up.

		@since 1.0.0
	**/
	public function centerPopUp(popUp:DisplayObject):Void;
}
