/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.core.IMeasureObject;
import openfl.display.DisplayObject;

/**
	Stores the current measurements for a display object.

	@since 1.0.0
**/
class Measurements {
	/**
		Creates a new `Measurements` object from the given arguments.

		@since 1.0.0
	**/
	public function new(target:DisplayObject = null) {
		this.save(target);
	}

	/**
		Saves the saved measurements from a new target. If the new target is
		`null`, sets all measurements back to `null`.

		@since 1.0.0
	**/
	public function save(target:DisplayObject = null):Void {
		if (target == null) {
			this.width = null;
			this.height = null;
			this.minWidth = null;
			this.minHeight = null;
			this.maxWidth = null;
			this.maxHeight = null;
			return;
		}
		if (Std.is(target, IMeasureObject)) {
			var measureTarget = cast(target, IMeasureObject);
			this.width = measureTarget.explicitWidth;
			this.height = measureTarget.explicitHeight;
			this.minWidth = measureTarget.explicitMinWidth;
			this.minHeight = measureTarget.explicitMinHeight;
			this.maxWidth = measureTarget.explicitMaxWidth;
			this.maxHeight = measureTarget.explicitMaxHeight;
			return;
		}
		this.width = target.width;
		this.height = target.height;
		this.minWidth = this.width;
		this.minHeight = this.height;
		this.maxWidth = this.width;
		this.maxHeight = this.height;
	}

	/**
		Restores the saved measurements to the target.

		@since 1.0.0
	**/
	public function restore(target:DisplayObject):Void {
		if (Std.is(target, IMeasureObject)) {
			var measureTarget = cast(target, IMeasureObject);
			if (this.width == null) {
				measureTarget.resetWidth();
			} else {
				measureTarget.width = this.width;
			}
			if (this.height == null) {
				measureTarget.resetHeight();
			} else {
				measureTarget.height = this.height;
			}
			if (this.minWidth == null) {
				measureTarget.resetMinWidth();
			} else {
				measureTarget.minWidth = this.minWidth;
			}
			if (this.minHeight == null) {
				measureTarget.resetMinHeight();
			} else {
				measureTarget.minHeight = this.minHeight;
			}
			if (this.maxWidth == null) {
				measureTarget.resetMaxWidth();
			} else {
				measureTarget.maxWidth = this.maxWidth;
			}
			if (this.maxHeight == null) {
				measureTarget.resetMaxHeight();
			} else {
				measureTarget.maxHeight = this.maxHeight;
			}
			return;
		}
		if (this.width != null) {
			target.width = this.width;
		}
		if (this.height != null) {
			target.height = this.height;
		}
	}

	/**
		The object's width value, or `null`, if width is not available.

		@since 1.0.0
	**/
	public var width:Null<Float> = null;

	/**
		The object's height value, or `null`, if height is not available.

		@since 1.0.0
	**/
	public var height:Null<Float> = null;

	/**
		The object's minimum width value, or `null`, if a minimum width is not
		available.

		@since 1.0.0
	**/
	public var minWidth:Null<Float> = null;

	/**
		The object's minimum height value, or `null`, if a minimum height is not
		available.

		@since 1.0.0
	**/
	public var minHeight:Null<Float> = null;

	/**
		The object's maximum width value, or `null`, if a maximum width is not
		available.

		@since 1.0.0
	**/
	public var maxWidth:Null<Float> = null;

	/**
		The object's maximum height value, or `null`, if a maximum height is not
		available.

		@since 1.0.0
	**/
	public var maxHeight:Null<Float> = null;
}
