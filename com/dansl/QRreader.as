﻿/**************************************************************************
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
		private var foundFile:Boolean = false;
					foundFile = true;
					var filePath:String = tempString.slice(7,tempString.length);
					trace("FILE OPEN "+filePath);
					resultView.text_txt.htmlText = "File Path: "+filePath+" \n\n\n\nTo open this file on scan, go into Settings, and enable \"Auto Open All Links\"";
					if(autoURL == true){
						var openFile:File = new File(filePath);
						openFile.openWithDefaultApplication();
					}

				}else{
			foundFile = false;