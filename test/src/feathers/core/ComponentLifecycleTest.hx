/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.LayoutGroup;
import feathers.events.FeathersEvent;
import massive.munit.Assert;

@:keep
class ComponentLifecycleTest {
	private var _control:LayoutGroup;

	@Before
	public function prepare():Void {
		this._control = new LayoutGroup();
	}

	@After
	public function cleanup():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testFlagsAfterConstructor():Void {
		Assert.isFalse(this._control.initialized, "Feathers component must not be initialized immediately after constructor");
		Assert.isFalse(this._control.created, "Feathers component must not be created immediately after constructor");
		Assert.areEqual(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}

	@Test
	public function testEventsAndFlagsAfterAddedToStage():Void {
		var initializeEvent = false;
		var createdEvent = false;
		this._control.addEventListener(FeathersEvent.INITIALIZE, (event:FeathersEvent) -> {
			initializeEvent = true;
			Assert.isFalse(createdEvent, "FeathersEvent.CREATION_COMPLETE must not dispatched be dispatched before FeathersEvent.INITIALIZE");
		});
		this._control.addEventListener(FeathersEvent.CREATION_COMPLETE, (event:FeathersEvent) -> {
			createdEvent = true;
		});
		TestMain.openfl_root.addChild(this._control);
		Assert.isTrue(initializeEvent, "FeathersEvent.INTIALIZE must be dispatched after added to stage");
		Assert.isFalse(createdEvent, "FeathersEvent.CREATION_COMPLETE must not be dispatched after initializeNow()");
		Assert.isTrue(this._control.initialized, "Feathers component must be initialized after added to stage");
		Assert.isFalse(this._control.created, "Feathers component must not be created after added to stage");
		Assert.areNotEqual(-1, this._control.depth, "Feathers component must have depth != -1 when on stage");
	}

	@Test
	public function testEventsAndFlagsAfterRemovedFromStage():Void {
		TestMain.openfl_root.addChild(this._control);
		TestMain.openfl_root.removeChild(this._control);
		Assert.areEqual(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}

	@Test
	public function testEventsAndFlagsAfterInitializeNowOffStage():Void {
		var initializeEvent = false;
		var createdEvent = false;
		this._control.addEventListener(FeathersEvent.INITIALIZE, (event:FeathersEvent) -> {
			initializeEvent = true;
			Assert.isFalse(createdEvent, "FeathersEvent.CREATION_COMPLETE must not dispatched be dispatched before FeathersEvent.INITIALIZE");
		});
		this._control.addEventListener(FeathersEvent.CREATION_COMPLETE, (event:FeathersEvent) -> {
			createdEvent = true;
		});
		this._control.initializeNow();
		Assert.isTrue(initializeEvent, "FeathersEvent.INTIALIZE must be dispatched after initializeNow()");
		Assert.isFalse(createdEvent, "FeathersEvent.CREATION_COMPLETE must not be dispatched after initializeNow()");
		Assert.isTrue(this._control.initialized, "Feathers component must be initialized after initializeNow()");
		Assert.isFalse(this._control.created, "Feathers component must not be created after initializeNow()");
		Assert.areEqual(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}

	@Test
	public function testEventsAndFlagsAfterValidateNowOffStage():Void {
		var initializeEvent = false;
		var createdEvent = false;
		this._control.addEventListener(FeathersEvent.INITIALIZE, (event:FeathersEvent) -> {
			initializeEvent = true;
			Assert.isFalse(createdEvent, "FeathersEvent.CREATION_COMPLETE must not dispatched be dispatched before FeathersEvent.INITIALIZE");
		});
		this._control.addEventListener(FeathersEvent.CREATION_COMPLETE, (event:FeathersEvent) -> {
			createdEvent = true;
		});
		this._control.validateNow();
		Assert.isTrue(initializeEvent, "FeathersEvent.INTIALIZE must be dispatched after validateNow()");
		Assert.isTrue(createdEvent, "FeathersEvent.CREATION_COMPLETE was not dispatched after validateNow()");
		Assert.isTrue(this._control.initialized, "Feathers component must be initialized after initializeNow()");
		Assert.isTrue(this._control.created, "Feathers component must not be created after initializeNow()");
		Assert.areEqual(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}
}
