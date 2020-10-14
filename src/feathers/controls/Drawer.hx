/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.steel.components.SteelDrawerStyles;
import feathers.core.FeathersControl;
import feathers.core.IOpenCloseToggle;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.AutoSizeMode;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.EdgePuller;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
#if air
import openfl.ui.Multitouch;
#end

@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:event(feathers.events.FeathersEvent.OPENING)
@:event(feathers.events.FeathersEvent.CLOSING)

/**
	@since 1.0.0
**/
@:styleContext
class Drawer extends FeathersControl implements IOpenCloseToggle {
	public function new(?target:InteractiveObject, ?content:DisplayObject) {
		initializeDrawerTheme();
		super();
		this.target = target;
		this.content = content;
	}

	private var _edgePuller:EdgePuller;

	private var _target:InteractiveObject;

	/**
		The target used for detecting pull gestures.

		@since 1.0.0
	**/
	@:flash.property
	public var target(get, set):InteractiveObject;

	private function get_target():InteractiveObject {
		return this._target;
	}

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this._target == value) {
			return this._target;
		}
		if (this._target != null && this._target.parent == this) {
			this.removeChild(this._target);
		}
		this._target = value;
		if (this._target != null) {
			this.addChild(this._target);
		}
		this.setInvalid(DATA);
		return this._target;
	}

	private var _content:DisplayObject;

	/**
		The content to display in the drawer.

		@since 1.0.0
	**/
	@:flash.property
	public var content(get, set):DisplayObject;

	private function get_content():DisplayObject {
		return this._content;
	}

	private function set_content(value:DisplayObject):DisplayObject {
		if (this._content == value) {
			return this._content;
		}
		if (this._content != null && this._target.parent == this) {
			this.removeChild(this._content);
		}
		this._content = value;
		if (this._content != null) {
			this._content.visible = false;
			this.addChild(this._content);
		}
		this.setInvalid(DATA);
		return this._content;
	}

	private var _pullableEdge:RelativePosition = RelativePosition.LEFT;

	/**
		The edge of the target where the pull originates.

		@default `feathers.layout.RelativePosition.LEFT`

		@since 1.0.0
	**/
	@:flash.property
	public var pullableEdge(get, set):RelativePosition;

	private function get_pullableEdge():RelativePosition {
		return this._pullableEdge;
	}

	private function set_pullableEdge(value:RelativePosition):RelativePosition {
		if (this._pullableEdge == value) {
			return this._pullableEdge;
		}
		this._pullableEdge = value;
		this.setInvalid(DATA);
		return this._pullableEdge;
	}

	private var _pendingOpened:Null<Bool> = null;

	private var _opened:Bool = false;

	/**
		@see `feathers.core.IOpenCloseToggle.opened`
	**/
	@:flash.property
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		if (this._pendingOpened != null) {
			return this._pendingOpened;
		}
		return this._opened;
	}

	private function set_opened(value:Bool):Bool {
		if (this._pendingOpened == value) {
			return this._pendingOpened;
		}
		this._pendingOpened = value;
		this.setInvalid(DATA);
		return this._pendingOpened;
	}

	private var _autoSizeMode:AutoSizeMode = STAGE;

	/**
		Determines how the drawer container will set its own size when its
		dimensions (width and height) aren't set explicitly.

		In the following example, the drawer container will be sized to match
		the stage:

		```hx
		group.autoSizeMode = STAGE;
		```

		@see `feathers.layout.AutoSizeMode.STAGE`
		@see `feathers.layout.AutoSizeMode.CONTENT`

		@since 1.0.0
	**/
	@:flash.property
	public var autoSizeMode(get, set):AutoSizeMode;

	private function get_autoSizeMode():AutoSizeMode {
		return this._autoSizeMode;
	}

	private function set_autoSizeMode(value:AutoSizeMode):AutoSizeMode {
		if (this._autoSizeMode == value) {
			return this._autoSizeMode;
		}
		this._autoSizeMode = value;
		this.setInvalid(SIZE);
		if (this.stage != null) {
			if (this._autoSizeMode == STAGE) {
				this.stage.addEventListener(Event.RESIZE, drawer_stage_resizeHandler);
				this.addEventListener(Event.REMOVED_FROM_STAGE, drawer_removedFromStageHandler);
			} else {
				this.stage.removeEventListener(Event.RESIZE, drawer_stage_resizeHandler);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, drawer_removedFromStageHandler);
			}
		}
		return this._autoSizeMode;
	}

	private var _simulateTouch:Bool = false;

	/**
		Determines if mouse events should be treated like touch events when
		detecting a swipe.

		@since 1.0.0
	**/
	@:flash.property
	public var simulateTouch(get, set):Bool;

	private function get_simulateTouch():Bool {
		return this._simulateTouch;
	}

	private function set_simulateTouch(value:Bool):Bool {
		if (this._simulateTouch == value) {
			return this._simulateTouch;
		}
		this._simulateTouch = value;
		this.setInvalid(DATA);
		return this._simulateTouch;
	}

	private var _currentOverlaySkin:DisplayObject;
	private var _overlaySkinMeasurements:Measurements;
	private var _overlaySkinAlpha:Float;
	private var _fallbackOverlaySkin:Sprite;

	/**
		@since 1.0.0
	**/
	@:style
	public var overlaySkin:DisplayObject = null;

	private function initializeDrawerTheme():Void {
		SteelDrawerStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this._edgePuller == null) {
			this._edgePuller = new EdgePuller(this._target);
		}
		this._edgePuller.addEventListener(FeathersEvent.OPENING, drawer_edgePuller_openingHandler);
		this._edgePuller.addEventListener(FeathersEvent.CLOSING, drawer_edgePuller_closingHandler);
		this._edgePuller.addEventListener(Event.OPEN, drawer_edgePuller_openHandler);
		this._edgePuller.addEventListener(Event.CLOSE, drawer_edgePuller_closeHandler);
		this._edgePuller.addEventListener(Event.CHANGE, drawer_edgePuller_changeHandler);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (dataInvalid) {
			this._edgePuller.target = this._target;
			this._edgePuller.pullableEdge = this._pullableEdge;
			if (this._pendingOpened != null) {
				this._edgePuller.opened = this._pendingOpened;
				this._pendingOpened = null;
			} else {
				this._edgePuller.opened = this._opened;
			}
			this._edgePuller.simulateTouch = this._simulateTouch;
		}

		if (stylesInvalid) {
			this.refreshOverlaySkin();
		}

		if (stateInvalid) {
			this.refreshEnabled();
		}

		this.measure();

		this.layoutContent();
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var needsToMeasureContent = this._autoSizeMode == CONTENT || this.stage == null;
		var stageWidth:Float = 0.0;
		var stageHeight:Float = 0.0;
		if (!needsToMeasureContent) {
			// TODO: see if this can be done without allocations
			var topLeft = this.globalToLocal(new Point());
			var bottomRight = this.globalToLocal(new Point(this.stage.stageWidth, this.stage.stageHeight));
			stageWidth = bottomRight.x - topLeft.x;
			stageHeight = bottomRight.y - topLeft.y;
			return this.saveMeasurements(stageWidth, stageHeight, stageWidth, stageHeight, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		}

		// TODO: measure content
		var newWidth = 0.0;
		var newHeight = 0.0;
		var newMinWidth = 0.0;
		var newMinHeight = 0.0;
		var newMaxWidth = Math.POSITIVE_INFINITY;
		var newMaxHeight = Math.POSITIVE_INFINITY;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshEnabled():Void {
		this._edgePuller.enabled = this._enabled;
		if (Std.is(this._target, IUIControl)) {
			cast(this._target, IUIControl).enabled = this._enabled;
		}
	}

	private function refreshOverlaySkin():Void {
		var oldSkin = this._currentOverlaySkin;
		this._currentOverlaySkin = this.getCurrentOverlaySkin();
		if (this._currentOverlaySkin == oldSkin) {
			return;
		}
		this.removeCurrentOverlaySkin(oldSkin);
		if (this._currentOverlaySkin == null) {
			this._overlaySkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentOverlaySkin, IUIControl)) {
			cast(this._currentOverlaySkin, IUIControl).initializeNow();
		}
		if (this._overlaySkinMeasurements == null) {
			this._overlaySkinMeasurements = new Measurements(this._currentOverlaySkin);
		} else {
			this._overlaySkinMeasurements.save(this._currentOverlaySkin);
		}
		this._overlaySkinAlpha = this._currentOverlaySkin.alpha;
		if (Std.is(this._currentOverlaySkin, IProgrammaticSkin)) {
			cast(this._currentOverlaySkin, IProgrammaticSkin).uiContext = this;
		}
		this._currentOverlaySkin.addEventListener(MouseEvent.CLICK, drawer_overlaySkin_clickHandler, false, 0, true);
		this._currentOverlaySkin.addEventListener(TouchEvent.TOUCH_TAP, drawer_overlaySkin_touchTapHandler, false, 0, true);
		this._currentOverlaySkin.visible = false;
		var index = this.getChildIndex(this._content);
		if (index == -1) {
			index = this.numChildren;
		}
		this.addChildAt(this._currentOverlaySkin, index);
	}

	private function getCurrentOverlaySkin():DisplayObject {
		if (this.overlaySkin == null) {
			if (this._fallbackOverlaySkin == null) {
				this._fallbackOverlaySkin = new Sprite();
				this._fallbackOverlaySkin.graphics.beginFill(0xff00ff, 0.0);
				this._fallbackOverlaySkin.graphics.drawRect(0.0, 0.0, 1.0, 1.0);
				this._fallbackOverlaySkin.graphics.endFill();
			}
			return this._fallbackOverlaySkin;
		}
		return this.overlaySkin;
	}

	private function removeCurrentOverlaySkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		skin.removeEventListener(MouseEvent.CLICK, drawer_overlaySkin_clickHandler);
		skin.removeEventListener(TouchEvent.TOUCH_TAP, drawer_overlaySkin_touchTapHandler);
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._overlaySkinMeasurements.restore(skin);
		this._currentOverlaySkin.alpha = this._overlaySkinAlpha;
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function layoutContent():Void {
		if (this._target != null) {
			this._target.x = 0.0;
			this._target.y = 0.0;
			this._target.width = this.actualWidth;
			this._target.height = this.actualHeight;
		}
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.x = 0.0;
			this._currentOverlaySkin.y = 0.0;
			this._currentOverlaySkin.width = this.actualWidth;
			this._currentOverlaySkin.height = this.actualHeight;
		}
		if (this._content != null) {
			switch (this._pullableEdge) {
				case TOP:
					this._content.x = 0.0;
					this._content.width = this.actualWidth;
				case RIGHT:
					this._content.y = 0.0;
					this._content.height = this.actualHeight;
				case BOTTOM:
					this._content.x = 0.0;
					this._content.width = this.actualWidth;
				case LEFT:
					this._content.y = 0.0;
					this._content.height = this.actualHeight;
				default:
					throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
			}
			if (Std.is(this._content, IValidating)) {
				cast(this._content, IValidating).validateNow();
			}
			this._edgePuller.maxPullDistance = switch (this._pullableEdge) {
				case TOP: this._content.height;
				case RIGHT: this._content.width;
				case BOTTOM: this._content.height;
				case LEFT: this._content.width;
				default:
					throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
			}
		}
	}

	private function updateWithPullDistance():Void {
		switch (this._pullableEdge) {
			case TOP:
				this._content.y = -this._content.height + this._edgePuller.pullDistance
					;
			case RIGHT:
				this._content.x = this.actualWidth - this._edgePuller.pullDistance;
			case BOTTOM:
				this._content.y = this.actualHeight - this._edgePuller.pullDistance;
			case LEFT:
				this._content.x = -this._content.width + this._edgePuller.pullDistance
					;
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		}
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.alpha = this._overlaySkinAlpha * (this._edgePuller.pullDistance / this.getMaxPullDistance());
		}
	}

	private function getMaxPullDistance():Float {
		if (this._edgePuller.maxPullDistance != null) {
			return this._edgePuller.maxPullDistance;
		}
		return switch (this._pullableEdge) {
			case TOP: this._target.height;
			case RIGHT: this._target.width;
			case BOTTOM: this._target.height;
			case LEFT: this._target.width;
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		};
	}

	private function drawer_edgePuller_openingHandler(event:FeathersEvent):Void {
		var result = FeathersEvent.dispatch(this, FeathersEvent.OPENING);
		if (!result) {
			event.preventDefault();
			return;
		}
		this.updateWithPullDistance();
		this._content.visible = true;
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.visible = true;
		}
	}

	private function drawer_edgePuller_closingHandler(event:FeathersEvent):Void {
		var result = FeathersEvent.dispatch(this, FeathersEvent.CLOSING);
		if (!result) {
			event.preventDefault();
			return;
		}
		this.updateWithPullDistance();
		this._content.visible = true;
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.visible = true;
		}
	}

	private function drawer_edgePuller_openHandler(event:Event):Void {
		this._opened = true;
		FeathersEvent.dispatch(this, Event.OPEN);
	}

	private function drawer_edgePuller_closeHandler(event:Event):Void {
		this._content.visible = false;
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.alpha = this._overlaySkinAlpha;
			this._currentOverlaySkin.visible = false;
		}
		this._opened = false;
		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function drawer_edgePuller_changeHandler(event:Event):Void {
		this.updateWithPullDistance();
	}

	private function drawer_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, drawer_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, drawer_stage_resizeHandler);
	}

	private function drawer_stage_resizeHandler(event:Event):Void {
		this.setInvalid(SIZE);
	}

	private function drawer_overlaySkin_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		this.opened = false;
	}

	private function drawer_overlaySkin_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		this.opened = false;
	}
}
