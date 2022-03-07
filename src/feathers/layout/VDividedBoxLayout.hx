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
	The layout used by the `VDividedBox` component.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@see `feathers.controls.VDividedBox`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class VDividedBoxLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `VDividedBoxLayout` object.

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

	private var _horizontalAlign:HorizontalAlign = JUSTIFY;

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

	private var _customItemHeights:Array<Null<Float>>;

	/**
		Set automatically by `VDividedBox`. Do not set this manually.

		@since 1.0.0
	**/
	public var customItemHeights(get, set):Array<Null<Float>>;

	private function get_customItemHeights():Array<Null<Float>> {
		return this._customItemHeights;
	}

	private function set_customItemHeights(value:Array<Null<Float>>):Array<Null<Float>> {
		if (this._customItemHeights == value) {
			return this._customItemHeights;
		}
		this._customItemHeights = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._customItemHeights;
	}

	private var _fallbackFluidIndex:Int = -1;

	/**
		Set automatically by `VDividedBox`. Do not set this manually.

		@since 1.0.0
	**/
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

		@see `VDividedBoxLayout.paddingTop`
		@see `VDividedBoxLayout.paddingRight`
		@see `VDividedBoxLayout.paddingBottom`
		@see `VDividedBoxLayout.paddingLeft`

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
		this.applyPercentHeight(items, measurements.height, measurements.minHeight, measurements.maxHeight);

		var contentWidth = 0.0;
		var contentHeight = this._paddingTop;
		for (item in items) {
			if ((item is IValidating)) {
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
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = contentWidth;
		result.contentHeight = contentHeight;
		result.viewPortWidth = viewPortWidth;
		result.viewPortHeight = viewPortHeight;
		return result;
	}

	private inline function validateItems(items:Array<DisplayObject>) {
		for (i in 0...items.length) {
			var item = items[i];
			var isDivider = i % 2 == 1;
			if (!isDivider) {
				if (this._customItemHeights != null && i < this._customItemHeights.length) {
					var itemHeight = this._customItemHeights[i];
					if (itemHeight != null) {
						item.height = itemHeight;
					}
				}
			}
			if ((item is IValidating)) {
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

	private function applyPercentHeight(items:Array<DisplayObject>, explicitHeight:Null<Float>, explicitMinHeight:Null<Float>,
			explicitMaxHeight:Null<Float>):Void {
		var customHeightIndices:Array<Int> = [];
		var pendingIndices:Array<Int> = [];
		var totalMeasuredHeight = 0.0;
		var totalMinHeight = 0.0;
		var totalPercentHeight = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			var isDivider = i % 2 == 1;
			if (!isDivider) {
				var nonDividerIndex = Math.floor(i / 2);
				var needsPercentHeight = true;
				if (this._customItemHeights != null && nonDividerIndex < this._customItemHeights.length) {
					var itemHeight = this._customItemHeights[nonDividerIndex];
					if (itemHeight != null) {
						needsPercentHeight = false;
						item.height = itemHeight;
						customHeightIndices.push(i);
						if ((item is IValidating)) {
							// changing the height of the item may cause its width
							// to change, so we need to validate. the width is
							// needed for measurement.
							cast(item, IValidating).validateNow();
						}
					}
				}
				if (needsPercentHeight) {
					var percentHeight = 100.0;
					if ((item is IMeasureObject)) {
						var measureItem = cast(item, IMeasureObject);
						var columnExplicitMinHeight = measureItem.explicitMinHeight;
						if (columnExplicitMinHeight != null) {
							totalMinHeight += columnExplicitMinHeight;
						}
					}
					totalPercentHeight += percentHeight;
					pendingIndices.push(i);
					continue;
				}
			}
			totalMeasuredHeight += item.height;
		}

		totalMeasuredHeight += this._paddingTop + this._paddingBottom;
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
		var needsAnotherPass = false;
		do {
			needsAnotherPass = false;
			var heightSum = 0.0;
			var percentToPixels = remainingHeight / totalPercentHeight;
			if (percentToPixels < 0.0) {
				percentToPixels = 0.0;
			}
			for (index in pendingIndices) {
				var item = items[index];
				var percentHeight = 100.0;
				// round to nearest pixel so that there aren't any visual gaps
				// between items. we'll append the remainder at the end.
				var itemHeight = Math.ffloor(percentToPixels * percentHeight);
				var columnMinHeight:Null<Float> = null;
				if ((item is IMeasureObject)) {
					var measureItem = cast(item, IMeasureObject);
					columnMinHeight = measureItem.explicitMinHeight;
				}

				if (columnMinHeight != null) {
					if (columnMinHeight > remainingHeight) {
						// we try to respect the item's minimum height, but if
						// it's larger than the remaining space, we need to
						// force it to fit
						columnMinHeight = remainingHeight;
					}
					if (itemHeight < columnMinHeight) {
						itemHeight = columnMinHeight;
						remainingHeight -= itemHeight;
						totalPercentHeight -= percentHeight;
						pendingIndices.remove(index);
						needsAnotherPass = true;
					}
				}
				item.height = itemHeight;
				if ((item is IValidating)) {
					// changing the height of the item may cause its width
					// to change, so we need to validate. the width is
					// needed for measurement.
					cast(item, IValidating).validateNow();
				}
				heightSum += itemHeight;
			}
			if (needsAnotherPass) {
				heightSum = 0.0;
			} else {
				remainingHeight -= heightSum;
			}
		} while (needsAnotherPass);
		if (remainingHeight > 0.0 && pendingIndices.length > 0) {
			// minimize the impact of a non-integer width by adding the
			// remainder to the final item
			var index = pendingIndices[pendingIndices.length - 1];
			var finalItem = items[index];
			finalItem.height += remainingHeight;
			return;
		}

		if (remainingHeight == 0.0) {
			return;
		}

		var index = this._fallbackFluidIndex;
		if (index == -1) {
			index = items.length - 1;
		}
		if (index != -1) {
			var fallbackItem = items[index];
			var itemHeight = fallbackItem.height + remainingHeight;
			if (itemHeight < 0.0) {
				remainingHeight = itemHeight;
				itemHeight = 0.0;
				customHeightIndices.remove(index);
			} else {
				remainingHeight = 0.0;
			}
			fallbackItem.height = itemHeight;
		}

		if (remainingHeight == 0.0) {
			return;
		}

		var offset = remainingHeight / customHeightIndices.length;
		for (index in customHeightIndices) {
			var item = items[index];
			item.height += offset;
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
			if ((item is IMeasureObject)) {
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
}
