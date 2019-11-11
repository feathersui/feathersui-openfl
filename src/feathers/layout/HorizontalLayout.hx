/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

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
	Positions items from top to bottom in a single column.

	@see [Tutorial: How to use HorizontalLayout with layout containers](https://feathersui.com/learn/haxe-openfl/horizontal-layout/)

	@since 1.0.0
**/
class HorizontalLayout extends EventDispatcher implements ILayout {
	public function new() {
		super();
	}

	/**
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
		@since 1.0.0
	**/
	public var horizontalAlign(default, set):HorizontalAlign = HorizontalAlign.LEFT;

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this.horizontalAlign == value) {
			return this.horizontalAlign;
		}
		this.horizontalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.horizontalAlign;
	}

	/**
		@since 1.0.0
	**/
	public var verticalAlign(default, set):VerticalAlign = VerticalAlign.TOP;

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this.verticalAlign == value) {
			return this.verticalAlign;
		}
		this.verticalAlign = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.verticalAlign;
	}

	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.validateItems(items);
		this.applyPercentWidth(items, measurements.width, measurements.minWidth, measurements.maxWidth);

		var maxHeight = 0.0;
		var xPosition = this.paddingLeft;
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
			if (maxHeight < item.height) {
				maxHeight = item.height;
			}
			item.x = xPosition;
			xPosition += item.width + this.gap;
		}
		xPosition += this.paddingRight;
		if (items.length > 0) {
			xPosition -= this.gap;
		}
		var yPosition = maxHeight + this.paddingTop + this.paddingBottom;

		var viewPortWidth = xPosition;
		if (measurements.width != null) {
			viewPortWidth = measurements.width;
		} else {
			if (measurements.minWidth != null && viewPortWidth < measurements.minWidth) {
				viewPortWidth = measurements.minWidth;
			} else if (measurements.maxWidth != null && viewPortWidth > measurements.maxWidth) {
				viewPortWidth = measurements.maxWidth;
			}
		}
		var viewPortHeight = yPosition;
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
		this.applyHorizontalAlign(items, xPosition, viewPortWidth);

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentWidth = xPosition;
		result.contentHeight = yPosition;
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
				case VerticalAlign.BOTTOM:
					item.y = this.paddingTop + (viewPortHeight - this.paddingTop - this.paddingBottom) - item.height;
				case VerticalAlign.MIDDLE:
					item.y = this.paddingTop + (viewPortHeight - this.paddingTop - this.paddingBottom - item.height) / 2.0;
				case VerticalAlign.JUSTIFY:
					item.y = this.paddingTop;
					item.height = viewPortHeight - this.paddingTop - this.paddingBottom;
				default:
					item.y = this.paddingTop;
			}
		}
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, contentWidth:Float, viewPortWidth:Float):Void {
		if (this.horizontalAlign != HorizontalAlign.RIGHT && this.horizontalAlign != HorizontalAlign.CENTER) {
			return;
		}
		var maxAlignmentWidth = viewPortWidth - this.paddingLeft - this.paddingRight;
		if (contentWidth >= maxAlignmentWidth) {
			return;
		}
		var horizontalOffset = 0.0;
		if (this.horizontalAlign == HorizontalAlign.RIGHT) {
			horizontalOffset = maxAlignmentWidth - contentWidth;
		} else if (this.horizontalAlign == HorizontalAlign.CENTER) {
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
			item.x += horizontalOffset;
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
		/*if (this.firstGap != null && itemCount > 1) {
				totalMeasuredWidth += (this.firstGap - this.gap);
			} else if (this.lastGap != null && itemCount > 2) {
				totalMeasuredWidth += (this.lastGap - this.gap);
		}*/
		totalMeasuredWidth += this.paddingLeft + this.paddingRight;
		if (totalPercentWidth < 100.0) {
			totalPercentWidth = 100.0;
		}
		var remainingWidth = explicitWidth;
		if (remainingWidth == null) {
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
		for (item in items) {
			if (Std.is(item, ILayoutObject)) {
				var layoutItem = cast(item, ILayoutObject);
				if (!layoutItem.includeInLayout) {
					continue;
				}
				var layoutData = Std.downcast(layoutItem.layoutData, VerticalLayoutData);
				if (layoutData != null) {
					var percentHeight = layoutData.percentHeight;
					if (percentHeight != null) {
						item.height = (viewPortHeight - this.paddingTop - this.paddingBottom) * percentHeight / 100.0;
					}
				}
			}
		}
	}
}
