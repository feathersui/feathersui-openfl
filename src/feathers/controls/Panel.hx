/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IFocusExtras;
import feathers.utils.MeasurementsUtil;
import feathers.core.InvalidationFlag;
import feathers.core.IMeasureObject;
import feathers.themes.steel.components.SteelPanelStyles;
import openfl.display.DisplayObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;

/**
	A container with a header on top and a footer on the bottom, with a region
	in the center for content that supports layout and scrolling. Both the
	header and the footer are optional.

	@see [Tutorial: How to use the Panel component](https://feathersui.com/learn/haxe-openfl/panel/)

	@since 1.0.0
**/
@:styleContext
class Panel extends ScrollContainer implements IFocusExtras {
	/**
		Creates a new `Panel` object.

		@since 1.0.0
	**/
	public function new() {
		initializePanelTheme();

		super();
	}

	/**
		The panel's optional header, displayed along the top edge.

		@since 1.0.0
	**/
	public var header(default, set):DisplayObject = null;

	private function set_header(value:DisplayObject):DisplayObject {
		if (this.header == value) {
			return this.header;
		}
		if (this.header != null) {
			this.focusExtrasBefore.remove(this.header);
			this.removeRawChild(this.header);
		}
		this.header = value;
		if (this.header != null) {
			this.focusExtrasBefore.push(this.header);
			this.addRawChild(this.header);
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.header;
	}

	/**
		The panel's optional header, displayed along the bottom edge.

		@since 1.0.0
	**/
	public var footer(default, set):DisplayObject = null;

	private function set_footer(value:DisplayObject):DisplayObject {
		if (this.footer == value) {
			return this.footer;
		}
		if (this.footer != null) {
			this.focusExtrasAfter.remove(this.footer);
			this.removeRawChild(this.footer);
		}
		this.footer = value;
		if (this.footer != null) {
			this.focusExtrasAfter.push(this.footer);
			this.addRawChild(this.footer);
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.footer;
	}

	@:dox(hide)
	@:isVar
	public var focusExtrasBefore(get, never):Array<DisplayObject> = [];

	private function get_focusExtrasBefore():Array<DisplayObject> {
		return this.focusExtrasBefore;
	}

	@:dox(hide)
	@:isVar
	public var focusExtrasAfter(get, never):Array<DisplayObject> = [];

	private function get_focusExtrasAfter():Array<DisplayObject> {
		return this.focusExtrasAfter;
	}

	private function initializePanelTheme():Void {
		SteelPanelStyles.initialize();
	}

	override private function update():Void {
		super.update();
		this.layoutHeader();
		this.layoutFooter();
	}

	override private function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void {
		super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
		if (this.header != null) {
			if (Std.is(this.header, IValidating)) {
				cast(this.header, IValidating).validateNow();
			}
			this.topViewPortOffset += this.header.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this.header.width);
			if (Std.is(this.header, IMeasureObject)) {
				var measureHeader = cast(this.header, IMeasureObject);
				this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, measureHeader.minWidth);
			}
		}
		if (this.footer != null) {
			if (Std.is(this.footer, IValidating)) {
				cast(this.footer, IValidating).validateNow();
			}
			this.bottomViewPortOffset += this.footer.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this.footer.width);
			if (Std.is(this.footer, IMeasureObject)) {
				var measureFooter = cast(this.footer, IMeasureObject);
				this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, measureFooter.minWidth);
			}
		}
	}

	private function layoutHeader():Void {
		if (this.header == null) {
			return;
		}
		this.header.x = this.paddingLeft;
		this.header.y = this.paddingTop;
		this.header.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (Std.is(this.header, IValidating)) {
			cast(this.header, IValidating).validateNow();
		}
	}

	private function layoutFooter():Void {
		if (this.footer == null) {
			return;
		}
		this.footer.x = this.paddingLeft;
		this.footer.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (Std.is(this.footer, IValidating)) {
			cast(this.footer, IValidating).validateNow();
		}
		this.footer.y = this.actualHeight - this.footer.height - this.paddingBottom;
	}
}
