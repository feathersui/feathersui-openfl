/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

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
	The layout used by the `HDividedBox` component.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see `feathers.controls.HDividedBox`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class HDividedBoxLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `HDividedBoxLayout` object.

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

	private var _verticalAlign:VerticalAlign = JUSTIFY;

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

	private var _customItemWidths:Array<Null<Float>>;

	/**
		Set automatically by `HDividedBox`. Do not set this manually.

		@since 1.0.0
	**/
	@:bindable("change")
	public var customItemWidths(get, set):Array<Null<Float>>;

	private function get_customItemWidths():Array<Null<Float>> {
		return this._customItemWidths;
	}

	private function set_customItemWidths(value:Array<Null<Float>>):Array<Null<Float>> {
		if (this._customItemWidths == value) {
			return this._customItemWidths;
		}
		this._customItemWidths = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._customItemWidths;
	}

	private var _fallbackFluidIndex:Int = -1;

	/**
		Set automatically by `HDividedBox`. Do not set this manually.

		@since 1.0.0
	**/
	@:bindable("change")
	public var fallbackFluidIndex(get, set):Int;

	private function get_fallbackFluidIndex():Int {
		return this._fallbackFluidIndex;
	}

	private function set_fallbackFluidIndex(value:Int):Int {
		if (this._fallbackFluidIndex == value) {
			return this._fallbackFluidIndex;
		}
		this._fallbackFluidIndex = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._fallbackFluidIndex;
	}

	/**
		Sets all four padding properties to the same value.

		@see `HDividedBoxLayout.paddingTop`
		@see `HDividedBoxLayout.paddingRight`
		@see `HDividedBoxLayout.paddingBottom`
		@see `HDividedBoxLayout.paddingLeft`

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
		this.validateItems(items);
		this.applyPercentWidth(items, measurements.width, measurements.minWidth, measurements.maxWidth);

		var contentWidth = this._paddingLeft;
		var contentHeight = 0.0;
		var i = 0;
		while (i < items.length) {
			var item = items[i];
			var divider:DisplayObject = null;
			if (i > 0) {
				divider = items[i - 1];
			}
			if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
				// also skip the divider because this item is skipped
				i += 2;
				continue;
			}
			if ((divider is IValidating)) {
				(cast divider : IValidating).validateNow();
			}
			if (divider != null && divider.visible) {
				divider.x = contentWidth;
				contentWidth += divider.width;
			}
			if ((item is IValidating)) {
				// the width might have changed after the initial validation
				(cast item : IValidating).validateNow();
			}
			if (contentHeight < item.height) {
				contentHeight = item.height;
			}
			item.x = contentWidth;
			contentWidth += item.width;
			i += 2;
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
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>) {
		var i = 0;
		while (i < items.length) {
			var item = items[i];
			var divider:DisplayObject = null;
			if (i > 0) {
				divider = items[i - 1];
			}
			if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
				i += 2;
				continue;
			}
			if (this._customItemWidths != null && i < this._customItemWidths.length) {
				var itemWidth = this._customItemWidths[i];
				if (itemWidth != null) {
					item.width = itemWidth;
				}
			}
			if ((item is IValidating)) {
				(cast item : IValidating).validateNow();
			}
			if ((divider is IValidating)) {
				(cast divider : IValidating).validateNow();
			}
			i += 2;
		}
	}

	private inline function applyVerticalAlign(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		var i = 0;
		while (i < items.length) {
			var divider:DisplayObject = null;
			if (i > 0) {
				divider = items[i - 1];
			}
			if (divider == null) {
				i += 2;
				continue;
			}
			switch (this._verticalAlign) {
				case BOTTOM:
					divider.y = Math.max(this._paddingTop, this._paddingTop + (viewPortHeight - this._paddingTop - this._paddingBottom) - divider.height);
				case MIDDLE:
					divider.y = Math.max(this._paddingTop, this._paddingTop
						+ (viewPortHeight - this._paddingTop - this._paddingBottom - divider.height) / 2.0);
				case TOP:
					divider.y = this._paddingTop;
				case JUSTIFY:
					divider.y = this._paddingTop;
					divider.height = viewPortHeight - this._paddingTop - this._paddingBottom;
				default:
					throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
			}
			i += 2;
		}
	}

	private function applyPercentWidth(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>, explicitMaxWidth:Null<Float>):Void {
		var customWidthIndices:Array<Int> = [];
		var pendingIndices:Array<Int> = [];
		var totalMeasuredWidth = 0.0;
		var totalMinWidth = 0.0;
		var totalPercentWidth = 0.0;
		var fallbackFluidIndex = this._fallbackFluidIndex;
		var fallbackFallbackFluidIndex = -1;
		var i = 0;
		while (i < items.length) {
			var item = items[i];
			var divider:DisplayObject = null;
			if (i > 0) {
				divider = items[i - 1];
			}
			if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
				if (fallbackFluidIndex == i) {
					// no longer valid (probably a bug in HDividedBox)
					fallbackFluidIndex = -1;
				}
				i += 2;
				continue;
			}
			if (divider != null && divider.visible) {
				totalMeasuredWidth += divider.width;
			}
			fallbackFallbackFluidIndex = i;
			var nonDividerIndex = Math.floor(i / 2);
			var needsPercentWidth = true;
			if (this._customItemWidths != null && nonDividerIndex < this._customItemWidths.length) {
				var itemWidth = this._customItemWidths[nonDividerIndex];
				if (itemWidth != null) {
					needsPercentWidth = false;
					item.width = itemWidth;
					customWidthIndices.push(i);
					if ((item is IValidating)) {
						// changing the width of the item may cause its height
						// to change, so we need to validate. the height is
						// needed for measurement.
						(cast item : IValidating).validateNow();
					}
				}
			}
			if (needsPercentWidth) {
				var percentWidth = 100.0;
				if ((item is IMeasureObject)) {
					var measureItem:IMeasureObject = cast item;
					var columnExplicitMinWidth = measureItem.explicitMinWidth;
					if (columnExplicitMinWidth != null) {
						totalMinWidth += columnExplicitMinWidth;
					}
				}
				totalPercentWidth += percentWidth;
				pendingIndices.push(i);
				i += 2;
				continue;
			}
			totalMeasuredWidth += item.width;
			i += 2;
		}

		totalMeasuredWidth += this._paddingLeft + this._paddingRight;
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
		var needsAnotherPass = false;
		do {
			needsAnotherPass = false;
			var widthSum = 0.0;
			var percentToPixels = remainingWidth / totalPercentWidth;
			if (percentToPixels < 0.0) {
				percentToPixels = 0.0;
			}
			for (index in pendingIndices) {
				var item = items[index];
				var percentWidth = 100.0;
				// round to nearest pixel so that there aren't any visual gaps
				// between items. we'll append the remainder at the end.
				var itemWidth = Math.ffloor(percentToPixels * percentWidth);
				var columnMinWidth:Null<Float> = null;
				if ((item is IMeasureObject)) {
					var measureItem:IMeasureObject = cast item;
					columnMinWidth = measureItem.explicitMinWidth;
				}

				if (columnMinWidth != null) {
					if (columnMinWidth > remainingWidth) {
						// we try to respect the item's minimum width, but if
						// it's larger than the remaining space, we need to
						// force it to fit
						columnMinWidth = remainingWidth;
					}
					if (itemWidth < columnMinWidth) {
						itemWidth = columnMinWidth;
						remainingWidth -= itemWidth;
						totalPercentWidth -= percentWidth;
						pendingIndices.remove(index);
						needsAnotherPass = true;
					}
				}
				item.width = itemWidth;
				if ((item is IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					(cast item : IValidating).validateNow();
				}
				widthSum += itemWidth;
			}
			if (needsAnotherPass) {
				widthSum = 0.0;
			} else {
				remainingWidth -= widthSum;
			}
		} while (needsAnotherPass);
		if (remainingWidth > 0.0 && pendingIndices.length > 0) {
			// minimize the impact of a non-integer width by adding the
			// remainder to the final item
			var index = pendingIndices[pendingIndices.length - 1];
			var finalItem = items[index];
			finalItem.width += remainingWidth;
			return;
		}

		if (remainingWidth == 0.0) {
			return;
		}

		// if there is no fallback specified by HDividedBox,
		// or we never encountered the one that it specified,
		// use the last one that we discovered
		if (fallbackFluidIndex == -1 || fallbackFallbackFluidIndex < fallbackFluidIndex) {
			fallbackFluidIndex = fallbackFallbackFluidIndex;
		}
		if (fallbackFluidIndex != -1) {
			var fallbackItem = items[fallbackFluidIndex];
			var itemWidth = fallbackItem.width + remainingWidth;
			if (itemWidth < 0.0) {
				remainingWidth = itemWidth;
				itemWidth = 0.0;
				customWidthIndices.remove(fallbackFluidIndex);
			} else {
				remainingWidth = 0.0;
			}
			fallbackItem.width = itemWidth;
		}

		if (remainingWidth == 0.0) {
			return;
		}

		var offset = remainingWidth / customWidthIndices.length;
		for (index in customWidthIndices) {
			var item = items[index];
			item.width += offset;
		}
	}

	private function applyPercentHeight(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		var availableHeight = viewPortHeight - this._paddingTop - this._paddingBottom;
		var i = 0;
		while (i < items.length) {
			var item = items[i];
			if ((item is ILayoutObject) && !(cast item : ILayoutObject).includeInLayout) {
				i += 2;
				continue;
			}
			var itemHeight = availableHeight;
			if ((item is IMeasureObject)) {
				var measureItem:IMeasureObject = cast item;
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
			i += 2;
		}
	}
}
