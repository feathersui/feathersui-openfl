/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.popups;

import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.core.PopUpManager;
import feathers.core.ValidationQueue;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Stage;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
#if air
import openfl.ui.Multitouch;
#end

/**
	Displays a pop-up like a sub-menu, positioned relative to the top-right
	corner of the source menu item.

	@event openfl.events.Event.OPEN Dispatched when the pop-up adapter opens,
	and `DropDownPopUpAdapter.active` changes to `true`.

	@event openfl.events.Event.CLOSE Dispatched when the pop-up adapter closes,
	and `DropDownPopUpAdapter.active` changes to `false`.

	@since 1.4.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
class SubMenuPopUpAdapter extends EventDispatcher implements IPopUpAdapter {
	/**
		Creates a new `SubMenuPopUpAdapter` object.

		@since 1.4.0
	**/
	public function new() {
		super();
	}

	private var content:DisplayObject = null;
	private var origin:DisplayObject = null;

	/**
		@see `feathers.controls.popups.IPopUpAdapter.active`
	**/
	public var active(get, never):Bool;

	private function get_active():Bool {
		return this.content != null;
	}

	private var _gap:Float = 0.0;

	/**
		The gap, measured in pixels, between the origin and the content.

		@since 1.0.0
	**/
	public var gap(get, set):Float;

	private function get_gap():Float {
		return this._gap;
	}

	private function set_gap(value:Float):Float {
		if (this._gap == value) {
			return this._gap;
		}
		this._gap = value;
		if (this.active) {
			this.layout();
		}
		return this._gap;
	}

	/**
		Determines if the content is displayed modally on the pop-up manager.

		@since 1.4.0
	**/
	public var modal:Bool = false;

	/**
		Used to optionally provide a custom overlay when opening the pop-up.

		@since 1.4.0
	**/
	public var customOverlayFactory:() -> DisplayObject;

	/**
		@see `feathers.controls.popups.IPopUpAdapter.persistent`
	**/
	public var persistent(get, never):Bool;

	private function get_persistent():Bool {
		return false;
	}

	/**
		Determines if the content is closed when a mouse down or touch begin
		event is dispatched outside of the content's or origin's bounds.

		@since 1.4.0
	**/
	public var closeOnPointerActiveOutside:Bool = false;

	private var _fitContentToGlobalHeight:Bool = true;

	/**
		Determines if the `height` or `maxHeight` of the content is adjusted to
		match the height of the stage, when the content is larger than the
		stage.

		@since 1.4.0
	**/
	public var fitContentToGlobalHeight(get, set):Bool;

	private function get_fitContentToGlobalHeight():Bool {
		return this._fitContentToGlobalHeight;
	}

	private function set_fitContentToGlobalHeight(value:Bool):Bool {
		if (this._fitContentToGlobalHeight == value) {
			return this._fitContentToGlobalHeight;
		}
		this._fitContentToGlobalHeight = value;
		if (this.active) {
			this.layout();
		}
		return this._fitContentToGlobalHeight;
	}

	private var _stage:Stage;

	private var _prevOriginX:Float;
	private var _prevOriginY:Float;

	private var _contentMeasurements:Measurements = new Measurements();
	private var _ignoreContentResizing:Bool = false;
	private var _ignoreOriginResizing:Bool = false;

	/**
		@see `feathers.controls.popups.IPopUpAdapter.open`
	**/
	public function open(content:DisplayObject, origin:DisplayObject):Void {
		if (this.active) {
			throw new IllegalOperationError("Pop-up adapter is already open. Close the previous content before opening new content.");
		}
		if (origin.stage == null) {
			throw new IllegalOperationError("Pop-up adapter failed to open because the origin is not added to the stage.");
		}
		this._stage = origin.stage;
		this._stage.addEventListener(MouseEvent.MOUSE_DOWN, dropDownPopUpAdapter_stage_mouseDownHandler, false, 0, true);
		this._stage.addEventListener(TouchEvent.TOUCH_BEGIN, dropDownPopUpAdapter_stage_touchBeginHandler, false, 0, true);
		this._stage.addEventListener(Event.RESIZE, dropDownPopUpAdapter_stage_resizeHandler, false, 0, true);
		this.content = content;
		this.content.addEventListener(Event.ENTER_FRAME, dropDownPopUpAdapter_content_enterFrameHandler, false, 0, true);
		this.content.addEventListener(Event.RESIZE, dropDownPopUpAdapter_content_resizeHandler, false, 0, true);
		this.content.addEventListener(Event.REMOVED_FROM_STAGE, dropDownPopUpAdapter_content_removedFromStageHandler, false, 0, true);
		this.origin = origin;
		this.origin.addEventListener(Event.RESIZE, dropDownPopUpAdapter_origin_resizeHandler, false, 0, true);
		this.origin.addEventListener(Event.REMOVED_FROM_STAGE, dropDownPopUpAdapter_origin_removedFromStageHandler, false, 0, true);
		PopUpManager.addPopUp(this.content, this.origin, this.modal, false, this.customOverlayFactory);
		if (!this.active) {
			// it's possible to immediately close this adapter in an
			// ADDED_TO_STAGE listener. in that case, we should not continue
			return;
		}

		if ((this.content is IValidating)) {
			var oldIgnoreContentResizing = this._ignoreContentResizing;
			this._ignoreContentResizing = true;
			(cast this.content : IValidating).validateNow();
			this._ignoreContentResizing = oldIgnoreContentResizing;
		}
		this._contentMeasurements.save(this.content);

		this.layout();

		FeathersEvent.dispatch(this, Event.OPEN);
	}

	/**
		@see `feathers.controls.popups.IPopUpAdapter.close`

		When the adapter closes, it will dispatch an event of type
		`Event.CLOSE`.

		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)
	**/
	public function close():Void {
		if (!this.active) {
			return;
		}
		this._stage.removeEventListener(Event.RESIZE, dropDownPopUpAdapter_stage_resizeHandler);
		this._stage.removeEventListener(MouseEvent.MOUSE_DOWN, dropDownPopUpAdapter_stage_mouseDownHandler);
		this._stage.addEventListener(TouchEvent.TOUCH_BEGIN, dropDownPopUpAdapter_stage_touchBeginHandler);

		this.content.removeEventListener(Event.ENTER_FRAME, dropDownPopUpAdapter_content_enterFrameHandler);
		this.content.removeEventListener(Event.RESIZE, dropDownPopUpAdapter_content_resizeHandler);
		this.content.removeEventListener(Event.REMOVED_FROM_STAGE, dropDownPopUpAdapter_content_removedFromStageHandler);

		if (this.origin != null) {
			this.origin.removeEventListener(Event.RESIZE, dropDownPopUpAdapter_origin_resizeHandler);
			this.origin.removeEventListener(Event.REMOVED_FROM_STAGE, dropDownPopUpAdapter_origin_removedFromStageHandler);
		}

		var content = this.content;
		this.origin = null;
		this.content = null;
		this._stage = null;

		if (content.parent != null) {
			content.parent.removeChild(content);
		}
		this._contentMeasurements.restore(content);
		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function layout():Void {
		if ((this.origin is IValidating)) {
			var oldIgnoreOriginResizing = this._ignoreOriginResizing;
			this._ignoreOriginResizing = true;
			(cast this.origin : IValidating).validateNow();
			this._ignoreOriginResizing = oldIgnoreOriginResizing;
		}

		var popUpRoot = PopUpManager.forStage(this._stage).root;

		var originTopRight = new Point(this.origin.x + this.origin.width, this.origin.y);
		originTopRight = origin.parent.localToGlobal(originTopRight);
		originTopRight = popUpRoot.globalToLocal(originTopRight);

		var originBottomRight = new Point(this.origin.x + this.origin.width, this.origin.y + this.origin.height);
		originBottomRight = origin.parent.localToGlobal(originBottomRight);
		originBottomRight = popUpRoot.globalToLocal(originBottomRight);

		this._prevOriginX = originTopRight.x;
		this._prevOriginY = originTopRight.y;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);
		var stageBottomRight = new Point(this._stage.stageWidth, this._stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var globalHeight = Math.max(0.0, stageBottomRight.y - stageTopLeft.y);

		var hasSetMaxHeight = false;
		if (this._fitContentToGlobalHeight && (this.content is IMeasureObject)) {
			var measureContent:IMeasureObject = cast this.content;
			if (measureContent.maxHeight > globalHeight) {
				measureContent.maxHeight = globalHeight;
				hasSetMaxHeight = true;
			}
		}

		var oldIgnoreContentResizing = this._ignoreContentResizing;
		this._ignoreContentResizing = true;
		if ((this.content is IValidating)) {
			(cast this.content : IValidating).validateNow();
		}
		if (this._fitContentToGlobalHeight && !hasSetMaxHeight && this.content.height > globalHeight) {
			this.content.height = globalHeight;
		}
		this._ignoreContentResizing = oldIgnoreContentResizing;

		var contentX = originTopRight.x + this._gap;
		if ((contentX + this.content.width) > stageBottomRight.x) {
			contentX = originTopRight.x - this._gap - this.content.width;
		}
		if (contentX < stageTopLeft.x) {
			// don't go into negative stage coordinates
			contentX = stageTopLeft.x;
		}
		this.content.x = contentX;

		var contentY = originTopRight.y;
		if ((contentY + this.content.height) > stageBottomRight.y) {
			contentY = Math.max(stageTopLeft.y, originTopRight.y - this._gap - this.content.height);
		}
		this.content.y = contentY;
	}

	private function dropDownPopUpAdapter_origin_removedFromStageHandler(event:Event):Void {
		if (!this.active) {
			return;
		}
		this.close();
	}

	private function dropDownPopUpAdapter_content_removedFromStageHandler(event:Event):Void {
		if (!this.active) {
			return;
		}
		this.close();
	}

	private function dropDownPopUpAdapter_stage_resizeHandler(event:Event):Void {
		if (!this.active) {
			return;
		}
		var stage = cast(event.currentTarget, Stage);
		ValidationQueue.forStage(stage).validateNow();
		this.layout();
	}

	private function dropDownPopUpAdapter_content_resizeHandler(event:Event):Void {
		if (!this.active || this._ignoreContentResizing) {
			return;
		}
		this.layout();
	}

	private function dropDownPopUpAdapter_origin_resizeHandler(event:Event):Void {
		if (!this.active || this._ignoreOriginResizing) {
			return;
		}
		this.layout();
	}

	private function dropDownPopUpAdapter_content_enterFrameHandler(event:Event):Void {
		if (!this.active) {
			return;
		}

		var popUpRoot = PopUpManager.forStage(this._stage).root;

		var originTopLeft = new Point(this.origin.x, this.origin.y);
		originTopLeft = origin.parent.localToGlobal(originTopLeft);
		originTopLeft = popUpRoot.globalToLocal(originTopLeft);

		// check if the position of the origin has changed since the previous
		// time we updated the size/position of the content
		if (originTopLeft.x != this._prevOriginX || originTopLeft.y != this._prevOriginY) {
			this.layout();
		}
	}

	private function dropDownPopUpAdapter_stage_mouseDownHandler(event:MouseEvent):Void {
		if (!this.closeOnPointerActiveOutside) {
			return;
		}
		var mouseTarget = cast(event.target, DisplayObject);
		if ((this.content is DisplayObjectContainer)) {
			var container:DisplayObjectContainer = cast this.content;
			if (container.contains(mouseTarget)) {
				return;
			}
		} else if (this.content == mouseTarget) {
			return;
		}
		if ((this.origin is DisplayObjectContainer)) {
			var container:DisplayObjectContainer = cast this.origin;
			if (container.contains(mouseTarget)) {
				return;
			}
		} else if (this.origin == mouseTarget) {
			return;
		}
		this.close();
	}

	private function dropDownPopUpAdapter_stage_touchBeginHandler(event:TouchEvent):Void {
		if (!this.closeOnPointerActiveOutside) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		var mouseTarget = cast(event.target, DisplayObject);
		if ((this.content is DisplayObjectContainer)) {
			var container:DisplayObjectContainer = cast this.content;
			if (container.contains(mouseTarget)) {
				return;
			}
		} else if (this.content == mouseTarget) {
			return;
		}
		if ((this.origin is DisplayObjectContainer)) {
			var container:DisplayObjectContainer = cast this.origin;
			if (container.contains(mouseTarget)) {
				return;
			}
		} else if (this.origin == mouseTarget) {
			return;
		}
		this.close();
	}
}
