/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;

@:event(openfl.events.Event.CHANGE)

/**
	The layout used by the `HDividedBox` component.

	@see `feathers.controls.HDividedBox`

	@since 1.0.0
**/
class HDividedBoxLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `HDividedBoxLayout` object.

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

	private var _verticalAlign:VerticalAlign = JUSTIFY;

	/**
		How the content is positioned vertically (along the y-axis) within the
		container.

		The following example aligns the container's content to the bottom:

		```hx
		layout.verticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`

		@since 1.0.0
	**/
	@:flash.property
	public var verticalAlign(get, set):VerticalAlign;

	private function get_verticalAlign():VerticalAlign {
		return this._verticalAlign;
	}

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this._verticalAlign == value) {
			return this._verticalAlign;
		}
		this._verticalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._verticalAlign;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.validateItems(items);
		this.applyPercentWidth(items, measurements.width, measurements.minWidth, measurements.maxWidth);

		var contentWidth = this._paddingLeft;
		var contentHeight = 0.0;
		for (item in items) {
			if (Std.is(item, IValidating)) {
				// the width might have changed after the initial validation
				cast(item, IValidating).validateNow();
			}
			if (contentHeight < item.height) {
				contentHeight = item.height;
			}
			item.x = contentWidth;
			contentWidth += item.width;
		}
		contentWidth += this._paddingRight;
		contentHeight += this._paddingTop + this._paddingBottom;

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

		this.applyPercentHeight(items, viewPortHeight);
		this.applyVerticalAlign(items, viewPortHeight);

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

	private inline function applyVerticalAlign(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		for (i in 0...items.length) {
			var isDivider = i % 2 == 1;
			if (!isDivider) {
				continue;
			}
			var item = items[i];
			switch (this._verticalAlign) {
				case BOTTOM:
					item.y = Math.max(this._paddingTop, this._paddingTop + (viewPortHeight - this._paddingTop - this._paddingBottom) - item.height);
				case MIDDLE:
					item.y = Math.max(this._paddingTop, this._paddingTop + (viewPortHeight - this._paddingTop - this._paddingBottom - item.height) / 2.0);
				case JUSTIFY:
					item.y = this._paddingTop;
					item.height = viewPortHeight - this._paddingTop - this._paddingBottom;
				default:
					item.y = this._paddingTop;
			}
		}
	}

	private function applyPercentWidth(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>,
			explicitMaxWidth:Null<Float>):Void {
		var totalMeasuredWidth = 0.0;
		var totalMinWidth = 0.0;
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
				if (measureItem.explicitWidth == null) {
					fluidItemIndex = i;
				}
			}
			totalMeasuredWidth += item.width;
		}
		totalMeasuredWidth += this._paddingLeft + this._paddingRight;
		if (fluidItemIndex == -1 && items.length > 0) {
			fluidItemIndex = items.length - 1;
		}
		if (fluidItemIndex == -1) {
			return;
		}
		this._fluidItemIndex = fluidItemIndex;
		var fluidItem = items[fluidItemIndex];
		totalMeasuredWidth -= fluidItem.width;
		if (Std.is(fluidItem, IMeasureObject)) {
			var measureItem = cast(fluidItem, IMeasureObject);
			totalMinWidth += measureItem.minWidth;
		}

		var remainingWidth = 0.0;
		if (explicitWidth != null) {
			remainingWidth = explicitWidth;
		} else {
			remainingWidth = totalMeasuredWidth + totalMinWidth;
			if (explicitMinWidth != null && remainingWidth < explicitMinWidth) {
				remainingWidth = explicitMinWidth;
			} else if (explicitMaxWidth != null && remainingWidth > explicitMaxWidth) {
				remainingWidth = explicitMaxWidth;
			}
		}
		remainingWidth -= totalMeasuredWidth;
		if (remainingWidth <= 0.0) {
			return;
		}
		fluidItem.width = remainingWidth;
	}

	private function applyPercentHeight(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		var availableHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		for (i in 0...items.length) {
			var isDivider = i % 2 == 1;
			if (isDivider) {
				continue;
			}
			var item = items[i];
			var itemHeight = availableHeight;
			if (Std.is(item, IMeasureObject)) {
				var measureItem = cast(item, IMeasureObject);
				var itemMinHeight = measureItem.explicitMinHeight;
				if (itemMinHeight != null) {
					// we try to respect the minHeight, but not
					// when it's larger than 100%
					if (itemMinHeight > availableHeight) {
						itemMinHeight = availableHeight;
					}
					if (itemHeight < itemMinHeight) {
						itemHeight = itemMinHeight;
					}
				}
				var itemMaxHeight = measureItem.explicitMaxHeight;
				if (itemMaxHeight != null && itemHeight > itemMaxHeight) {
					itemHeight = itemMaxHeight;
				}
			}
			item.height = itemHeight;
		}
	}
}
