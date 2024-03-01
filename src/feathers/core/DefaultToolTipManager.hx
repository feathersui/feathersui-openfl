/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.Label;
import feathers.style.IVariantStyleObject;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
	The default implementation of `IToolTipManager`.

	@see feathers.core.ToolTipManager

	@since 1.0.0
**/
class DefaultToolTipManager implements IToolTipManager {
	/**
		A variant used to style the tool tip label.

		The following example uses this variant:

		```haxe
		var toolTip = new Label();
		toolTip.variant = DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_TOOL_TIP = "toolTip";

	/**
		Creates a new `DefaultToolTipManager` object with the given arguments.

		@since 1.0.0
	**/
	public function new(root:DisplayObject) {
		initializeToolTipStyles();

		this._root = root;
		this._root.addEventListener(MouseEvent.MOUSE_MOVE, defaultToolTipManager_root_mouseMoveHandler, false, 0, true);
	}

	private var _root:DisplayObject;

	/**
		@see `feathers.core.IToolTipManager.root`
	**/
	public var root(get, never):DisplayObject;

	private function get_root():DisplayObject {
		return this._root;
	}

	private var _target:IUIControl;
	private var _toolTip:ITextControl;

	private var _toolTipStageX:Float;
	private var _toolTipStageY:Float;

	private var _delayTimeoutID:Null<UInt> = null;
	private var _delay = 0.5;
	private var _hideTime:Int = -1;

	private var _offsetX:Float = 0.0;
	private var _offsetY:Float = 0.0;

	/**
		@see `feathers.core.IToolTipManager.dispose()`
	**/
	public function dispose():Void {
		this.clearTarget();
		if (this._root != null) {
			this._root.removeEventListener(MouseEvent.MOUSE_MOVE, defaultToolTipManager_root_mouseMoveHandler);
			this._root = null;
		}
	}

	private function initializeToolTipStyles():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelToolTipStyles.initialize();
		#end
	}

	private function clearTarget():Void {
		this.hideToolTip();
		if (this._target != null) {
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, defaultToolTipManager_target_mouseDownHandler);
			this._target.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, defaultToolTipManager_target_rightMouseDownHandler);
			this._target.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, defaultToolTipManager_target_middleMouseDownHandler);
			this._target.removeEventListener(MouseEvent.ROLL_OUT, defaultToolTipManager_target_rollOutHandler);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, defaultToolTipManager_target_removedFromStageHandler);
			this._target = null;
		}
	}

	private function hideToolTip():Void {
		if (this._delayTimeoutID != null) {
			Lib.clearTimeout(this._delayTimeoutID);
			this._delayTimeoutID = null;
		}
		if (this._toolTip != null && this._toolTip.parent != null) {
			PopUpManager.removePopUp(cast(this._toolTip, DisplayObject));
			this._hideTime = Lib.getTimer();
		}
	}

	private function hoverDelayCallback():Void {
		this._delayTimeoutID = null;
		if (this._target.toolTip == null) {
			// tool tip has been cleared since mouse over
			return;
		}
		if (this._toolTip == null) {
			var toolTip = new Label();
			toolTip.variant = CHILD_VARIANT_TOOL_TIP;
			this._toolTip = toolTip;
		}
		if ((this._toolTip is InteractiveObject)) {
			var interactiveToolTip:InteractiveObject = cast this._toolTip;
			interactiveToolTip.mouseEnabled = false;
			interactiveToolTip.tabEnabled = false;
		}
		if ((this._toolTip is DisplayObjectContainer)) {
			(cast this._toolTip : DisplayObjectContainer).mouseChildren = false;
		}
		if ((this._toolTip is IVariantStyleObject)) {
			var variantToolTip:IVariantStyleObject = cast this._toolTip;
			if (variantToolTip.variant == null) {
				variantToolTip.variant = CHILD_VARIANT_TOOL_TIP;
			}
		}
		this._toolTip.text = this._target.toolTip;
		if ((this._toolTip is IValidating)) {
			(cast this._toolTip : IValidating).validateNow();
		}

		var stage = this._target.stage;
		var popUpManager = PopUpManager.forStage(stage);
		var position = popUpManager.root.globalToLocal(new Point(this._toolTipStageX, this._toolTipStageY));
		var dimensions = popUpManager.root.globalToLocal(new Point(stage.stageWidth, stage.stageHeight));
		var toolTipX = position.x + this._offsetX;
		if (toolTipX < 0.0) {
			toolTipX = 0.0;
		} else if ((toolTipX + this._toolTip.width) > dimensions.x) {
			toolTipX = dimensions.x - this._toolTip.width;
		}
		var toolTipY = position.y - this._toolTip.height + this._offsetY;
		if (toolTipY < 0.0) {
			toolTipY = 0.0;
		} else if ((toolTipY + this._toolTip.height) > dimensions.y) {
			toolTipY = dimensions.y - this._toolTip.height;
		}
		this._toolTip.x = toolTipX;
		this._toolTip.y = toolTipY;
		PopUpManager.addPopUp(cast(this._toolTip, DisplayObject), cast(this._target, DisplayObject), false, false);
	}

	private function defaultToolTipManager_root_mouseMoveHandler(event:MouseEvent):Void {
		if (event.buttonDown) {
			// if a button is already down, don't try to show a tool tip
			return;
		}
		var eventTarget = cast(event.target, DisplayObject);
		while (eventTarget != null && !(eventTarget is IUIControl)) {
			eventTarget = eventTarget.parent;
		}
		if (!(eventTarget is IUIControl)) {
			this.clearTarget();
			return;
		}
		var uiTarget:IUIControl = cast eventTarget;
		if (this._target == uiTarget) {
			this._toolTipStageX = event.stageX;
			this._toolTipStageY = event.stageY;
			return;
		}
		this.clearTarget();
		this._target = uiTarget;
		if (this._target.toolTip == null) {
			this._target = null;
			return;
		}
		this._target.addEventListener(MouseEvent.MOUSE_DOWN, defaultToolTipManager_target_mouseDownHandler, false, 0, true);
		this._target.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, defaultToolTipManager_target_rightMouseDownHandler, false, 0, true);
		this._target.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, defaultToolTipManager_target_middleMouseDownHandler, false, 0, true);
		this._target.addEventListener(MouseEvent.ROLL_OUT, defaultToolTipManager_target_rollOutHandler, false, 0, true);
		this._target.addEventListener(Event.REMOVED_FROM_STAGE, defaultToolTipManager_target_removedFromStageHandler, false, 0, true);
		this._toolTipStageX = event.stageX;
		this._toolTipStageY = event.stageY;
		this._delayTimeoutID = Lib.setTimeout(hoverDelayCallback, Std.int(this._delay * 1000.0));
	}

	private function defaultToolTipManager_target_mouseDownHandler(event:MouseEvent):Void {
		// hide the tooltip, but keep the target so that the tool tip doesn't
		// show for the same target twice on a single roll over
		this.hideToolTip();
	}

	private function defaultToolTipManager_target_rightMouseDownHandler(event:MouseEvent):Void {
		// hide the tooltip, but keep the target so that the tool tip doesn't
		// show for the same target twice on a single roll over
		this.hideToolTip();
	}

	private function defaultToolTipManager_target_middleMouseDownHandler(event:MouseEvent):Void {
		// hide the tooltip, but keep the target so that the tool tip doesn't
		// show for the same target twice on a single roll over
		this.hideToolTip();
	}

	private function defaultToolTipManager_target_rollOutHandler(event:MouseEvent):Void {
		this.clearTarget();
	}

	private function defaultToolTipManager_target_removedFromStageHandler(event:Event):Void {
		this.clearTarget();
	}
}
