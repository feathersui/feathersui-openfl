/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IOpenCloseToggle;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;

/**
	A branch and leaf renderer for data containers that can drill down into
	hierarchical data. Displays an additional icon on the right side to indicate
	whether it represents a branch or not.

	@since 1.4.0
**/
@:styleContext
class DrillDownItemRenderer extends ItemRenderer implements IHierarchicalItemRenderer {
	/**
		Creates a new `DrillDownItemRenderer` object.

		@since 1.4.0
	**/
	public function new() {
		initializeDrillDownItemRendererTheme();
		super();
	}

	private var _branch:Bool = false;

	/**
		@see `feathers.controls.dataRenderers.IHierarchicalItemRenderer.branch`
	**/
	public var branch(get, set):Bool;

	private function get_branch():Bool {
		return this._branch;
	}

	private function set_branch(value:Bool):Bool {
		if (this._branch == value) {
			return this._branch;
		}
		this._branch = value;
		this.setInvalid(DATA);
		return this._branch;
	}

	private var _currentDrillDownIcon:DisplayObject;
	private var _drillDownIconMeasurements:Measurements;
	private var _ignoreDrillDownIconResizes = false;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch. This icon is displayed in addition to the standard `icon`
		property.

		@since 1.4.0
	**/
	@:style
	public var drillDownIcon:DisplayObject = null;

	private function initializeDrillDownItemRendererTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelDrillDownItemRendererStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid || stateInvalid || dataInvalid) {
			this.refreshDrillDownIcon();
		}

		super.update();
	}

	override private function calculateExplicitWidthForTextMeasurement():Null<Float> {
		var textFieldExplicitWidth = super.calculateExplicitWidthForTextMeasurement();
		if (textFieldExplicitWidth == null) {
			return textFieldExplicitWidth;
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		if (this._currentDrillDownIcon != null) {
			var oldgnoreDrillDownIconResizes = this._ignoreDrillDownIconResizes;
			this._ignoreDrillDownIconResizes = true;
			if ((this._currentDrillDownIcon is IValidating)) {
				(cast this._currentDrillDownIcon : IValidating).validateNow();
			}
			this._ignoreDrillDownIconResizes = oldgnoreDrillDownIconResizes;
			textFieldExplicitWidth -= (this._currentDrillDownIcon.width + adjustedGap);
		}
		if (textFieldExplicitWidth < 0.0) {
			// flash may sometimes render a TextField with negative width
			// so make sure it is never smaller than 0.0
			textFieldExplicitWidth = 0.0;
		}
		return textFieldExplicitWidth;
	}

	override private function measureContentWidth():Float {
		var contentWidth = super.measureContentWidth();
		var oldgnoreDrillDownIconResizes = this._ignoreDrillDownIconResizes;
		this._ignoreDrillDownIconResizes = true;
		if ((this._currentDrillDownIcon is IValidating)) {
			(cast this._currentDrillDownIcon : IValidating).validateNow();
		}
		this._ignoreDrillDownIconResizes = oldgnoreDrillDownIconResizes;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		if (this._currentDrillDownIcon != null) {
			contentWidth += this._currentDrillDownIcon.width + adjustedGap;
		}
		return contentWidth;
	}

	override private function measureContentMinWidth():Float {
		var contentMinWidth = super.measureContentMinWidth();
		var oldgnoreDrillDownIconResizes = this._ignoreDrillDownIconResizes;
		this._ignoreDrillDownIconResizes = true;
		if ((this._currentDrillDownIcon is IValidating)) {
			(cast this._currentDrillDownIcon : IValidating).validateNow();
		}
		this._ignoreDrillDownIconResizes = oldgnoreDrillDownIconResizes;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		if (this._currentDrillDownIcon != null) {
			contentMinWidth += this._currentDrillDownIcon.width + adjustedGap;
		}
		return contentMinWidth;
	}

	override private function layoutChildren():Void {
		var oldgnoreDrillDownIconResizes = this._ignoreDrillDownIconResizes;
		this._ignoreDrillDownIconResizes = true;
		if ((this._currentDrillDownIcon is IValidating)) {
			(cast this._currentDrillDownIcon : IValidating).validateNow();
		}
		this._ignoreDrillDownIconResizes = oldgnoreDrillDownIconResizes;
		var paddingRight = this.paddingRight;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		this.runWithoutInvalidation(() -> {
			var newPaddingRight = paddingRight;
			if (this._currentDrillDownIcon != null) {
				newPaddingRight += this._currentDrillDownIcon.width + adjustedGap;
			}
			this.paddingRight = newPaddingRight;
		});
		super.layoutChildren();
		this.runWithoutInvalidation(() -> {
			this.paddingRight = paddingRight;
		});
		if (this._currentDrillDownIcon != null) {
			this._currentDrillDownIcon.x = this.actualWidth - this.paddingRight - this._currentDrillDownIcon.width;
			switch (this.verticalAlign) {
				case TOP:
					this._currentDrillDownIcon.y = this.paddingTop;
				case BOTTOM:
					this._currentDrillDownIcon.y = Math.max(this.paddingTop,
						this.paddingTop
						+ this.actualHeight
						- this.paddingTop
						- this.paddingBottom
						- this._currentDrillDownIcon.height);
				case MIDDLE:
					this._currentDrillDownIcon.y = Math.max(this.paddingTop,
						this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this._currentDrillDownIcon.height) / 2.0);
				default:
					throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
			}
		}
	}

	private function refreshDrillDownIcon():Void {
		var oldIcon = this._currentDrillDownIcon;
		this._currentDrillDownIcon = this.getCurrentDrillDownIcon();
		if (this._currentDrillDownIcon == oldIcon) {
			return;
		}
		this.removeCurrentDrillDownIcon(oldIcon);
		this.addCurrentDrillDownIcon(this._currentDrillDownIcon);
	}

	private function getCurrentDrillDownIcon():DisplayObject {
		if (this._branch) {
			return this.drillDownIcon;
		}
		return null;
	}

	private function removeCurrentDrillDownIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		icon.removeEventListener(Event.RESIZE, drillDownItemRenderer_drillDownIcon_resizeHandler);
		if ((icon is IProgrammaticSkin)) {
			(cast icon : IProgrammaticSkin).uiContext = null;
		}
		if ((icon is IStateObserver)) {
			(cast icon : IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this icon is used for measurement
		this._drillDownIconMeasurements.restore(icon);
		if (icon.parent == this) {
			this.removeChild(icon);
		}
	}

	private function addCurrentDrillDownIcon(icon:DisplayObject):Void {
		if (icon == null) {
			this._drillDownIconMeasurements = null;
			return;
		}
		if ((icon is IUIControl)) {
			(cast icon : IUIControl).initializeNow();
		}
		if (this._drillDownIconMeasurements == null) {
			this._drillDownIconMeasurements = new Measurements(icon);
		} else {
			this._drillDownIconMeasurements.save(icon);
		}
		if ((icon is IProgrammaticSkin)) {
			(cast icon : IProgrammaticSkin).uiContext = this;
		}
		if ((icon is IStateObserver)) {
			(cast icon : IStateObserver).stateContext = this;
		}
		icon.addEventListener(Event.RESIZE, drillDownItemRenderer_drillDownIcon_resizeHandler, false, 0, true);
		this.addChild(icon);
	}

	private function drillDownItemRenderer_drillDownIcon_resizeHandler(event:Event):Void {
		if (this._ignoreDrillDownIconResizes) {
			return;
		}
		this.setInvalid(STYLES);
	}
}
