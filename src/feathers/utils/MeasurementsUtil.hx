/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.core.IMeasureObject;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;

/**
	Utility functions for use with the `Measurements` class.

	@see `feathers.layout.Meaesurements`
**/
final class MeasurementsUtil {
	/**
		With the saved measurements, and a parent's measurements, resets the
		dimensions of the target display object.

		@since 1.0.0
	**/
	public static function resetFluidlyWithParentValues(measurements:Measurements, target:DisplayObject, ?parentExplicitWidth:Float,
			?parentExplicitHeight:Float, ?parentExplicitMinWidth:Float, ?parentExplicitMinHeight:Float, ?parentExplicitMaxWidth:Float,
			?parentExplicitMaxHeight:Float):Void {
		if (target == null) {
			return;
		}
		if ((target is IMeasureObject)) {
			var measureTarget:IMeasureObject = cast target;

			var width = parentExplicitWidth;
			if (width == null) {
				width = measurements.width;
			}
			if (width == null) {
				measureTarget.resetWidth();
			} else {
				measureTarget.width = width;
			}

			var height = parentExplicitHeight;
			if (height == null) {
				height = measurements.height;
			}
			if (height == null) {
				measureTarget.resetHeight();
			} else {
				measureTarget.height = height;
			}

			var minWidth = parentExplicitMinWidth;
			if (minWidth == null || (measureTarget.explicitMinWidth != null && measureTarget.explicitMinWidth > minWidth)) {
				minWidth = measureTarget.explicitMinWidth;
			}
			if (minWidth == null) {
				minWidth = 0.0;
			}
			measureTarget.minWidth = minWidth;

			var minHeight = parentExplicitMinHeight;
			if (minHeight == null || (measureTarget.explicitMinHeight != null && measureTarget.explicitMinHeight > minHeight)) {
				minHeight = measureTarget.explicitMinHeight;
			}
			if (minHeight == null) {
				minHeight = 0.0;
			}
			measureTarget.minHeight = minHeight;

			var maxWidth = parentExplicitMaxWidth;
			if (maxWidth == null || (measureTarget.explicitMaxWidth != null && measureTarget.explicitMaxWidth < maxWidth)) {
				maxWidth = measureTarget.explicitMaxWidth;
			}
			if (maxWidth == null) {
				maxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
			measureTarget.maxWidth = maxWidth;

			var maxHeight = parentExplicitMaxHeight;
			if (maxHeight == null || (measureTarget.explicitMaxHeight != null && measureTarget.explicitMaxHeight < maxHeight)) {
				maxHeight = measureTarget.explicitMaxHeight;
			}
			if (maxHeight == null) {
				maxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
			measureTarget.maxHeight = maxHeight;
			return;
		}
		if (parentExplicitWidth != null) {
			target.width = parentExplicitWidth;
		} else if (measurements.width != null) {
			target.width = measurements.width;
		}
		if (parentExplicitHeight != null) {
			target.height = parentExplicitHeight;
		} else if (measurements.height != null) {
			target.height = measurements.height;
		}
	}

	/**
		With the saved measurements, and a parent's measurements, resets the
		dimensions of the target display object.

		@since 1.0.0
	**/
	public static function resetFluidlyWithParent(measurements:Measurements, target:DisplayObject, parent:IMeasureObject):Void {
		return resetFluidlyWithParentValues(measurements, target, parent.explicitWidth, parent.explicitHeight, parent.explicitMinWidth,
			parent.explicitMinHeight, parent.explicitMaxWidth, parent.explicitMaxHeight);
	}
}
