/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFocusExclusions;
import feathers.core.IFocusObject;
import feathers.core.IMeasureObject;
import feathers.core.IOpenCloseToggle;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.AutoSizeMode;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelDrawerStyles;
import feathers.utils.EdgePuller;
import feathers.utils.ExclusivePointer;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
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

/**
	A container that displays primary `content` in the center with a `drawer`
	that opens and closes from one of the four edges of the container.

	@event openfl.events.Event.OPEN Dispatched when the drawer has completely
	opened.

	@event openfl.events.Event.CLOSE Dispatched when the drawer has completely
	closed.

	@event openfl.events.Event.CANCEL Dispatched when an open or close action
	is cancelled before completing.

	@event feathers.events.FeathersEvent.OPENING Dispatched when the drawer
	starts opening. This event may be cancelled.

	@event feathers.events.FeathersEvent.CLOSING Dispatched when the drawer
	starts closing. This event may be cancelled.

	@see [Tutorial: How to use the Drawer component](https://feathersui.com/learn/haxe-openfl/drawer/)

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:event(openfl.events.Event.CANCEL)
@:event(feathers.events.FeathersEvent.OPENING)
@:event(feathers.events.FeathersEvent.CLOSING)
@:meta(DefaultProperty("content"))
@defaultXmlProperty("content")
@:styleContext
class Drawer extends FeathersControl implements IOpenCloseToggle implements IFocusExclusions {
	private static final MAX_CLICK_DISTANCE_FOR_CLOSE = 6.0;

	/**
		Creates a new `Drawer` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?content:InteractiveObject, ?drawer:DisplayObject) {
		initializeDrawerTheme();
		super();
		this.content = content;
		this.drawer = drawer;
		this.addEventListener(Event.ADDED_TO_STAGE, drawer_addedToStageHandler);
	}

	private var _focusExclusions:Array<DisplayObject> = [];

	/**
		@see `feathers.core.IFocusExclusions.focusExclusions`
	**/
	public var focusExclusions(get, never):Array<DisplayObject>;

	private function get_focusExclusions():Array<DisplayObject> {
		if (this._edgePuller != null && (this._edgePuller.opened || this._edgePuller.active)) {
			return this._focusExclusions;
		}
		return null;
	}

	private var _edgePuller:EdgePuller;

	private var _drawerMeasurements:Measurements;
	private var _ignoreDrawerResize = false;
	private var _drawer:DisplayObject;

	/**
		The drawer that may be opened and closed.

		@since 1.0.0
	**/
	@:flash.property
	public var drawer(get, set):DisplayObject;

	private function get_drawer():DisplayObject {
		return this._drawer;
	}

	private function set_drawer(value:DisplayObject):DisplayObject {
		if (this._drawer == value) {
			return this._drawer;
		}
		if (this._drawer != null) {
			this._drawer.removeEventListener(Event.RESIZE, drawer_drawer_resizeHandler);
			this._drawerMeasurements.restore(this._drawer);
			if (this._drawer.parent == this) {
				this.removeChild(this._drawer);
			}
		}
		this._drawer = value;
		if (this._drawer != null) {
			this._drawer.visible = false;
			this.addChild(this._drawer);
			if ((this._drawer is IUIControl)) {
				cast(this._drawer, IUIControl).initializeNow();
			}
			if (this._drawerMeasurements == null) {
				this._drawerMeasurements = new Measurements(this._drawer);
			} else {
				this._drawerMeasurements.save(this._drawer);
			}
			this._drawer.addEventListener(Event.RESIZE, drawer_drawer_resizeHandler, false, 0, true);
		}
		this.setInvalid(DATA);
		return this._drawer;
	}

	private var _contentMeasurements:Measurements;
	private var _ignoreContentResize = false;
	private var _content:InteractiveObject;

	/**
		The primary content to display in the container.

		@since 1.0.0
	**/
	@:flash.property
	public var content(get, set):InteractiveObject;

	private function get_content():InteractiveObject {
		return this._content;
	}

	private function set_content(value:InteractiveObject):InteractiveObject {
		if (this._content == value) {
			return this._content;
		}
		if (this._content != null) {
			this._content.removeEventListener(Event.RESIZE, drawer_content_resizeHandler);
			this._contentMeasurements.restore(this._content);
			if (this._content.parent == this) {
				this.removeChild(this._content);
			}
			this._focusExclusions.remove(this._content);
		}
		this._content = value;
		if (this._content != null) {
			this.addChildAt(this._content, 0);
			if ((this._content is IUIControl)) {
				cast(this._content, IUIControl).initializeNow();
			}
			if (this._contentMeasurements == null) {
				this._contentMeasurements = new Measurements(this._content);
			} else {
				this._contentMeasurements.save(this._content);
			}
			this._content.addEventListener(Event.RESIZE, drawer_content_resizeHandler, false, 0, true);
			this._focusExclusions.push(this._content);
		}
		this.setInvalid(DATA);
		return this._content;
	}

	private var _pullableEdge:RelativePosition = RelativePosition.LEFT;

	/**
		The edge of the container where the drawer is attached.

		@default `feathers.layout.RelativePosition.LEFT`

		@see `feathers.layout.RelativePosition.TOP`
		@see `feathers.layout.RelativePosition.RIGHT`
		@see `feathers.layout.RelativePosition.BOTTOM`
		@see `feathers.layout.RelativePosition.LEFT`

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
		if (value && this._drawer == null) {
			throw new ArgumentError("Cannot set opened property to true because drawer property is null");
		}
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
		drawer.autoSizeMode = STAGE;
		```

		@default feathers.layout.AutoSizeMode.STAGE`

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
		detecting a pull gesture that opens or closes a drawer.

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
		A display object to display below the drawer and above the primary
		content when the drawer is opened. Blocks mouse and touch events from
		reaching the primary content.

		@since 1.0.0
	**/
	@:style
	public var overlaySkin:DisplayObject = null;

	private var _clickStartX = 0.0;
	private var _clickStartY = 0.0;

	private var _clickOverlayToClose:Bool = true;

	/**
		Determines if the drawer may be closed by clicking the modal overlay.

		@since 1.0.0
	**/
	@:flash.property
	public var clickOverlayToClose(get, set):Bool;

	private function get_clickOverlayToClose():Bool {
		return this._clickOverlayToClose;
	}

	private function set_clickOverlayToClose(value:Bool):Bool {
		this._clickOverlayToClose = value;
		return this._clickOverlayToClose;
	}

	private var _swipeCloseEnabled:Bool = true;

	/**
		Determines if the drawer may be closed by swiping it.

		@see `Drawer.swipeOpenEnabled`

		@since 1.0.0
	**/
	@:flash.property
	public var swipeCloseEnabled(get, set):Bool;

	private function get_swipeCloseEnabled():Bool {
		return this._swipeCloseEnabled;
	}

	private function set_swipeCloseEnabled(value:Bool):Bool {
		if (this._swipeCloseEnabled == value) {
			return this._swipeCloseEnabled;
		}
		this._swipeCloseEnabled = value;
		this.setInvalid(STATE);
		return this._swipeCloseEnabled;
	}

	private var _swipeOpenEnabled:Bool = true;

	/**
		Determines if the drawer may be opened by swiping it.

		@see `Drawer.swipeCloseEnabled`

		@since 1.0.0
	**/
	@:flash.property
	public var swipeOpenEnabled(get, set):Bool;

	private function get_swipeOpenEnabled():Bool {
		return this._swipeOpenEnabled;
	}

	private function set_swipeOpenEnabled(value:Bool):Bool {
		if (this._swipeOpenEnabled == value) {
			return this._swipeOpenEnabled;
		}
		this._swipeOpenEnabled = value;
		this.setInvalid(STATE);
		return this._swipeOpenEnabled;
	}

	private function initializeDrawerTheme():Void {
		SteelDrawerStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this._edgePuller == null) {
			this._edgePuller = new EdgePuller(this._content);
		}
		this._edgePuller.addEventListener(FeathersEvent.OPENING, drawer_edgePuller_openingHandler);
		this._edgePuller.addEventListener(FeathersEvent.CLOSING, drawer_edgePuller_closingHandler);
		this._edgePuller.addEventListener(Event.OPEN, drawer_edgePuller_openHandler);
		this._edgePuller.addEventListener(Event.CLOSE, drawer_edgePuller_closeHandler);
		this._edgePuller.addEventListener(Event.CANCEL, drawer_edgePuller_cancelHandler);
		this._edgePuller.addEventListener(Event.CHANGE, drawer_edgePuller_changeHandler);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (dataInvalid) {
			this._edgePuller.target = this._content;
			this._edgePuller.pullableEdge = this._pullableEdge;
			this._edgePuller.simulateTouch = this._simulateTouch;
		}

		if (stylesInvalid) {
			this.refreshOverlaySkin();
		}

		if (stateInvalid || dataInvalid) {
			this.refreshEnabled();
		}

		this.measure();

		this.layoutChildren();

		if (dataInvalid) {
			if (this._pendingOpened != null) {
				this._edgePuller.opened = this._pendingOpened;
				this._pendingOpened = null;
			} else {
				this._edgePuller.opened = this._opened;
			}
		}
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
			return this.saveMeasurements(stageWidth, stageHeight, stageWidth, stageHeight);
		}

		var measureContent:IMeasureObject = null;
		if ((this._content is IMeasureObject)) {
			measureContent = cast(this._content, IMeasureObject);
		}
		if (this._content != null) {
			var oldIgnoreContentResize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			MeasurementsUtil.resetFluidlyWithParentValues(this._contentMeasurements, this._content, this.explicitWidth, this.explicitHeight,
				this.explicitMinWidth, this.explicitMinHeight, this.explicitMaxWidth, this.explicitMaxHeight);
			if ((this._content is IValidating)) {
				cast(this._content, IValidating).validateNow();
			}
			this._ignoreContentResize = oldIgnoreContentResize;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = 0.0;
			if (this._content != null) {
				newWidth = this._content.width;
			}
		}
		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = 0.0;
			if (this._content != null) {
				newHeight = this._content.height;
			}
		}
		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (measureContent != null) {
				newMinWidth = measureContent.minWidth;
			} else if (this._contentMeasurements != null) {
				newMinWidth = this._contentMeasurements.minWidth;
			}
		}
		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (measureContent != null) {
				newMinHeight = measureContent.minHeight;
			} else if (this._contentMeasurements != null) {
				newMinHeight = this._contentMeasurements.minHeight;
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (measureContent != null) {
				newMaxWidth = measureContent.maxWidth;
			} else if (this._contentMeasurements != null) {
				newMaxWidth = this._contentMeasurements.maxWidth;
			}
		}
		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (measureContent != null) {
				newMaxHeight = measureContent.maxHeight;
			} else if (this._contentMeasurements != null) {
				newMaxHeight = this._contentMeasurements.maxHeight;
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshEnabled():Void {
		this._edgePuller.enabled = this._enabled
			&& this._drawer != null
			&& ((this._opened && this._swipeCloseEnabled) || (!this._opened && this._swipeOpenEnabled));
		if ((this._content is IUIControl)) {
			cast(this._content, IUIControl).enabled = this._enabled;
		}
		if ((this._drawer is IUIControl)) {
			cast(this._drawer, IUIControl).enabled = this._enabled;
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
		if ((this._currentOverlaySkin is IUIControl)) {
			cast(this._currentOverlaySkin, IUIControl).initializeNow();
		}
		if (this._overlaySkinMeasurements == null) {
			this._overlaySkinMeasurements = new Measurements(this._currentOverlaySkin);
		} else {
			this._overlaySkinMeasurements.save(this._currentOverlaySkin);
		}
		this._overlaySkinAlpha = this._currentOverlaySkin.alpha;
		if ((this._currentOverlaySkin is IProgrammaticSkin)) {
			cast(this._currentOverlaySkin, IProgrammaticSkin).uiContext = this;
		}
		this._currentOverlaySkin.addEventListener(MouseEvent.MOUSE_DOWN, drawer_overlaySkin_mouseDownHandler, false, 0, true);
		this._currentOverlaySkin.addEventListener(MouseEvent.CLICK, drawer_overlaySkin_clickHandler, false, 0, true);
		this._currentOverlaySkin.addEventListener(TouchEvent.TOUCH_BEGIN, drawer_overlaySkin_touchBeginHandler, false, 0, true);
		this._currentOverlaySkin.addEventListener(TouchEvent.TOUCH_TAP, drawer_overlaySkin_touchTapHandler, false, 0, true);
		this._currentOverlaySkin.visible = false;
		var index = -1;
		if (this._drawer != null) {
			index = this.getChildIndex(this._drawer);
		}
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
		skin.removeEventListener(MouseEvent.MOUSE_DOWN, drawer_overlaySkin_mouseDownHandler);
		skin.removeEventListener(MouseEvent.CLICK, drawer_overlaySkin_clickHandler);
		skin.removeEventListener(TouchEvent.TOUCH_BEGIN, drawer_overlaySkin_touchBeginHandler);
		skin.removeEventListener(TouchEvent.TOUCH_TAP, drawer_overlaySkin_touchTapHandler);
		if ((skin is IProgrammaticSkin)) {
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

	private function layoutChildren():Void {
		var oldIgnoreContentResize = this._ignoreContentResize;
		this._ignoreContentResize = true;
		if (this._content != null) {
			this._content.x = 0.0;
			this._content.y = 0.0;
			if (this._content.width != this.actualWidth) {
				this._content.width = this.actualWidth;
			}
			if (this._content.height != this.actualHeight) {
				this._content.height = this.actualHeight;
			}
			if ((this._content is IValidating)) {
				cast(this._content, IValidating).validateNow();
			}
		}
		this._ignoreContentResize = oldIgnoreContentResize;

		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.x = 0.0;
			this._currentOverlaySkin.y = 0.0;
			this._currentOverlaySkin.width = this.actualWidth;
			this._currentOverlaySkin.height = this.actualHeight;
		}
		var oldIgnoreDrawerResize = this._ignoreDrawerResize;
		this._ignoreDrawerResize = true;
		if (this._drawer != null) {
			switch (this._pullableEdge) {
				case TOP:
					this._drawer.x = 0.0;
					this._drawer.width = this.actualWidth;
				case RIGHT:
					this._drawer.y = 0.0;
					this._drawer.height = this.actualHeight;
				case BOTTOM:
					this._drawer.x = 0.0;
					this._drawer.width = this.actualWidth;
				case LEFT:
					this._drawer.y = 0.0;
					this._drawer.height = this.actualHeight;
				default:
					throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
			}
			if ((this._drawer is IValidating)) {
				cast(this._drawer, IValidating).validateNow();
			}
			var maxPullDistance = 0.0;
			if (this._drawer != null) {
				maxPullDistance = switch (this._pullableEdge) {
					case TOP: this._drawer.height;
					case RIGHT: this._drawer.width;
					case BOTTOM: this._drawer.height;
					case LEFT: this._drawer.width;
					default:
						throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
				}
			}

			this._edgePuller.maxPullDistance = maxPullDistance;
		}
		this._ignoreDrawerResize = oldIgnoreDrawerResize;
	}

	private function updateWithPullDistance():Void {
		switch (this._pullableEdge) {
			case TOP:
				this._drawer.y = -this._drawer.height + this._edgePuller.pullDistance;
			case RIGHT:
				this._drawer.x = this.actualWidth - this._edgePuller.pullDistance;
			case BOTTOM:
				this._drawer.y = this.actualHeight - this._edgePuller.pullDistance;
			case LEFT:
				this._drawer.x = -this._drawer.width + this._edgePuller.pullDistance;
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
		if (this._content == null) {
			return 0.0;
		}
		return switch (this._pullableEdge) {
			case TOP: this._content.height;
			case RIGHT: this._content.width;
			case BOTTOM: this._content.height;
			case LEFT: this._content.width;
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		};
	}

	private function clearFocusOnOpening():Void {
		if (this._focusManager != null) {
			if (this._focusManager.focus == null) {
				return;
			}
			if ((this._content is IFocusObject) && this._focusManager.focus == cast(this._content, IFocusObject)) {
				this._focusManager.focus = null;
			} else if ((this._content is DisplayObjectContainer)
				&& cast(this._content, DisplayObjectContainer).contains(cast(this._focusManager.focus, DisplayObject))) {
				this._focusManager.focus = null;
			}
		}

		if (this.stage.focus == null) {
			return;
		}
		if (this.stage.focus == this._content
			|| ((this._content is DisplayObjectContainer) && cast(this._content, DisplayObjectContainer).contains(this.stage.focus))) {
			this.stage.focus = this.stage;
		}
	}

	private function drawer_edgePuller_openingHandler(event:FeathersEvent):Void {
		var pointerID = this._edgePuller.pointerID;
		if (pointerID != -1) {
			var exclusivePointer = ExclusivePointer.forStage(this.stage);
			var result = exclusivePointer.claimPointer(pointerID, this);
			if (!result) {
				event.preventDefault();
				return;
			}
		}
		var result = FeathersEvent.dispatch(this, FeathersEvent.OPENING);
		if (!result) {
			event.preventDefault();
			return;
		}
		this.clearFocusOnOpening();
		this.updateWithPullDistance();
		this._drawer.visible = true;
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
		this._drawer.visible = true;
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.visible = true;
		}
	}

	private function drawer_edgePuller_openHandler(event:Event):Void {
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.alpha = this._overlaySkinAlpha;
			this._currentOverlaySkin.visible = true;
		}
		this._opened = true;
		FeathersEvent.dispatch(this, Event.OPEN);
		this.setInvalid(STATE);
	}

	private function drawer_edgePuller_closeHandler(event:Event):Void {
		this._drawer.visible = false;
		if (this._currentOverlaySkin != null) {
			this._currentOverlaySkin.alpha = this._overlaySkinAlpha;
			this._currentOverlaySkin.visible = false;
		}
		this._opened = false;
		FeathersEvent.dispatch(this, Event.CLOSE);
		this.setInvalid(STATE);
	}

	private function drawer_edgePuller_cancelHandler(event:Event):Void {
		if (!this._opened) {
			this._drawer.visible = false;
			if (this._currentOverlaySkin != null) {
				this._currentOverlaySkin.alpha = this._overlaySkinAlpha;
				this._currentOverlaySkin.visible = false;
			}
		}
		FeathersEvent.dispatch(this, Event.CANCEL);
		this.setInvalid(STATE);
	}

	private function drawer_edgePuller_changeHandler(event:Event):Void {
		this.updateWithPullDistance();
	}

	private function drawer_addedToStageHandler(event:Event):Void {
		if (this._autoSizeMode == STAGE) {
			// if we validated before being added to the stage, or if we've
			// been removed from stage and added again, we need to be sure
			// that the new stage dimensions are accounted for.
			this.setInvalid(SIZE);

			this.addEventListener(Event.REMOVED_FROM_STAGE, drawer_removedFromStageHandler);
			this.stage.addEventListener(Event.RESIZE, drawer_stage_resizeHandler);
		}
	}

	private function drawer_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, drawer_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, drawer_stage_resizeHandler);
	}

	private function drawer_stage_resizeHandler(event:Event):Void {
		this.setInvalid(SIZE);
	}

	private function drawer_overlaySkin_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		this._clickStartX = event.localX;
		this._clickStartY = event.localY;
	}

	private function drawer_overlaySkin_clickHandler(event:MouseEvent):Void {
		if (!this._enabled || !this._clickOverlayToClose) {
			return;
		}
		var movementX = Math.abs(event.localX - this._clickStartX);
		var movementY = Math.abs(event.localY - this._clickStartY);
		if (movementX > MAX_CLICK_DISTANCE_FOR_CLOSE || movementY > MAX_CLICK_DISTANCE_FOR_CLOSE) {
			return;
		}
		this.opened = false;
	}

	private function drawer_overlaySkin_touchBeginHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		this._clickStartX = event.localX;
		this._clickStartY = event.localY;
	}

	private function drawer_overlaySkin_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		var movementX = Math.abs(event.localX - this._clickStartX);
		var movementY = Math.abs(event.localY - this._clickStartY);
		if (movementX > MAX_CLICK_DISTANCE_FOR_CLOSE || movementY > MAX_CLICK_DISTANCE_FOR_CLOSE) {
			return;
		}
		this.opened = false;
	}

	private function drawer_drawer_resizeHandler(event:Event):Void {
		if (this._ignoreDrawerResize) {
			return;
		}
		this.setInvalid(SIZE);
	}

	private function drawer_content_resizeHandler(event:Event):Void {
		if (this._ignoreContentResize) {
			return;
		}
		this._contentMeasurements.save(this.content);
		this.setInvalid(SIZE);
	}
}
