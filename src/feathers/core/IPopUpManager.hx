/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;

/**
	@since 1.0.0
**/
interface IPopUpManager {
	/**
		@since 1.0.0
	**/
	public var overlayFactory(get, set):() -> DisplayObject;

	/**
		@since 1.0.0
	**/
	public var root(get, set):DisplayObjectContainer;

	/**
		@since 1.0.0
	**/
	public var popUpCount(get, never):Int;

	/**
		@since 1.0.0
	**/
	public function addPopUp(popUp:DisplayObject, isModal:Bool = true, isCentered:Bool = true, ?customOverlayFactory:() -> DisplayObject):DisplayObject;

	/**
		@since 1.0.0
	**/
	public function removePopUp(popUp:DisplayObject):DisplayObject;

	/**
		@since 1.0.0
	**/
	public function removeAllPopUps():Void;

	/**
		@since 1.0.0
	**/
	public function isPopUp(target:DisplayObject):Bool;

	/**
		@since 1.0.0
	**/
	public function isTopLevelPopUp(target:DisplayObject):Bool;

	/**
		@since 1.0.0
	**/
	public function isModal(target:DisplayObject):Bool;

	/**
		@since 1.0.0
	**/
	public function centerPopUp(popUp:DisplayObject):Void;
}
