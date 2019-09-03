/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.core.IStateObserver;
import feathers.core.IStateContext;
import feathers.core.IUIControl;
import openfl.events.Event;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import feathers.utils.Scroller;
import feathers.core.InvalidationFlag;
import feathers.core.FeathersControl;
import openfl.geom.Rectangle;

/**
	A base class for scrolling containers.

	@since 1.0.0
**/
class BaseScrollContainer extends FeathersControl {
	private function new() {
		super();
	}

	/**
		@since 1.0.0
	**/
	@:dox(show)
	private var viewPort:IViewPort;

	private var scroller:Scroller;
	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	private var topViewPortOffset:Float = 0.0;
	private var rightViewPortOffset:Float = 0.0;
	private var bottomViewPortOffset:Float = 0.0;
	private var leftViewPortOffset:Float = 0.0;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a background skin:

		```hx
		group.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `LayoutGroup.backgroundDisabledSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a disabled background skin:

		```hx
		group.backgroundDisabledSkin = new Bitmap(bitmapData);
		group.enabled = false;
		```

		@default null

		@see `LayoutGroup.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundDisabledSkin:DisplayObject = null;

	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	override private function initialize():Void {
		if (this.scroller == null) {
			this.scroller = new Scroller();
		}
		this.scroller.target = this;
		this.scroller.addEventListener(Event.SCROLL, listBox_scroller_scrollHandler);
	}

	override private function update():Void {
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		this.refreshOffsets();
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

		this.refreshViewPortLayout();
		this.refreshScrollRect();
		this.refreshScroller();
		this.refreshBackgroundLayout();
	}

	private function refreshOffsets():Void {
		this.topViewPortOffset = 0.0;
		this.rightViewPortOffset = 0.0;
		this.bottomViewPortOffset = 0.0;
		this.leftViewPortOffset = 0.0;
	}

	private function refreshViewPortLayout():Void {
		this.viewPort.x = this.leftViewPortOffset;
		this.viewPort.y = this.topViewPortOffset;
		this.viewPort.visibleWidth = this.actualWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		this.viewPort.visibleHeight = this.actualHeight - this.topViewPortOffset - this.bottomViewPortOffset;
		this.viewPort.minVisibleWidth = this.actualMinWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		this.viewPort.minVisibleHeight = this.actualMinHeight - this.topViewPortOffset - this.bottomViewPortOffset;
		this.viewPort.maxVisibleWidth = this.actualMaxWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		this.viewPort.maxVisibleHeight = this.actualMaxHeight - this.topViewPortOffset - this.bottomViewPortOffset;
		this.viewPort.validateNow();
	}

	private function refreshScroller():Void {
		this.scroller.setDimensions(this.viewPort.visibleWidth, this.viewPort.visibleHeight, this.viewPort.width, this.viewPort.height);
	}

	private function autoSizeIfNeeded():Bool {
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
			newWidth = this.viewPort.visibleWidth + this.leftViewPortOffset + this.rightViewPortOffset;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(newWidth, this._currentBackgroundSkin.width);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.viewPort.visibleHeight + this.topViewPortOffset + this.bottomViewPortOffset;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(newHeight, this._currentBackgroundSkin.height);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this.viewPort.minVisibleWidth + this.leftViewPortOffset + this.rightViewPortOffset;
			if (measureSkin != null) {
				newMinWidth = Math.max(newMinWidth, measureSkin.minWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(newMinWidth, this._backgroundSkinMeasurements.minWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this.viewPort.minVisibleHeight + this.topViewPortOffset + this.bottomViewPortOffset;
			if (measureSkin != null) {
				newMinHeight = Math.max(newMinHeight, measureSkin.minHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = Math.max(newMinHeight, this._backgroundSkinMeasurements.minHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			newMaxWidth = this.viewPort.maxVisibleWidth + this.leftViewPortOffset + this.rightViewPortOffset;
			if (measureSkin != null) {
				newMaxWidth = Math.min(newMaxWidth, measureSkin.maxWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = Math.min(newMaxWidth, this._backgroundSkinMeasurements.maxWidth);
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			newMaxHeight = this.viewPort.maxVisibleHeight + this.topViewPortOffset + this.bottomViewPortOffset;
			if (measureSkin != null) {
				newMaxHeight = Math.min(newMaxHeight, measureSkin.maxHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = Math.min(newMaxHeight, this._backgroundSkinMeasurements.maxHeight);
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this, IStateContext) && Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext);
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.backgroundDisabledSkin != null) {
			return this.backgroundDisabledSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function refreshBackgroundLayout():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function refreshScrollRect():Void {
		// instead of creating a new Rectangle every time, we're going to swap
		// between two of them to avoid excessive garbage collection
		var scrollRect = this._scrollRect1;
		if (this._currentScrollRect == scrollRect) {
			scrollRect = this._scrollRect2;
		}
		this._currentScrollRect = scrollRect;
		scrollRect.setTo(scroller.scrollX, scroller.scrollY, this.actualWidth, this.actualHeight);
		var displayViewPort = cast(this.viewPort, DisplayObject);
		displayViewPort.scrollRect = scrollRect;
	}

	private function listBox_scroller_scrollHandler(event:Event):Void {
		this.refreshScrollRect();
	}
}
