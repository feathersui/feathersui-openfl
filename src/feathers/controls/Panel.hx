/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.steel.components.SteelPanelStyles;
import openfl.display.DisplayObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;

@:styleContext
class Panel extends ScrollContainer {
	private static final INVALIDATION_FLAG_HEADER_FACTORY = "headerFactory";
	private static final INVALIDATION_FLAG_FOOTER_FACTORY = "footerFactory";

	public function new() {
		initializePanelTheme();

		super();
	}

	private var header:IUIControl;
	private var footer:IUIControl;

	public var headerFactory(default, set):() -> IUIControl = null;

	private function set_headerFactory(value:() -> IUIControl):() -> IUIControl {
		if (this.headerFactory == value) {
			return this.headerFactory;
		}
		this.headerFactory = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_FACTORY);
		return this.headerFactory;
	}

	public var footerFactory(default, set):() -> IUIControl = null;

	private function set_footerFactory(value:() -> IUIControl):() -> IUIControl {
		if (this.footerFactory == value) {
			return this.footerFactory;
		}
		this.footerFactory = value;
		this.setInvalid(INVALIDATION_FLAG_FOOTER_FACTORY);
		return this.footerFactory;
	}

	private function initializePanelTheme():Void {
		SteelPanelStyles.initialize();
	}

	override private function update():Void {
		var headerInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_FACTORY);
		var footerInvalid = this.isInvalid(INVALIDATION_FLAG_FOOTER_FACTORY);
		if (headerInvalid) {
			this.createHeader();
		}
		if (footerInvalid) {
			this.createFooter();
		}
		super.update();
		this.layoutHeader();
		this.layoutFooter();
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

	private function createHeader():Void {
		if (this.header != null) {
			this.removeChild(cast(this.header, DisplayObject));
			this.header = null;
		}
		if (this.headerFactory == null) {
			return;
		}
		this.header = this.headerFactory();
		this.addRawChild(cast(this.header, DisplayObject));
	}

	private function createFooter():Void {
		if (this.footer != null) {
			this.removeChild(cast(this.footer, DisplayObject));
			this.footer = null;
		}
		if (this.footerFactory == null) {
			return;
		}
		this.footer = this.footerFactory();
		this.addRawChild(cast(this.footer, DisplayObject));
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
