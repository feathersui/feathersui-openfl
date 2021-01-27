/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IValidating;
import feathers.core.IUIControl;
import feathers.layout.Measurements;
import feathers.core.IStateObserver;
import feathers.skins.IProgrammaticSkin;
import openfl.display.DisplayObject;
import feathers.events.FeathersEvent;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.core.IOpenCloseToggle;
import feathers.themes.steel.components.SteelTreeViewItemRendererStyles;

/**
	A branch and leaf renderer for `TreeView`.

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:styleContext
class TreeViewItemRenderer extends ItemRenderer implements ITreeViewItemRenderer implements IOpenCloseToggle {
	/**
		A variant used to style the item renderer to appear in a file system
		context where branches are directories/folders and leaves and individual
		files. Variants allow themes to provide an assortment of different
		appearances for the same type of UI component.

		The following example uses this variant:

		```hx
		var itemRenderer = new TreeViewItemRenderer();
		itemRenderer.variant = TreeViewItemRenderer.VARIANT_FILE_SYSTEM;
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
	public static final CHILD_VARIANT_DISCLOSURE_BUTTON = "treeViewItemRenderer_disclosureButton";

	/**
		Creates a new `TreeViewItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTreeViewItemRendererTheme();
		super();
	}

	private var _location:Array<Int>;

	/**
		@see `feathers.controls.dataRenderers.ITreeViewItemRenderer.location`
	**/
	@:flash.property
	public var location(get, set):Array<Int>;

	private function get_location():Array<Int> {
		return this._location;
	}

	private function set_location(value:Array<Int>):Array<Int> {
		if (this._location == value) {
			return this._location;
		}
		this._location = value;
		this.setInvalid(DATA);
		return this._location;
	}

	private var _branch:Bool = false;

	/**
		@see `feathers.controls.dataRenderers.ITreeViewItemRenderer.branch`
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

	private var _treeViewOwner:TreeView;

	/**
		@see `feathers.controls.dataRenderers.ITreeViewItemRenderer.treeViewOwner`
	**/
	@:flash.property
	public var treeViewOwner(get, set):TreeView;

	private function get_treeViewOwner():TreeView {
		return this._treeViewOwner;
	}

	private function set_treeViewOwner(value:TreeView):TreeView {
		if (this._treeViewOwner == value) {
			return this._treeViewOwner;
		}
		this._treeViewOwner = value;
		this.setInvalid(DATA);
		return this._treeViewOwner;
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

	/**
		The display object to use as an icon when the item renderer's data is a
		branch. This icon is displayed in addition to the standard `icon`
		property.

		@see `TreeViewItemRenderer.leafIcon`
		@see `TreeViewItemRenderer.branchOpenIcon`
		@see `TreeViewItemRenderer.branchClosedIcon`

		@since 1.0.0
	**/
	@:style
	public var branchIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch, and the branch is open. If `null`, falls back to `branchIcon`
		instead.

		@see `TreeViewItemRenderer.branchClosedIcon`
		@see `TreeViewItemRenderer.branchIcon`

		@since 1.0.0
	**/
	@:style
	public var branchOpenIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		branch, and the branch is closed. If `null`, falls back to `branchIcon`
		instead.

		@see `TreeViewItemRenderer.branchOpenIcon`
		@see `TreeViewItemRenderer.branchIcon`

		@since 1.0.0
	**/
	@:style
	public var branchClosedIcon:DisplayObject = null;

	/**
		The display object to use as an icon when the item renderer's data is a
		leaf. This icon is displayed in addition to the standard `icon`
		property.

		@see `TreeViewItemRenderer.branchIcon`

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
		this.disclosureButton.addEventListener(Event.CHANGE, treeViewItemRenderer_disclosureButton_changeHandler);
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

	override private function measureContentWidth():Float {
		var contentWidth = super.measureContentWidth();
		this.disclosureButton.validateNow();
		if (Std.is(this._currentBranchOrLeafIcon, IValidating)) {
			cast(this._currentBranchOrLeafIcon, IValidating).validateNow();
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var depth = 0;
		if (this._location != null) {
			depth = this._location.length - 1;
		}
		var indent = this.indentation * depth;
		contentWidth += indent + this.disclosureButton.width + adjustedGap;
		if (this._currentBranchOrLeafIcon != null) {
			contentWidth += this._currentBranchOrLeafIcon.width + adjustedGap;
		}
		return contentWidth;
	}

	override private function measureContentMinWidth():Float {
		var contentMinWidth = super.measureContentMinWidth();
		this.disclosureButton.validateNow();
		if (Std.is(this._currentBranchOrLeafIcon, IValidating)) {
			cast(this._currentBranchOrLeafIcon, IValidating).validateNow();
		}
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var depth = 0;
		if (this._location != null) {
			depth = this._location.length - 1;
		}
		var indent = this.indentation * depth;
		contentMinWidth += indent + this.disclosureButton.width + adjustedGap;
		if (this._currentBranchOrLeafIcon != null) {
			contentMinWidth += this._currentBranchOrLeafIcon.width + adjustedGap;
		}
		return contentMinWidth;
	}

	override private function layoutContent():Void {
		this.disclosureButton.validateNow();
		if (Std.is(this._currentBranchOrLeafIcon, IValidating)) {
			cast(this._currentBranchOrLeafIcon, IValidating).validateNow();
		}
		var paddingLeft = this.paddingLeft;
		var adjustedGap = this.gap;
		// Math.POSITIVE_INFINITY bug workaround
		if (adjustedGap == (1.0 / 0.0)) {
			adjustedGap = this.minGap;
		}
		var disclosureGap = adjustedGap;
		var branchOrLeafIconGap = adjustedGap;
		var depth = 0;
		if (this._location != null) {
			depth = this._location.length - 1;
		}
		var indent = this.indentation * depth;
		this.runWithoutInvalidation(() -> {
			var newPaddingLeft = paddingLeft + indent + this.disclosureButton.width + disclosureGap;
			if (this._currentBranchOrLeafIcon != null) {
				newPaddingLeft += this._currentBranchOrLeafIcon.width + branchOrLeafIconGap;
			}
			this.paddingLeft = newPaddingLeft;
		});
		super.layoutContent();
		this.runWithoutInvalidation(() -> {
			this.paddingLeft = paddingLeft;
		});
		this.disclosureButton.x = this.paddingLeft + indent;
		this.disclosureButton.y = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this.disclosureButton.height) / 2.0;
		if (this._currentBranchOrLeafIcon != null) {
			this._currentBranchOrLeafIcon.x = this.disclosureButton.x + this.disclosureButton.width + disclosureGap;
			this._currentBranchOrLeafIcon.y = this.paddingTop
				+ (this.actualHeight - this.paddingTop - this.paddingBottom - this._currentBranchOrLeafIcon.height) / 2.0;
		}
	}

	private function initializeTreeViewItemRendererTheme():Void {
		SteelTreeViewItemRendererStyles.initialize();
	}

	private function refreshBranchOrLeafIcon():Void {
		var oldIcon = this._currentBranchOrLeafIcon;
		this._currentBranchOrLeafIcon = this.getCurrentBranchOrLeafIcon();
		if (this._currentBranchOrLeafIcon == oldIcon) {
			return;
		}
		this.removeCurrentBranchOrLeafIcon(oldIcon);
		if (this._currentBranchOrLeafIcon == null) {
			this._branchOrLeafIconMeasurements = null;
			return;
		}
		if (Std.is(this._currentBranchOrLeafIcon, IUIControl)) {
			cast(this._currentBranchOrLeafIcon, IUIControl).initializeNow();
		}
		if (this._branchOrLeafIconMeasurements == null) {
			this._branchOrLeafIconMeasurements = new Measurements(this._currentBranchOrLeafIcon);
		} else {
			this._branchOrLeafIconMeasurements.save(this._currentBranchOrLeafIcon);
		}
		if (Std.is(this._currentBranchOrLeafIcon, IProgrammaticSkin)) {
			cast(this._currentBranchOrLeafIcon, IProgrammaticSkin).uiContext = this;
		}
		if (Std.is(this._currentBranchOrLeafIcon, IStateObserver)) {
			cast(this._currentBranchOrLeafIcon, IStateObserver).stateContext = this;
		}
		this.addChild(this._currentBranchOrLeafIcon);
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
		if (Std.is(icon, IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = null;
		}
		if (Std.is(icon, IStateObserver)) {
			cast(icon, IStateObserver).stateContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this icon is used for measurement
		this._branchOrLeafIconMeasurements.restore(icon);
		if (icon.parent == this) {
			this.removeChild(icon);
		}
	}

	private function refreshBranchOrLeafStatus():Void {
		this.disclosureButton.visible = this._branch;
	}

	private function refreshOpenedState():Void {
		var oldIgnoreOpenCloseChange = this._ignoreOpenCloseChange;
		this._ignoreOpenCloseChange = true;
		this.disclosureButton.selected = this._opened;
		this._ignoreOpenCloseChange = oldIgnoreOpenCloseChange;
	}

	private function treeViewItemRenderer_disclosureButton_changeHandler(event:Event):Void {
		if (this._ignoreOpenCloseChange) {
			return;
		}
		// use the setter
		this.opened = this.disclosureButton.selected;
	}
}
