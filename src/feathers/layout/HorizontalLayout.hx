/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Positions items from left to right in a single row.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see [Tutorial: How to use HorizontalLayout with layout containers](https://feathersui.com/learn/haxe-openfl/horizontal-layout/)
	@see `feathers.layout.HorizontalLayoutData`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class HorizontalLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `HorizontalLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _paddingTop:Float = 0.0;

	/**
		The space, in pixels, between the parent container's top edge and its
		content.

		In the following example, the layout's top padding is set to 20 pixels:

		```haxe
		layout.paddingTop = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
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

		```haxe
		layout.paddingRight = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
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

		```haxe
		layout.paddingBottom = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
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

		```haxe
		layout.paddingLeft = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
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

	private var _gap:Float = 0.0;

	/**
		The space, in pixels, between each two adjacent items in the layout.

		If the `gap` is set to `Math.POSITIVE_INFINITY`, the items will be
		positioned as far apart as possible. In this case, the gap will never be
		smaller than `minGap`.

		In the following example, the layout's gap is set to 20 pixels:

		```haxe
		layout.gap = 20.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var gap(get, set):Float;

	private function get_gap():Float {
		return this._gap;
	}

	private function set_gap(value:Float):Float {
		if (this._gap == value) {
			return this._gap;
		}
		this._gap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._gap;
	}

	private var _minGap:Float = 0.0;

	/**
		If the value of the `gap` property is `Math.POSITIVE_INFINITY`, meaning
		that the gap will fill as much space as possible and position the items
		as far from each other as they can go without going outside of the view
		port bounds, the final calculated value of the gap will not be smaller
		than the value of the `minGap` property.

		In the following example, the layout's minimum gap is set to 4 pixels:

		```haxe
		layout.minGap = 4.0;
		```

		@default 0.0

		@since 1.0.0
	**/
	public var minGap(get, set):Float;

	private function get_minGap():Float {
		return this._minGap;
	}

	private function set_minGap(value:Float):Float {
		if (this._minGap == value) {
			return this._minGap;
		}
		this._minGap = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._minGap;
	}

	private var _horizontalAlign:HorizontalAlign = LEFT;

	/**
		How the content is positioned horizontally (along the x-axis) within the
		container. If the total width of the content is larger than the
		available width within the container, then the positioning of the items
		will always start from the left.

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the right:

		```haxe
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	public var horizontalAlign(get, set):HorizontalAlign;

	private function get_horizontalAlign():HorizontalAlign {
		return this._horizontalAlign;
	}

	private function set_horizontalAlign(value:HorizontalAlign):HorizontalAlign {
		if (this._horizontalAlign == value) {
			return this._horizontalAlign;
		}
		this._horizontalAlign = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._horizontalAlign;
	}

	private var _verticalAlign:VerticalAlign = TOP;

	/**
		How the content is positioned vertically (along the y-axis) within the
		container.

		The following example aligns the container's content to the bottom:

		```haxe
		layout.verticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`
		@see `feathers.layout.VerticalAlign.JUSTIFY`

		@since 1.0.0
	**/
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

	private var _justifyResetEnabled:Bool = false;

	/**
		Indicates if the height of items should be reset if the `verticalAlign`
		property is set to `VerticalAlign.JUSTIFY` and the explicit height of
		the parent container is not set.

		@see `HorizontalLayout.verticalAlign`

		@since 1.0.0
	**/
	public var justifyResetEnabled(get, set):Bool;

	private function get_justifyResetEnabled():Bool {
		return this._justifyResetEnabled;
	}

	private function set_justifyResetEnabled(value:Bool):Bool {
		if (this._justifyResetEnabled == value) {
			return this._justifyResetEnabled;
		}
		this._justifyResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._justifyResetEnabled;
	}

	/**
		Sets all four padding properties to the same value.

		@see `HorizontalLayout.paddingTop`
		@see `HorizontalLayout.paddingRight`
		@see `HorizontalLayout.paddingBottom`
		@see `HorizontalLayout.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		this.validateItems(items, measurements);
		this.applyPercentWidth(items, measurements.width, measurements.minWidth, measurements.maxWidth, adjustedGap);

		var contentWidth = this._paddingLeft;
		var contentHeight = 0.0;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (contentHeight < item.height) {
				contentHeight = item.height;
			}
			item.x = contentWidth;
			contentWidth += item.width + adjustedGap;
		}
		var maxItemHeight = contentHeight;
		contentWidth += this._paddingRight;
		if (items.length > 0) {
			contentWidth -= adjustedGap;
		}
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
		this.applyVerticalAlign(items, maxItemHeight, viewPortHeight);
		this.applyHorizontalAlign(items, contentWidth - this._paddingLeft - this._paddingRight, viewPortWidth);

		if (contentWidth < viewPortWidth) {
			contentWidth = viewPortWidth;
		}
		if (contentHeight < viewPortHeight) {
			contentHeight = viewPortHeight;
		}

		if (result == null) {
			result = new LayoutBoundsResult();
		}
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>, measurements:Measurements) {
		var isJustified = this._verticalAlign == JUSTIFY;
		var justifyHeight = measurements.height;
		if (justifyHeight != null) {
			justifyHeight -= (this._paddingTop + this._paddingBottom);
		}
		for (item in items) {
			if (isJustified) {
				if (justifyHeight != null) {
					item.height = justifyHeight;
				} else if (this._justifyResetEnabled && (item is IMeasureObject)) {
					cast(item, IMeasureObject).resetHeight();
				}
			} else if (justifyHeight != null) {
				var percentHeight:Null<Float> = null;
				if ((item is ILayoutObject)) {
					var layoutItem = cast(item, ILayoutObject);
					if (!layoutItem.includeInLayout) {
						continue;
					}
					var layoutData = Std.downcast(layoutItem.layoutData, HorizontalLayoutData);
					if (layoutData != null) {
						percentHeight = layoutData.percentHeight;
					}
				}
				if (percentHeight != null) {
					if (percentHeight < 0.0) {
						percentHeight = 0.0;
					} else if (percentHeight > 100.0) {
						percentHeight = 100.0;
					}
					item.height = justifyHeight * (percentHeight / 100.0);
				}
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (isJustified && justifyHeight == null && measurements.maxHeight != null) {
				var maxJustifyHeight = measurements.maxHeight - this._paddingTop - this._paddingBottom;
				if (item.height > maxJustifyHeight) {
					item.height = maxJustifyHeight;
					if ((item is IValidating)) {
						cast(item, IValidating).validateNow();
					}
				}
			}
		}
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, maxItemHeight:Float, viewPortHeight:Float):Void {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			switch (this._verticalAlign) {
				case BOTTOM:
					item.y = Math.max(this._paddingTop, this._paddingTop + (viewPortHeight - this._paddingTop - this._paddingBottom) - item.height);
				case MIDDLE:
					item.y = Math.max(this._paddingTop, this._paddingTop + (viewPortHeight - this._paddingTop - this._paddingBottom - item.height) / 2.0);
				case TOP:
					item.y = this._paddingTop;
				case JUSTIFY:
					item.y = this._paddingTop;
					item.height = viewPortHeight - this._paddingTop - this._paddingBottom;
				default:
					throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
			}
		}
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, contentWidth:Float, viewPortWidth:Float):Void {
		var alignOffset = 0.0;
		var gapOffset = 0.0;
		var maxAlignmentWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
			if (items.length > 1 && maxAlignmentWidth > contentWidth) {
				adjustedGap += (maxAlignmentWidth - contentWidth) / (items.length - 1);
			}
			gapOffset = adjustedGap - this._minGap;
		} else {
			alignOffset = switch (this._horizontalAlign) {
				case LEFT: 0.0;
				case RIGHT: maxAlignmentWidth - contentWidth;
				case CENTER: (maxAlignmentWidth - contentWidth) / 2.0;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
			}
			if (alignOffset < 0.0) {
				alignOffset = 0.0;
			}
		}
		if (alignOffset == 0.0 && gapOffset == 0.0) {
			return;
		}

		var totalOffset = alignOffset;
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast(item, ILayoutObject);
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.x = Math.max(this._paddingLeft, item.x + totalOffset);
			totalOffset += gapOffset;
		}
	}

	private function applyPercentWidth(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>, explicitMaxWidth:Null<Float>,
			adjustedGap:Float):Void {
		var pendingItems:Array<ILayoutObject> = [];
		var totalMeasuredWidth = 0.0;
		var totalMinWidth = 0.0;
		var totalPercentWidth = 0.0;
		for (item in items) {
			if ((item is ILayoutObject)) {
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
						if ((layoutItem is IMeasureObject)) {
							var measureItem = cast(layoutItem, IMeasureObject);
							totalMinWidth += measureItem.minWidth;
						}
						totalPercentWidth += percentWidth;
						totalMeasuredWidth += adjustedGap;
						pendingItems.push(layoutItem);
						continue;
					}
				}
			}
			totalMeasuredWidth += item.width + adjustedGap;
		}
		totalMeasuredWidth -= adjustedGap;
		totalMeasuredWidth += this._paddingLeft + this._paddingRight;
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
				if ((layoutItem is IMeasureObject)) {
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
				if ((layoutItem is IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					cast(layoutItem, IValidating).validateNow();
				}
			}
		}
	}

	private function applyPercentHeight(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		var availableHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		for (item in items) {
			if (!(item is ILayoutObject)) {
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
			if ((item is IMeasureObject)) {
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
