/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.display.Shape;
import feathers.core.PopUpManager;
import openfl.display.Sprite;
import utest.Assert;
import utest.Test;

@:keep
class PopUpUtilTest extends Test {
	private static final POPUP1_WIDTH = 10.0;
	private static final POPUP1_HEIGHT = 20.0;
	private static final POPUP2_WIDTH = 30.0;
	private static final POPUP2_HEIGHT = 15.0;

	private var _popUp1:Sprite;
	private var _popUp1Child:Shape;
	private var _popUp2:Sprite;
	private var _popUp2Child:Shape;

	public function teardown():Void {
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
		var popUpManager = PopUpManager.forStage(TestMain.openfl_root.stage);
		popUpManager.removeAllPopUps();
		popUpManager.root = TestMain.openfl_root.stage;

		// just in case
		PopUpManager.dispose();

		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, TestMain.openfl_root.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	private function createPopUp1():Void {
		this._popUp1 = new Sprite();
		this._popUp1.graphics.beginFill(0xff00ff, 1.0);
		this._popUp1.graphics.drawRect(0, 0, POPUP1_WIDTH, POPUP1_HEIGHT);
		this._popUp1.graphics.endFill();
		this._popUp1Child = new Shape();
		this._popUp1Child.graphics.beginFill(0x00ff00, 1.0);
		this._popUp1Child.graphics.drawRect(0, 0, POPUP1_WIDTH / 2.0, POPUP1_HEIGHT / 2.0);
		this._popUp1Child.graphics.endFill();
		this._popUp1.addChild(this._popUp1Child);
	}

	private function createPopUp2():Void {
		this._popUp2 = new Sprite();
		this._popUp2.graphics.beginFill(0xff00ff, 1.0);
		this._popUp2.graphics.drawRect(0, 0, POPUP2_WIDTH, POPUP2_HEIGHT);
		this._popUp2.graphics.endFill();
		this._popUp2Child = new Shape();
		this._popUp2Child.graphics.beginFill(0x00ff00, 1.0);
		this._popUp2Child.graphics.drawRect(0, 0, POPUP2_WIDTH / 2.0, POPUP2_HEIGHT / 2.0);
		this._popUp2Child.graphics.endFill();
		this._popUp2.addChild(this._popUp2Child);
	}

	public function testIsTopLevelPopUpOrIsContainedByTopLevelPopUpDefaults():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1Child));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2Child));
	}

	public function testIsTopLevelPopUpOrIsContainedByTopLevelPopUpDefaults2():Void {
		this.createPopUp1();
		this.createPopUp2();
		TestMain.openfl_root.addChild(this._popUp1);
		TestMain.openfl_root.addChild(this._popUp2);
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1Child));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2Child));
	}

	public function testIsTopLevelPopUpOrIsContainedByTopLevelPopUpWithNoModals():Void {
		this.createPopUp1();
		this.createPopUp2();
		var popUpManager = PopUpManager.forStage(TestMain.openfl_root.stage);
		popUpManager.addPopUp(this._popUp1, false);
		popUpManager.addPopUp(this._popUp2, false);
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1Child));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2Child));
	}

	public function testIsTopLevelPopUpOrIsContainedByTopLevelPopUpWithFirstModalAndSecondNotModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		var popUpManager = PopUpManager.forStage(TestMain.openfl_root.stage);
		popUpManager.addPopUp(this._popUp1, true);
		popUpManager.addPopUp(this._popUp2, false);
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1Child));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2Child));
	}

	public function testIsTopLevelPopUpOrIsContainedByTopLevelPopUpWithFirstNotModalAndSecondModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		var popUpManager = PopUpManager.forStage(TestMain.openfl_root.stage);
		popUpManager.addPopUp(this._popUp1, false);
		popUpManager.addPopUp(this._popUp2, true);
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1Child));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2Child));
	}

	public function testIsTopLevelPopUpOrIsContainedByTopLevelPopUpWithFirstModalAndSecondModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		var popUpManager = PopUpManager.forStage(TestMain.openfl_root.stage);
		popUpManager.addPopUp(this._popUp1, true);
		popUpManager.addPopUp(this._popUp2, true);
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp1Child));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2));
		Assert.isTrue(PopUpUtil.isTopLevelPopUpOrIsContainedByTopLevelPopUp(this._popUp2Child));
	}
}
