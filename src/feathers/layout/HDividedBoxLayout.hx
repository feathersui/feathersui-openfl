/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

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

/**
	The layout used by the `HDividedBox` component.

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

	private var _customItemWidths:Array<Null<Float>>;

	/**
		Set automatically by `HDividedBox`. Do not set this manually.

		@since 1.0.0
	**/
	@:flash.property
	public var customItemWidths(get, set):Array<Null<Float>>;

	private function get_customItemWidths():Array<Null<Float>> {
		return this._customItemWidths;
	}

	private function set_customItemWidths(value:Array<Null<Float>>):Array<Null<Float>> {
		if (this._customItemWidths == value) {
			return this._customItemWidths;
		}
		this._customItemWidths = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this._customItemWidths;
	}

	private var _fallbackFluidIndex:Int = -1;

	/**
		Set automatically by `HDividedBox`. Do not set this manually.

		@since 1.0.0
	**/
	@:flash.property
	public var fallbackFluidIndex(get, set):Int;

	private function get_fallbackFluidIndex():Int {
		return this._fallbackFluidIndex;
	}

	private function set_fallbackFluidIndex(value:Int):Int {
		if (this._fallbackFluidIndex == value) {
			return this._fallbackFluidIndex;
		}
		this._fallbackFluidIndex = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this._fallbackFluidIndex;
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
		for (i in 0...items.length) {
			var item = items[i];
			var isDivider = i % 2 == 1;
			if (!isDivider) {
				if (this._customItemWidths != null && i < this._customItemWidths.length) {
					var itemWidth = this._customItemWidths[i];
					if (itemWidth != null) {
						item.width = itemWidth;
					}
				}
			}
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
		var totalCustomWidth = 0.0;
		var customWidthIndices:Array<Int> = [];
		var pendingIndices:Array<Int> = [];
		var totalMeasuredWidth = 0.0;
		var totalMinWidth = 0.0;
		var totalPercentWidth = 0.0;
		for (i in 0...items.length) {
			var item = items[i];
			var isDivider = i % 2 == 1;
			if (!isDivider) {
				var nonDividerIndex = Math.floor(i / 2);
				var needsPercentWidth = true;
				if (this._customItemWidths != null && nonDividerIndex < this._customItemWidths.length) {
					var itemWidth = this._customItemWidths[nonDividerIndex];
					if (itemWidth != null) {
						needsPercentWidth = false;
						item.width = itemWidth;
						totalCustomWidth += itemWidth;
						customWidthIndices.push(i);
						if (Std.is(item, IValidating)) {
							// changing the width of the item may cause its height
							// to change, so we need to validate. the height is
							// needed for measurement.
							cast(item, IValidating).validateNow();
						}
					}
				}
				if (needsPercentWidth) {
					var percentWidth = 100.0;
					if (Std.is(item, IMeasureObject)) {
						var measureItem = cast(item, IMeasureObject);
						var columnExplicitMinWidth = measureItem.explicitMinWidth;
						if (columnExplicitMinWidth != null) {
							totalMinWidth += columnExplicitMinWidth;
						}
					}
					totalPercentWidth += percentWidth;
					pendingIndices.push(i);
					continue;
				}
			}
			totalMeasuredWidth += item.width;
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
				if (Std.is(item, IMeasureObject)) {
					var measureItem = cast(item, IMeasureObject);
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
				if (Std.is(item, IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					cast(item, IValidating).validateNow();
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

		var index = this._fallbackFluidIndex;
		if (index == -1) {
			index = items.length - 1;
		}
		if (index != -1) {
			var fallbackItem = items[index];
			var itemWidth = fallbackItem.width + remainingWidth;
			if (itemWidth < 0.0) {
				remainingWidth = itemWidth;
				itemWidth = 0.0;
				customWidthIndices.remove(index);
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
			item.width = item.width + offset;
		}
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
