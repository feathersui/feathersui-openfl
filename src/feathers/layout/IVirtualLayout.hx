/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**


	@since 1.0.0
**/
interface IVirtualLayout extends IScrollLayout {
	var virtualCache(get, set):Array<Dynamic>;

	function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange;
}

class VirtualLayoutRange {
	public function new(start:Int, end:Int) {
		this.start = start;
		this.end = end;
	}

	public var start:Int;
	public var end:Int;
}
