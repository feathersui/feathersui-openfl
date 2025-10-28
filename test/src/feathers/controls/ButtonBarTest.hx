/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.ITextControl;
import openfl.events.TouchEvent;
import feathers.events.TriggerEvent;
import openfl.events.MouseEvent;
import feathers.events.ButtonBarEvent;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.data.ArrayCollection;
import feathers.data.ButtonBarItemState;
import feathers.layout.ILayoutIndexObject;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class ButtonBarTest extends Test {
	private var _buttonBar:ButtonBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._buttonBar = new ButtonBar();
		Lib.current.addChild(this._buttonBar);
	}

	public function teardown():Void {
		if (this._buttonBar.parent != null) {
			this._buttonBar.parent.removeChild(this._buttonBar);
		}
		this._buttonBar = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNullDataProvider():Void {
		this._buttonBar.validateNow();
		Assert.pass();
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._buttonBar.validateNow();
		this._buttonBar.dispose();
		this._buttonBar.dispose();
		Assert.pass();
	}

	public function testValidateWithFilledDataProviderAndThenNullDataProvider():Void {
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.validateNow();
		this._buttonBar.dataProvider = null;
		this._buttonBar.validateNow();
		Assert.pass();
	}

	public function testItemToButton():Void {
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.validateNow();
		var button0 = this._buttonBar.itemToButton(collection.get(0));
		Assert.notNull(button0);
		Assert.isOfType(button0, Button);
		var button1 = this._buttonBar.itemToButton(collection.get(1));
		Assert.notNull(button1);
		Assert.isOfType(button1, Button);
		Assert.notEquals(button0, button1);
		var button2 = this._buttonBar.itemToButton(collection.get(2));
		Assert.notNull(button2);
		Assert.isOfType(button2, Button);
		Assert.notEquals(button0, button2);
		Assert.notEquals(button1, button2);
		var buttonNull = this._buttonBar.itemToButton(null);
		Assert.isNull(buttonNull);
	}

	public function testItemToText():Void {
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.itemToText = item -> item.text;
		this._buttonBar.validateNow();
		var button0 = this._buttonBar.itemToButton(collection.get(0));
		Assert.notNull(button0);
		Assert.isOfType(button0, Button);
		Assert.equals("One", cast(button0, Button).text);
		var button1 = this._buttonBar.itemToButton(collection.get(1));
		Assert.notNull(button1);
		Assert.isOfType(button1, Button);
		Assert.equals("Two", cast(button1, Button).text);
		var button2 = this._buttonBar.itemToButton(collection.get(2));
		Assert.notNull(button2);
		Assert.isOfType(button2, Button);
		Assert.equals("Three", cast(button2, Button).text);
	}

	public function testItemToEnabled():Void {
		var collection = new ArrayCollection([
			{text: "One", disable: false},
			{text: "Two", disable: true},
			{text: "Three", disable: false}
		]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.itemToEnabled = item -> !item.disable;
		this._buttonBar.validateNow();
		var button0 = this._buttonBar.itemToButton(collection.get(0));
		Assert.notNull(button0);
		Assert.isOfType(button0, Button);
		Assert.isTrue(cast(button0, Button).enabled);
		var button1 = this._buttonBar.itemToButton(collection.get(1));
		Assert.notNull(button1);
		Assert.isOfType(button1, Button);
		Assert.isFalse(cast(button1, Button).enabled);
		var button2 = this._buttonBar.itemToButton(collection.get(2));
		Assert.notNull(button2);
		Assert.isOfType(button2, Button);
		Assert.isTrue(cast(button2, Button).enabled);
	}

	public function testButtonRecycler():Void {
		var createCount = 0;
		var updateCount = 0;
		var resetCount = 0;
		var destroyCount = 0;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withFunction(() -> {
			createCount++;
			return new Button();
		}, (target:Button, state:ButtonBarItemState) -> {
			updateCount++;
		}, (target:Button, state:ButtonBarItemState) -> {
			resetCount++;
		}, (target:Button) -> {
			destroyCount++;
		});
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.itemToText = item -> item.text;
		this._buttonBar.validateNow();
		Assert.equals(2, createCount);
		Assert.equals(2, updateCount);
		Assert.equals(0, resetCount);
		Assert.equals(0, destroyCount);
		collection.removeAt(1);
		this._buttonBar.validateNow();
		Assert.equals(2, createCount);
		Assert.equals(2, updateCount);
		Assert.equals(1, resetCount);
		Assert.equals(1, destroyCount);
		collection.add({text: "New"});
		this._buttonBar.validateNow();
		Assert.equals(3, createCount);
		Assert.equals(3, updateCount);
		Assert.equals(1, resetCount);
		Assert.equals(1, destroyCount);
		collection.set(1, {text: "New 2"});
		this._buttonBar.validateNow();
		Assert.equals(3, createCount);
		Assert.equals(4, updateCount);
		Assert.equals(2, resetCount);
		Assert.equals(1, destroyCount);
		this._buttonBar.dataProvider = null;
		this._buttonBar.validateNow();
		Assert.equals(3, createCount);
		Assert.equals(4, updateCount);
		Assert.equals(4, resetCount);
		Assert.equals(3, destroyCount);
	}

	public function testUpdateItemSetsInterfaceProperties():Void {
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.itemToText = (item:Dynamic) -> item.text;
		var itemIndex = 1;
		var item = this._buttonBar.dataProvider.get(itemIndex);
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(CustomRendererWithInterfaces);
		this._buttonBar.validateNow();
		var sampleItemRenderer = cast(this._buttonBar.itemToButton(item), CustomRendererWithInterfaces);
		var setTextValues = sampleItemRenderer.setTextValues;
		var setDataValues = sampleItemRenderer.setDataValues;
		var setLayoutIndexValues = sampleItemRenderer.setLayoutIndexValues;
		Assert.equals(1, setTextValues.length);
		Assert.equals(1, setDataValues.length);
		Assert.equals(1, setLayoutIndexValues.length);

		this._buttonBar.dataProvider.updateAt(itemIndex);
		this._buttonBar.validateNow();

		Assert.equals(sampleItemRenderer, cast(this._buttonBar.itemToButton(item), CustomRendererWithInterfaces));

		Assert.equals(3, setTextValues.length);
		Assert.equals("Two", setTextValues[0]);
		Assert.isNull(setTextValues[1]);
		Assert.equals("Two", setTextValues[2]);

		Assert.equals(3, setDataValues.length);
		Assert.equals(item, setDataValues[0]);
		Assert.isNull(setDataValues[1]);
		Assert.equals(item, setDataValues[2]);

		Assert.equals(3, setLayoutIndexValues.length);
		Assert.equals(itemIndex, setLayoutIndexValues[0]);
		Assert.equals(-1, setLayoutIndexValues[1]);
		Assert.equals(itemIndex, setLayoutIndexValues[2]);
	}

	public function testDefaultItemStateUpdate():Void {
		var updatedIndices:Array<Int> = [];
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.itemToText = item -> item.text;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(Button, (target, state:ButtonBarItemState) -> {
			updatedIndices.push(state.index);
		});
		this._buttonBar.validateNow();
		Assert.equals(3, updatedIndices.length);
		Assert.equals(0, updatedIndices[0]);
		Assert.equals(1, updatedIndices[1]);
		Assert.equals(2, updatedIndices[2]);
		this._buttonBar.setInvalid(DATA);
		this._buttonBar.validateNow();
		Assert.equals(3, updatedIndices.length);
	}

	public function testForceItemStateUpdate():Void {
		var updatedIndices:Array<Int> = [];
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.itemToText = item -> item.text;
		this._buttonBar.forceItemStateUpdate = true;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(Button, (target, state:ButtonBarItemState) -> {
			updatedIndices.push(state.index);
		});
		this._buttonBar.validateNow();
		Assert.equals(3, updatedIndices.length);
		Assert.equals(0, updatedIndices[0]);
		Assert.equals(1, updatedIndices[1]);
		Assert.equals(2, updatedIndices[2]);
		this._buttonBar.setInvalid(DATA);
		this._buttonBar.validateNow();
		Assert.equals(6, updatedIndices.length);
		Assert.equals(0, updatedIndices[3]);
		Assert.equals(1, updatedIndices[4]);
		Assert.equals(2, updatedIndices[5]);
	}

	public function testUpdateItemCallsDisplayObjectRecyclerUpdate():Void {
		var updatedIndices:Array<Int> = [];
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.itemToText = item -> item.text;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(Button, (target, state:ButtonBarItemState) -> {
			updatedIndices.push(state.index);
		});
		this._buttonBar.validateNow();
		Assert.equals(3, updatedIndices.length);
		Assert.equals(0, updatedIndices[0]);
		Assert.equals(1, updatedIndices[1]);
		Assert.equals(2, updatedIndices[2]);
		this._buttonBar.dataProvider.updateAt(1);
		this._buttonBar.validateNow();
		Assert.equals(4, updatedIndices.length);
		Assert.equals(1, updatedIndices[3]);
	}

	public function testUpdateAllCallsDisplayObjectRecyclerUpdate():Void {
		var updatedIndices:Array<Int> = [];
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.itemToText = item -> item.text;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withClass(Button, (target, state:ButtonBarItemState) -> {
			updatedIndices.push(state.index);
		});
		this._buttonBar.validateNow();
		Assert.equals(3, updatedIndices.length);
		Assert.equals(0, updatedIndices[0]);
		Assert.equals(1, updatedIndices[1]);
		Assert.equals(2, updatedIndices[2]);
		this._buttonBar.dataProvider.updateAll();
		this._buttonBar.validateNow();
		Assert.equals(6, updatedIndices.length);
		Assert.equals(0, updatedIndices[3]);
		Assert.equals(1, updatedIndices[4]);
		Assert.equals(2, updatedIndices[5]);
	}

	public function testAddItemToDataProviderCreatesNewButton():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._buttonBar.dataProvider = new ArrayCollection([item1]);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.isNull(this._buttonBar.itemToButton(item2));
		this._buttonBar.dataProvider.add(item2);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.notNull(this._buttonBar.itemToButton(item2));
	}

	public function testRemoveItemFromDataProviderDestroysButton():Void {
		var item1 = {text: "One"};
		var item2 = {text: "Two"};
		this._buttonBar.dataProvider = new ArrayCollection([item1, item2]);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.notNull(this._buttonBar.itemToButton(item2));
		this._buttonBar.dataProvider.remove(item2);
		this._buttonBar.validateNow();
		Assert.notNull(this._buttonBar.itemToButton(item1));
		Assert.isNull(this._buttonBar.itemToButton(item2));
	}

	public function testDefaultTextUpdateForAdditionalRecyclers():Void {
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}]);
		this._buttonBar.itemToText = item -> item.text;
		this._buttonBar.setButtonRecycler("other", DisplayObjectRecycler.withClass(Button));
		this._buttonBar.buttonRecyclerIDFunction = (state) -> {
			return "other";
		};
		this._buttonBar.validateNow();
		var button = cast(this._buttonBar.itemToButton(this._buttonBar.dataProvider.get(0)), Button);
		Assert.notNull(button);
		Assert.equals("One", button.text);
	}

	public function testButtonDefaultVariant():Void {
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.validateNow();
		var button:Button = this._buttonBar.indexToButton(0);
		Assert.notNull(button);
		Assert.equals(ButtonBar.CHILD_VARIANT_BUTTON, button.variant);
	}

	public function testButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._buttonBar.customButtonVariant = customVariant;
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.validateNow();
		var button:Button = this._buttonBar.indexToButton(0);
		Assert.notNull(button);
		Assert.equals(customVariant, button.variant);
	}

	public function testButtonCustomVariant2():Void {
		final customVariant = "custom";
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var button = new Button();
			button.variant = customVariant;
			return button;
		});
		this._buttonBar.validateNow();
		var button:Button = this._buttonBar.indexToButton(0);
		Assert.notNull(button);
		Assert.equals(customVariant, button.variant);
	}

	public function testButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._buttonBar.customButtonVariant = customVariant1;
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var button = new Button();
			button.variant = customVariant2;
			return button;
		});
		this._buttonBar.validateNow();
		var button:Button = this._buttonBar.indexToButton(0);
		Assert.notNull(button);
		Assert.equals(customVariant2, button.variant);
	}

	private function testDispatchItemTriggerFromMouseClick():Void {
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var item = this._buttonBar.dataProvider.get(1);
		this._buttonBar.validateNow();
		var button = cast(this._buttonBar.itemToButton(item), Button);
		var dispatchedTriggerCount = 0;
		this._buttonBar.addEventListener(ButtonBarEvent.ITEM_TRIGGER, event -> {
			dispatchedTriggerCount++;
			Assert.equals(event.state.index, 1);
		});
		Assert.equals(0, dispatchedTriggerCount);
		TriggerEvent.dispatchFromMouseEvent(button, new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, dispatchedTriggerCount);
	}

	private function testDispatchItemTriggerFromTouchTap():Void {
		this._buttonBar.dataProvider = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		var item = this._buttonBar.dataProvider.get(1);
		this._buttonBar.validateNow();
		var button = cast(this._buttonBar.itemToButton(item), Button);
		var dispatchedTriggerCount = 0;
		this._buttonBar.addEventListener(ButtonBarEvent.ITEM_TRIGGER, event -> {
			dispatchedTriggerCount++;
			Assert.equals(event.state.index, 1);
		});
		Assert.equals(0, dispatchedTriggerCount);
		TriggerEvent.dispatchFromTouchEvent(button, new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.equals(1, dispatchedTriggerCount);
	}

	private function testRecyclerIDFunction():Void {
		var collection = new ArrayCollection([{text: "One"}, {text: "Two"}, {text: "Three"}]);
		this._buttonBar.dataProvider = collection;
		this._buttonBar.setButtonRecycler("alternate", DisplayObjectRecycler.withClass(Button));
		this._buttonBar.setButtonRecycler("alternate2", DisplayObjectRecycler.withClass(Button));
		this._buttonBar.buttonRecyclerIDFunction = (state) -> {
			if (state.index == 1) {
				return "alternate";
			} else if (state.index == 2) {
				return "alternate2";
			}
			return null;
		};
		this._buttonBar.validateNow();
		var state0 = this._buttonBar.itemToItemState(collection.get(0));
		Assert.notNull(state0);
		Assert.isNull(state0.recyclerID);
		var state1 = this._buttonBar.itemToItemState(collection.get(1));
		Assert.notNull(state1);
		Assert.equals("alternate", state1.recyclerID);
		var state2 = this._buttonBar.itemToItemState(collection.get(2));
		Assert.notNull(state2);
		Assert.equals("alternate2", state2.recyclerID);
	}
}

private class CustomRendererWithInterfaces extends Button implements IDataRenderer implements ILayoutIndexObject {
	public function new() {
		super();
	}

	public var setTextValues:Array<String> = [];

	override private function set_text(value:String):String {
		if (_text == value) {
			return _text;
		}
		super.text = value;
		setTextValues.push(value);
		return _text;
	}

	public var setDataValues:Array<Dynamic> = [];

	private var _data:Dynamic;

	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return _data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (_data == value) {
			return _data;
		}
		_data = value;
		setDataValues.push(value);
		return _data;
	}

	public var setLayoutIndexValues:Array<Int> = [];

	private var _layoutIndex:Int = -1;

	public var layoutIndex(get, set):Int;

	private function get_layoutIndex():Int {
		return _layoutIndex;
	}

	private function set_layoutIndex(value:Int):Int {
		if (_layoutIndex == value) {
			return _layoutIndex;
		}
		_layoutIndex = value;
		setLayoutIndexValues.push(value);
		return _layoutIndex;
	}

	override private function update():Void {
		saveMeasurements(1.0, 1.0);
	}
}
