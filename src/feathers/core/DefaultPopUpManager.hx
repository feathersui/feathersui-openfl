/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.geom.Point;

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

	private var _root:DisplayObjectContainer;

	/**
		@see `feathers.core.IPopUpManager.root`
	**/
	@:flash.property
	public var root(get, set):DisplayObjectContainer;

	private function get_root():DisplayObjectContainer {
		return this._root;
	}

	private function set_root(value:DisplayObjectContainer):DisplayObjectContainer {
		if (this._root == value) {
			return this._root;
		}
		if (value.stage == null) {
			throw new ArgumentError("DefaultPopUpManager root's stage property must not be null.");
		}
		var oldIgnoreRemoval = this._ignoreRemoval;
		this._ignoreRemoval = true;
		for (popUp in this.popUps) {
			this._root.removeChild(popUp);
			var overlay = this._popUpToOverlay.get(popUp);
			if (overlay != null) {
				this._root.removeChild(overlay);
			}
		}
		this._ignoreRemoval = oldIgnoreRemoval;
		this._root = value;
		for (popUp in this.popUps) {
			var overlay = this._popUpToOverlay.get(popUp);
			if (overlay != null) {
				this._root.addChild(overlay);
			}
			this._root.addChild(popUp);
		}
		return this._root;
	}

	private var popUps:Array<DisplayObject> = [];

	private var _centeredPopUps:Array<DisplayObject> = [];

	private var _popUpToOverlay:Map<DisplayObject, DisplayObject> = [];

	private var _overlayFactory:() -> DisplayObject;

	/**
		@see `feathers.core.IPopUpManager.overlayFactory`
	**/
	@:flash.property
	public var overlayFactory(get, set):() -> DisplayObject;

	private function get_overlayFactory():() -> DisplayObject {
		return this._overlayFactory;
	}

	private function set_overlayFactory(value:() -> DisplayObject):() -> DisplayObject {
		if (Reflect.compareMethods(this._overlayFactory, value)) {
			return this._overlayFactory;
		}
		this._overlayFactory = value;
		return this._overlayFactory;
	}

	/**
		@see `feathers.core.IPopUpManager.popUpCount`
	**/
	@:flash.property
	public var popUpCount(get, never):Int;

	private function get_popUpCount():Int {
		return this.popUps.length;
	}

	/**
		@see `feathers.core.IPopUpManager.topLevelPopUpCount`
	**/
	@:flash.property
	public var topLevelPopUpCount(get, never):Int;

	private function get_topLevelPopUpCount():Int {
		var count = 0;
		var i = this.popUps.length - 1;
		while (i >= 0) {
			count++;
			var popUp = this.popUps[i];
			var overlay = this._popUpToOverlay.get(popUp);
			if (overlay != null) {
				return count;
			}
			i--;
		}
		return count;
	}

	/**
		@see `feathers.core.IPopUpManager.getPopUpAt()`
	**/
	public function getPopUpAt(index:Int):DisplayObject {
		return this.popUps[index];
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
		@see `feathers.core.IPopUpManager.hasModalPopUps`
	**/
	public function hasModalPopUps():Bool {
		return this._popUpToOverlay.keyValueIterator().hasNext();
	}

	/**
		@see `feathers.core.IPopUpManager.addPopUp`
	**/
	public function addPopUp(popUp:DisplayObject, isModal:Bool = true, isCentered:Bool = true, ?customOverlayFactory:() -> DisplayObject):DisplayObject {
		var index = this.popUps.indexOf(popUp);
		if (index != -1) {
			this.cleanupOverlay(popUp);
			this.popUps.splice(index, 1);
		}
		if (isModal) {
			if (customOverlayFactory == null) {
				customOverlayFactory = this._overlayFactory;
			}
			if (customOverlayFactory == null) {
				customOverlayFactory = DefaultPopUpManager.defaultOverlayFactory;
			}
			var overlay = customOverlayFactory();
			var stage = this._root.stage;
			var stageTopLeft = this._root.globalToLocal(new Point());
			var stageBottomRight = this._root.globalToLocal(new Point(stage.stageWidth, stage.stageHeight));
			overlay.x = stageTopLeft.x;
			overlay.y = stageTopLeft.y;
			overlay.width = stageBottomRight.x - stageTopLeft.x;
			overlay.height = stageBottomRight.y - stageTopLeft.y;
			this._root.addChild(overlay);
			this._popUpToOverlay.set(popUp, overlay);
		}

		this.popUps.push(popUp);

		var result = this._root.addChild(popUp);
		if (popUp.parent == null) {
			this.cleanupOverlay(popUp);
			this.popUps.remove(popUp);
			return null;
		}

		// this listener needs to be added after the pop-up is added to the
		// root because the pop-up may not have been removed from its old
		// parent yet, which will trigger the listener if it is added first.
		popUp.addEventListener(Event.REMOVED_FROM_STAGE, defaultPopUpManager_popUp_removedFromStageHandler);
		if (this.popUps.length == 1) {
			this._root.stage.addEventListener(Event.RESIZE, defaultPopUpManager_stage_resizeHandler, false, 0, true);
		}
		if (isCentered) {
			if ((popUp is IMeasureObject)) {
				var measurePopUp = cast(popUp, IMeasureObject);
				measurePopUp.addEventListener(Event.RESIZE, defaultPopUpManager_popUp_resizeHandler);
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
		return this._root.removeChild(popUp);
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
		if ((popUp is IValidating)) {
			cast(popUp, IValidating).validateNow();
		}
		var stage = this._root.stage;
		var stageTopLeft = this._root.globalToLocal(new Point());
		var stageBottomRight = this._root.globalToLocal(new Point(stage.stageWidth, stage.stageHeight));
		popUp.x = stageTopLeft.x + (stageBottomRight.x - stageTopLeft.x - popUp.width) / 2.0;
		popUp.y = stageTopLeft.y + (stageBottomRight.y - stageTopLeft.y - popUp.height) / 2.0;
	}

	private function cleanupOverlay(popUp:DisplayObject):Void {
		var overlay = this._popUpToOverlay.get(popUp);
		if (overlay == null) {
			return;
		}
		this._root.removeChild(overlay);
		this._popUpToOverlay.remove(popUp);
	}

	private function defaultPopUpManager_popUp_removedFromStageHandler(event:Event):Void {
		if (this._ignoreRemoval) {
			return;
		}
		var popUp = cast(event.currentTarget, DisplayObject);
		popUp.removeEventListener(Event.REMOVED_FROM_STAGE, defaultPopUpManager_popUp_removedFromStageHandler);
		this.popUps.remove(popUp);
		this.cleanupOverlay(popUp);

		if (this.popUps.length == 0) {
			this._root.stage.removeEventListener(Event.RESIZE, defaultPopUpManager_stage_resizeHandler);
		}
	}

	private function defaultPopUpManager_popUp_resizeHandler(event:Event):Void {
		var popUp = cast(event.currentTarget, DisplayObject);
		this.centerPopUp(popUp);
	}

	private function defaultPopUpManager_stage_resizeHandler(event:Event):Void {
		var stage = this._root.stage;
		var stageTopLeft = this._root.globalToLocal(new Point());
		var stageBottomRight = this._root.globalToLocal(new Point(stage.stageWidth, stage.stageHeight));
		for (popUp in popUps) {
			var overlay = this._popUpToOverlay.get(popUp);
			if (overlay != null) {
				overlay.x = stageTopLeft.x;
				overlay.y = stageTopLeft.y;
				overlay.width = stageBottomRight.x - stageTopLeft.x;
				overlay.height = stageBottomRight.y - stageTopLeft.y;
			}
		}
		for (popUp in this._centeredPopUps) {
			this.centerPopUp(popUp);
		}
	}
}
