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
	Positions items from top to bottom in a single column, and all items are
	resized to have the same width and height.

	@see [Tutorial: How to use VerticalDistributedLayout with layout containers](https://feathersui.com/learn/haxe-openfl/vertical-distributed-layout/)

	@since 1.0.0
**/
class VerticalDistributedLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `VerticalDistributedLayout` object.

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
		The maximum height of an item in the layout.

		In the following example, the layout's maximum item height is set to 20
		pixels:

		```hx
		layout.maxItemHeight = 20.0;
		```

		@since 1.0.0
	**/
	public var maxItemHeight(default, set):Float = Math.POSITIVE_INFINITY;

	private function set_maxItemHeight(value:Float):Float {
		if (this.maxItemHeight == value) {
			return this.maxItemHeight;
		}
		this.maxItemHeight = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.maxItemHeight;
	}

	/**
		The minimum height of an item in the layout.

		In the following example, the layout's minimum item height is set to 20
		pixels:

		```hx
		layout.minItemHeight = 20.0;
		```

		@since 1.0.0
	**/
	public var minItemHeight(default, set):Float = 0.0;

	private function set_minItemHeight(value:Float):Float {
		if (this.minItemHeight == value) {
			return this.minItemHeight;
		}
		this.minItemHeight = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.minItemHeight;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.applyDistributedHeight(items, measurements.height, measurements.minHeight, measurements.maxHeight);

		var contentWidth = 0.0;
		var contentHeight = this.paddingTop;
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
			if (contentWidth < item.width) {
				contentWidth = item.width;
			}
			item.y = contentHeight;
			contentHeight += item.height + this.gap;
		}
		contentWidth += this.paddingLeft + this.paddingRight;
		contentHeight += this.paddingBottom;
		if (items.length > 0) {
			contentHeight -= this.gap;
		}

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

	private inline function validateItems(items:Array<DisplayObject>) {
		for (item in items) {
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}

	private function applyDistributedHeight(items:Array<DisplayObject>, explicitHeight:Null<Float>, explicitMinHeight:Null<Float>,
			explicitMaxHeight:Null<Float>):Void {
		var maxMinHeight = 0.0;
		var totalPercentHeight = 0.0;
		for (item in items) {
			if (Std.is(item, IValidating)) {
				cast(item, IValidating).validateNow();
			}
			var itemMinHeight = 0.0;
			if (Std.is(item, IMeasureObject)) {
				var measureItem = cast(item, IMeasureObject);
				itemMinHeight = measureItem.minHeight;
			}
			if (maxMinHeight < itemMinHeight) {
				maxMinHeight = itemMinHeight;
			}
			totalPercentHeight += 100.0;
		}
		var remainingHeight = 0.0;
		if (explicitHeight != null) {
			remainingHeight = explicitHeight;
		} else {
			remainingHeight = this.paddingTop + this.paddingBottom + ((maxMinHeight + this.gap) * items.length) - this.gap;
			if (explicitMinHeight != null && remainingHeight < explicitMinHeight) {
				remainingHeight = explicitMinHeight;
			} else if (explicitMaxHeight != null && remainingHeight > explicitMaxHeight) {
				remainingHeight = explicitMaxHeight;
			}
		}
		remainingHeight -= (this.paddingTop + this.paddingBottom + this.gap * (items.length - 1));
		if (remainingHeight < 0.0) {
			remainingHeight = 0.0;
		}
		var percentToPixels = remainingHeight / totalPercentHeight;
		for (item in items) {
			var itemHeight = percentToPixels * 100.0;
			if (itemHeight < this.minItemHeight) {
				itemHeight = this.minItemHeight;
			} else if (itemHeight > this.maxItemHeight) {
				itemHeight = this.maxItemHeight;
			}
			item.height = itemHeight;
			if (Std.is(item, IValidating)) {
				// changing the width of the item may cause its height
				// to change, so we need to validate. the height is
				// needed for measurement.
				cast(item, IValidating).validateNow();
			}
		}
	}
}
