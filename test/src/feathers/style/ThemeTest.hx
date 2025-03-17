/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import feathers.controls.LayoutGroup;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class ThemeTest extends Test {
	private var _container:LayoutGroup;
	private var _containerChild:LayoutGroup;
	private var _otherChild:LayoutGroup;
	private var _themeDisabledChild:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._container = new LayoutGroup();
		this._containerChild = new LayoutGroup();
		this._container.addChild(this._containerChild);
		Lib.current.addChild(this._container);
		this._otherChild = new LayoutGroup();
		Lib.current.addChild(this._otherChild);
		this._themeDisabledChild = new LayoutGroup();
		this._themeDisabledChild.themeEnabled = false;
		Lib.current.addChild(this._themeDisabledChild);
	}

	public function teardown():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
		this._containerChild = null;
		if (this._otherChild.parent != null) {
			this._otherChild.parent.removeChild(this._otherChild);
		}
		this._otherChild = null;
		if (this._themeDisabledChild.parent != null) {
			this._themeDisabledChild.parent.removeChild(this._themeDisabledChild);
		}
		this._themeDisabledChild = null;
		Theme.setTheme(null);
		Theme.setTheme(null, this._container);
		Assert.equals(Theme.fallbackTheme, Theme.getTheme(), "Test cleanup failed to remove primary theme.");
		Assert.equals(Theme.fallbackTheme, Theme.getTheme(this._container), "Test cleanup failed to remove container theme");
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testGetThemeWithNoThemes():Void {
		Assert.equals(Theme.fallbackTheme, Theme.getTheme(), "Must not have primary theme");
		Assert.equals(Theme.fallbackTheme, Theme.getTheme(this._container), "Must not have primary theme for container");
		Assert.equals(Theme.fallbackTheme, Theme.getTheme(this._containerChild), "Must not have primary theme for child of container");
		Assert.equals(Theme.fallbackTheme, Theme.getTheme(this._otherChild), "Must not have primary theme for child of container");
		Assert.isNull(Theme.getTheme(this._themeDisabledChild));
	}

	public function testGetThemeWithPrimaryTheme():Void {
		var primaryTheme = new MockTheme();
		Theme.setTheme(primaryTheme);
		Assert.equals(primaryTheme, Theme.getTheme(), "Must return primary theme");
		Assert.equals(primaryTheme, Theme.getTheme(this._container), "Must return primary theme for container");
		Assert.equals(primaryTheme, Theme.getTheme(this._containerChild), "Must return primary theme for child of container");
		Assert.equals(primaryTheme, Theme.getTheme(this._otherChild), "Must return primary theme for non-child of container");
		Assert.isNull(Theme.getTheme(this._themeDisabledChild));
	}

	public function testGetThemeWithPrimaryAndContainerTheme():Void {
		var primaryTheme = new MockTheme();
		Theme.setTheme(primaryTheme);
		var containerTheme = new MockTheme();
		Theme.setTheme(containerTheme, this._container);
		Assert.equals(primaryTheme, Theme.getTheme(), "Must return primary theme");
		Assert.equals(containerTheme, Theme.getTheme(this._container), "Must return container theme for container");
		Assert.equals(containerTheme, Theme.getTheme(this._containerChild), "Must return container theme for child of container");
		Assert.equals(primaryTheme, Theme.getTheme(this._otherChild), "Must return primary theme for non-child of container");
		Assert.isNull(Theme.getTheme(this._themeDisabledChild));
	}
}

class MockTheme implements ITheme {
	public function new() {}

	public function dispose() {}

	public function getStyleProvider(target:IStyleObject):IStyleProvider {
		return null;
	}
}
