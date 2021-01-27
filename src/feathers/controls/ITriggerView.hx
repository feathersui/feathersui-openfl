/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IUIControl;

/**
	A UI component that dispatches `TriggerEvent.TRIGGER`. Some components may
	prefer to listen for `TriggerEvent.TRIGGER` instead of `MouseEvent.CLICK` or
	`TouchEvent.TOUCH_TAP`.

	@event feathers.events.TriggerEvent.TRIGGER

	@since 1.0.0
**/
@:event(feathers.events.TriggerEvent.TRIGGER)
interface ITriggerView extends IUIControl {}
