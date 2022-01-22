package com.feathersui.hn.views.events;

import openfl.events.Event;
import openfl.events.EventType;

class ReaderHeaderViewEvent extends Event {
	public static final GOTO_TOP:EventType<ReaderHeaderViewEvent> = "gotoTop";
	public static final GOTO_NEW:EventType<ReaderHeaderViewEvent> = "gotoNew";
	public static final GOTO_SHOW:EventType<ReaderHeaderViewEvent> = "gotoShow";
	public static final GOTO_ASK:EventType<ReaderHeaderViewEvent> = "gotoAsk";
	public static final GOTO_JOBS:EventType<ReaderHeaderViewEvent> = "gotoJobs";
	public static final GOTO_ABOUT:EventType<ReaderHeaderViewEvent> = "gotoAbout";

	public function new(type:String) {
		super(type, false, false);
	}

	override public function clone():ReaderHeaderViewEvent {
		return new ReaderHeaderViewEvent(type);
	}
}
