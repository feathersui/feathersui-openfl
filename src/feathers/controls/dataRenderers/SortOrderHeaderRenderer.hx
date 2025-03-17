/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.data.ISortOrderObserver;
import feathers.data.SortOrder;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;

/**
	A header renderer for `GridView` and `TreeGridView`. Includes a sort order
	indicator on the right side.

	@see `feathers.controls.GridView`
	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
@:styleContext
class SortOrderHeaderRenderer extends ItemRenderer implements ISortOrderObserver {
	/**
		Creates a new `SortOrderHeaderRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeSortOrderHeaderRendererTheme();
		super();
		this.toggleable = false;
	}

	private var _sortOrder:SortOrder = NONE;

	/**
		@see `feathers.data.ISortOrderObserver.sortOrder`
	**/
	public var sortOrder(get, set):SortOrder;

	private function get_sortOrder():SortOrder {
		return this._sortOrder;
	}

	private function set_sortOrder(value:SortOrder):SortOrder {
		if (this._sortOrder == value) {
			return this._sortOrder;
		}
		this._sortOrder = value;
		this.setInvalid(DATA);
		return this._sortOrder;
	}

	private var _currentSortOrderIcon:DisplayObject;
	private var _sortOrderIconMeasurements:Measurements;

	/**
		An icon to display when `sortOrder` property is set to
		`SortOrder.ASCENDING`.

		@see `SortOrderHeaderRenderer.sortDescendingIcon`

		@since 1.0.0
	**/
	@:style
	public var sortAscendingIcon:DisplayObject = null;

	/**
		An icon to display when `sortOrder` property is set to
		`SortOrder.DESCENDING`.

		@see `SortOrderHeaderRenderer.sortAscendingIcon`

		@since 1.0.0
	**/
	@:style
	public var sortDescendingIcon:DisplayObject = null;

	private function initializeSortOrderHeaderRendererTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelSortOrderHeaderRendererStyles.initialize();
		#end
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid || stateInvalid || dataInvalid) {
			this.refreshSortOrderIcon();
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
		if (this._currentSortOrderIcon != null) {
			if ((this._currentSortOrderIcon is IValidating)) {
				(cast this._currentSortOrderIcon : IValidating).validateNow();
			}
			textFieldExplicitWidth -= (this._currentSortOrderIcon.width + adjustedGap);
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
		if ((this._currentSortOrderIcon is IValidating)) {
			(cast this._currentSortOrderIcon : IValidating).validateNow();
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		if (this._currentSortOrderIcon != null) {
			contentWidth += this._currentSortOrderIcon.width + adjustedGap;
		}
		return contentWidth;
	}

	override private function measureContentMinWidth():Float {
		var contentMinWidth = super.measureContentMinWidth();
		if ((this._currentSortOrderIcon is IValidating)) {
			(cast this._currentSortOrderIcon : IValidating).validateNow();
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		if (this._currentSortOrderIcon != null) {
			contentMinWidth += this._currentSortOrderIcon.width + adjustedGap;
		}
		return contentMinWidth;
	}

	override private function layoutChildren():Void {
		if ((this._currentSortOrderIcon is IValidating)) {
			(cast this._currentSortOrderIcon : IValidating).validateNow();
		}
		var paddingRight = this.paddingRight;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround for swf
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		this.runWithoutInvalidation(() -> {
			var newPaddingRight = paddingRight;
			if (this._currentSortOrderIcon != null) {
				newPaddingRight += this._currentSortOrderIcon.width + adjustedGap;
			}
			this.paddingRight = newPaddingRight;
		});
		super.layoutChildren();
		this.runWithoutInvalidation(() -> {
			this.paddingRight = paddingRight;
		});
		if (this._currentSortOrderIcon != null) {
			this._currentSortOrderIcon.x = this.actualWidth - this.paddingRight - this._currentSortOrderIcon.width;
			switch (this.verticalAlign) {
				case TOP:
					this._currentSortOrderIcon.y = this.paddingTop;
				case BOTTOM:
					this._currentSortOrderIcon.y = Math.max(this.paddingTop,
						this.paddingTop
						+ this.actualHeight
						- this.paddingTop
						- this.paddingBottom
						- this._currentSortOrderIcon.height);
				case MIDDLE:
					this._currentSortOrderIcon.y = Math.max(this.paddingTop,
						this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this._currentSortOrderIcon.height) / 2.0);
				default:
					throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
			}
		}
	}

	private function refreshSortOrderIcon():Void {
		var oldIcon = this._currentSortOrderIcon;
		this._currentSortOrderIcon = this.getCurrentSortOrderIcon();
		if (this._currentSortOrderIcon == oldIcon) {
			return;
		}
		this.removeCurrentSortOrderIcon(oldIcon);
		if (this._currentSortOrderIcon == null) {
			this._sortOrderIconMeasurements = null;
			return;
		}
		if ((this._currentSortOrderIcon is IUIControl)) {
			(cast this._currentSortOrderIcon : IUIControl).initializeNow();
		}
		if (this._sortOrderIconMeasurements == null) {
			this._sortOrderIconMeasurements = new Measurements(this._currentSortOrderIcon);
		} else {
			this._sortOrderIconMeasurements.save(this._currentSortOrderIcon);
		}
		if ((this._currentSortOrderIcon is IProgrammaticSkin)) {
			(cast this._currentSortOrderIcon : IProgrammaticSkin).uiContext = this;
		}
		if ((this._currentSortOrderIcon is IStateObserver)) {
			(cast this._currentSortOrderIcon : IStateObserver).stateContext = this;
		}
		this.addChild(this._currentSortOrderIcon);
	}

	private function getCurrentSortOrderIcon():DisplayObject {
		switch (this._sortOrder) {
			case ASCENDING:
				return this.sortAscendingIcon;
			case DESCENDING:
				return this.sortDescendingIcon;
			default:
				return null;
		}
	}

	private function removeCurrentSortOrderIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		if ((icon is IProgrammaticSkin)) {
			(cast icon : IProgrammaticSkin).uiContext = null;
		}
		if ((icon is IStateObserver)) {
			(cast icon : IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this icon is used for measurement
		this._sortOrderIconMeasurements.restore(icon);
		if (icon.parent == this) {
			this.removeChild(icon);
		}
	}
}
