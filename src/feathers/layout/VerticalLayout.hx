/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

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
import openfl.geom.Rectangle;

/**
	Positions items from top to bottom in a single column.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see [Tutorial: How to use VerticalLayout with layout containers](https://feathersui.com/learn/haxe-openfl/vertical-layout/)
	@see `feathers.layout.VerticalLayoutData`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class VerticalLayout extends EventDispatcher implements ILayout implements IDragDropLayout {
	/**
		Creates a new `VerticalLayout` object.

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
	@:bindable("change")
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
	@:bindable("change")
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
	@:bindable("change")
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
	@:bindable("change")
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

		@see `VerticalLayoutData.marginTop`
		@see `VerticalLayoutData.marginBottom`

		@since 1.0.0
	**/
	@:bindable("change")
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
	@:bindable("change")
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
		container.

		The following example aligns the container's content to the right:

		```haxe
		layout.horizontalAlign = RIGHT;
		```

		@default feathers.layout.HorizontalAlign.LEFT

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`
		@see `feathers.layout.HorizontalAlign.JUSTIFY`

		@since 1.0.0
	**/
	@:bindable("change")
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
		container. If the total height of the content is larger than the
		available height within the container, then the positioning of the items
		will always start from the top.

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		layout.

		The following example aligns the container's content to the bottom:

		```haxe
		layout.verticalAlign = BOTTOM;
		```

		@default feathers.layout.VerticalAlign.TOP

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`

		@since 1.0.0
	**/
	@:bindable("change")
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
		Indicates if the width of items should be reset if the `horizontalAlign`
		property is set to `HorizontalAlign.JUSTIFY` and the explicit width of
		the parent container is not set.

		@see `VerticalLayout.horizontalAlign`

		@since 1.0.0
	**/
	@:bindable("change")
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

	private var _percentWidthResetEnabled:Bool = false;

	/**
		Indicates if the width of items should be reset for re-measurement if
		the item has `HorizontalLayoutData` with the `percentWidth` property
		populated and the container's width is not explicitly set.

		Useful if changes to the items' content might affect their measured
		dimensions after applying the percentages. For instance, if changing a
		component's text should cause it to resize.

		@see `HorizontalLayoutData.percentWidth`

		@since 1.0.0
	**/
	@:bindable("change")
	public var percentWidthResetEnabled(get, set):Bool;

	private function get_percentWidthResetEnabled():Bool {
		return this._percentWidthResetEnabled;
	}

	private function set_percentWidthResetEnabled(value:Bool):Bool {
		if (this._percentWidthResetEnabled == value) {
			return this._percentWidthResetEnabled;
		}
		this._percentWidthResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._percentWidthResetEnabled;
	}

	private var _percentHeightResetEnabled:Bool = false;

	/**
		Indicates if the height of items should be reset for re-measurement if
		the item has `HorizontalLayoutData` with the `percentHeight` property
		populated and the container's height is not explicitly set.

		Useful if changes to the items' content might affect their measured
		dimensions after applying the percentages. For instance, if changing a
		component's text should cause it to resize.

		@see `HorizontalLayoutData.percentHeight`

		@since 1.0.0
	**/
	@:bindable("change")
	public var percentHeightResetEnabled(get, set):Bool;

	private function get_percentHeightResetEnabled():Bool {
		return this._percentHeightResetEnabled;
	}

	private function set_percentHeightResetEnabled(value:Bool):Bool {
		if (this._percentHeightResetEnabled == value) {
			return this._percentHeightResetEnabled;
		}
		this._percentHeightResetEnabled = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._percentHeightResetEnabled;
	}

	/**
		Sets all four padding properties to the same value.

		@see `VerticalLayout.paddingTop`
		@see `VerticalLayout.paddingRight`
		@see `VerticalLayout.paddingBottom`
		@see `VerticalLayout.paddingLeft`

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
		this.applyPercentHeight(items, measurements.height, measurements.minHeight, measurements.maxHeight, adjustedGap);

		var contentWidth = 0.0;
		var contentHeight = this._paddingTop;
		for (item in items) {
			var layoutData:VerticalLayoutData = null;
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
				layoutData = Std.downcast(layoutObject.layoutData, VerticalLayoutData);
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			if (contentWidth < item.width) {
				contentWidth = item.width;
			}
			if (layoutData != null && layoutData.marginTop != null) {
				contentHeight += layoutData.marginTop;
			}
			item.y = contentHeight;
			contentHeight += item.height + adjustedGap;
			if (layoutData != null && layoutData.marginBottom != null) {
				contentHeight += layoutData.marginBottom;
			}
		}
		var maxItemWidth = contentWidth;
		contentWidth += this._paddingLeft + this._paddingRight;
		contentHeight += this._paddingBottom;
		if (items.length > 0) {
			contentHeight -= adjustedGap;
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

		this.applyPercentWidth(items, viewPortWidth);
		this.applyHorizontalAlign(items, maxItemWidth, viewPortWidth);
		this.applyVerticalAlign(items, contentHeight - this._paddingTop - this._paddingBottom, viewPortHeight);

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

	/**
		@see `feathers.layout.IDragDropLayout.getDragDropIndex()`

		@since 1.3.0
	**/
	public function getDragDropIndex(items:Array<DisplayObject>, x:Float, y:Float, width:Float, height:Float):Int {
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var positionY = this._paddingTop;
		for (i in 0...items.length) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			var itemHeight = item.height;
			if (y < (positionY + (itemHeight / 2.0))) {
				return i;
			}
			positionY += itemHeight + adjustedGap;
		}
		return items.length;
	}

	/**
		@see `feathers.layout.IDragDropLayout.getDragDropRegion()`

		@since 1.3.0
	**/
	public function getDragDropRegion(items:Array<DisplayObject>, dropIndex:Int, x:Float, y:Float, width:Float, height:Float,
			result:Rectangle = null):Rectangle {
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
		}

		var maxIndex = dropIndex;
		if (maxIndex < 0) {
			maxIndex = 0;
		} else if (maxIndex > items.length) {
			maxIndex = items.length;
		}

		var positionY = this._paddingTop;
		for (i in 0...maxIndex) {
			var item = items[i];
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			positionY += item.height + adjustedGap;
		}

		if (result == null) {
			result = new Rectangle(0.0, positionY, width, 0.0);
		} else {
			result.setTo(0.0, positionY, width, 0.0);
		}
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>, measurements:Measurements) {
		var isJustified = this._horizontalAlign == JUSTIFY;
		var explicitContentWidth = measurements.width;
		if (explicitContentWidth != null) {
			explicitContentWidth -= (this._paddingLeft + this._paddingRight);
		}
		var explicitContentHeight = measurements.height;
		if (explicitContentHeight != null) {
			explicitContentHeight -= (this._paddingTop + this._paddingBottom);
		}
		for (item in items) {
			var percentWidth:Null<Float> = null;
			var percentHeight:Null<Float> = null;
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
				var layoutData = Std.downcast(layoutItem.layoutData, VerticalLayoutData);
				if (layoutData != null) {
					percentWidth = layoutData.percentWidth;
					percentHeight = layoutData.percentHeight;
				}
			}
			if (isJustified) {
				if (explicitContentWidth != null) {
					item.width = explicitContentWidth;
				} else if (this._justifyResetEnabled && (item is IMeasureObject)) {
					(cast item : IMeasureObject).resetWidth();
				}
			} else if (explicitContentWidth != null) {
				if (percentWidth != null) {
					if (percentWidth < 0.0) {
						percentWidth = 0.0;
					} else if (percentWidth > 100.0) {
						percentWidth = 100.0;
					}
					item.width = explicitContentWidth * (percentWidth / 100.0);
				}
			} else if (percentWidth != null && this._percentWidthResetEnabled && (item is IMeasureObject)) {
				(cast item : IMeasureObject).resetWidth();
			}
			if (percentHeight != null && this._percentHeightResetEnabled && explicitContentHeight == null && (item is IMeasureObject)) {
				(cast item : IMeasureObject).resetHeight();
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			if (isJustified && explicitContentWidth == null && measurements.maxWidth != null) {
				var maxExplicitContentWidth = measurements.maxWidth - this._paddingLeft - this._paddingRight;
				if (item.width > maxExplicitContentWidth) {
					item.width = maxExplicitContentWidth;
					if ((item is IValidating)) {
						(cast item : IValidating).validateNow();
					}
				}
			}
		}
	}

	private inline function applyHorizontalAlign(items:Array<DisplayObject>, maxItemWidth:Float, viewPortWidth:Float):Void {
		for (item in items) {
			var layoutObject:ILayoutObject = null;
			if ((item is ILayoutObject)) {
				layoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			switch (this._horizontalAlign) {
				case RIGHT:
					item.x = Math.max(this._paddingLeft, this._paddingLeft + (viewPortWidth - this._paddingLeft - this._paddingRight) - item.width);
				case CENTER:
					item.x = Math.max(this._paddingLeft, this._paddingLeft + (viewPortWidth - this._paddingLeft - this._paddingRight - item.width) / 2.0);
				case LEFT:
					item.x = this._paddingLeft;
				case JUSTIFY:
					item.x = this._paddingLeft;
					item.width = viewPortWidth - this._paddingLeft - this._paddingRight;
				default:
					throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
			}
		}
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, contentHeight:Float, viewPortHeight:Float):Void {
		var alignOffset = 0.0;
		var gapOffset = 0.0;
		var maxAlignmentHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		var adjustedGap = this._gap;
		var hasFlexGap = this._gap == (1.0 / 0.0);
		if (hasFlexGap) {
			adjustedGap = this._minGap;
			if (items.length > 1 && maxAlignmentHeight > contentHeight) {
				adjustedGap += (maxAlignmentHeight - contentHeight) / (items.length - 1);
			}
			gapOffset = adjustedGap - this._minGap;
		} else {
			alignOffset = switch (this._verticalAlign) {
				case TOP: 0.0;
				case BOTTOM: maxAlignmentHeight - contentHeight;
				case MIDDLE: (maxAlignmentHeight - contentHeight) / 2.0;
				default:
					throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
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
				layoutObject = cast item;
				if (!layoutObject.includeInLayout) {
					continue;
				}
			}
			item.y = Math.max(this._paddingTop, item.y + totalOffset);
			totalOffset += gapOffset;
		}
	}

	private function applyPercentWidth(items:Array<DisplayObject>, viewPortWidth:Float):Void {
		var availableWidth = viewPortWidth - this._paddingLeft - this._paddingRight;
		for (item in items) {
			if (!(item is ILayoutObject)) {
				continue;
			}
			var layoutItem:ILayoutObject = cast item;
			if (!layoutItem.includeInLayout) {
				continue;
			}
			var layoutData = Std.downcast(layoutItem.layoutData, VerticalLayoutData);
			if (layoutData == null) {
				continue;
			}
			var percentWidth = layoutData.percentWidth;
			if (percentWidth == null) {
				continue;
			}
			if (percentWidth < 0.0) {
				percentWidth = 0.0;
			} else if (percentWidth > 100.0) {
				percentWidth = 100.0;
			}
			var itemWidth = availableWidth * percentWidth / 100.0;
			if ((item is IMeasureObject)) {
				var measureItem:IMeasureObject = cast item;
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

	private function applyPercentHeight(items:Array<DisplayObject>, explicitHeight:Null<Float>, explicitMinHeight:Null<Float>, explicitMaxHeight:Null<Float>,
			adjustedGap:Float):Void {
		var pendingItems:Array<ILayoutObject> = [];
		var totalMeasuredHeight = 0.0;
		var totalMinHeight = 0.0;
		var totalPercentHeight = 0.0;
		for (item in items) {
			if ((item is ILayoutObject)) {
				var layoutItem:ILayoutObject = cast item;
				if (!layoutItem.includeInLayout) {
					continue;
				}
				var layoutData = Std.downcast(layoutItem.layoutData, VerticalLayoutData);
				if (layoutData != null) {
					var percentHeight = layoutData.percentHeight;
					if (percentHeight != null) {
						if (percentHeight < 0.0) {
							percentHeight = 0.0;
						}
						if ((layoutItem is IMeasureObject)) {
							var measureItem:IMeasureObject = cast layoutItem;
							totalMinHeight += measureItem.minHeight;
						}
						totalPercentHeight += percentHeight;
						if (layoutData.marginTop != null) {
							totalMeasuredHeight += layoutData.marginTop;
						}
						if (layoutData.marginBottom != null) {
							totalMeasuredHeight += layoutData.marginBottom;
						}
						totalMeasuredHeight += adjustedGap;
						pendingItems.push(layoutItem);
						continue;
					}
				}
			}
			totalMeasuredHeight += item.height + adjustedGap;
		}
		totalMeasuredHeight -= adjustedGap;
		totalMeasuredHeight += this._paddingTop + this._paddingBottom;
		if (totalPercentHeight < 100.0) {
			totalPercentHeight = 100.0;
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
		if (remainingHeight < 0.0) {
			remainingHeight = 0.0;
		}
		var needsAnotherPass = true;
		while (needsAnotherPass) {
			needsAnotherPass = false;
			var percentToPixels = remainingHeight / totalPercentHeight;
			for (layoutItem in pendingItems) {
				var layoutData = cast(layoutItem.layoutData, VerticalLayoutData);
				var percentHeight = layoutData.percentHeight;
				if (percentHeight < 0.0) {
					percentHeight = 0.0;
				}
				var itemHeight = percentToPixels * percentHeight;
				if ((layoutItem is IMeasureObject)) {
					var measureItem:IMeasureObject = cast layoutItem;
					var itemMinHeight = measureItem.explicitMinHeight;
					if (itemMinHeight != null && itemMinHeight > remainingHeight) {
						// we try to respect the item's minimum height, but
						// if it's larger than the remaining space, we need
						// to force it to fit
						itemMinHeight = remainingHeight;
					}
					if (itemHeight < itemMinHeight) {
						itemHeight = itemMinHeight;
						remainingHeight -= itemHeight;
						totalPercentHeight -= percentHeight;
						pendingItems.remove(layoutItem);
						needsAnotherPass = true;
					}
					// we don't check maxHeight here because it is used in
					// validateItems() for performance optimization, so it
					// isn't a real maximum
				}
				cast(layoutItem, DisplayObject).height = itemHeight;
				if ((layoutItem is IValidating)) {
					// changing the height of the item may cause its width
					// to change, so we need to validate. the width is needed
					// for measurement.
					(cast layoutItem : IValidating).validateNow();
				}
			}
		}
	}
}
