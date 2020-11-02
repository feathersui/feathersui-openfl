/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.events.FeathersEvent;
import feathers.core.IMeasureObject;
import openfl.events.Event;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;
import feathers.core.IValidating;

@:event(openfl.events.Event.CHANGE)

/**
	The layout used by the `VDividedBox` component.

	@see `feathers.controls.VDividedBox`

	@since 1.0.0
**/
class VDividedBoxLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `VDividedBoxLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _fluidItemIndex:Int = -1;

	private var _paddingTop:Float = 0.0;

	/**
		The space, in pixels, between the parent container's top edge and its
		content.

		In the following example, the layout's top padding is set to 20 pixels:

		```hx
		layout.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingTop(get, set):Float;

	private function get_paddingTop():Float {
		return this._paddingTop;
	}

	private function set_paddingTop(value:Float):Float {
		if (this._paddingTop == value) {
			return this._paddingTop;
		}
		this._paddingTop = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingTop;
	}

	private var _paddingRight:Float = 0.0;

	/**
		The space, in pixels, between the parent container's right edge and its
		content.

		In the following example, the layout's right padding is set to 20 pixels:

		```hx
		layout.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingRight(get, set):Float;

	private function get_paddingRight():Float {
		return this._paddingRight;
	}

	private function set_paddingRight(value:Float):Float {
		if (this._paddingRight == value) {
			return this._paddingRight;
		}
		this._paddingRight = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingRight;
	}

	private var _paddingBottom:Float = 0.0;

	/**
		The space, in pixels, between the parent container's bottom edge and its
		content.

		In the following example, the layout's bottom padding is set to 20 pixels:

		```hx
		layout.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingBottom(get, set):Float;

	private function get_paddingBottom():Float {
		return this._paddingBottom;
	}

	private function set_paddingBottom(value:Float):Float {
		if (this._paddingBottom == value) {
			return this._paddingBottom;
		}
		this._paddingBottom = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingBottom;
	}

	private var _paddingLeft:Float = 0.0;

	/**
		The space, in pixels, between the parent container's left edge and its
		content.

		In the following example, the layout's left padding is set to 20 pixels:

		```hx
		layout.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var paddingLeft(get, set):Float;

	private function get_paddingLeft():Float {
		return this._paddingLeft;
	}

	private function set_paddingLeft(value:Float):Float {
		if (this._paddingLeft == value) {
			return this._paddingLeft;
		}
		this._paddingLeft = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._paddingLeft;
	}

	private var _horizontalAlign:HorizontalAlign = JUSTIFY;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		container.

		The following example aligns the container's content to the right:

		```hx
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`
		@see `feathers.layout.HorizontalAlign.JUSTIFY`

		@since 1.0.0
	**/
	@:flash.property
	public var horizontalAlign(get, set):HorizontalAlign;

	private function get_horizontalAlign():HorizontalAlign {
		return this._horizontalAlign;
	}

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this._horizontalAlign == value) {
			return this._horizontalAlign;
		}
		this._horizontalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this._horizontalAlign;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.validateItems(items);
		this.applyPercentHeight(items, measurements.height, measurements.minHeight, measurements.maxHeight);

		var contentWidth = 0.0;
		var contentHeight = this._paddingTop;
		for (item in items) {
			if (Std.is(item, IValidating)) {
				// the height might have changed after the initial validation
				cast(item, IValidating).validateNow();
			}
			if (contentWidth < item.width) {
				contentWidth = item.width;
			}
			item.y = contentHeight;
			contentHeight += item.height;
		}
		contentWidth += this._paddingLeft + this._paddingRight;
		contentHeight += this._paddingBottom;

		var viewPortWidth = contentWidth;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}
		var viewPortHeight = contentHeight;
		if (measurements.height != null) {
			viewPortHeight = measurements.height;
		} else {
			if (measurements.minHeight != null && viewPortHeight < measurements.minHeight) {
				viewPortHeight = measurements.minHeight;
			} else if (measurements.maxHeight != null && viewPortHeight > measurements.maxHeight) {
				viewPortHeight = measurements.maxHeight;
			}
		}

		this.applyPercentWidth(items, viewPortWidth);
		this.applyHorizontalAlign(items, viewPortWidth);

		if (contentWidth < viewPortWidth) {
			contentWidth = viewPortWidth;
		}
		if (contentHeight < viewPortHeight) {
			contentHeight = viewPortHeight;
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>) {
		for (item in items) {
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, viewPortWidth:Float):Void {
		for (i in 0...items.length) {
			var isDivider = i % 2 == 1;
			if (!isDivider) {
				continue;
			}
			var item = items[i];
			switch (this._horizontalAlign) {
				case RIGHT:
					item.x = Math.max(this._paddingLeft, this._paddingLeft + (viewPortWidth - this._paddingLeft - this._paddingRight) - item.width);
				case CENTER:
					item.x = Math.max(this._paddingLeft, this._paddingLeft + (viewPortWidth - this._paddingLeft - this._paddingRight - item.width) / 2.0);
				case JUSTIFY:
					item.x = this._paddingLeft;
					item.width = viewPortWidth - this._paddingLeft - this._paddingRight;
				default:
					item.x = this._paddingLeft;
			}
		}
	}

	private function applyPercentWidth(items:Array<DisplayObject>, viewPortWidth:Float):Void {
		var availableWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		for (i in 0...items.length) {
			var isDivider = i % 2 == 1;
			if (isDivider) {
				continue;
			}
			var item = items[i];
			var itemWidth = availableWidth;
			if (Std.is(item, IMeasureObject)) {
				var measureItem = cast(item, IMeasureObject);
				var itemMinWidth = measureItem.explicitMinWidth;
				if (itemMinWidth != null) {
					// we try to respect the minWidth, but not
					// when it's larger than 100%
					if (itemMinWidth > availableWidth) {
						itemMinWidth = availableWidth;
					}
					if (itemWidth < itemMinWidth) {
						itemWidth = itemMinWidth;
					}
				}
				var itemMaxWidth = measureItem.explicitMaxWidth;
				if (itemMaxWidth != null && itemWidth > itemMaxWidth) {
					itemWidth = itemMaxWidth;
				}
			}
			item.width = itemWidth;
		}
	}

	private function applyPercentHeight(items:Array<DisplayObject>, explicitHeight:Null<Float>, explicitMinHeight:Null<Float>,
			explicitMaxHeight:Null<Float>):Void {
		var totalMeasuredHeight = 0.0;
		var totalMinHeight = 0.0;
		var fluidItemIndex = this._fluidItemIndex;
		if (fluidItemIndex >= items.length) {
			fluidItemIndex = -1;
		}
		var needsNewFluidItem = fluidItemIndex == -1;
		for (i in 0...items.length) {
			var isDivider = i % 2 == 1;
			var item = items[i];
			if (needsNewFluidItem && !isDivider && Std.is(item, IMeasureObject)) {
				var measureItem = cast(item, IMeasureObject);
				if (measureItem.explicitHeight == null) {
					fluidItemIndex = i;
				}
			}
			totalMeasuredHeight += item.height;
		}
		totalMeasuredHeight += this._paddingTop + this._paddingBottom;
		if (fluidItemIndex == -1 && items.length > 0) {
			fluidItemIndex = items.length - 1;
		}
		if (fluidItemIndex == -1) {
			return;
		}
		this._fluidItemIndex = fluidItemIndex;
		var fluidItem = items[fluidItemIndex];
		totalMeasuredHeight -= fluidItem.height;
		if (Std.is(fluidItem, IMeasureObject)) {
			var measureItem = cast(fluidItem, IMeasureObject);
			totalMinHeight += measureItem.minHeight;
		}

		var remainingHeight = 0.0;
		if (explicitHeight != null) {
			remainingHeight = explicitHeight;
		} else {
			remainingHeight = totalMeasuredHeight + totalMinHeight;
			if (explicitMinHeight != null && remainingHeight < explicitMinHeight) {
				remainingHeight = explicitMinHeight;
			} else if (explicitMaxHeight != null && remainingHeight > explicitMaxHeight) {
				remainingHeight = explicitMaxHeight;
			}
		}
		remainingHeight -= totalMeasuredHeight;
		if (remainingHeight <= 0.0) {
			return;
		}
		fluidItem.height = remainingHeight;
	}
}
