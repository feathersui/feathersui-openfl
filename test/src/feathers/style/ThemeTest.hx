/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import feathers.controls.LayoutGroup;
import massive.munit.Assert;

@:keep
class ThemeTest {
	private var _container:LayoutGroup;
	private var _containerChild:LayoutGroup;
	private var _otherChild:LayoutGroup;

	@Before
	public function prepare():Void {
		this._container = new LayoutGroup();
		this._containerChild = new LayoutGroup();
		this._container.addChild(this._containerChild);
		TestMain.openfl_root.addChild(this._container);
		this._otherChild = new LayoutGroup();
		TestMain.openfl_root.addChild(this._otherChild);
	}

	@After
	public function cleanup():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
		this._containerChild = null;
		if (this._otherChild.parent != null) {
			this._otherChild.parent.removeChild(this._otherChild);
		}
		this._otherChild = null;
		Theme.setTheme(null);
		Theme.setTheme(null, this._container);
		Assert.areEqual(Theme.fallbackTheme, Theme.getTheme(), "Test cleanup failed to remove primary theme.");
		Assert.areEqual(Theme.fallbackTheme, Theme.getTheme(this._container), "Test cleanup failed to remove container theme");
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testGetThemeWithNoThemes():Void {
		Assert.areEqual(Theme.fallbackTheme, Theme.getTheme(), "Must not have primary theme");
		Assert.areEqual(Theme.fallbackTheme, Theme.getTheme(this._container), "Must not have primary theme for container");
		Assert.areEqual(Theme.fallbackTheme, Theme.getTheme(this._containerChild), "Must not have primary theme for child of container");
		Assert.areEqual(Theme.fallbackTheme, Theme.getTheme(this._otherChild), "Must not have primary theme for child of container");
	}

	@Test
	public function testGetThemeWithPrimaryTheme():Void {
		var primaryTheme = new MockTheme();
		Theme.setTheme(primaryTheme);
		Assert.areEqual(primaryTheme, Theme.getTheme(), "Must return primary theme");
		Assert.areEqual(primaryTheme, Theme.getTheme(this._container), "Must return primary theme for container");
		Assert.areEqual(primaryTheme, Theme.getTheme(this._containerChild), "Must return primary theme for child of container");
		Assert.areEqual(primaryTheme, Theme.getTheme(this._otherChild), "Must return primary theme for non-child of container");
	}

	@Test
	public function testGetThemeWithPrimaryAndContainerTheme():Void {
		var primaryTheme = new MockTheme();
		Theme.setTheme(primaryTheme);
		var containerTheme = new MockTheme();
		Theme.setTheme(containerTheme, this._container);
		Assert.areEqual(primaryTheme, Theme.getTheme(), "Must return primary theme");
		Assert.areEqual(containerTheme, Theme.getTheme(this._container), "Must return container theme for container");
		Assert.areEqual(containerTheme, Theme.getTheme(this._containerChild), "Must return container theme for child of container");
		Assert.areEqual(primaryTheme, Theme.getTheme(this._otherChild), "Must return primary theme for non-child of container");
	}
}

class MockTheme implements ITheme {
	public function new() {}

	public function dispose() {}

	public function getStyleProvider(target:IStyleObject):IStyleProvider {
		return null;
	}
}
