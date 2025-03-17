/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.LayoutGroup;
import feathers.events.FeathersEvent;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class ComponentLifecycleTest extends Test {
	private var _control:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new LayoutGroup();
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testFlagsAfterConstructor():Void {
		Assert.isFalse(this._control.initialized, "Feathers component must not be initialized immediately after constructor");
		Assert.isFalse(this._control.created, "Feathers component must not be created immediately after constructor");
		Assert.equals(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}

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
		Lib.current.addChild(this._control);
		Assert.isTrue(initializeEvent, "FeathersEvent.INTIALIZE must be dispatched after added to stage");
		Assert.isFalse(createdEvent, "FeathersEvent.CREATION_COMPLETE must not be dispatched after initializeNow()");
		Assert.isTrue(this._control.initialized, "Feathers component must be initialized after added to stage");
		Assert.isFalse(this._control.created, "Feathers component must not be created after added to stage");
		Assert.notEquals(-1, this._control.depth, "Feathers component must have depth != -1 when on stage");
	}

	public function testEventsAndFlagsAfterRemovedFromStage():Void {
		Lib.current.addChild(this._control);
		Lib.current.removeChild(this._control);
		Assert.equals(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}

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
		Assert.equals(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}

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
		Assert.equals(-1, this._control.depth, "Feathers component must have depth == -1 when not on stage");
	}
}
