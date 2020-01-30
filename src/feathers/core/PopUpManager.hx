/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.errors.ArgumentError;
import openfl.display.DisplayObjectContainer;
import openfl.display.Stage;
import openfl.display.DisplayObject;

/**
	Adds a display object as a pop-up above all other content on the stage.

	@since 1.0.0
**/
class PopUpManager {
	/**
		Creates an `IPopUpManager` for the specified container.

		@since 1.0.0
	**/
	public static var popUpManagerFactory:(stage:Stage) -> IPopUpManager;

	/**
		The container where pop-ups are added. If not set manually, defaults to
		the stage.

		@since 1.0.0
	**/
	public static var root(never, set):DisplayObjectContainer;

	private static function set_root(value:DisplayObjectContainer):DisplayObjectContainer {
		var popUpManager = forStage(value.stage);
		popUpManager.root = value;
		return value;
	}

	/**
		Returns the total number of pop-ups added to all pop up managers.

		To get the number of pop-ups for a specific pop up manager, use
		`PopUpManager.forStage(stage).popUpCount` instead.

		@since 1.0.0
	**/
	public static var popUpCount(get, never):Int;

	private static function get_popUpCount():Int {
		var count = 0;
		for (popUpManager in stageToManager) {
			count += popUpManager.popUpCount;
		}
		return count;
	}

	private static var stageToManager:Map<Stage, IPopUpManager> = [];

	/**
		Returns the `IPopUpManager` instanceassociated with the specified
		`Stage` instance. If a pop-up manager hasn't been created for this stage
		yet, one will be created automatically using
		`PopUpManager.popUpManagerFactory`.

		@see `PopUpManager.popUpManagerFactory`

		@since 1.0.0
	**/
	public static function forStage(stage:Stage):IPopUpManager {
		if (stage == null) {
			throw new ArgumentError("PopUpManager stage argument must not be null.");
		}
		var popUpManager = stageToManager.get(stage);
		if (popUpManager == null) {
			var factory = PopUpManager.popUpManagerFactory;
			if (factory == null) {
				factory = PopUpManager.defaultPopUpManagerFactory;
			}
			popUpManager = factory(stage);
			stageToManager.set(stage, popUpManager);
		}
		return popUpManager;
	}

	/**
		@since 1.0.0
	**/
	public static function dispose():Void {
		removeAllPopUps();
		for (stage in stageToManager.keys()) {
			stageToManager.remove(stage);
		}
	}

	/**
		A convenience method for `PopUpManager.forStage(stage).addPopUp()`.
		Attempts to use `parent.stage`, but throws an error if `parent.stage` is
		`null`.

		@since 1.0.0
	**/
	public static function addPopUp(popUp:DisplayObject, parent:DisplayObject, isModal:Bool = true, isCentered:Bool = true,
			?customOverlayFactory:() -> DisplayObject):DisplayObject {
		if (parent == null) {
			throw new ArgumentError("The pop-up's parent must not be null.");
		}
		var stage = parent.stage;
		if (stage == null) {
			throw new ArgumentError("The stage property of a pop-up's parent must not be null.");
		}
		var popUpManager = PopUpManager.forStage(stage);
		return popUpManager.addPopUp(popUp, isModal, isCentered, customOverlayFactory);
	}

	/**
		A convenience method for `PopUpManager.forStage(stage).removePopUp()`.

		@since 1.0.0
	**/
	public static function removePopUp(popUp:DisplayObject):DisplayObject {
		var stage = popUp.stage;
		if (stage == null) {
			return popUp;
		}
		var popUpManager = PopUpManager.forStage(stage);
		return popUpManager.removePopUp(popUp);
	}

	/**
		Removes all pop-ups added to all pop up managers.

		@since 1.0.0
	**/
	public static function removeAllPopUps():Void {
		for (popUpManager in stageToManager) {
			popUpManager.removeAllPopUps();
		}
	}

	/**
		A convenience method for `PopUpManager.forStage(stage).centerPopUp()`.
		Attempts to use `target.stage`, but throws an error if `target.stage` is
		`null`.

		@since 1.0.0
	**/
	public static function centerPopUp(target:DisplayObject):Void {
		var stage = target.stage;
		if (stage == null) {
			throw new ArgumentError("A pop-up's stage property must not be null.");
		}
		var popUpManager = PopUpManager.forStage(stage);
		popUpManager.centerPopUp(target);
	}

	/**
		A convenience method for `PopUpManager.forStage(stage).isPopUp()`.
		Attempts to use `target.stage`, but returns `false` if `target.stage` is
		`null`.

		@since 1.0.0
	**/
	public static function isPopUp(target:DisplayObject):Bool {
		if (target == null) {
			return false;
		}
		var stage = target.stage;
		if (stage == null) {
			return false;
		}
		var popUpManager = PopUpManager.forStage(stage);
		return popUpManager.isPopUp(target);
	}

	/**
		A convenience method for `PopUpManager.forStage(stage).isModal()`.
		Attempts to use `target.stage`, but returns `false` if `target.stage` is
		`null`.

		@since 1.0.0
	**/
	public static function isModal(target:DisplayObject):Bool {
		if (target == null) {
			return false;
		}
		var stage = target.stage;
		if (stage == null) {
			return false;
		}
		var popUpManager = PopUpManager.forStage(stage);
		return popUpManager.isModal(target);
	}

	/**
		A convenience method for `PopUpManager.forStage(stage).isTopLevelPopUp()`.
		Attempts to use `target.stage`, but returns `false` if `target.stage` is
		`null`.

		@since 1.0.0
	**/
	public static function isTopLevelPopUp(target:DisplayObject):Bool {
		if (target == null) {
			return false;
		}
		var stage = target.stage;
		if (stage == null) {
			return false;
		}
		var popUpManager = PopUpManager.forStage(stage);
		return popUpManager.isTopLevelPopUp(target);
	}

	private static function defaultPopUpManagerFactory(stage:Stage):IPopUpManager {
		return new DefaultPopUpManager(stage);
	}
}
