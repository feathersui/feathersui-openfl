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

	private var _header:DisplayObject = null;

	/**
		The panel's optional header, displayed along the top edge.

		@since 1.0.0
	**/
	@:flash.property
	public var header(get, set):DisplayObject;

	private function get_header():DisplayObject {
		return this._header;
	}

	private function set_header(value:DisplayObject):DisplayObject {
		if (this._header == value) {
			return this._header;
		}
		if (this._header != null) {
			this._focusExtrasBefore.remove(this._header);
			this.removeRawChild(this._header);
		}
		this._header = value;
		if (this._header != null) {
			this._focusExtrasBefore.push(this._header);
			this.addRawChild(this._header);
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this._header;
	}

	private var _footer:DisplayObject = null;

	/**
		The panel's optional header, displayed along the bottom edge.

		@since 1.0.0
	**/
	@:flash.property
	public var footer(get, set):DisplayObject;

	private function get_footer():DisplayObject {
		return this._footer;
	}

	private function set_footer(value:DisplayObject):DisplayObject {
		if (this._footer == value) {
			return this._footer;
		}
		if (this._footer != null) {
			this._focusExtrasAfter.remove(this._footer);
			this.removeRawChild(this._footer);
		}
		this._footer = value;
		if (this._footer != null) {
			this._focusExtrasAfter.push(this._footer);
			this.addRawChild(this._footer);
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this._footer;
	}

	private var _focusExtrasBefore:Array<DisplayObject> = [];

	@:dox(hide)
	@:flash.property
	public var focusExtrasBefore(get, never):Array<DisplayObject>;

	private function get_focusExtrasBefore():Array<DisplayObject> {
		return this._focusExtrasBefore;
	}

	private var _focusExtrasAfter:Array<DisplayObject> = [];

	@:dox(hide)
	@:flash.property
	public var focusExtrasAfter(get, never):Array<DisplayObject>;

	private function get_focusExtrasAfter():Array<DisplayObject> {
		return this._focusExtrasAfter;
	}

	private function initializePanelTheme():Void {
		SteelPanelStyles.initialize();
	}

	override private function update():Void {
		// children are allowed to change during update() in a subclass up
		// until it calls super.update().
		this._ignoreChildChangesButSetFlags = false;

		super.update();
		this.layoutHeader();
		this.layoutFooter();
	}

	override private function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void {
		super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
		if (this._header != null) {
			if (Std.is(this._header, IValidating)) {
				cast(this._header, IValidating).validateNow();
			}
			this.topViewPortOffset += this._header.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this._header.width);
			if (Std.is(this._header, IMeasureObject)) {
				var measureHeader = cast(this._header, IMeasureObject);
				this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, measureHeader.minWidth);
			}
		}
		if (this._footer != null) {
			if (Std.is(this._footer, IValidating)) {
				cast(this._footer, IValidating).validateNow();
			}
			this.bottomViewPortOffset += this._footer.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this._footer.width);
			if (Std.is(this._footer, IMeasureObject)) {
				var measureFooter = cast(this._footer, IMeasureObject);
				this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, measureFooter.minWidth);
			}
		}
	}

	private function layoutHeader():Void {
		if (this._header == null) {
			return;
		}
		this._header.x = this.paddingLeft;
		this._header.y = this.paddingTop;
		this._header.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (Std.is(this._header, IValidating)) {
			cast(this._header, IValidating).validateNow();
		}
	}

	private function layoutFooter():Void {
		if (this._footer == null) {
			return;
		}
		this._footer.x = this.paddingLeft;
		this._footer.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (Std.is(this._footer, IValidating)) {
			cast(this._footer, IValidating).validateNow();
		}
		this._footer.y = this.actualHeight - this._footer.height - this.paddingBottom;
	}
}
