/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IFocusExtras;
import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import openfl.events.Event;

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

	private var _ignoreHeaderResize:Bool = false;

	private var _headerMeasurements:Measurements = null;

	private var _header:DisplayObject = null;

	/**
		The panel's optional header, displayed along the top edge.

		@since 1.0.0
	**/
	public var header(get, set):DisplayObject;

	private function get_header():DisplayObject {
		return this._header;
	}

	private function set_header(value:DisplayObject):DisplayObject {
		if (this._header == value) {
			return this._header;
		}
		if (this._header != null) {
			this._header.removeEventListener(Event.RESIZE, panel_header_resizeHandler);
			this._focusExtrasBefore.remove(this._header);
			this.removeRawChild(this._header);
		}
		this._header = value;
		if (this._header != null) {
			this._focusExtrasBefore.push(this._header);
			var index = (this.layoutViewPort != null) ? (this.getRawChildIndex(this.layoutViewPort) + 1) : 0;
			this.addRawChildAt(this._header, index);
			if ((this._header is IUIControl)) {
				(cast this._header : IUIControl).initializeNow();
			}
			if (this._headerMeasurements == null) {
				this._headerMeasurements = new Measurements(this._header);
			} else {
				this._headerMeasurements.save(this._header);
			}
			this._header.addEventListener(Event.RESIZE, panel_header_resizeHandler, false, 0, true);
		} else {
			this._headerMeasurements = null;
		}
		this.setInvalid(LAYOUT);
		return this._header;
	}

	private var _ignoreFooterResize:Bool = false;

	private var _footerMeasurements:Measurements = null;

	private var _footer:DisplayObject = null;

	/**
		The panel's optional header, displayed along the bottom edge.

		@since 1.0.0
	**/
	public var footer(get, set):DisplayObject;

	private function get_footer():DisplayObject {
		return this._footer;
	}

	private function set_footer(value:DisplayObject):DisplayObject {
		if (this._footer == value) {
			return this._footer;
		}
		if (this._footer != null) {
			this._footer.removeEventListener(Event.RESIZE, panel_footer_resizeHandler);
			this._focusExtrasAfter.remove(this._footer);
			this.removeRawChild(this._footer);
		}
		this._footer = value;
		if (this._footer != null) {
			this._focusExtrasAfter.push(this._footer);
			this.addRawChild(this._footer);
			if ((this._footer is IUIControl)) {
				(cast this._footer : IUIControl).initializeNow();
			}
			if (this._footerMeasurements == null) {
				this._footerMeasurements = new Measurements(this._footer);
			} else {
				this._footerMeasurements.save(this._footer);
			}
			this._footer.addEventListener(Event.RESIZE, panel_footer_resizeHandler, false, 0, true);
		} else {
			this._footerMeasurements = null;
		}
		this.setInvalid(LAYOUT);
		return this._footer;
	}

	private var _focusExtrasBefore:Array<DisplayObject> = [];

	@:dox(hide)
	public var focusExtrasBefore(get, never):Array<DisplayObject>;

	private function get_focusExtrasBefore():Array<DisplayObject> {
		return this._focusExtrasBefore;
	}

	private var _focusExtrasAfter:Array<DisplayObject> = [];

	@:dox(hide)
	public var focusExtrasAfter(get, never):Array<DisplayObject>;

	private function get_focusExtrasAfter():Array<DisplayObject> {
		return this._focusExtrasAfter;
	}

	override public function dispose():Void {
		if (this._header != null) {
			this.header = null;
		}
		if (this._footer != null) {
			this.footer = null;
		}
		super.dispose();
	}

	private function initializePanelTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelPanelStyles.initialize();
		#end
	}

	override private function update():Void {
		// children are allowed to change during update() in a subclass up
		// until it calls super.update().
		this._ignoreChangesButSetFlags = false;

		super.update();

		var oldIgnoreHeaderResize = this._ignoreHeaderResize;
		this._ignoreHeaderResize = true;
		this.layoutHeader();
		this._ignoreHeaderResize = oldIgnoreHeaderResize;

		var oldIgnoreFooterResize = this._ignoreFooterResize;
		this._ignoreFooterResize = true;
		this.layoutFooter();
		this._ignoreFooterResize = oldIgnoreFooterResize;
	}

	override private function refreshEnabled():Void {
		super.refreshEnabled();

		if ((this._header is IUIControl)) {
			(cast this._header : IUIControl).enabled = this._enabled;
		}

		if ((this._footer is IUIControl)) {
			(cast this._footer : IUIControl).enabled = this._enabled;
		}
	}

	override private function calculateViewPortOffsets(forceScrollBars:Bool, useActualBounds:Bool):Void {
		if (this._header != null) {
			var oldIgnoreHeaderResize = this._ignoreHeaderResize;
			this._ignoreHeaderResize = true;
			if (this._headerMeasurements != null) {
				this._headerMeasurements.restore(this._header);
			}
			// the header's height might change with different width values,
			// so if the panel's width is known, set the header width
			if (useActualBounds) {
				this._header.width = this.actualWidth - this.paddingLeft - this.paddingRight;
			} else if (this.explicitWidth != null) {
				this._header.width = this.explicitWidth - this.paddingLeft - this.paddingRight;
			}
			if ((this._header is IValidating)) {
				(cast this._header : IValidating).validateNow();
			}
			this.topViewPortOffset += this._header.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this._header.width);
			if ((this._header is IMeasureObject)) {
				var measureHeader:IMeasureObject = cast this._header;
				this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, measureHeader.minWidth);
			}
			this._ignoreHeaderResize = oldIgnoreHeaderResize;
		}
		if (this._footer != null) {
			var oldIgnoreFooterResize = this._ignoreFooterResize;
			this._ignoreFooterResize = true;
			if (this._footerMeasurements != null) {
				this._footerMeasurements.restore(this._footer);
			}
			// the footer's height might change with different width values,
			// so if the panel's width is known, set the footer width
			if (useActualBounds) {
				this._footer.width = this.actualWidth - this.paddingLeft - this.paddingRight;
			} else if (this.explicitWidth != null) {
				this._footer.width = this.explicitWidth - this.paddingLeft - this.paddingRight;
			}
			if ((this._footer is IValidating)) {
				(cast this._footer : IValidating).validateNow();
			}
			this.bottomViewPortOffset += this._footer.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this._footer.width);
			if ((this._footer is IMeasureObject)) {
				var measureFooter:IMeasureObject = cast this._footer;
				this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, measureFooter.minWidth);
			}
			this._ignoreFooterResize = oldIgnoreFooterResize;
		}
		super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
	}

	private function layoutHeader():Void {
		if (this._header == null) {
			return;
		}
		this._header.x = this.paddingLeft;
		this._header.y = this.paddingTop;
		this._header.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		if ((this._header is IValidating)) {
			(cast this._header : IValidating).validateNow();
		}
	}

	private function layoutFooter():Void {
		if (this._footer == null) {
			return;
		}
		this._footer.x = this.paddingLeft;
		this._footer.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		if ((this._footer is IValidating)) {
			(cast this._footer : IValidating).validateNow();
		}
		this._footer.y = this.actualHeight - this._footer.height - this.paddingBottom;
	}

	private function panel_header_resizeHandler(event:Event):Void {
		if (this._ignoreHeaderResize) {
			return;
		}
		if (this._headerMeasurements != null) {
			// if the header resizes outside of the panel's validation cycle,
			// then its new measurements should replace the original
			this._headerMeasurements.save(this._header);
		}
		this.setInvalid(SIZE);
	}

	private function panel_footer_resizeHandler(event:Event):Void {
		if (this._ignoreFooterResize) {
			return;
		}
		if (this._footerMeasurements != null) {
			// if the footer resizes outside of the panel's validation cycle,
			// then its new measurements should replace the original
			this._footerMeasurements.save(this._footer);
		}
		this.setInvalid(SIZE);
	}
}
