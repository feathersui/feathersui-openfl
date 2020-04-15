/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.MeasurementsUtil;
import feathers.layout.RelativePositions;
import feathers.core.IStateObserver;
import feathers.core.IStateContext;
import feathers.themes.steel.components.SteelCalloutStyles;
import openfl.display.Sprite;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import feathers.layout.Measurements;
import feathers.core.IMeasureObject;
import feathers.layout.RelativePosition;
import feathers.events.FeathersEvent;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import openfl.geom.Point;
import feathers.layout.HorizontalAlign;
import openfl.geom.Rectangle;
import feathers.core.PopUpManager;
import openfl.errors.ArgumentError;
import openfl.display.DisplayObject;
import feathers.core.FeathersControl;
#if air
import openfl.ui.Multitouch;
#end

/**
	A pop-up container that points at (or calls out) a specific region of the
	application (typically a specific control that triggered it).

	In the following example, a callout displaying a `Label` is shown when a
	`Button` is triggered:

	```hx
	function button_triggerHandler(event:TriggerEvent):Void {
		var button = cast(event.currentTarget, Button);

		var label = new Label();
		label.text = "Hello World!";

		Callout.show(label, button);
	}
	button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
	```

	@see [Tutorial: How to use the Callout component](https://feathersui.com/learn/haxe-openfl/callout/)
	@see `feathers.controls.TextCallout`
	@see `Callout.show()`

	@since 1.0.0
**/
@:styleContext
class Callout extends FeathersControl {
	private static final INVALIDATION_FLAG_ORIGIN:String = "origin";

	/**
		Creates a callout, and then positions and sizes it automatically based
		based on an origin component and an optional set of positions.

		In the following example, a callout displaying a `Label` is shown when
		a `Button` is triggered:

		```hx
		function button_triggerHandler(event:TriggerEvent):Void {
			var button = cast(event.currentTarget, Button);

			var label = new Label();
			label.text = "Hello World!";

			Callout.show(label, button);
		}
		button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
		```

		@since 1.0.0
	**/
	public static function show(content:DisplayObject, origin:DisplayObject, ?supportedPositions:RelativePositions, modal:Bool = true,
			?customOverlayFactory:() -> DisplayObject):Callout {
		var callout = new Callout();
		callout.content = content;
		return showCallout(callout, origin, supportedPositions, modal, customOverlayFactory);
	}

	private static function showCallout(callout:Callout, origin:DisplayObject, ?supportedPositions:RelativePositions, modal:Bool = true,
			?customOverlayFactory:() -> DisplayObject):Callout {
		callout.supportedPositions = supportedPositions;
		callout.origin = origin;
		var overlayFactory = customOverlayFactory;
		if (overlayFactory == null) {
			overlayFactory = () -> {
				var overlay = new Sprite();
				overlay.graphics.beginFill(0xff00ff, 0.0);
				overlay.graphics.drawRect(0, 0, 1, 1);
				overlay.graphics.endFill();
				return overlay;
			};
		}
		PopUpManager.addPopUp(callout, origin, modal, false, overlayFactory);
		return callout;
	}

	private static function positionBelowOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(TOP);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealXPosition = originBounds.x;
		switch (callout.horizontalAlign) {
			case CENTER:
				{
					idealXPosition += (originBounds.width - callout.width) / 2.0;
				}
			case RIGHT:
				{
					idealXPosition += originBounds.width - callout.width;
				}
			default:
		}
		var minX = stageTopLeft.x + callout.marginLeft;
		var maxX = stageBottomRight.x - callout.width - callout.marginRight;
		var xPosition = idealXPosition;
		if (xPosition < minX) {
			xPosition = minX;
		} else if (xPosition > maxX) {
			xPosition = maxX;
		}
		callout.x = xPosition;
		callout.y = originBounds.y + originBounds.height;
	}

	private static function positionAboveOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(BOTTOM);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealXPosition = originBounds.x;
		switch (callout.horizontalAlign) {
			case CENTER:
				{
					idealXPosition += (originBounds.width - callout.width) / 2.0;
				}
			case RIGHT:
				{
					idealXPosition += originBounds.width - callout.width;
				}
			default:
		}
		var minX = stageTopLeft.x + callout.marginLeft;
		var maxX = stageBottomRight.x - callout.width - callout.marginRight;
		var xPosition = idealXPosition;
		if (xPosition < minX) {
			xPosition = minX;
		} else if (xPosition > maxX) {
			xPosition = maxX;
		}
		callout.x = xPosition;
		callout.y = originBounds.y - callout.height;
	}

	private static function positionLeftOfOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(RIGHT);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealYPosition = originBounds.y;
		switch (callout.verticalAlign) {
			case MIDDLE:
				{
					idealYPosition += (originBounds.height - callout.height) / 2.0;
				}
			case BOTTOM:
				{
					idealYPosition += originBounds.height - callout.height;
				}
			default:
		}
		var minY = stageTopLeft.y + callout.marginTop;
		var maxY = stageBottomRight.y - callout.height - callout.marginBottom;
		var yPosition = idealYPosition;
		if (yPosition < minY) {
			yPosition = minY;
		} else if (yPosition > maxY) {
			yPosition = maxY;
		}
		callout.x = originBounds.x - callout.width;
		callout.y = yPosition;
	}

	private static function positionRightOfOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(RIGHT);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealYPosition = originBounds.y;
		switch (callout.verticalAlign) {
			case MIDDLE:
				{
					idealYPosition += (originBounds.height - callout.height) / 2.0;
				}
			case BOTTOM:
				{
					idealYPosition += originBounds.height - callout.height;
				}
			default:
		}
		var minY = stageTopLeft.y + callout.marginTop;
		var maxY = stageBottomRight.y - callout.height - callout.marginBottom;
		var yPosition = idealYPosition;
		if (yPosition < minY) {
			yPosition = minY;
		} else if (yPosition > maxY) {
			yPosition = maxY;
		}
		callout.x = originBounds.x + originBounds.width;
		callout.y = yPosition;
	}

	/**
		Creates a new `Callout` object.

		In general, a `Callout` shouldn't be instantiated directly with the
		constructor. Instead, use the static function `Callout.show()` to create
		a `Callout`, as this often requires less pop-up management code.

		@see `Callout.show()`

		@since 1.0.0
	**/
	public function new() {
		initializeCalloutTheme();
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, callout_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
	}

	private var _contentMeasurements:Measurements;

	/**
		The display object that will be displayed by the callout.

		This object may be resized to fit the callout's bounds. If the content
		needs to be scrolled when placed into a smaller region than its ideal
		size, it should be added to a `ScrollContainer`, and the
		`ScrollContainer` should be passed in as the content.

		In the following example, the callout's content is a bitmap:

		```hx
		callout.content = new Bitmap(bitmapData);
		```

		@see `Callout.show()`

		@since 1.0.0
	**/
	public var content(default, set):DisplayObject;

	private function set_content(value:DisplayObject):DisplayObject {
		if (this.content == value) {
			return this.content;
		}
		if (this.content != null) {
			this.content.removeEventListener(Event.RESIZE, callout_content_resizeHandler);
			this._contentMeasurements.restore(this.content);
		}
		this.content = value;
		if (this.content != null) {
			this.content.addEventListener(Event.RESIZE, callout_content_resizeHandler, false, 0, true);
			this.addChild(this.content);
			if (Std.is(this.content, IUIControl)) {
				cast(this.content, IUIControl).initializeNow();
			}
			if (this._contentMeasurements == null) {
				this._contentMeasurements = new Measurements(this.content);
			} else {
				this._contentMeasurements.save(this.content);
			}
		}
		this.setInvalid(InvalidationFlag.DATA);
		this.setInvalid(InvalidationFlag.SIZE);
		return this.content;
	}

	/**
		A callout may be positioned relative to another display object, known as
		the origin. Even if the position of the origin changes, the callout will
		be re-positioned automatically to always point at the origin.

		@see `Callout.show()`

		@since 1.0.0
	**/
	public var origin(default, set):DisplayObject;

	private function set_origin(value:DisplayObject):DisplayObject {
		if (this.origin == value) {
			return this.origin;
		}
		if (value != null && value.stage == null) {
			throw new ArgumentError("origin must be added to the stage.");
		}
		this.origin = value;
		this._lastPopUpOriginBounds = null;
		this.setInvalid(INVALIDATION_FLAG_ORIGIN);
		return this.origin;
	}

	/**
		The minimum space, in pixels, between the callout and the stage's top edge.

		In the following example, the callout's top margin is set to 20 pixels:

		```hx
		callout.marginTop = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var marginTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the callout and the stage's right edge.

		In the following example, the callout's right margin is set to 20 pixels:

		```hx
		callout.marginRight = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var marginRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the callout and the stage's bottom edge.

		In the following example, the callout's bottom margin is set to 20 pixels:

		```hx
		callout.marginBottom = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var marginBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the callout and the stage's left edge.

		In the following example, the callout's left margin is set to 20 pixels:

		```hx
		callout.marginLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var marginLeft:Float = 0.0;

	/**
		The minimum space, in pixels, between the callout's top edge and the
		callout's content.

		In the following example, the callout's top padding is set to 20 pixels:

		```hx
		callout.paddingTop = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the callout's right edge and the
		button's content.

		In the following example, the callout's right padding is set to 20
		pixels:

		```hx
		callout.paddingRight = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the callout's bottom edge and the
		callout's content.

		In the following example, the callout's bottom padding is set to 20
		pixels:

		```hx
		callout.paddingBottom = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the callout's left edge and the
		callout's content.

		In the following example, the callout's left padding is set to 20
		pixels:

		```hx
		callout.paddingLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		The horizontal alignment of the callout, relative to the origin, if the
		callout is positioned on the top or bottom side of the origin.

		The following example aligns the callout to the right:

		```hx
		callout.horizontalAlign = RIGHT;
		```

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	@:style
	public var horizontalAlign:HorizontalAlign = CENTER;

	/**
		The vertical alignment of the callout, relative to the origin, if the
		callout is positioned on the left or right side of the origin.

		The following example aligns the callout to the top:

		```hx
		callout.verticalAlign = TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`

		@since 1.0.0
	**/
	@:style
	public var verticalAlign:VerticalAlign = MIDDLE;

	/**
		The edge of the callout where the arrow is positioned.

		When calling `Callout.show()`, the `arrowPosition` property will be
		managed automatically and should not be modified.

		@since 1.0.0
	**/
	@:style
	public var arrowPosition:RelativePosition = TOP;

	private var _currentBackgroundSkin:DisplayObject;
	private var _backgroundSkinMeasurements:Measurements;

	/**
		The primary background to display behind the callout's content.

		In the following example, the callout's background is set to a bitmap:

		```hx
		callout.backgroundSkin = new Bitmap(bitmapData);
		```

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		The set of positions that the callout may appear at, relative to its
		origin. Positioning of the callout is attempted in order, and if the
		callout does not fit between the origin and the edge of the stage, the
		next position is attempted. If the callout is too large for all
		positions, the position with the most space will be used.

		@see `Callout.show()`

		@see `feathers.layout.RelativePosition.TOP`
		@see `feathers.layout.RelativePosition.RIGHT`
		@see `feathers.layout.RelativePosition.BOTTOM`
		@see `feathers.layout.RelativePosition.LEFT`

		@since 1.0.0
	**/
	public var supportedPositions:Array<RelativePosition>;

	private var _lastPopUpOriginBounds:Rectangle;
	private var _ignoreContentResize:Bool = false;

	/**
		Closes the callout, if opened.

		When the callout closes, it will dispatch an event of type
		`Event.CLOSE`.

		@see `openfl.events.Event.CLOSE`

		@since 1.0.0
	**/
	public function close():Void {
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}

	private function initializeCalloutTheme():Void {
		SteelCalloutStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var originInvalid = this.isInvalid(INVALIDATION_FLAG_ORIGIN);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (sizeInvalid) {
			this._lastPopUpOriginBounds = null;
			originInvalid = true;
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (originInvalid) {
			this.positionRelativeToOrigin();
		}

		if (stateInvalid || dataInvalid) {
			this.refreshEnabled();
		}

		sizeInvalid = this.measure() || sizeInvalid;

		this.layoutChildren();
	}

	private function measure():Bool {
		return this.measureWithArrowPosition(this.arrowPosition);
	}

	private function measureWithArrowPosition(position:RelativePosition):Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var stageWidth = 0.0;
		var stageHeight = 0.0;
		if (this.stage != null) {
			var stageTopLeft = new Point();
			stageTopLeft = this.globalToLocal(stageTopLeft);

			var stageBottomRight = new Point(this.stage.stageWidth, this.stage.stageHeight);
			stageBottomRight = this.globalToLocal(stageBottomRight);

			stageWidth = stageBottomRight.x - stageTopLeft.x;
			stageHeight = stageBottomRight.y - stageTopLeft.y;
		}

		var maxWidthWithStage = this.explicitMaxWidth;
		if (this.stage != null) {
			var stageMaxWidth = stageWidth - this.marginLeft - this.marginRight;
			if (maxWidthWithStage == null || maxWidthWithStage < stageMaxWidth) {
				maxWidthWithStage = stageMaxWidth;
			}
		} else {
			maxWidthWithStage = Math.POSITIVE_INFINITY;
		}
		var maxHeightWithStage = this.explicitMaxHeight;
		if (this.stage != null) {
			var stageMaxHeight = stageHeight - this.marginTop - this.marginBottom;
			if (maxHeightWithStage == null || maxHeightWithStage < stageMaxHeight) {
				maxHeightWithStage = stageMaxHeight;
			}
		} else {
			maxHeightWithStage = Math.POSITIVE_INFINITY;
		}

		if (this.backgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParentValues(this._backgroundSkinMeasurements, this.backgroundSkin, this.explicitWidth, this.explicitHeight,
				this.explicitMinWidth, this.explicitMinHeight, maxWidthWithStage, maxHeightWithStage);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this.backgroundSkin, IMeasureObject)) {
			measureSkin = cast(this.backgroundSkin, IMeasureObject);
		}

		if (Std.is(this.backgroundSkin, IValidating)) {
			cast(this.backgroundSkin, IValidating).validateNow();
		}

		var measureContent:IMeasureObject = null;
		if (Std.is(this.content, IMeasureObject)) {
			measureContent = cast(this.content, IMeasureObject);
		}
		if (this.content != null) {
			var oldIgnoreContentReize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			MeasurementsUtil.resetFluidlyWithParentValues(this._contentMeasurements, this.content,
				this.explicitWidth != null ? this.explicitWidth - this.paddingLeft - this.paddingRight : null,
				this.explicitHeight != null ? this.explicitHeight - this.paddingTop - this.paddingBottom : null,
				this.explicitMinWidth != null ? this.explicitMinWidth - this.paddingLeft - this.paddingRight : null,
				this.explicitMinHeight != null ? this.explicitMinHeight - this.paddingLeft - this.paddingRight : null,
				maxWidthWithStage != null ? maxWidthWithStage - this.paddingLeft - this.paddingRight : null,
				maxHeightWithStage != null ? maxHeightWithStage - this.paddingLeft - this.paddingRight : null);
			if (Std.is(this.content, IValidating)) {
				cast(this.content, IValidating).validateNow();
			}
			this._ignoreContentResize = oldIgnoreContentReize;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			var contentWidth = 0.0;
			if (this.content != null) {
				contentWidth = this.content.width;
			}
			newWidth = contentWidth + this.paddingLeft + this.paddingRight;
			if (this.backgroundSkin != null) {
				var backgroundWidth = this.backgroundSkin.width;
				if (newWidth < backgroundWidth) {
					newWidth = backgroundWidth;
				}
			}
		}
		var newHeight = this.explicitHeight;
		if (needsHeight) {
			var contentHeight = 0.0;
			if (this.content != null) {
				contentHeight = this.content.height;
			}
			newHeight = contentHeight + this.paddingTop + this.paddingBottom;
			if (this.backgroundSkin != null) {
				var backgroundHeight = this.backgroundSkin.height;
				if (newHeight < backgroundHeight) {
					newHeight = backgroundHeight;
				}
			}
		}
		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			var contentMinWidth = 0.0;
			if (measureContent != null) {
				contentMinWidth = measureContent.minWidth;
			} else if (this._contentMeasurements != null) {
				contentMinWidth = this._contentMeasurements.minWidth;
			}
			newMinWidth = contentMinWidth + this.paddingLeft + this.paddingRight;
			var backgroundMinWidth = 0.0;
			if (measureSkin != null) {
				backgroundMinWidth = measureSkin.minWidth;
			} else if (this._backgroundSkinMeasurements != null) {
				backgroundMinWidth = this._backgroundSkinMeasurements.minWidth;
			}
			if (newMinWidth < backgroundMinWidth) {
				newMinWidth = backgroundMinWidth;
			}
			if (newMinWidth > maxWidthWithStage) {
				newMinWidth = maxWidthWithStage;
			}
		}
		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			var contentMinHeight = 0.0;
			if (measureContent != null) {
				contentMinHeight = measureContent.minWidth;
			} else if (this._contentMeasurements != null) {
				contentMinHeight = this._contentMeasurements.minHeight;
			}
			newMinHeight = contentMinHeight + this.paddingTop + this.paddingBottom;
			var backgroundMinHeight = 0.0;
			if (measureSkin != null) {
				backgroundMinHeight = measureSkin.minHeight;
			} else if (this._backgroundSkinMeasurements != null) {
				backgroundMinHeight = this._backgroundSkinMeasurements.minHeight;
			}
			if (newMinHeight < backgroundMinHeight) {
				newMinHeight = backgroundMinHeight;
			}
			if (newMinHeight > maxHeightWithStage) {
				newMinHeight = maxHeightWithStage;
			}
		}
		var newMaxWidth = maxWidthWithStage;
		var newMaxHeight = maxHeightWithStage;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		return this.backgroundSkin;
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this, IStateContext) && Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext<Dynamic>);
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function refreshEnabled():Void {
		if (Std.is(this.content, IUIControl)) {
			cast(this.content, IUIControl).enabled = this.enabled;
		}
	}

	private function layoutChildren():Void {
		var xPosition = 0.0;
		var yPosition = 0.0;
		var widthOffset = 0.0;
		var heightOffset = 0.0;
		var backgroundWidth = this.actualWidth - xPosition - widthOffset;
		var backgroundHeight = this.actualHeight - yPosition - heightOffset;
		if (this.backgroundSkin != null) {
			this.backgroundSkin.x = xPosition;
			this.backgroundSkin.y = yPosition;
			this.backgroundSkin.width = backgroundWidth;
			this.backgroundSkin.height = backgroundHeight;
		}

		if (this.content != null) {
			this.content.x = xPosition + this.paddingLeft;
			this.content.y = yPosition + this.paddingTop;
			var oldIgnoreContentResize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			this.content.width = backgroundWidth - this.paddingLeft - this.paddingRight;
			this.content.height = backgroundHeight - this.paddingTop - this.paddingBottom;
			if (Std.is(this.content, IValidating)) {
				cast(this.content, IValidating).validateNow();
			}
			this._ignoreContentResize = oldIgnoreContentResize;
		}
	}

	private function positionRelativeToOrigin():Void {
		if (this.origin == null) {
			return;
		}
		var popUpRoot = PopUpManager.forStage(this.stage).root;
		var bounds = this.origin.getBounds(popUpRoot);
		var hasPopUpBounds = this._lastPopUpOriginBounds != null;
		if (hasPopUpBounds && this._lastPopUpOriginBounds.equals(bounds)) {
			return;
		}
		this._lastPopUpOriginBounds = bounds;

		var stageBottomRight = new Point(this.stage.stageWidth, this.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var upSpace = Math.NEGATIVE_INFINITY;
		var downSpace = Math.NEGATIVE_INFINITY;
		var rightSpace = Math.NEGATIVE_INFINITY;
		var leftSpace = Math.NEGATIVE_INFINITY;
		var positions = this.supportedPositions;
		if (positions == null) {
			positions = [BOTTOM, TOP, RIGHT, LEFT,];
		}
		for (position in positions) {
			switch (position) {
				case TOP:
					{
						// arrow is opposite, on bottom side
						this.measureWithArrowPosition(BOTTOM);
						upSpace = this._lastPopUpOriginBounds.y - this.actualHeight;
						if (upSpace >= this.marginTop) {
							positionAboveOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (upSpace < 0.0) {
							upSpace = 0.0;
						}
					}
				case RIGHT:
					{
						// arrow is opposite, on left side
						this.measureWithArrowPosition(LEFT);
						rightSpace = (stageBottomRight.x - this.actualWidth) - (this._lastPopUpOriginBounds.x + this._lastPopUpOriginBounds.width);
						if (rightSpace >= this.marginRight) {
							positionRightOfOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (rightSpace < 0.0) {
							rightSpace = 0.0;
						}
					}
				case LEFT:
					{
						// arrow is opposite, on right side
						this.measureWithArrowPosition(RIGHT);
						leftSpace = this._lastPopUpOriginBounds.x - this.actualWidth;
						if (leftSpace >= this.marginLeft) {
							positionLeftOfOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (leftSpace < 0.0) {
							leftSpace = 0.0;
						}
					}
				default: // bottom
					{
						// arrow is opposite, on top side
						this.measureWithArrowPosition(TOP);
						downSpace = (stageBottomRight.y - this.actualHeight) - (this._lastPopUpOriginBounds.y + this._lastPopUpOriginBounds.height);
						if (downSpace >= this.marginBottom) {
							positionBelowOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (downSpace < 0.0) {
							downSpace = 0.0;
						}
					}
			}
		}
		if (downSpace != Math.NEGATIVE_INFINITY && downSpace >= upSpace && downSpace >= rightSpace && downSpace >= leftSpace) {
			positionBelowOrigin(this, this._lastPopUpOriginBounds);
		} else if (upSpace != Math.NEGATIVE_INFINITY && upSpace >= rightSpace && upSpace >= leftSpace) {
			positionAboveOrigin(this, this._lastPopUpOriginBounds);
		} else if (rightSpace != Math.NEGATIVE_INFINITY && rightSpace >= leftSpace) {
			positionRightOfOrigin(this, this._lastPopUpOriginBounds);
		} else if (leftSpace != Math.NEGATIVE_INFINITY) {
			positionLeftOfOrigin(this, this._lastPopUpOriginBounds);
		} else {
			positionBelowOrigin(this, this._lastPopUpOriginBounds);
		}
	}

	private function callout_addedToStageHandler(event:Event):Void {
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, callout_stage_mouseDownHandler, false, 0, true);
		this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, callout_stage_touchBeginHandler, false, 0, true);
	}

	private function callout_removedFromStageHandler(event:Event):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, callout_stage_mouseDownHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, callout_stage_touchBeginHandler);

		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function callout_content_resizeHandler(event:Event):Void {
		if (this._ignoreContentResize) {
			return;
		}
		this.setInvalid(InvalidationFlag.SIZE);
	}

	private function callout_stage_mouseDownHandler(event:MouseEvent):Void {
		if (this.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.close();
	}

	private function callout_stage_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.close();
	}
}
