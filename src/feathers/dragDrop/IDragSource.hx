/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.dragDrop;

import openfl.events.IEventDispatcher;

/**
	A display object that can initiate drag actions with the drag and drop manager.
	Must be a subclass of `openfl.display.InteractiveObject`.

	@see `feathers.dragDrop.DragDropManager`

	@since 1.3.0
**/
interface IDragSource extends IEventDispatcher {}
