/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.Shape;
import feathers.core.PopUpManager;
import massive.munit.Assert;

@:keep
class PopUpManagerTest {
	private static final POPUP1_WIDTH = 10.0;
	private static final POPUP1_HEIGHT = 20.0;
	private static final POPUP2_WIDTH = 30.0;
	private static final POPUP2_HEIGHT = 15.0;

	private var _popUp1:Shape;
	private var _popUp2:Shape;
	private var _customRoot:Sprite;

	@After
	public function cleanup():Void {
		if (this._popUp1 != null) {
			if (this._popUp1.parent != null) {
				this._popUp1.parent.removeChild(this._popUp1);
			}
			this._popUp1 = null;
		}
		if (this._popUp2 != null) {
			if (this._popUp2.parent != null) {
				this._popUp2.parent.removeChild(this._popUp2);
			}
			this._popUp2 = null;
		}
		if (this._customRoot != null) {
			if (this._customRoot.parent != null) {
				this._customRoot.parent.removeChild(this._customRoot);
			}
			this._customRoot = null;
		}
		PopUpManager.dispose();

		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.areEqual(1, TestMain.openfl_root.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	private function createPopUp1():Void {
		this._popUp1 = new Shape();
		this._popUp1.graphics.beginFill(0xff00ff, 1.0);
		this._popUp1.graphics.drawRect(0, 0, POPUP1_WIDTH, POPUP1_HEIGHT);
		this._popUp1.graphics.endFill();
	}

	private function createPopUp2():Void {
		this._popUp2 = new Shape();
		this._popUp2.graphics.beginFill(0xff00ff, 1.0);
		this._popUp2.graphics.drawRect(0, 0, POPUP2_WIDTH, POPUP2_HEIGHT);
		this._popUp2.graphics.endFill();
	}

	@Test
	public function testDefaults():Void {
		this.createPopUp1();
		Assert.areEqual(0, PopUpManager.popUpCount);
		Assert.isFalse(PopUpManager.isModal(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isModal(this._popUp1));
		var popUpManager = PopUpManager.forStage(TestMain.openfl_root.stage);
		Assert.isNotNull(popUpManager);
		Assert.areEqual(TestMain.openfl_root.stage, popUpManager.root);
	}

	@Test
	public function testIsFunctionsWithNull():Void {
		Assert.isFalse(PopUpManager.isPopUp(null));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(null));
		Assert.isFalse(PopUpManager.isModal(null));
	}

	@Test
	public function testPopUpCount():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.areEqual(0, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		Assert.areEqual(1, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		Assert.areEqual(2, PopUpManager.popUpCount);
		PopUpManager.removePopUp(this._popUp1);
		Assert.areEqual(1, PopUpManager.popUpCount);
		PopUpManager.removePopUp(this._popUp2);
		Assert.areEqual(0, PopUpManager.popUpCount);
	}

	@Test
	public function testPopUpCountWithRemoveChild():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.areEqual(0, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		Assert.areEqual(1, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		Assert.areEqual(2, PopUpManager.popUpCount);
		this._popUp1.parent.removeChild(this._popUp1);
		Assert.areEqual(1, PopUpManager.popUpCount);
		this._popUp2.parent.removeChild(this._popUp2);
		Assert.areEqual(0, PopUpManager.popUpCount);
	}

	@Test
	public function testIsPopUp():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		Assert.isTrue(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		Assert.isTrue(PopUpManager.isPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.removePopUp(this._popUp1);
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.removePopUp(this._popUp2);
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp2));
	}

	@Test
	public function testPopUpParent():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isNull(this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		Assert.isNotNull(this._popUp1.parent);
		Assert.areEqual(TestMain.openfl_root.stage, this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		Assert.isNotNull(this._popUp1.parent);
		Assert.isNotNull(this._popUp2.parent);
		Assert.areEqual(TestMain.openfl_root.stage, this._popUp2.parent);
		PopUpManager.removePopUp(this._popUp1);
		Assert.isNull(this._popUp1.parent);
		Assert.isNotNull(this._popUp2.parent);
		PopUpManager.removePopUp(this._popUp2);
		Assert.isNull(this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
	}

	@Test
	public function testIsTopLevelPopUpWithModals():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root, true);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root, true);
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	@Test
	public function testAddPopUpAndIsTopLevelPopUpWithModalAndNonModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root, true);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	@Test
	public function testAddPopUpAndIsTopLevelPopUpWithNonModalAndModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root, true);
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	@Test
	public function testAddPopUpAndIsTopLevelPopUpWithNonModals():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	@Test
	public function testRemoveAllPopUps():Void {
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		Assert.areEqual(2, PopUpManager.popUpCount);
		PopUpManager.removeAllPopUps();
		Assert.areEqual(0, PopUpManager.popUpCount);
		Assert.isNull(this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
	}

	@Test
	public function testCenterPopUp():Void {
		this.createPopUp1();
		this.createPopUp2();
		var x = -10;
		var y = -50;
		this._popUp1.x = x;
		this._popUp1.y = y;
		this._popUp2.x = x;
		this._popUp2.y = y;
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root, false, true);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root, false, false);
		Assert.areNotEqual(x, this._popUp1.x);
		Assert.areNotEqual(y, this._popUp1.y);
		Assert.areEqual((TestMain.openfl_root.stage.stageWidth - POPUP1_WIDTH) / 2.0, this._popUp1.x);
		Assert.areEqual((TestMain.openfl_root.stage.stageHeight - POPUP1_HEIGHT) / 2.0, this._popUp1.y);
		Assert.areEqual(x, this._popUp2.x);
		Assert.areEqual(y, this._popUp2.y);
	}

	@Test
	public function testRemovePopUpFromRemovedEventForOtherPopUp():Void {
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		this._popUp1.addEventListener(Event.REMOVED, (event:Event) -> {
			this._popUp2.parent.removeChild(this._popUp2);
		});
		PopUpManager.removeAllPopUps();
		Assert.areEqual(0, PopUpManager.popUpCount);
	}

	@Test
	public function testCustomRoot():Void {
		this._customRoot = new Sprite();
		TestMain.openfl_root.addChild(this._customRoot);
		Assert.areEqual(TestMain.openfl_root.stage, PopUpManager.forStage(TestMain.openfl_root.stage).root);
		PopUpManager.root = this._customRoot;
		Assert.areNotEqual(TestMain.openfl_root.stage, PopUpManager.forStage(TestMain.openfl_root.stage).root);
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		Assert.areEqual(this._customRoot, this._popUp1.parent);
		Assert.areEqual(this._customRoot, this._popUp2.parent);
	}

	@Test
	public function testCustomRootAfterAddPopUp():Void {
		this._customRoot = new Sprite();
		TestMain.openfl_root.addChild(this._customRoot);
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, TestMain.openfl_root);
		PopUpManager.addPopUp(this._popUp2, TestMain.openfl_root);
		Assert.areNotEqual(this._customRoot, this._popUp1.parent);
		Assert.areNotEqual(this._customRoot, this._popUp2.parent);
		PopUpManager.root = this._customRoot;
		Assert.areEqual(this._customRoot, this._popUp1.parent);
		Assert.areEqual(this._customRoot, this._popUp2.parent);
	}
}
