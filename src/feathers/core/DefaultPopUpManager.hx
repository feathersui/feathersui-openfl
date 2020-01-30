/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.geom.Point;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;

/**
	The default implementation of the `IPopUpManager` interface.

	@see `feathers.core.PopUpManager`

	@since 1.0.0
**/
class DefaultPopUpManager implements IPopUpManager {
	private static function defaultOverlayFactory():DisplayObject {
		var overlay = new Sprite();
		overlay.graphics.beginFill(0x808080, 0.75);
		overlay.graphics.drawRect(0, 0, 1, 1);
		overlay.graphics.endFill();
		return overlay;
	}

	/**
		Creates a new `DefaultPopUpManager` object with the given arguments.

		@since 1.0.0
	**/
	public function new(root:DisplayObjectContainer) {
		this.root = root;
	}

	private var _ignoreRemoval = false;

	/**
		@see `feathers.core.IPopUpManager.root`
	**/
	@:isVar
	public var root(get, set):DisplayObjectContainer;

	private function get_root():DisplayObjectContainer {
		return this.root;
	}

	private function set_root(value:DisplayObjectContainer):DisplayObjectContainer {
		if (this.root == value) {
			return this.root;
		}
		if (value.stage == null) {
			throw new ArgumentError("DefaultPopUpManager root's stage property must not be null.");
		}
		var oldIgnoreRemoval = this._ignoreRemoval;
		this._ignoreRemoval = true;
		for (popUp in this.popUps) {
			this.root.removeChild(popUp);
			var overlay = this._popUpToOverlay.get(popUp);
			if (overlay != null) {
				this.root.removeChild(overlay);
			}
		}
		this._ignoreRemoval = oldIgnoreRemoval;
		this.root = value;
		for (popUp in this.popUps) {
			var overlay = this._popUpToOverlay.get(popUp);
			if (overlay != null) {
				this.root.addChild(overlay);
			}
			this.root.addChild(popUp);
		}
		return this.root;
	}

	private var popUps:Array<DisplayObject> = [];

	private var _centeredPopUps:Array<DisplayObject> = [];

	private var _popUpToOverlay:Map<DisplayObject, DisplayObject> = [];

	/**
		@see `feathers.core.IPopUpManager.overlayFactory`
	**/
	@:isVar
	public var overlayFactory(get, set):() -> DisplayObject;

	private function get_overlayFactory():() -> DisplayObject {
		return this.overlayFactory;
	}

	private function set_overlayFactory(value:() -> DisplayObject):() -> DisplayObject {
		if (Reflect.compareMethods(this.overlayFactory, value)) {
			return this.overlayFactory;
		}
		this.overlayFactory = value;
		return this.overlayFactory;
	}

	/**
		@see `feathers.core.IPopUpManager.popUpCount`
	**/
	public var popUpCount(get, never):Int;

	private function get_popUpCount():Int {
		return this.popUps.length;
	}

	/**
		@see `feathers.core.IPopUpManager.isPopUp`
	**/
	public function isPopUp(target:DisplayObject):Bool {
		return this.popUps.indexOf(target) != -1;
	}

	/**
		@see `feathers.core.IPopUpManager.isTopLevelPopUp`
	**/
	public function isTopLevelPopUp(target:DisplayObject):Bool {
		var i = this.popUps.length - 1;
		while (i >= 0) {
			var otherPopUp = this.popUps[i];
			if (otherPopUp == target) {
				// we haven't encountered an overlay yet, so it is top-level
				return true;
			}
			var overlay = this._popUpToOverlay.get(otherPopUp);
			if (overlay != null) {
				// this is the first overlay, and we haven't found the pop-up
				// yet, so it is not top-level
				return false;
			}
			i--;
		}
		return false;
	}

	/**
		@see `feathers.core.IPopUpManager.isModal`
	**/
	public function isModal(target:DisplayObject):Bool {
		if (target == null) {
			return false;
		}
		return this._popUpToOverlay.get(target) != null;
	}

	/**
		@see `feathers.core.IPopUpManager.addPopUp`
	**/
	public function addPopUp(popUp:DisplayObject, isModal:Bool = true, isCentered:Bool = true, ?customOverlayFactory:() -> DisplayObject):DisplayObject {
		if (isModal) {
			if (customOverlayFactory == null) {
				customOverlayFactory = this.overlayFactory;
			}
			if (customOverlayFactory == null) {
				customOverlayFactory = DefaultPopUpManager.defaultOverlayFactory;
			}
			var overlay = customOverlayFactory();
			overlay.width = this.root.stage.stageWidth;
			overlay.height = this.root.stage.stageHeight;
			this.root.addChild(overlay);
			this._popUpToOverlay.set(popUp, overlay);
		}

		this.popUps.push(popUp);
		var result = this.root.addChild(popUp);

		// this listener needs to be added after the pop-up is added to the
		// root because the pop-up may not have been removed from its old
		// parent yet, which will trigger the listener if it is added first.
		popUp.addEventListener(Event.REMOVED_FROM_STAGE, popUp_removedFromStageHandler);
		if (this.popUps.length == 1) {
			this.root.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);
		}
		if (isCentered) {
			if (Std.is(popUp, IMeasureObject)) {
				var measurePopUp = cast(popUp, IMeasureObject);
				measurePopUp.addEventListener(Event.RESIZE, popUp_resizeHandler);
			}
			this._centeredPopUps.push(popUp);
			this.centerPopUp(popUp);
		}
		return result;
	}

	/**
		@see `feathers.core.IPopUpManager.removePopUp`
	**/
	public function removePopUp(popUp:DisplayObject):DisplayObject {
		var index = this.popUps.indexOf(popUp);
		if (index == -1) {
			return popUp;
		}
		return this.root.removeChild(popUp);
	}

	/**
		@see `feathers.core.IPopUpManager.removePopUp`
	**/
	public function removeAllPopUps():Void {
		// removing pop-ups may call event listeners that add new pop-ups,
		// and we don't want to remove the new ones or miss old ones, so
		// create a copy of the popUps array to be safe.
		var popUps = this.popUps.copy();
		for (popUp in popUps) {
			// we check if this is still a pop-up because it might have been
			// removed in an Event.REMOVED or Event.REMOVED_FROM_STAGE
			// listener for another pop-up earlier in the loop
			if (this.isPopUp(popUp)) {
				this.removePopUp(popUp);
			}
		}
	}

	/**
		@see `feathers.core.IPopUpManager.centerPopUp`
	**/
	public function centerPopUp(popUp:DisplayObject):Void {
		var stage = this.root.stage;
		if (Std.is(popUp, IValidating)) {
			cast(popUp, IValidating).validateNow();
		}
		var topLeft = new Point(0, 0);
		topLeft = this.root.globalToLocal(topLeft);
		var bottomRight = new Point(stage.stageWidth, stage.stageHeight);
		bottomRight = this.root.globalToLocal(bottomRight);
		popUp.x = topLeft.x + (bottomRight.x - topLeft.x - popUp.width) / 2.0;
		popUp.y = topLeft.y + (bottomRight.y - topLeft.y - popUp.height) / 2.0;
	}

	private function popUp_removedFromStageHandler(event:Event):Void {
		if (this._ignoreRemoval) {
			return;
		}
		var popUp = cast(event.currentTarget, DisplayObject);
		popUp.removeEventListener(Event.REMOVED_FROM_STAGE, popUp_removedFromStageHandler);
		this.popUps.remove(popUp);
		var overlay = this._popUpToOverlay.get(popUp);
		if (overlay != null) {
			this.root.removeChild(overlay);
			this._popUpToOverlay.remove(popUp);
		}

		if (this.popUps.length == 0) {
			this.root.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
		}
	}

	private function popUp_resizeHandler(event:Event):Void {
		var popUp = cast(event.currentTarget, DisplayObject);
		this.centerPopUp(popUp);
	}

	private function stage_resizeHandler(event:Event):Void {
		var stage = this.root.stage;
		var stageWidth = stage.stageWidth;
		var stageHeight = stage.stageHeight;
		for (popUp in popUps) {
			var overlay = this._popUpToOverlay.get(popUp);
			if (overlay != null) {
				overlay.width = stageWidth;
				overlay.height = stageHeight;
			}
		}
		for (popUp in this._centeredPopUps) {
			this.centerPopUp(popUp);
		}
	}
}
