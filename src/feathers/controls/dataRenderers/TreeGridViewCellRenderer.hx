/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IOpenCloseToggle;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.FeathersEvent;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelTreeGridViewCellRendererStyles;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Point;

/**
	A branch and leaf renderer for `TreeGridView`.

	@event openfl.events.Event.OPEN Dispatched when a branch item renderer
	opens. Does not get dispatched for leaf item renderers.

	@event openfl.events.Event.CLOSE Dispatched when a branch item renderer
	closes. Does not get dispatched for leaf item renderers.

	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:styleContext
class TreeGridViewCellRenderer extends ItemRenderer implements ITreeGridViewCellRenderer implements IOpenCloseToggle {
	/**
		The variant used to style the `ToggleButton` child component in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DISCLOSURE_BUTTON = "treeGridViewCellRenderer_disclosureButton";

	/**
		Creates a new `TreeGridViewCellRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTreeGridViewCellRendererTheme();
		super();
	}

	private var _rowLocation:Array<Int>;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.rowLocation`
	**/
	@:flash.property
	public var rowLocation(get, set):Array<Int>;

	private function get_rowLocation():Array<Int> {
		return this._rowLocation;
	}

	private function set_rowLocation(value:Array<Int>):Array<Int> {
		if (this._rowLocation == value) {
			return this._rowLocation;
		}
		this._rowLocation = value;
		this.setInvalid(DATA);
		return this._rowLocation;
	}

	private var _branch:Bool = false;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.branch`
	**/
	@:flash.property
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

	private var _columnIndex:Int = -1;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.columnIndex`
	**/
	@:flash.property
	public var columnIndex(get, set):Int;

	private function get_columnIndex():Int {
		return this._columnIndex;
	}

	private function set_columnIndex(value:Int):Int {
		if (this._columnIndex == value) {
			return this._columnIndex;
		}
		this._columnIndex = value;
		this.setInvalid(DATA);
		return this._columnIndex;
	}

	private var _column:TreeGridViewColumn = null;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.column`
	**/
	@:flash.property
	public var column(get, set):TreeGridViewColumn;

	private function get_column():TreeGridViewColumn {
		return this._column;
	}

	private function set_column(value:TreeGridViewColumn):TreeGridViewColumn {
		if (this._column == value) {
			return this._column;
		}
		this._column = value;
		this.setInvalid(DATA);
		return this._column;
	}

	private var _treeGridViewOwner:TreeGridView;

	/**
		@see `feathers.controls.dataRenderers.ITreeGridViewCellRenderer.treeGridViewOwner`
	**/
	@:flash.property
	public var treeGridViewOwner(get, set):TreeGridView;

	private function get_treeGridViewOwner():TreeGridView {
		return this._treeGridViewOwner;
	}

	private function set_treeGridViewOwner(value:TreeGridView):TreeGridView {
		if (this._treeGridViewOwner == value) {
			return this._treeGridViewOwner;
		}
		this._treeGridViewOwner = value;
		this.setInvalid(DATA);
		return this._treeGridViewOwner;
	}

	private var _opened:Bool = false;

	/**
		@see `feathers.core.IOpenCloseToggle.opened`
	**/
	@:flash.property
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		return this._opened;
	}

	private function set_opened(value:Bool):Bool {
		if (this._opened == value) {
			return this._opened;
		}
		this._opened = value;
		this.setInvalid(DATA);
		if (this._opened) {
			FeathersEvent.dispatch(this, Event.OPEN);
		} else {
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
		return this._opened;
	}

	private var _ignoreOpenCloseChange = false;

	/**
		The space, measured in pixels, added to the left side of the item
		renderer at each level of the hierarchy.

		@since 1.0.0
	**/
	@:style
	public var indentation:Float = 0.0;

	private var _currentBranchOrLeafIcon:DisplayObject;
	private var _branchOrLeafIconMeasurements:Measurements;
	private var _ignoreBranchOrLeafIconResizes:Bool;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch. This icon is displayed in addition to the standard `icon`
		property.

		@see `TreeGridViewCellRenderer.leafIcon`
		@see `TreeGridViewCellRenderer.branchOpenIcon`
		@see `TreeGridViewCellRenderer.branchClosedIcon`

		@since 1.0.0
	**/
	@:style
	public var branchIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch, and the branch is open. If `null`, falls back to `branchIcon`
		instead.

		@see `TreeGridViewCellRenderer.branchClosedIcon`
		@see `TreeGridViewCellRenderer.branchIcon`

		@since 1.0.0
	**/
	@:style
	public var branchOpenIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch, and the branch is closed. If `null`, falls back to `branchIcon`
		instead.

		@see `TreeGridViewCellRenderer.branchOpenIcon`
		@see `TreeGridViewCellRenderer.branchIcon`

		@since 1.0.0
	**/
	@:style
	public var branchClosedIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		leaf. This icon is displayed in addition to the standard `icon`
		property.

		@see `TreeGridViewCellRenderer.branchIcon`

		@since 1.0.0
	**/
	@:style
	public var leafIcon:DisplayObject = null;

	private var disclosureButton:ToggleButton;

	override private function initialize():Void {
		super.initialize();
		if (this.disclosureButton == null) {
			this.disclosureButton = new ToggleButton();
			this.disclosureButton.variant = CHILD_VARIANT_DISCLOSURE_BUTTON;
			this.addChild(this.disclosureButton);
		}
		this.disclosureButton.addEventListener(Event.CHANGE, treeGridViewCellRenderer_disclosureButton_changeHandler);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (stylesInvalid || stateInvalid || dataInvalid) {
			this.refreshBranchOrLeafIcon();
		}

		if (dataInvalid) {
			this.refreshBranchOrLeafStatus();
		}

		if (stateInvalid) {
			this.disclosureButton.enabled = this._enabled;
		}

		if (dataInvalid) {
			this.refreshOpenedState();
		}

		super.update();
	}

	override private function calculateExplicitWidthForTextMeasurement():Null<Float> {
		var textFieldExplicitWidth = super.calculateExplicitWidthForTextMeasurement();
		if (textFieldExplicitWidth == null) {
			return textFieldExplicitWidth;
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var indentDepth = 0;
		if (this._rowLocation != null && this._columnIndex == 0) {
			indentDepth = this._rowLocation.length - 1;
		}
		var indent = this.indentation * indentDepth;
		textFieldExplicitWidth -= indent;
		if (this._columnIndex == 0) {
			this.disclosureButton.validateNow();
			textFieldExplicitWidth -= (this.disclosureButton.width + adjustedGap);
		}
		if (this._currentBranchOrLeafIcon != null) {
			var oldgnoreBranchOrLeafIconResizes = this._ignoreBranchOrLeafIconResizes;
			this._ignoreBranchOrLeafIconResizes = true;
			if ((this._currentBranchOrLeafIcon is IValidating)) {
				cast(this._currentBranchOrLeafIcon, IValidating).validateNow();
			}
			this._ignoreBranchOrLeafIconResizes = oldgnoreBranchOrLeafIconResizes;
			textFieldExplicitWidth -= (this._currentBranchOrLeafIcon.width + adjustedGap);
		}
		if (textFieldExplicitWidth < 0.0) {
			textFieldExplicitWidth = 0.0;
		}
		return textFieldExplicitWidth;
	}

	override private function measureContentWidth():Float {
		var contentWidth = super.measureContentWidth();
		this.disclosureButton.validateNow();
		var oldgnoreBranchOrLeafIconResizes = this._ignoreBranchOrLeafIconResizes;
		this._ignoreBranchOrLeafIconResizes = true;
		if ((this._currentBranchOrLeafIcon is IValidating)) {
			cast(this._currentBranchOrLeafIcon, IValidating).validateNow();
		}
		this._ignoreBranchOrLeafIconResizes = oldgnoreBranchOrLeafIconResizes;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var indentDepth = 0;
		if (this._rowLocation != null && this._columnIndex == 0) {
			indentDepth = this._rowLocation.length - 1;
		}
		var indent = this.indentation * indentDepth;
		contentWidth += indent;
		if (this._columnIndex == 0) {
			contentWidth += this.disclosureButton.width + adjustedGap;
		}
		if (this._currentBranchOrLeafIcon != null) {
			contentWidth += this._currentBranchOrLeafIcon.width + adjustedGap;
		}
		return contentWidth;
	}

	override private function measureContentMinWidth():Float {
		var contentMinWidth = super.measureContentMinWidth();
		this.disclosureButton.validateNow();
		var oldgnoreBranchOrLeafIconResizes = this._ignoreBranchOrLeafIconResizes;
		this._ignoreBranchOrLeafIconResizes = true;
		if ((this._currentBranchOrLeafIcon is IValidating)) {
			cast(this._currentBranchOrLeafIcon, IValidating).validateNow();
		}
		this._ignoreBranchOrLeafIconResizes = oldgnoreBranchOrLeafIconResizes;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var indentDepth = 0;
		if (this._rowLocation != null && this._columnIndex == 0) {
			indentDepth = this._rowLocation.length - 1;
		}
		var indent = this.indentation * indentDepth;
		contentMinWidth += indent;
		if (this._columnIndex == 0) {
			contentMinWidth += this.disclosureButton.width + adjustedGap;
		}
		if (this._currentBranchOrLeafIcon != null) {
			contentMinWidth += this._currentBranchOrLeafIcon.width + adjustedGap;
		}
		return contentMinWidth;
	}

	override private function layoutChildren():Void {
		this.disclosureButton.validateNow();
		var oldgnoreBranchOrLeafIconResizes = this._ignoreBranchOrLeafIconResizes;
		this._ignoreBranchOrLeafIconResizes = true;
		if ((this._currentBranchOrLeafIcon is IValidating)) {
			cast(this._currentBranchOrLeafIcon, IValidating).validateNow();
		}
		this._ignoreBranchOrLeafIconResizes = oldgnoreBranchOrLeafIconResizes;
		var paddingLeft = this.paddingLeft;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var disclosureGap = adjustedGap;
		var branchOrLeafIconGap = adjustedGap;
		var indentDepth = 0;
		if (this._rowLocation != null && this._columnIndex == 0) {
			indentDepth = this._rowLocation.length - 1;
		}
		var indent = this.indentation * indentDepth;
		this.runWithoutInvalidation(() -> {
			var newPaddingLeft = paddingLeft + indent;
			if (this._columnIndex == 0) {
				newPaddingLeft += this.disclosureButton.width + disclosureGap;
			}
			if (this._currentBranchOrLeafIcon != null) {
				newPaddingLeft += this._currentBranchOrLeafIcon.width + branchOrLeafIconGap;
			}
			this.paddingLeft = newPaddingLeft;
		});
		super.layoutChildren();
		this.runWithoutInvalidation(() -> {
			this.paddingLeft = paddingLeft;
		});
		this.disclosureButton.x = this.paddingLeft + indent;
		this.disclosureButton.y = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this.disclosureButton.height) / 2.0;
		if (this._currentBranchOrLeafIcon != null) {
			var branchOrLeafX = this.paddingLeft + indent;
			if (this._columnIndex == 0) {
				branchOrLeafX += this.disclosureButton.width + disclosureGap;
			}
			this._currentBranchOrLeafIcon.x = branchOrLeafX;
			this._currentBranchOrLeafIcon.y = this.paddingTop
				+ (this.actualHeight - this.paddingTop - this.paddingBottom - this._currentBranchOrLeafIcon.height) / 2.0;
		}
	}

	private function initializeTreeGridViewCellRendererTheme():Void {
		SteelTreeGridViewCellRendererStyles.initialize();
	}

	private function refreshBranchOrLeafIcon():Void {
		var oldIcon = this._currentBranchOrLeafIcon;
		this._currentBranchOrLeafIcon = this.getCurrentBranchOrLeafIcon();
		if (this._currentBranchOrLeafIcon == oldIcon) {
			return;
		}
		this.removeCurrentBranchOrLeafIcon(oldIcon);
		this.addCurrentBranchOrLeafIcon(this._currentBranchOrLeafIcon);
	}

	private function getCurrentBranchOrLeafIcon():DisplayObject {
		if (this._branch) {
			if (this._opened && this.branchOpenIcon != null) {
				return this.branchOpenIcon;
			}
			if (!this._opened && this.branchClosedIcon != null) {
				return this.branchClosedIcon;
			}
			return this.branchIcon;
		}
		return this.leafIcon;
	}

	private function removeCurrentBranchOrLeafIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		icon.removeEventListener(Event.RESIZE, treeGridViewCellRenderer_branchOrLeafIcon_resizeHandler);
		if ((icon is IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = null;
		}
		if ((icon is IStateObserver)) {
			cast(icon, IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this icon is used for measurement
		this._branchOrLeafIconMeasurements.restore(icon);
		if (icon.parent == this) {
			this.removeChild(icon);
		}
	}

	private function addCurrentBranchOrLeafIcon(icon:DisplayObject):Void {
		if (icon == null) {
			this._branchOrLeafIconMeasurements = null;
			return;
		}
		if ((icon is IUIControl)) {
			cast(icon, IUIControl).initializeNow();
		}
		if (this._branchOrLeafIconMeasurements == null) {
			this._branchOrLeafIconMeasurements = new Measurements(icon);
		} else {
			this._branchOrLeafIconMeasurements.save(icon);
		}
		if ((icon is IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = this;
		}
		if ((icon is IStateObserver)) {
			cast(icon, IStateObserver).stateContext = this;
		}
		icon.addEventListener(Event.RESIZE, treeGridViewCellRenderer_branchOrLeafIcon_resizeHandler, false, 0, true);
		this.addChild(icon);
	}

	private function refreshBranchOrLeafStatus():Void {
		this.disclosureButton.visible = this._branch && this._columnIndex == 0;
	}

	private function refreshOpenedState():Void {
		var oldIgnoreOpenCloseChange = this._ignoreOpenCloseChange;
		this._ignoreOpenCloseChange = true;
		this.disclosureButton.selected = this._opened;
		this._ignoreOpenCloseChange = oldIgnoreOpenCloseChange;
	}

	private function treeGridViewCellRenderer_disclosureButton_changeHandler(event:Event):Void {
		if (this._ignoreOpenCloseChange) {
			return;
		}
		// use the setter
		this.opened = this.disclosureButton.selected;
	}

	private function treeGridViewCellRenderer_branchOrLeafIcon_resizeHandler(event:Event):Void {
		if (this._ignoreBranchOrLeafIconResizes) {
			return;
		}
		this.setInvalid(STYLES);
	}
}
