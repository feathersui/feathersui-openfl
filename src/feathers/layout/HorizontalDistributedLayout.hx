/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import openfl.events.Event;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;
import feathers.core.IValidating;

/**
	Positions items from left to right in a single row, and all items are
	resized to have the same width and height.

	@see [Tutorial: How to use HorizontalDistributedLayout with layout containers](https://feathersui.com/learn/haxe-openfl/horizontal-distributed-layout/)

	@since 1.0.0
**/
class HorizontalDistributedLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `HorizontalDistributedLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

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
	public var paddingTop(default, set):Float = 0.0;

	private function set_paddingTop(value:Float):Float {
		if (this.paddingTop == value) {
			return this.paddingTop;
		}
		this.paddingTop = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingTop;
	}

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
	public var paddingRight(default, set):Float = 0.0;

	private function set_paddingRight(value:Float):Float {
		if (this.paddingRight == value) {
			return this.paddingRight;
		}
		this.paddingRight = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingRight;
	}

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
	public var paddingBottom(default, set):Float = 0.0;

	private function set_paddingBottom(value:Float):Float {
		if (this.paddingBottom == value) {
			return this.paddingBottom;
		}
		this.paddingBottom = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingBottom;
	}

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
	public var paddingLeft(default, set):Float = 0.0;

	private function set_paddingLeft(value:Float):Float {
		if (this.paddingLeft == value) {
			return this.paddingLeft;
		}
		this.paddingLeft = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.paddingLeft;
	}

	/**
		The space, in pixels, between each two adjacent items in the layout.

		In the following example, the layout's gap is set to 20 pixels:

		```hx
		layout.gap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var gap(default, set):Float = 0.0;

	private function set_gap(value:Float):Float {
		if (this.gap == value) {
			return this.gap;
		}
		this.gap = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.gap;
	}

	/**
		The maximum width of an item in the layout.

		In the following example, the layout's maximum item width is set to 20
		pixels:

		```hx
		layout.maxItemWidth = 20.0;
		```

		@since 1.0.0
	**/
	public var maxItemWidth(default, set):Float = Math.POSITIVE_INFINITY;

	private function set_maxItemWidth(value:Float):Float {
		if (this.maxItemWidth == value) {
			return this.maxItemWidth;
		}
		this.maxItemWidth = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.maxItemWidth;
	}

	/**
		The minimum width of an item in the layout.

		In the following example, the layout's minimum item width is set to 20
		pixels:

		```hx
		layout.minItemWidth = 20.0;
		```

		@since 1.0.0
	**/
	public var minItemWidth(default, set):Float = 0.0;

	private function set_minItemWidth(value:Float):Float {
		if (this.minItemWidth == value) {
			return this.minItemWidth;
		}
		this.minItemWidth = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.minItemWidth;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.applyDistributedWidth(items, measurements.width, measurements.minWidth, measurements.maxWidth);

		var contentWidth = this.paddingLeft;
		var contentHeight = 0.0;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (contentHeight < item.height) {
				contentHeight = item.height;
			}
			if (measurements.height != null) {
				item.height = measurements.height;
			}
			item.x = contentWidth;
			contentWidth += item.width + this.gap;
		}
		contentWidth += this.paddingRight;
		if (items.length > 0) {
			contentWidth -= this.gap;
		}
		contentHeight += this.paddingTop + this.paddingBottom;

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

	private function applyDistributedWidth(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>,
			explicitMaxWidth:Null<Float>):Void {
		var maxMinWidth = 0.0;
		var totalPercentWidth = 0.0;
		for (item in items) {
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemMinWidth = 0.0;
			if (Std.is(item, IMeasureObject)) {
				var measureItem = cast(item, IMeasureObject);
				itemMinWidth = measureItem.minWidth;
			} else {
				itemMinWidth = item.width;
			}
			if (maxMinWidth < itemMinWidth) {
				maxMinWidth = itemMinWidth;
			}
			totalPercentWidth += 100.0;
		}
		var remainingWidth = 0.0;
		if (explicitWidth != null) {
			remainingWidth = explicitWidth;
		} else {
			remainingWidth = this.paddingLeft + this.paddingRight + ((maxMinWidth + this.gap) * items.length) - this.gap;
			if (explicitMinWidth != null && remainingWidth < explicitMinWidth) {
				remainingWidth = explicitMinWidth;
			} else if (explicitMaxWidth != null && remainingWidth > explicitMaxWidth) {
				remainingWidth = explicitMaxWidth;
			}
		}
		remainingWidth -= (this.paddingLeft + this.paddingRight + this.gap * (items.length - 1));
		if (remainingWidth < 0.0) {
			remainingWidth = 0.0;
		}
		var percentToPixels = remainingWidth / totalPercentWidth;
		for (item in items) {
			var itemWidth = percentToPixels * 100.0;
			if (itemWidth < this.minItemWidth) {
				itemWidth = this.minItemWidth;
			} else if (itemWidth > this.maxItemWidth) {
				itemWidth = this.maxItemWidth;
			}
			item.width = itemWidth;
			if (Std.is(item, IValidating)) {
				// changing the width of the item may cause its height
				// to change, so we need to validate. the height is
				// needed for measurement.
				cast(item, IValidating).validateNow();
			}
		}
	}
}
