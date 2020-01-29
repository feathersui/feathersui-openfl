/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

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
class Panel extends ScrollContainer {
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
			this.removeRawChild(this.header);
		}
		this.header = value;
		if (this.header != null) {
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
			this.removeRawChild(this.footer);
		}
		this.footer = value;
		if (this.footer != null) {
			this.addRawChild(this.footer);
		}
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.footer;
	}

	private function initializePanelTheme():Void {
		SteelPanelStyles.initialize();
	}

	override private function update():Void {
		super.update();
		this.layoutHeader();
		this.layoutFooter();
	}

	override private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._currentBackgroundSkin != null) {
			this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		this.viewPort.validateNow();

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this.measureViewPort) {
				newWidth = this.viewPort.visibleWidth;
			} else {
				newWidth = 0.0;
			}
			newWidth += this.leftViewPortOffset + this.rightViewPortOffset;
			if (this.header != null) {
				newWidth = Math.max(newWidth, this.header.width);
			}
			if (this.footer != null) {
				newWidth = Math.max(newWidth, this.footer.width);
			}
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(newWidth, this._currentBackgroundSkin.width);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this.measureViewPort) {
				newHeight = this.viewPort.visibleHeight;
			} else {
				newHeight = 0.0;
			}
			newHeight += this.topViewPortOffset + this.bottomViewPortOffset;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(newHeight, this._currentBackgroundSkin.height);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (this.measureViewPort) {
				newMinWidth = this.viewPort.minVisibleWidth;
			} else {
				newMinWidth = 0.0;
			}
			newMinWidth += this.leftViewPortOffset + this.rightViewPortOffset;
			if (measureSkin != null) {
				newMinWidth = Math.max(newMinWidth, measureSkin.minWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(newMinWidth, this._backgroundSkinMeasurements.minWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (this.measureViewPort) {
				newMinHeight = this.viewPort.minVisibleHeight;
			} else {
				newMinHeight = 0.0;
			}
			newMinHeight += this.topViewPortOffset + this.bottomViewPortOffset;
			if (measureSkin != null) {
				newMinHeight = Math.max(newMinHeight, measureSkin.minHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = Math.max(newMinHeight, this._backgroundSkinMeasurements.minHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (this.measureViewPort) {
				newMaxWidth = this.viewPort.maxVisibleWidth;
			} else {
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
			newMaxWidth += this.leftViewPortOffset + this.rightViewPortOffset;
			if (measureSkin != null) {
				newMaxWidth = Math.min(newMaxWidth, measureSkin.maxWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = Math.min(newMaxWidth, this._backgroundSkinMeasurements.maxWidth);
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (this.measureViewPort) {
				newMaxHeight = this.viewPort.maxVisibleHeight;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
			newMaxHeight += this.topViewPortOffset + this.bottomViewPortOffset;
			if (measureSkin != null) {
				newMaxHeight = Math.min(newMaxHeight, measureSkin.maxHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = Math.min(newMaxHeight, this._backgroundSkinMeasurements.maxHeight);
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	override private function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void {
		super.calculateViewPortOffsets(forceScrollBars);
		if (this.header != null) {
			if (Std.is(this.header, IValidating)) {
				cast(this.header, IValidating).validateNow();
			}
			this.topViewPortOffset += this.header.height;
		}
		if (this.footer != null) {
			if (Std.is(this.footer, IValidating)) {
				cast(this.footer, IValidating).validateNow();
			}
			this.bottomViewPortOffset += this.footer.height;
		}
	}

	private function layoutHeader():Void {
		if (this.header == null) {
			return;
		}
		this.header.x = 0;
		this.header.y = 0;
		this.header.width = this.actualWidth;
		if (Std.is(this.header, IValidating)) {
			cast(this.header, IValidating).validateNow();
		}
	}

	private function layoutFooter():Void {
		if (this.footer == null) {
			return;
		}
		this.footer.x = 0;
		this.footer.width = this.actualWidth;
		if (Std.is(this.footer, IValidating)) {
			cast(this.footer, IValidating).validateNow();
		}
		this.footer.y = this.actualHeight - this.footer.height;
	}
}
