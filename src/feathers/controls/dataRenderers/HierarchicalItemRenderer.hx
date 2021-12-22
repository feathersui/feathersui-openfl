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
import feathers.themes.steel.components.SteelHierarchicalItemRendererStyles;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;

/**
	A branch and leaf renderer for hierarchical data containers, such as
	`TreeView` and `TreeGridView`.

	@event openfl.events.Event.OPEN Dispatched when a branch item renderer
	opens. Does not get dispatched for leaf item renderers.

	@event openfl.events.Event.CLOSE Dispatched when a branch item renderer
	closes. Does not get dispatched for leaf item renderers.

	@see `feathers.controls.TreeView`
	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:styleContext
class HierarchicalItemRenderer extends ItemRenderer implements IHierarchicalItemRenderer implements IHierarchicalDepthItemRenderer
		implements IOptionalHierarchyItemRenderer implements IOpenCloseToggle {
	/**
		A variant used to style the item renderer to appear in a file system
		context where branches are directories/folders and leaves and individual
		files. Variants allow themes to provide an assortment of different
		appearances for the same type of UI component.

		The following example uses this variant:

		```hx
		var itemRenderer = new HierarchicalItemRenderer();
		itemRenderer.variant = HierarchicalItemRenderer.VARIANT_FILE_SYSTEM;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_FILE_SYSTEM = "fileSystem";

	/**
		The variant used to style the `ToggleButton` child component in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_DISCLOSURE_BUTTON = "hierarchicalItemRenderer_disclosureButton";

	/**
		Creates a new `HierarchicalItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeHierarchicalItemRendererTheme();
		super();
	}

	private var _hierarchyDepth:Int = 0;

	/**
		@see `feathers.controls.dataRenderers.IHierarchicalDepthItemRenderer.hierarchyDepth`
	**/
	@:flash.property
	public var hierarchyDepth(get, set):Int;

	private function get_hierarchyDepth():Int {
		return this._hierarchyDepth;
	}

	private function set_hierarchyDepth(value:Int):Int {
		if (this._hierarchyDepth == value) {
			return this._hierarchyDepth;
		}
		this._hierarchyDepth = value;
		this.setInvalid(DATA);
		return this._hierarchyDepth;
	}

	private var _branch:Bool = false;

	/**
		@see `feathers.controls.dataRenderers.IHierarchicalItemRenderer.branch`
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

	private var _showHierarchy:Bool = true;

	/**
		@see `feathers.controls.dataRenderers.IOptionaHierarchyItemRenderer.showHierarchy`
	**/
	@:flash.property
	public var showHierarchy(get, set):Bool;

	private function get_showHierarchy():Bool {
		return this._showHierarchy;
	}

	private function set_showHierarchy(value:Bool):Bool {
		if (this._showHierarchy == value) {
			return this._showHierarchy;
		}
		this._showHierarchy = value;
		this.setInvalid(DATA);
		return this._showHierarchy;
	}

	/**
		The space, measured in pixels, added to the left side of the item
		renderer at each level of the hierarchy.

		@since 1.0.0
	**/
	@:style
	public var indentation:Float = 0.0;

	private var _currentBranchOrLeafIcon:DisplayObject;
	private var _branchOrLeafIconMeasurements:Measurements;
	private var _ignoreBranchOrLeafIconResizes = false;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch. This icon is displayed in addition to the standard `icon`
		property.

		@see `HierarchicalItemRenderer.leafIcon`
		@see `HierarchicalItemRenderer.branchOpenIcon`
		@see `HierarchicalItemRenderer.branchClosedIcon`

		@since 1.0.0
	**/
	@:style
	public var branchIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch, and the branch is open. If `null`, falls back to `branchIcon`
		instead.

		@see `HierarchicalItemRenderer.branchClosedIcon`
		@see `HierarchicalItemRenderer.branchIcon`

		@since 1.0.0
	**/
	@:style
	public var branchOpenIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch, and the branch is closed. If `null`, falls back to `branchIcon`
		instead.

		@see `HierarchicalItemRenderer.branchOpenIcon`
		@see `HierarchicalItemRenderer.branchIcon`

		@since 1.0.0
	**/
	@:style
	public var branchClosedIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		leaf. This icon is displayed in addition to the standard `icon`
		property.

		@see `HierarchicalItemRenderer.branchIcon`

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
		this.disclosureButton.addEventListener(Event.CHANGE, hierarchicalItemRenderer_disclosureButton_changeHandler);
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
		if (textFieldExplicitWidth == null || !this._showHierarchy) {
			return textFieldExplicitWidth;
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var indent = this._showHierarchy ? (this.indentation * this._hierarchyDepth) : 0;
		textFieldExplicitWidth -= indent;
		this.disclosureButton.validateNow();
		textFieldExplicitWidth -= (this.disclosureButton.width + adjustedGap);
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
		if (!this._showHierarchy) {
			return contentWidth;
		}
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
		var indent = this._showHierarchy ? (this.indentation * this._hierarchyDepth) : 0;
		contentWidth += indent + this.disclosureButton.width + adjustedGap;
		if (this._currentBranchOrLeafIcon != null) {
			contentWidth += this._currentBranchOrLeafIcon.width + adjustedGap;
		}
		return contentWidth;
	}

	override private function measureContentMinWidth():Float {
		var contentMinWidth = super.measureContentMinWidth();
		if (!this._showHierarchy) {
			return contentMinWidth;
		}
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
		var indent = this._showHierarchy ? (this.indentation * this._hierarchyDepth) : 0;
		contentMinWidth += indent + this.disclosureButton.width + adjustedGap;
		if (this._currentBranchOrLeafIcon != null) {
			contentMinWidth += this._currentBranchOrLeafIcon.width + adjustedGap;
		}
		return contentMinWidth;
	}

	override private function layoutChildren():Void {
		if (!this._showHierarchy) {
			super.layoutChildren();
			return;
		}
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
		var indent = this._showHierarchy ? (this.indentation * this._hierarchyDepth) : 0;
		this.runWithoutInvalidation(() -> {
			var newPaddingLeft = paddingLeft + indent + this.disclosureButton.width + disclosureGap;
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
		switch (this.verticalAlign) {
			case TOP:
				this.disclosureButton.y = this.paddingTop;
			case BOTTOM:
				this.disclosureButton.y = Math.max(this.paddingTop,
					this.paddingTop
					+ this.actualHeight
					- this.paddingTop
					- this.paddingBottom
					- this.disclosureButton.height);
			case MIDDLE:
				this.disclosureButton.y = Math.max(this.paddingTop,
					this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this.disclosureButton.height) / 2.0);
			default:
				throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
		}
		if (this._currentBranchOrLeafIcon != null) {
			this._currentBranchOrLeafIcon.x = this.disclosureButton.x + this.disclosureButton.width + disclosureGap;
			switch (this.verticalAlign) {
				case TOP:
					this._currentBranchOrLeafIcon.y = this.paddingTop;
				case BOTTOM:
					this._currentBranchOrLeafIcon.y = Math.max(this.paddingTop,
						this.paddingTop
						+ this.actualHeight
						- this.paddingTop
						- this.paddingBottom
						- this._currentBranchOrLeafIcon.height);
				case MIDDLE:
					this._currentBranchOrLeafIcon.y = Math.max(this.paddingTop,
						this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this._currentBranchOrLeafIcon.height) / 2.0);
				default:
					throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
			}
		}
	}

	private function initializeHierarchicalItemRendererTheme():Void {
		SteelHierarchicalItemRendererStyles.initialize();
	}

	private function refreshBranchOrLeafIcon():Void {
		var oldIcon = this._currentBranchOrLeafIcon;
		this._currentBranchOrLeafIcon = this.getCurrentBranchOrLeafIcon();
		if (this._currentBranchOrLeafIcon != null) {
			this._currentBranchOrLeafIcon.visible = this._showHierarchy;
		}
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
		icon.removeEventListener(Event.RESIZE, hierarchicalItemRenderer_branchOrLeafIcon_resizeHandler);
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
		icon.addEventListener(Event.RESIZE, hierarchicalItemRenderer_branchOrLeafIcon_resizeHandler, false, 0, true);
		this.addChild(icon);
	}

	private function refreshBranchOrLeafStatus():Void {
		this.disclosureButton.visible = this._showHierarchy && this._branch;
	}

	private function refreshOpenedState():Void {
		var oldIgnoreOpenCloseChange = this._ignoreOpenCloseChange;
		this._ignoreOpenCloseChange = true;
		this.disclosureButton.selected = this._opened;
		this._ignoreOpenCloseChange = oldIgnoreOpenCloseChange;
	}

	private function hierarchicalItemRenderer_disclosureButton_changeHandler(event:Event):Void {
		if (this._ignoreOpenCloseChange) {
			return;
		}
		// use the setter
		this.opened = this.disclosureButton.selected;
	}

	private function hierarchicalItemRenderer_branchOrLeafIcon_resizeHandler(event:Event):Void {
		if (this._ignoreBranchOrLeafIconResizes) {
			return;
		}
		this.setInvalid(STYLES);
	}
}
