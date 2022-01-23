/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import utest.ui.common.PackageResult;
import utest.ui.text.PrintReport;

class NoExitPrintReport extends PrintReport {
	override function complete(result:PackageResult) {
		this.result = result;
		if (handler != null) {
			handler(this);
		}
	}
}
