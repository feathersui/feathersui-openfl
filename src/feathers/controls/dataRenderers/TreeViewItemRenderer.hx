/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

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
@:styleContext
class TreeViewItemRenderer extends ItemRenderer implements ITreeViewItemRenderer implements IDataRenderer implements IOpenCloseToggle {
	/**
		The variant used to style the `ToggleButton` child component in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)
	**/
	public static final CHILD_VARIANT_DISCLOSURE_BUTTON = "treeViewItemRenderer_disclosureButton";

	/**
		Creates a new `TreeViewItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTreeViewItemRendererTheme();
		super();
		this.mouseChildren = true;
	}

	/**
		@since 1.0.0
	**/
	@:isVar
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this.data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (this.data == value) {
			return this.data;
		}
		this.data = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.data;
	}

	@:isVar
	public var location(get, set):Array<Int>;

	private function get_location():Array<Int> {
		return this.location;
	}

	private function set_location(value:Array<Int>):Array<Int> {
		if (this.location == value) {
			return this.location;
		}
		this.location = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.location;
	}

	@:isVar
	public var branch(get, set):Bool;

	private function get_branch():Bool {
		return this.branch;
	}

	private function set_branch(value:Bool):Bool {
		if (this.branch == value) {
			return this.branch;
		}
		this.branch = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.branch;
	}

	@:isVar
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		return this.opened;
	}

	private function set_opened(value:Bool):Bool {
		if (this.opened == value) {
			return this.opened;
		}
		this.opened = value;
		this.setInvalid(InvalidationFlag.DATA);
		if (this.opened) {
			FeathersEvent.dispatch(this, Event.OPEN);
		} else {
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
		return this.opened;
	}

	private var _ignoreOpenCloseChange = false;

	@:style
	public var indentation:Float = 0.0;

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
		this.disclosureButton.visible = this.branch;
		var oldIgnoreOpenCloseChange = this._ignoreOpenCloseChange;
		this._ignoreOpenCloseChange = true;
		this.disclosureButton.selected = this.opened;
		this._ignoreOpenCloseChange = oldIgnoreOpenCloseChange;
		super.update();
	}

	override private function layoutContent():Void {
		this.disclosureButton.validateNow();
		var paddingLeft = this.paddingLeft;
		var disclosureGap = this.gap;
		var depth = 0;
		if (this.location != null) {
			depth = this.location.length - 1;
		}
		var indent = this.indentation * depth;
		@:bypassAccessor this.paddingLeft = paddingLeft + indent + this.disclosureButton.width + disclosureGap;
		super.layoutContent();
		@:bypassAccessor this.paddingLeft = paddingLeft;
		this.disclosureButton.x = this.paddingLeft + indent;
		this.disclosureButton.y = this.paddingTop + (this.actualHeight - this.paddingTop - this.paddingBottom - this.disclosureButton.height) / 2.0;
	}

	private function initializeTreeViewItemRendererTheme():Void {
		SteelTreeViewItemRendererStyles.initialize();
	}

	private function treeViewItemRenderer_disclosureButton_changeHandler(event:Event):Void {
		if (this._ignoreOpenCloseChange) {
			return;
		}
		this.opened = this.disclosureButton.selected;
	}
}
