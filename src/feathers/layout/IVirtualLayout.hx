/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.geom.Point;

/**


	@since 1.0.0
**/
interface IVirtualLayout extends IScrollLayout {
	var virtualCache(get, set):Array<Dynamic>;
	var trimmedItemsBefore:Int;
	var trimmedItemsAfter:Int;

	function createEmptyCacheItem():Dynamic;
}
