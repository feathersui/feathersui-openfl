/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import feathers.controls.IGridViewColumn;
import feathers.core.IValidating;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Positions cell or header renderers in a `GridView` component.

	@event openfl.events.Event.CHANGE

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
class GridViewRowLayout extends EventDispatcher implements ILayout {
	/**
		Creates a new `GridViewRowLayout` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var _paddingLeft:Float = 0.0;

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

	private var _paddingRight:Float = 0.0;

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

	private var _columns:IFlatCollection<IGridViewColumn>;

	/**
		The collection of columns displayed by the `GridView`.
	**/
	@:flash.property
	public var columns(get, set):IFlatCollection<IGridViewColumn>;

	private function get_columns():IFlatCollection<IGridViewColumn> {
		return this._columns;
	}

	private function set_columns(value:IFlatCollection<IGridViewColumn>):IFlatCollection<IGridViewColumn> {
		if (this._columns == value) {
			return this._columns;
		}
		this._columns = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._columns;
	}

	private var _customColumnWidths:Array<Float>;

	@:flash.property
	public var customColumnWidths(get, set):Array<Float>;

	private function get_customColumnWidths():Array<Float> {
		return this._customColumnWidths;
	}

	private function set_customColumnWidths(value:Array<Float>):Array<Float> {
		if (this._customColumnWidths == value) {
			return this._customColumnWidths;
		}
		this._customColumnWidths = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._customColumnWidths;
	}

	/**
		Sets all padding properties to the same value.

		@see `GridViewRowLayout.paddingRight`
		@see `GridViewRowLayout.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingRight = value;
		this.paddingLeft = value;
	}

	/**
		@see `feathers.layout.ILayout.layout()`
	**/
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		this.applyColumnWidths(items, measurements.width, measurements.minWidth, measurements.maxWidth);

		var contentWidth = this._paddingLeft;
		var contentHeight = 0.0;
		for (item in items) {
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
			if (contentHeight < item.height) {
				contentHeight = item.height;
			}
			item.x = contentWidth;
			contentWidth += item.width;
		}
		contentWidth += this._paddingRight;

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

		this.applyViewPortHeight(items, viewPortHeight);

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
		for (i in 0...this._columns.length) {
			var column = this._columns.get(i);
			var item = items[i];
			var columnWidth = column.width;
			if (columnWidth != null) {
				item.width = columnWidth;
			} else if (this._customColumnWidths != null && i < this._customColumnWidths.length) {
				item.width = this._customColumnWidths[i];
			}
			if ((item is IValidating)) {
				cast(item, IValidating).validateNow();
			}
		}
	}

	private inline function applyViewPortHeight(items:Array<DisplayObject>, viewPortHeight:Float):Void {
		for (item in items) {
			item.height = viewPortHeight;
		}
	}

	private function applyColumnWidths(items:Array<DisplayObject>, explicitWidth:Null<Float>, explicitMinWidth:Null<Float>,
			explicitMaxWidth:Null<Float>):Void {
		var pendingIndices:Array<Int> = [];
		var totalMeasuredWidth = 0.0;
		var totalPercentWidth = 0.0;
		var maxMinWidth = 0.0;
		for (i in 0...this._columns.length) {
			var column = this._columns.get(i);
			var columnWidth = column.width;
			var item = items[i];
			if (columnWidth != null) {
				item.width = columnWidth;
				if ((item is IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					cast(item, IValidating).validateNow();
				}
			} else if (this._customColumnWidths != null && i < this._customColumnWidths.length) {
				item.width = this._customColumnWidths[i];
				if ((item is IValidating)) {
					// changing the width of the item may cause its height
					// to change, so we need to validate. the height is
					// needed for measurement.
					cast(item, IValidating).validateNow();
				}
			} else {
				var percentWidth = 100.0;
				var itemMinWidth = 0.0;
				if ((item is IMeasureObject)) {
					if ((item is IValidating)) {
						cast(item, IValidating).validateNow();
					}
					itemMinWidth = cast(item, IMeasureObject).minWidth;
				}
				itemMinWidth = Math.max(column.minWidth, itemMinWidth);
				maxMinWidth = Math.max(itemMinWidth, maxMinWidth);
				totalPercentWidth += percentWidth;
				pendingIndices.push(i);
				continue;
			}
			totalMeasuredWidth += item.width;
		}

		totalMeasuredWidth += this._paddingLeft + this._paddingRight;
		var remainingWidth = 0.0;
		if (explicitWidth != null) {
			remainingWidth = explicitWidth;
		} else {
			// since we're dividing the space equally among the remaining
			// columns, use the maximum column width to ensure that everything
			// is visible and not cropped
			var totalMaxMinWidth = pendingIndices.length * maxMinWidth;
			remainingWidth = totalMeasuredWidth + totalMaxMinWidth;
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
		var needsAnotherPass = false;
		do {
			needsAnotherPass = false;
			var widthSum = 0.0;
			var percentToPixels = remainingWidth / totalPercentWidth;
			for (index in pendingIndices) {
				var item = items[index];
				var column = this._columns.get(index);
				var percentWidth = 100.0;
				// round to nearest pixel so that there aren't any visual gaps
				// between items. we'll append the remainder at the end.
				var itemWidth = Math.ffloor(percentToPixels * percentWidth);
				var columnMinWidth = column.minWidth;

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
				item.width = itemWidth;
				if ((item is IValidating)) {
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
		}
	}
}
