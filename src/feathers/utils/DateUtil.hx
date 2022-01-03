/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

/**
	Utility functions for working with dates.

	@since 1.0.0
**/
class DateUtil {
	private static final MONTH_NUMBER_OF_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
	private static final FEBRUARY_NUMBER_OF_DAYS_LEAP_YEAR = 29;

	/**
		Returns the number of days in the specified month (with an optional
		year that may be used in February to determine leap years).

		@since 1.0.0
	**/
	public static function getDaysInMonth(month:Int, ?year:Int):Int {
		if (month == 1 && year != null && isLeapYear(year)) {
			return FEBRUARY_NUMBER_OF_DAYS_LEAP_YEAR;
		}
		return MONTH_NUMBER_OF_DAYS[month];
	}

	/**
		Determines if the specified year is a leap year.

		@since 1.0.0
	**/
	public static function isLeapYear(year:Int):Bool {
		if (year % 100 == 0) {
			return year % 400 == 0;
		}
		return year % 4 == 0;
	}
}
