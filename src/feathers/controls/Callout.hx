/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.core.PopUpManager;
import feathers.events.FeathersEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.layout.RelativePositions;
import feathers.layout.VerticalAlign;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelCalloutStyles;
import feathers.utils.MeasurementsUtil;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
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

	@event openfl.events.Event.CLOSE Dispatched when the callout closes.

	@see [Tutorial: How to use the Callout component](https://feathersui.com/learn/haxe-openfl/callout/)
	@see `feathers.controls.TextCallout`
	@see `Callout.show()`

	@since 1.0.0
**/
@:event(openfl.events.Event.CLOSE)
@:meta(DefaultProperty("content"))
@defaultXmlProperty("content")
@:styleContext
class Callout extends FeathersControl {
	private static final INVALIDATION_FLAG_ORIGIN = InvalidationFlag.CUSTOM("origin");

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
		callout.y = originBounds.y + originBounds.height + callout.gap;
		callout._arrowOffset = idealXPosition - xPosition;
		callout.arrowPosition = TOP;
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
		callout.y = originBounds.y - callout.height - callout.gap;
		callout._arrowOffset = idealXPosition - xPosition;
		callout.arrowPosition = BOTTOM;
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
		callout.x = originBounds.x - callout.width - callout.gap;
		callout.y = yPosition;
		callout._arrowOffset = idealYPosition - yPosition;
		callout.arrowPosition = RIGHT;
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
		callout.x = originBounds.x + originBounds.width + callout.gap;
		callout.y = yPosition;
		callout._arrowOffset = idealYPosition - yPosition;
		callout.arrowPosition = LEFT;
	}

	/**
		Creates a new `Callout` object.

		In general, a `Callout` shouldn't be instantiated directly with the
		constructor. Instead, use the static function `Callout.show()` to create
		a `Callout`, as this often requires less pop-up management code.

		@see `Callout.show()`

		@since 1.0.0
	**/
	public function new(?content:DisplayObject) {
		initializeCalloutTheme();

		super();

		this.content = content;

		this.addEventListener(Event.ADDED_TO_STAGE, callout_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
	}

	private var _contentMeasurements:Measurements;

	private var _content:DisplayObject;

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
	public var content(get, set):DisplayObject;

	private function get_content():DisplayObject {
		return this._content;
	}

	private function set_content(value:DisplayObject):DisplayObject {
		if (this._content == value) {
			return this._content;
		}
		if (this._content != null) {
			this._content.removeEventListener(Event.RESIZE, callout_content_resizeHandler);
			this._contentMeasurements.restore(this._content);
			if (this._content.parent == this) {
				this.removeChild(this._content);
			}
		}
		this._content = value;
		if (this._content != null) {
			this._content.addEventListener(Event.RESIZE, callout_content_resizeHandler, false, 0, true);
			this.addChild(this._content);
			if ((this._content is IUIControl)) {
				cast(this._content, IUIControl).initializeNow();
			}
			if (this._contentMeasurements == null) {
				this._contentMeasurements = new Measurements(this._content);
			} else {
				this._contentMeasurements.save(this._content);
			}
		}
		this.setInvalid(DATA);
		this.setInvalid(SIZE);
		return this._content;
	}

	private var _origin:DisplayObject;

	/**
		A callout may be positioned relative to another display object, known as
		the origin. Even if the position of the origin changes, the callout will
		be re-positioned automatically to always point at the origin.

		@see `Callout.show()`

		@since 1.0.0
	**/
	public var origin(get, set):DisplayObject;

	private function get_origin():DisplayObject {
		return this._origin;
	}

	private function set_origin(value:DisplayObject):DisplayObject {
		if (this._origin == value) {
			return this._origin;
		}
		if (value != null && value.stage == null) {
			throw new ArgumentError("origin must be added to the stage.");
		}
		if (this._origin != null) {
			this._origin.removeEventListener(Event.REMOVED_FROM_STAGE, callout_origin_removedFromStageHandler);
			this.removeEventListener(Event.ENTER_FRAME, callout_enterFrameHandler);
		}
		this._origin = value;
		if (this._origin != null) {
			this._origin.addEventListener(Event.REMOVED_FROM_STAGE, callout_origin_removedFromStageHandler);
			if (this.stage != null) {
				this.addEventListener(Event.ENTER_FRAME, callout_enterFrameHandler);
			}
		}
		this._lastPopUpOriginBounds = null;
		this.setInvalid(INVALIDATION_FLAG_ORIGIN);
		return this._origin;
	}

	/**
		The space, in pixels, between the callout and its origin.

		In the following example, the callout's gap is set to 20 pixels:

		```hx
		callout.gap = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var gap:Float = 0.0;

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

	private var _currentArrowSkin:DisplayObject;

	/**
		The arrow skin to display when the arrow is positioned on the top of
		the callout.

		In the following example, the callout's top arrow skin is set to a
		bitmap:

		```hx
		callout.topArrowSkin = new Bitmap(bitmapData);
		```

		@since 1.0.0
	**/
	@:style
	public var topArrowSkin:DisplayObject = null;

	/**
		The arrow skin to display when the arrow is positioned on the right side
		of the callout.

		In the following example, the callout's right arrow skin is set to a
		bitmap:

		```hx
		callout.rightArrowSkin = new Bitmap(bitmapData);
		```

		@since 1.0.0
	**/
	@:style
	public var rightArrowSkin:DisplayObject = null;

	/**
		The arrow skin to display when the arrow is positioned on the bottom of
		the callout.

		In the following example, the callout's bottom arrow skin is set to a
		bitmap:

		```hx
		callout.bottomArrowSkin = new Bitmap(bitmapData);
		```

		@since 1.0.0
	**/
	@:style
	public var bottomArrowSkin:DisplayObject = null;

	/**
		The arrow skin to display when the arrow is positioned on the left side
		of the callout.

		In the following example, the callout's left arrow skin is set to a
		bitmap:

		```hx
		callout.leftArrowSkin = new Bitmap(bitmapData);
		```

		@since 1.0.0
	**/
	@:style
	public var leftArrowSkin:DisplayObject = null;

	/**
		The gap, in pixels, between the callout and the `topArrowSkin`.

		In the following example, the callout's top arrow gap is set to -1.0
		pixels:

		```hx
		callout.topArrowGap = -1.0;
		```

		@since 1.0.0
	**/
	@:style
	public var topArrowGap:Float = 0.0;

	/**
		The gap, in pixels, between the callout and the `rightArrowSkin`.

		In the following example, the callout's right arrow gap is set to -1.0
		pixels:

		```hx
		callout.rightArrowGap = -1.0;
		```

		@since 1.0.0
	**/
	@:style
	public var rightArrowGap:Float = 0.0;

	/**
		The gap, in pixels, between the callout and the `bottomArrowSkin`.

		In the following example, the callout's bottom arrow gap is set to -1.0
		pixels:

		```hx
		callout.bottomArrowGap = -1.0;
		```

		@since 1.0.0
	**/
	@:style
	public var bottomArrowGap:Float = 0.0;

	/**
		The gap, in pixels, between the callout and the `leftArrowSkin`.

		In the following example, the callout's left arrow gap is set to -1.0
		pixels:

		```hx
		callout.leftArrowGap = -1.0;
		```

		@since 1.0.0
	**/
	@:style
	public var leftArrowGap:Float = 0.0;

	private var _arrowOffset:Float = 0.0;

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
		@since 1.0.0
	**/
	public var closeOnPointerOutside:Bool = true;

	/**
		Closes the callout, if opened.

		When the callout closes, it will dispatch an event of type
		`Event.CLOSE`.

		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)

		@since 1.0.0
	**/
	public function close():Void {
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}

	/**
		Sets all four padding properties to the same value.

		@see `Callout.paddingTop`
		@see `Callout.paddingRight`
		@see `Callout.paddingBottom`
		@see `Callout.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	private function initializeCalloutTheme():Void {
		SteelCalloutStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var originInvalid = this.isInvalid(INVALIDATION_FLAG_ORIGIN);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (sizeInvalid) {
			this._lastPopUpOriginBounds = null;
			originInvalid = true;
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshArrowSkin();
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

	private function measureWithArrowPosition(arrowPosition:RelativePosition):Bool {
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
			maxWidthWithStage = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		var maxHeightWithStage = this.explicitMaxHeight;
		if (this.stage != null) {
			var stageMaxHeight = stageHeight - this.marginTop - this.marginBottom;
			if (maxHeightWithStage == null || maxHeightWithStage < stageMaxHeight) {
				maxHeightWithStage = stageMaxHeight;
			}
		} else {
			maxHeightWithStage = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}

		if (this._currentBackgroundSkin != null) {
			MeasurementsUtil.resetFluidlyWithParentValues(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this.explicitWidth,
				this.explicitHeight, this.explicitMinWidth, this.explicitMinHeight, maxWidthWithStage, maxHeightWithStage);
		}

		var measureSkin:IMeasureObject = null;
		if ((this._currentBackgroundSkin is IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if ((this._currentBackgroundSkin is IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		if ((this.topArrowSkin is IValidating)) {
			cast(this.topArrowSkin, IValidating).validateNow();
		}
		if ((this.rightArrowSkin is IValidating)) {
			cast(this.rightArrowSkin, IValidating).validateNow();
		}
		if ((this.bottomArrowSkin is IValidating)) {
			cast(this.bottomArrowSkin, IValidating).validateNow();
		}
		if ((this.leftArrowSkin is IValidating)) {
			cast(this.leftArrowSkin, IValidating).validateNow();
		}

		var leftOrRightArrowWidth = 0.0;
		var leftOrRightArrowHeight = 0.0;
		var topOrBottomArrowWidth = 0.0;
		var topOrBottomArrowHeight = 0.0;
		if (this._currentArrowSkin != null) {
			switch (arrowPosition) {
				case LEFT:
					leftOrRightArrowWidth = this.leftArrowSkin.width + this.leftArrowGap;
					leftOrRightArrowHeight = this.leftArrowSkin.height;
				case RIGHT:
					leftOrRightArrowWidth = this.rightArrowSkin.width + this.rightArrowGap;
					leftOrRightArrowHeight = this.rightArrowSkin.height;
				case BOTTOM:
					topOrBottomArrowWidth = this.bottomArrowSkin.width;
					topOrBottomArrowHeight = this.bottomArrowSkin.height + this.bottomArrowGap;
				default:
					topOrBottomArrowWidth = this.topArrowSkin.width;
					topOrBottomArrowHeight = this.topArrowSkin.height + this.topArrowGap;
			}
		}

		var measureContent:IMeasureObject = null;
		if ((this._content is IMeasureObject)) {
			measureContent = cast(this._content, IMeasureObject);
		}
		if (this._content != null) {
			var oldIgnoreContentResize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			MeasurementsUtil.resetFluidlyWithParentValues(this._contentMeasurements, this._content,
				this.explicitWidth != null ? this.explicitWidth
					- leftOrRightArrowWidth
					- this.paddingLeft
					- this.paddingRight : null,
				this.explicitHeight != null ? this.explicitHeight
					- topOrBottomArrowHeight
					- this.paddingTop
					- this.paddingBottom : null,
				this.explicitMinWidth != null ? this.explicitMinWidth
					- leftOrRightArrowWidth
					- this.paddingLeft
					- this.paddingRight : null,
				this.explicitMinHeight != null ? this.explicitMinHeight
					- topOrBottomArrowHeight
					- this.paddingLeft
					- this.paddingRight : null,
				maxWidthWithStage != null ? maxWidthWithStage
				- leftOrRightArrowWidth
				- this.paddingLeft
				- this.paddingRight : null,
				maxHeightWithStage != null ? maxHeightWithStage
				- topOrBottomArrowHeight
				- this.paddingLeft
				- this.paddingRight : null);
			if ((this._content is IValidating)) {
				cast(this._content, IValidating).validateNow();
			}
			this._ignoreContentResize = oldIgnoreContentResize;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			var contentWidth = 0.0;
			if (this._content != null) {
				contentWidth = this._content.width;
			}
			if (contentWidth < topOrBottomArrowWidth) {
				contentWidth = topOrBottomArrowWidth;
			}
			newWidth = contentWidth + this.paddingLeft + this.paddingRight;
			if (this._currentBackgroundSkin != null) {
				var backgroundWidth = this._currentBackgroundSkin.width;
				if (newWidth < backgroundWidth) {
					newWidth = backgroundWidth;
				}
			}
			newWidth += leftOrRightArrowWidth;
		}
		var newHeight = this.explicitHeight;
		if (needsHeight) {
			var contentHeight = 0.0;
			if (this._content != null) {
				contentHeight = this._content.height;
			}
			if (contentHeight < leftOrRightArrowHeight) {
				contentHeight = leftOrRightArrowHeight;
			}
			newHeight = contentHeight + this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				var backgroundHeight = this._currentBackgroundSkin.height;
				if (newHeight < backgroundHeight) {
					newHeight = backgroundHeight;
				}
			}
			newHeight += topOrBottomArrowHeight;
		}
		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			var contentMinWidth = 0.0;
			if (measureContent != null) {
				contentMinWidth = measureContent.minWidth;
			} else if (this._contentMeasurements != null) {
				contentMinWidth = this._contentMeasurements.minWidth;
			}
			if (contentMinWidth < topOrBottomArrowWidth) {
				contentMinWidth = topOrBottomArrowWidth;
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
			newMinWidth += leftOrRightArrowWidth;
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
			if (contentMinHeight < leftOrRightArrowHeight) {
				contentMinHeight = leftOrRightArrowHeight;
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
			newMinHeight += topOrBottomArrowHeight;
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
		this.addCurrentBackgroundSkin(this._currentBackgroundSkin);
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			cast(skin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = this;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshArrowSkin():Void {
		var oldArrowSkin = this._currentArrowSkin;
		this._currentArrowSkin = this.getCurrentArrowSkin();
		if (oldArrowSkin == this._currentArrowSkin) {
			return;
		}
		this.removeCurrentArrowSkin(oldArrowSkin);
		if ((this._currentArrowSkin is IProgrammaticSkin)) {
			cast(this._currentArrowSkin, IProgrammaticSkin).uiContext = this;
		}
		this.addChild(this._currentArrowSkin);
	}

	private function getCurrentArrowSkin():DisplayObject {
		return switch (this.arrowPosition) {
			case LEFT: leftArrowSkin;
			case RIGHT: rightArrowSkin;
			case BOTTOM: bottomArrowSkin;
			default: topArrowSkin;
		}
	}

	private function removeCurrentArrowSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshEnabled():Void {
		if ((this._content is IUIControl)) {
			cast(this._content, IUIControl).enabled = this._enabled;
		}
	}

	private function layoutChildren():Void {
		if ((this._currentArrowSkin is IValidating)) {
			cast(this._currentArrowSkin, IValidating).validateNow();
		}
		var xPosition = 0.0;
		var yPosition = 0.0;
		var widthOffset = 0.0;
		var heightOffset = 0.0;
		if (this._currentArrowSkin != null) {
			switch (this.arrowPosition) {
				case LEFT:
					xPosition = this._currentArrowSkin.width + this.leftArrowGap;
				case RIGHT:
					widthOffset = this._currentArrowSkin.width + this.rightArrowGap;
				case BOTTOM:
					heightOffset = this._currentArrowSkin.height + this.bottomArrowGap;
				default: // TOP
					yPosition = this._currentArrowSkin.height + this.topArrowGap;
			}
		}
		var backgroundWidth = this.actualWidth - xPosition - widthOffset;
		var backgroundHeight = this.actualHeight - yPosition - heightOffset;
		if (this._currentBackgroundSkin != null) {
			this._currentBackgroundSkin.x = xPosition;
			this._currentBackgroundSkin.y = yPosition;
			this._currentBackgroundSkin.width = backgroundWidth;
			this._currentBackgroundSkin.height = backgroundHeight;
		}

		if (this._currentArrowSkin != null) {
			var contentWidth = backgroundWidth - this.paddingLeft - this.paddingRight;
			var contentHeight = backgroundHeight - this.paddingTop - this.paddingBottom;
			switch (this.arrowPosition) {
				case LEFT:
					this.leftArrowSkin.x = xPosition - this.leftArrowSkin.width - this.leftArrowGap;
					var leftArrowSkinY = this._arrowOffset + yPosition + this.paddingTop;
					if (this.verticalAlign == MIDDLE) {
						leftArrowSkinY += Math.fround((contentHeight - this.leftArrowSkin.height) / 2.0);
					} else if (this.verticalAlign == BOTTOM) {
						leftArrowSkinY += (contentHeight - this.leftArrowSkin.height);
					}
					var minLeftArrowSkinY = yPosition + this.paddingTop;
					if (minLeftArrowSkinY > leftArrowSkinY) {
						leftArrowSkinY = minLeftArrowSkinY;
					} else {
						var maxLeftArrowSkinY = yPosition + this.paddingTop + contentHeight - this.leftArrowSkin.height;
						if (maxLeftArrowSkinY < leftArrowSkinY) {
							leftArrowSkinY = maxLeftArrowSkinY;
						}
					}
					this.leftArrowSkin.y = leftArrowSkinY;
				case RIGHT:
					this.rightArrowSkin.x = xPosition + backgroundWidth + this.rightArrowGap;
					var rightArrowSkinY = this._arrowOffset + yPosition + this.paddingTop;
					if (this.verticalAlign == MIDDLE) {
						rightArrowSkinY += Math.fround((contentHeight - this.rightArrowSkin.height) / 2.0);
					} else if (this.verticalAlign == BOTTOM) {
						rightArrowSkinY += (contentHeight - this.rightArrowSkin.height);
					}
					var minRightArrowSkinY = yPosition + this.paddingTop;
					if (minRightArrowSkinY > rightArrowSkinY) {
						rightArrowSkinY = minRightArrowSkinY;
					} else {
						var maxRightArrowSkinY = yPosition + this.paddingTop + contentHeight - this.rightArrowSkin.height;
						if (maxRightArrowSkinY < rightArrowSkinY) {
							rightArrowSkinY = maxRightArrowSkinY;
						}
					}
					this.rightArrowSkin.y = rightArrowSkinY;
				case BOTTOM:
					var bottomArrowSkinX = this._arrowOffset + xPosition + this.paddingLeft;
					if (this.horizontalAlign == CENTER) {
						bottomArrowSkinX += Math.fround((contentWidth - this.bottomArrowSkin.width) / 2.0);
					} else if (this.horizontalAlign == RIGHT) {
						bottomArrowSkinX += (contentWidth - this.bottomArrowSkin.width);
					}
					var minBottomArrowSkinX = xPosition + this.paddingLeft;
					if (minBottomArrowSkinX > bottomArrowSkinX) {
						bottomArrowSkinX = minBottomArrowSkinX;
					} else {
						var maxBottomArrowSkinX = xPosition + this.paddingLeft + contentWidth - this.bottomArrowSkin.width;
						if (maxBottomArrowSkinX < bottomArrowSkinX) {
							bottomArrowSkinX = maxBottomArrowSkinX;
						}
					}
					this.bottomArrowSkin.x = bottomArrowSkinX;
					this.bottomArrowSkin.y = yPosition + backgroundHeight + this.bottomArrowGap;
				default: // TOP
					var topArrowSkinX = this._arrowOffset + xPosition + this.paddingLeft;
					if (this.horizontalAlign == CENTER) {
						topArrowSkinX += Math.fround((contentWidth - this.topArrowSkin.width) / 2.0);
					} else if (this.horizontalAlign == RIGHT) {
						topArrowSkinX += (contentWidth - this.topArrowSkin.width);
					}
					var minTopArrowSkinX = xPosition + this.paddingLeft;
					if (minTopArrowSkinX > topArrowSkinX) {
						topArrowSkinX = minTopArrowSkinX;
					} else {
						var maxTopArrowSkinX = xPosition + this.paddingLeft + contentWidth - this.topArrowSkin.width;
						if (maxTopArrowSkinX < topArrowSkinX) {
							topArrowSkinX = maxTopArrowSkinX;
						}
					}
					this.topArrowSkin.x = topArrowSkinX;
					this.topArrowSkin.y = yPosition - this.topArrowSkin.height - this.topArrowGap;
			}
		}

		if (this._content != null) {
			this._content.x = xPosition + this.paddingLeft;
			this._content.y = yPosition + this.paddingTop;
			var oldIgnoreContentResize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			this._content.width = backgroundWidth - this.paddingLeft - this.paddingRight;
			this._content.height = backgroundHeight - this.paddingTop - this.paddingBottom;
			if ((this._content is IValidating)) {
				cast(this._content, IValidating).validateNow();
			}
			this._ignoreContentResize = oldIgnoreContentResize;
		}
	}

	private function checkForOriginMoved():Bool {
		if (this._origin == null) {
			return false;
		}
		var popUpRoot = PopUpManager.forStage(this.stage).root;

		#if flash
		var bounds = this._origin.getBounds(popUpRoot);
		#else
		// OpenFL bug: doesn't account for scrollRect in getBounds() calls
		var originTopLeft = new Point(this.origin.x, this.origin.y);
		originTopLeft = origin.parent.localToGlobal(originTopLeft);
		originTopLeft = popUpRoot.globalToLocal(originTopLeft);

		var originBottomRight = new Point(this.origin.x + this.origin.width, this.origin.y + this.origin.height);
		originBottomRight = origin.parent.localToGlobal(originBottomRight);
		originBottomRight = popUpRoot.globalToLocal(originBottomRight);

		var bounds = new Rectangle(originTopLeft.x, originTopLeft.y, originBottomRight.x - originTopLeft.x, originBottomRight.y - originTopLeft.y);
		#end

		var hasPopUpBounds = this._lastPopUpOriginBounds != null;
		if (hasPopUpBounds && this._lastPopUpOriginBounds.equals(bounds)) {
			return false;
		}
		this._lastPopUpOriginBounds = bounds;
		return true;
	}

	private function positionRelativeToOrigin():Void {
		// make sure that everything is up-to-date
		this.checkForOriginMoved();

		var popUpRoot = PopUpManager.forStage(this.stage).root;
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
		if (this._origin != null) {
			this.addEventListener(Event.ENTER_FRAME, callout_enterFrameHandler);
		}
	}

	private function callout_removedFromStageHandler(event:Event):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, callout_stage_mouseDownHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, callout_stage_touchBeginHandler);
		this.removeEventListener(Event.ENTER_FRAME, callout_enterFrameHandler);

		FeathersEvent.dispatch(this, Event.CLOSE);
	}

	private function callout_enterFrameHandler(event:Event):Void {
		if (!this.checkForOriginMoved()) {
			return;
		}
		this.setInvalid(INVALIDATION_FLAG_ORIGIN);
	}

	private function callout_origin_removedFromStageHandler(event:Event):Void {
		this.close();
	}

	private function callout_content_resizeHandler(event:Event):Void {
		if (this._ignoreContentResize) {
			return;
		}
		this._contentMeasurements.save(this.content);
		this.setInvalid(SIZE);
	}

	private function callout_stage_mouseDownHandler(event:MouseEvent):Void {
		if (!this.closeOnPointerOutside) {
			return;
		}
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
		if (!this.closeOnPointerOutside) {
			return;
		}
		if (this.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.close();
	}
}
