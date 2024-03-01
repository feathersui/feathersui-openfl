/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.core.PopUpManager;
import openfl.Lib;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class PopUpManagerTest extends Test {
	private static final POPUP1_WIDTH = 10.0;
	private static final POPUP1_HEIGHT = 20.0;
	private static final POPUP2_WIDTH = 30.0;
	private static final POPUP2_HEIGHT = 15.0;

	private var _popUp1:Shape;
	private var _popUp2:Shape;
	private var _customRoot:Sprite;

	public function new() {
		super();
	}

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
		if (this._customRoot != null) {
			if (this._customRoot.parent != null) {
				this._customRoot.parent.removeChild(this._customRoot);
			}
			this._customRoot = null;
		}
		PopUpManager.dispose();

		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, Lib.current.stage.numChildren, "Test cleanup failed to remove all children from the stage");
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

	public function testDefaults():Void {
		this.createPopUp1();
		Assert.equals(0, PopUpManager.popUpCount);
		Assert.isFalse(PopUpManager.isModal(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isModal(this._popUp1));
		var popUpManager = PopUpManager.forStage(Lib.current.stage);
		Assert.notNull(popUpManager);
		Assert.equals(Lib.current.stage, popUpManager.root);
	}

	public function testIsFunctionsWithNull():Void {
		Assert.isFalse(PopUpManager.isPopUp(null));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(null));
		Assert.isFalse(PopUpManager.isModal(null));
	}

	public function testPopUpCount():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.equals(0, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		Assert.equals(1, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		Assert.equals(2, PopUpManager.popUpCount);
		PopUpManager.removePopUp(this._popUp1);
		Assert.equals(1, PopUpManager.popUpCount);
		PopUpManager.removePopUp(this._popUp2);
		Assert.equals(0, PopUpManager.popUpCount);
	}

	public function testPopUpCountWithRemoveChild():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.equals(0, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		Assert.equals(1, PopUpManager.popUpCount);
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		Assert.equals(2, PopUpManager.popUpCount);
		this._popUp1.parent.removeChild(this._popUp1);
		Assert.equals(1, PopUpManager.popUpCount);
		this._popUp2.parent.removeChild(this._popUp2);
		Assert.equals(0, PopUpManager.popUpCount);
	}

	public function testIsPopUp():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		Assert.isTrue(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		Assert.isTrue(PopUpManager.isPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.removePopUp(this._popUp1);
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isPopUp(this._popUp2));
		PopUpManager.removePopUp(this._popUp2);
		Assert.isFalse(PopUpManager.isPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isPopUp(this._popUp2));
	}

	public function testPopUpParent():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isNull(this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		Assert.notNull(this._popUp1.parent);
		Assert.equals(Lib.current.stage, this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		Assert.notNull(this._popUp1.parent);
		Assert.notNull(this._popUp2.parent);
		Assert.equals(Lib.current.stage, this._popUp2.parent);
		PopUpManager.removePopUp(this._popUp1);
		Assert.isNull(this._popUp1.parent);
		Assert.notNull(this._popUp2.parent);
		PopUpManager.removePopUp(this._popUp2);
		Assert.isNull(this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
	}

	public function testIsTopLevelPopUpWithModals():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, Lib.current, true);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, Lib.current, true);
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	public function testAddPopUpAndIsTopLevelPopUpWithModalAndNonModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, Lib.current, true);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, Lib.current, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	public function testAddPopUpAndIsTopLevelPopUpWithNonModalAndModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, Lib.current, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, Lib.current, true);
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	public function testAddPopUpAndIsTopLevelPopUpWithNonModals():Void {
		this.createPopUp1();
		this.createPopUp2();
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp1, Lib.current, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.addPopUp(this._popUp2, Lib.current, false);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
	}

	public function testRemoveAllPopUps():Void {
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		Assert.equals(2, PopUpManager.popUpCount);
		PopUpManager.removeAllPopUps();
		Assert.equals(0, PopUpManager.popUpCount);
		Assert.isNull(this._popUp1.parent);
		Assert.isNull(this._popUp2.parent);
	}

	public function testCenterPopUp():Void {
		this.createPopUp1();
		this.createPopUp2();
		var x = -10;
		var y = -50;
		this._popUp1.x = x;
		this._popUp1.y = y;
		this._popUp2.x = x;
		this._popUp2.y = y;
		PopUpManager.addPopUp(this._popUp1, Lib.current, false, true);
		PopUpManager.addPopUp(this._popUp2, Lib.current, false, false);
		Assert.notEquals(x, this._popUp1.x);
		Assert.notEquals(y, this._popUp1.y);
		Assert.equals((Lib.current.stage.stageWidth - POPUP1_WIDTH) / 2.0, this._popUp1.x);
		Assert.equals((Lib.current.stage.stageHeight - POPUP1_HEIGHT) / 2.0, this._popUp1.y);
		Assert.equals(x, this._popUp2.x);
		Assert.equals(y, this._popUp2.y);
	}

	public function testRemovePopUpFromRemovedEventForOtherPopUp():Void {
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		this._popUp1.addEventListener(Event.REMOVED, (event:Event) -> {
			this._popUp2.parent.removeChild(this._popUp2);
		});
		PopUpManager.removeAllPopUps();
		Assert.equals(0, PopUpManager.popUpCount);
	}

	public function testCustomRoot():Void {
		this._customRoot = new Sprite();
		Lib.current.addChild(this._customRoot);
		Assert.equals(Lib.current.stage, PopUpManager.forStage(Lib.current.stage).root);
		PopUpManager.root = this._customRoot;
		Assert.notEquals(Lib.current.stage, PopUpManager.forStage(Lib.current.stage).root);
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		Assert.equals(this._customRoot, this._popUp1.parent);
		Assert.equals(this._customRoot, this._popUp2.parent);
	}

	public function testCustomRootAfterAddPopUp():Void {
		this._customRoot = new Sprite();
		Lib.current.addChild(this._customRoot);
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, Lib.current);
		PopUpManager.addPopUp(this._popUp2, Lib.current);
		Assert.notEquals(this._customRoot, this._popUp1.parent);
		Assert.notEquals(this._customRoot, this._popUp2.parent);
		PopUpManager.root = this._customRoot;
		Assert.equals(this._customRoot, this._popUp1.parent);
		Assert.equals(this._customRoot, this._popUp2.parent);
	}

	public function testBringToFrontNonModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, Lib.current, false, false);
		PopUpManager.addPopUp(this._popUp2, Lib.current, false, false);
		var childIndex1 = this._popUp1.parent.getChildIndex(this._popUp1);
		var childIndex2 = this._popUp2.parent.getChildIndex(this._popUp2);
		Assert.isTrue(childIndex1 < childIndex2);
		PopUpManager.bringToFront(this._popUp1);
		var childIndex1 = this._popUp1.parent.getChildIndex(this._popUp1);
		var childIndex2 = this._popUp2.parent.getChildIndex(this._popUp2);
		Assert.isTrue(childIndex1 > childIndex2);
	}

	public function testBringToFrontModal():Void {
		this.createPopUp1();
		this.createPopUp2();
		PopUpManager.addPopUp(this._popUp1, Lib.current, true, false);
		PopUpManager.addPopUp(this._popUp2, Lib.current, true, false);
		var childIndex1 = this._popUp1.parent.getChildIndex(this._popUp1);
		var childIndex2 = this._popUp2.parent.getChildIndex(this._popUp2);
		Assert.isTrue(childIndex1 < childIndex2);
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp2));
		PopUpManager.bringToFront(this._popUp1);
		var childIndex1 = this._popUp1.parent.getChildIndex(this._popUp1);
		var childIndex2 = this._popUp2.parent.getChildIndex(this._popUp2);
		Assert.isTrue(childIndex1 > childIndex2);
		Assert.isTrue(PopUpManager.isTopLevelPopUp(this._popUp1));
		Assert.isFalse(PopUpManager.isTopLevelPopUp(this._popUp2));
	}
}
