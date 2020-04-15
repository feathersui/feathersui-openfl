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
	Positions items from left to right in a single row.

	@see [Tutorial: How to use HorizontalLayout with layout containers](https://feathersui.com/learn/haxe-openfl/horizontal-layout/)
	@see `feathers.layout.HorizontalLayoutData`

	@since 1.0.0
**/
class HorizontalLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `HorizontalLayout` object.

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
		How the content is positioned horizontally (along the x-axis) within the
		container.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the right:

		```hx
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	public var horizontalAlign(default, set):HorizontalAlign = LEFT;

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this.horizontalAlign == value) {
			return this.horizontalAlign;
		}
		this.horizontalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.horizontalAlign;
	}

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
	public var verticalAlign(default, set):VerticalAlign = TOP;

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this.verticalAlign == value) {
			return this.verticalAlign;
		}
		this.verticalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.verticalAlign;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.validateItems(items);
		this.applyPercentWidth(items, measurements.width, measurements.minWidth, measurements.maxWidth);

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

		this.applyPercentHeight(items, viewPortHeight);
		this.applyVerticalAlign(items, viewPortHeight);
		this.applyHorizontalAlign(items, contentWidth, viewPortWidth);

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
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			switch (this.verticalAlign) {
				case BOTTOM:
					item.y = Math.max(this.paddingTop, this.paddingTop + (viewPortHeight - this.paddingTop - this.paddingBottom) - item.height);
				case MIDDLE:
					item.y = Math.max(this.paddingTop, this.paddingTop + (viewPortHeight - this.paddingTop - this.paddingBottom - item.height) / 2.0);
				case JUSTIFY:
					item.y = this.paddingTop;
					item.height = viewPortHeight - this.paddingTop - this.paddingBottom;
				default:
					item.y = this.paddingTop;
			}
		}
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, contentWidth:Float, viewPortWidth:Float):Void {
		if (this.horizontalAlign != RIGHT && this.horizontalAlign != CENTER) {
			return;
		}
		var maxAlignmentWidth = viewPortWidth - this.paddingLeft - this.paddingRight;
		if (contentWidth >= maxAlignmentWidth) {
			return;
		}
		var horizontalOffset = 0.0;
		if (this.horizontalAlign == RIGHT) {
			horizontalOffset = maxAlignmentWidth - contentWidth;
		} else if (this.horizontalAlign == CENTER) {
			horizontalOffset = (maxAlignmentWidth - contentWidth) / 2.0;
		}
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if (Std.is(item, ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.x = Math.max(this.paddingLeft, item.x + horizontalOffset);
		}
	}

	private function applyPercentWidth(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>,
			explicitMaxWidth:Null<Float>):Void {
		var pendingItems:Array<ILayoutObject> = [];
		var totalMeasuredWidth = 0.0;
		var totalMinWidth = 0.0;
		var totalPercentWidth = 0.0;
		for (item in items) {
			if (Std.is(item, ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
				var layoutData = Std.downcast(layoutItem.layoutData, HorizontalLayoutData);
				if (layoutData != null) {
					var percentWidth = layoutData.percentWidth;
					if (percentWidth != null) {
						if (percentWidth < 0.0) {
							percentWidth = 0.0;
						}
						if (Std.is(layoutItem, IMeasureObject)) {
							var measureItem = cast(layoutItem, IMeasureObject);
							totalMinWidth += measureItem.minWidth;
						}
						totalPercentWidth += percentWidth;
						totalMeasuredWidth += this.gap;
						pendingItems.push(layoutItem);
						continue;
					}
				}
			}
			totalMeasuredWidth += item.width + this.gap;
		}
		totalMeasuredWidth -= this.gap;
		totalMeasuredWidth += this.paddingLeft + this.paddingRight;
		if (totalPercentWidth < 100.0) {
			totalPercentWidth = 100.0;
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
		if (remainingWidth < 0.0) {
			remainingWidth = 0.0;
		}
		var needsAnotherPass = true;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			var percentToPixels = remainingWidth / totalPercentWidth;
			for (layoutItem in pendingItems) {
				var layoutData = cast(layoutItem.layoutData, HorizontalLayoutData);
				var percentWidth = layoutData.percentWidth;
				if (percentWidth < 0.0) {
					percentWidth = 0.0;
				}
				var itemWidth = percentToPixels * percentWidth;
				if (Std.is(layoutItem, IMeasureObject)) {
					var measureItem = cast(layoutItem, IMeasureObject);
					var itemMinWidth = measureItem.explicitMinWidth;
					if (itemMinWidth != null && itemMinWidth > remainingWidth) {
						// we try to respect the item's minimum width, but if
						// it's larger than the remaining space, we need to
						// force it to fit
						itemMinWidth = remainingWidth;
					}
					if (itemWidth < itemMinWidth) {
						itemWidth = itemMinWidth;
						remainingWidth -= itemWidth;
						totalPercentWidth -= percentWidth;
						pendingItems.remove(layoutItem);
						needsAnotherPass = true;
					}
					// we don't check maxWidth here because it is used in
					// validateItems() for performance optimization, so it
					// isn't a real maximum
				}
				cast(layoutItem, DisplayObject).width = itemWidth;
				if (Std.is(layoutItem, IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					cast(layoutItem, IValidating).validateNow();
				}
			}
		}
	}

	private function applyPercentHeight(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		var availableHeight = viewPortHeight - this.paddingTop - this.paddingBottom;
		for (item in items) {
			if (!Std.is(item, ILayoutObject)) {
				continue;
			}
			var layoutItem = cast(item, ILayoutObject);
			if (!layoutItem.includeInLayout) {
				continue;
			}
			var layoutData = Std.downcast(layoutItem.layoutData, HorizontalLayoutData);
			if (layoutData == null) {
				continue;
			}
			var percentHeight = layoutData.percentHeight;
			if (percentHeight == null) {
				continue;
			}
			if (percentHeight < 0.0) {
				percentHeight = 0.0;
			} else if (percentHeight > 100.0) {
				percentHeight = 100.0;
			}
			var itemHeight = availableHeight * percentHeight / 100.0;
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
