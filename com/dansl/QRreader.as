﻿/*************************************************************************** 	Dansl QRreader*   Copyright (C) 2010 Dan Long**   This program is free software: you can redistribute it and/or modify*   it under the terms of the GNU General Public License as published by*   the Free Software Foundation, either version 3 of the License, or*   (at your option) any later version.**   This program is distributed in the hope that it will be useful,*   but WITHOUT ANY WARRANTY; without even the implied warranty of*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the*   GNU General Public License for more details.**   You should have received a copy of the GNU General Public License*   along with this program.  If not, see <http://www.gnu.org/licenses/>**************************************************************************/package com.dansl {		import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.GradientType;	import flash.display.SimpleButton;	import flash.display.SpreadMethod;	import flash.display.Sprite;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.display.MovieClip;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.filters.BlurFilter;	import flash.filters.DropShadowFilter;	import flash.geom.Matrix;	import flash.geom.Point;	import flash.media.Camera;	import flash.media.Video;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.text.TextField;	import flash.text.TextFieldAutoSize;	import flash.text.TextFormat;	import flash.utils.Timer;	import flash.filters.GlowFilter;	import flash.net.navigateToURL;	import flash.net.URLRequest;	import flash.utils.ByteArray;	import flash.desktop.NativeApplication;	import flash.filesystem.FileStream;	import flash.geom.Rectangle;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;		import com.adobe.air.preferences.PreferenceChangeEvent;	import com.adobe.air.preferences.Preference;		import com.logosware.event.QRdecoderEvent;	import com.logosware.event.QRreaderEvent;	import com.logosware.utils.QRcode.QRdecode;	import com.logosware.utils.QRcode.GetQRimage;		import com.greensock.TweenMax;	import com.greensock.easing.Expo;		public class QRreader extends Sprite {		private const SRC_SIZE:int = 320;		private const STAGE_SIZE:int = 350;				private var markerAreaRect:Rectangle;				private var getQRimage:GetQRimage;		private var qrDecode:QRdecode = new QRdecode();		private var errorView:MovieClip;				private var cameraView:Sprite;		private var camera:Camera;		private var video:Video = new Video(SRC_SIZE, SRC_SIZE);		private var freezeImage:Bitmap;		private var blue:Sprite = new Sprite();		private var red:Sprite = new Sprite();		private var blurFilter:BlurFilter = new BlurFilter();				private var resultView:MovieClip;		private var textArea:TextField = new TextField();				private var settingsView:MovieClip;				private var greyOut:MovieClip;				private var detectionRate = 10;				private var cameraTimer:Timer = new Timer(2000);		private var redTimer:Timer = new Timer(400, 1);		private var runTime:Timer = new Timer(1000/detectionRate);				private var textArray:Array = ["", "", ""];				private var cameraList:Array = new Array();				private var autoURL:Boolean = true;		private var soundEnabled:Boolean = true;		private var flippedVideo:Boolean = true;		private var foundHTTP:Boolean = false;
		private var foundFile:Boolean = false;				/* Create a new prefernce variable and give it a name */		private var prefs:Preference =  new Preference( "settings.obj" );				/* Create a new bytearry to store the data */		private var byteArray:ByteArray = new ByteArray();				private var fileStream:FileStream;				public function QRreader(){			if(stage){				init(null);			}else{				addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);			}		}				private function init(e:Event):void {			removeEventListener(Event.ADDED_TO_STAGE, init);						stage.scaleMode = StageScaleMode.NO_SCALE;			stage.align = StageAlign.TOP_LEFT;						errorView = buildErrorView();			errorView.x = 30;			errorView.y = 175;						cameraTimer.addEventListener(TimerEvent.TIMER, getCamera);			cameraTimer.start();			getCamera();						close_mc.addEventListener(MouseEvent.CLICK, closeWindow, false, 0, true);			close_mc.addEventListener(MouseEvent.ROLL_OVER, showClosePopup, false, 0, true);			close_mc.addEventListener(MouseEvent.ROLL_OUT, hideClosePopup, false, 0, true);			close_mc.buttonMode = true;						settingBtn.addEventListener(MouseEvent.CLICK, openSettings, false, 0, true);			settingBtn.addEventListener(MouseEvent.ROLL_OVER, showSettingsPopup, false, 0, true);			settingBtn.addEventListener(MouseEvent.ROLL_OUT, hideSettingsPopup, false, 0, true);			settingBtn.buttonMode = true;						text_mc.mouseEnabled = false;						bg_mc.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow, false, 0, true);			//bg_mc.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow, false, 0, true);			bg_mc.buttonMode = true;						bg_mc.alpha = 0;			text_mc.alpha = 0;			close_mc.alpha = 0;		}				private function showSettingsPopup(e:MouseEvent){			settingsPopup_mc.alpha = 1;		}				private function hideSettingsPopup(e:MouseEvent){			settingsPopup_mc.alpha = 0;		}				private function showClosePopup(e:MouseEvent){			closePopup_mc.alpha = 1;		}				private function hideClosePopup(e:MouseEvent){			closePopup_mc.alpha = 0;		}				private function startDragWindow(e:MouseEvent):void {			stage.nativeWindow.startMove();		}				private function closeWindow(e:MouseEvent):void {			//removeEventListener(Event.ENTER_FRAME, processQR);			runTime.stop();			removeChild( cameraView );			TweenMax.to(bg_mc, 0.5, {delay:1, alpha:0, onComplete:closeIt});			TweenMax.to(text_mc, 0.5, {delay:1, alpha:0});			TweenMax.to(close_mc, 0.5, {delay:1, alpha:0});			TweenMax.to(settingBtn, 0.5, {delay:1, alpha:0});			TweenMax.to(bg_mc, 1, {scaleY:0.065, ease:Expo.easeOut});		}				private function closeIt():void {			NativeApplication.nativeApplication.exit();		}				private function getCamera(e:TimerEvent = null):void{			trace("GET CAMERA");			camera = Camera.getCamera();			this.graphics.clear();			if ( camera == null ) {				addChild( errorView );				startAni(false);			} else {				cameraTimer.stop();				if ( errorView.parent == this ) {					removeChild(errorView);				}				startAni(true);			}		}				private function startAni(_hasCamera:Boolean):void {			TweenMax.to(bg_mc, 0.5, {alpha:1});			TweenMax.to(text_mc, 0.5, {alpha:1});			TweenMax.to(close_mc, 0.5, {alpha:1});			if(_hasCamera){				TweenMax.to(bg_mc, 1, { delay:1, scaleY:1, ease:Expo.easeOut, onComplete:startReader});			}else{				TweenMax.to(bg_mc, 1, { delay:1, scaleY:1, ease:Expo.easeOut});			}		}				private function startReader():void {			cameraView = buildCameraView();			resultView = buildResultView();			settingsView = buildSettingsView();			greyOut = new GreyOut();						cameraView.x = 27;			cameraView.y = 30;			//cameraView.rotationY = 180;			greyOut.x = 30;			greyOut.y = 30;			resultView.x = 30;			resultView.y = 92;			settingsView.x = 30;			settingsView.y = 120;						addChild( cameraView );			addChild( greyOut );			addChild( resultView );			addChild( settingsView );						greyOut.visible = false			greyOut.alpha = 0;			resultView.visible = false;			resultView.alpha = 0;			settingsView.visible = false;			settingsView.alpha = 0;						markerAreaRect = new Rectangle((camera.width-SRC_SIZE)/2,(camera.height-SRC_SIZE)/2,SRC_SIZE,SRC_SIZE);						//getQRimage = new GetQRimage(video);			getQRimage = new GetQRimage(video, markerAreaRect, true, true);						getQRimage.addEventListener(QRreaderEvent.QR_IMAGE_READ_COMPLETE, onQrImageReadComplete);			qrDecode.addEventListener(QRdecoderEvent.QR_DECODE_COMPLETE, onQrDecodeComplete);			redTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRedTimer );			//addEventListener(Event.ENTER_FRAME, processQR);			runTime.start();			runTime.addEventListener(TimerEvent.TIMER, processQR, false, 0, true);						prefs.addEventListener( PreferenceChangeEvent.PREFERENCE_CHANGED_EVENT, onPrefChange );			checkSettings();		}				private function buildErrorView():MovieClip {			var errorWindow:MovieClip = new ErrorWindow();			return errorWindow;		}				private function buildCameraView():Sprite {			camera.setQuality(0, 100);			camera.setMode(SRC_SIZE, SRC_SIZE, 24, true );			video.attachCamera( camera );						var sprite:Sprite = new Sprite();						var glowDark:GlowFilter = new GlowFilter(0x000000, 1, 10, 10, 1,3);						var shadowBox:Sprite = new Sprite();			shadowBox.graphics.beginFill(0x000000);			shadowBox.graphics.drawRoundRect(25, 25, 300, 300, 10);			shadowBox.graphics.endFill();			shadowBox.filters = [glowDark];						var box:Sprite = new Sprite();			box.graphics.beginFill(0x000000);			box.graphics.drawRoundRect(25, 25, 300, 300, 10);			box.graphics.endFill();						var videoHolder:Sprite = new Sprite();			videoHolder.addChild( video );			videoHolder.x = videoHolder.y = 15;			videoHolder.mask = box;						freezeImage = new Bitmap(new BitmapData(SRC_SIZE, SRC_SIZE));			videoHolder.addChild( freezeImage );			freezeImage.visible = false;						red.graphics.lineStyle(2, 0xFFFFFF);			red.graphics.drawPath(Vector.<int>([1,2,2,1,2,2,1,2,2,1,2,2]), Vector.<Number>([30,60,30,30,60,30,290,60,290,30,260,30,30,260,30,290,60,290,290,260,290,290,260,290]));			blue.graphics.lineStyle(2, 0x990000);			blue.graphics.drawPath(Vector.<int>([1,2,2,1,2,2,1,2,2,1,2,2]), Vector.<Number>([30,60,30,30,60,30,290,60,290,30,260,30,30,260,30,290,60,290,290,260,290,290,260,290]));						sprite.addChild( shadowBox );			sprite.addChild( videoHolder );			sprite.addChild( box );			sprite.addChild( red );			sprite.addChild( blue );			blue.alpha = 0;			red.x = red.y = 15;			blue.x = blue.y = 15;			return sprite;		}				private function buildResultView():MovieClip {			var resultWindow:MovieClip = new ResultWindow();			resultWindow.close_mc.addEventListener(MouseEvent.CLICK, closeResults, false, 0, true);			resultWindow.close_mc.buttonMode = true;						return resultWindow;		}				private function buildSettingsView():MovieClip {			var settingWindow:MovieClip = new settingsWindow();			settingWindow.close_mc.addEventListener(MouseEvent.CLICK, closeSettings, false, 0, true);			settingWindow.close_mc.buttonMode = true;						settingWindow.cameras_list.width = 200;			settingWindow.cameras_list.dropdownWidth = 200;						for(var i:int = 0; i < Camera.names.length; ++i){				var titleObj:Object = {data:i, label:Camera.names[i]};				cameraList.push(titleObj);				settingWindow.cameras_list.addItem(titleObj);				if(camera.name == Camera.names[i]){					settingWindow.cameras_list.selectedItem = titleObj;				}			}						settingWindow.cameras_list.addEventListener(Event.CHANGE, changeCamera, false, 0, true);						settingWindow.autoURL.addEventListener(Event.CHANGE, clickAutoURL, false, 0, true);						settingWindow.beepSound.addEventListener(Event.CHANGE, clickBeepSound, false, 0, true);						settingWindow.flipVideo.addEventListener(Event.CHANGE, clickFlipVideo, false, 0, true);						return settingWindow;		}				private function changeCamera(e:Event):void {			var tempString:String = e.currentTarget.selectedItem.data;			//trace("CAMERA: "+tempString);			setCamera(tempString);			saveSettings();		}				private function setCamera(cameraPath: String){			var newCamera:Camera = Camera.getCamera(cameraPath);			newCamera.setQuality(0, 100);			newCamera.setMode(SRC_SIZE, SRC_SIZE, 24, true );			camera = newCamera;			video.clear();			video.attachCamera( newCamera );		}				private function clickAutoURL(e:Event):void {			trace(e.currentTarget.selected);			autoURL = e.currentTarget.selected;			saveSettings();		}				private function clickBeepSound(e:Event):void {			trace(e.currentTarget.selected);			soundEnabled = e.currentTarget.selected;			saveSettings();		}				private function clickFlipVideo(e:Event):void {			trace(e.currentTarget.selected);			flippedVideo = e.currentTarget.selected;			flipTheVideo();			saveSettings();		}				private function flipTheVideo(){			if(flippedVideo){				cameraView.x = 27+STAGE_SIZE;				cameraView.rotationY = 180;			}else{				cameraView.x = 27;				cameraView.rotationY = 0;			}		}				private function processQR(e:TimerEvent):void{			if( camera.currentFPS > 0 ){				getQRimage.process();			}		}				private function onQrImageReadComplete(e: QRreaderEvent):void{			qrDecode.setQR(e.data);			qrDecode.startDecode();		}				private function onQrDecodeComplete(e: QRdecoderEvent):void {			blue.alpha = 1.0;			redTimer.reset();			redTimer.start();			textArray.shift();			textArray.push( e.data );			trace("E: "+e.data + "\ntextArray[0]: "+textArray[0]+"\ntextArray[1]: "+textArray[0]);			//Checks twice to ensure accuracy.			if ( textArray[0] == textArray[1] && textArray[1] == textArray[2] ) {				if(soundEnabled == true){					var beepSound: Sound = new Beep();					var beepChannel:SoundChannel = new SoundChannel();					beepChannel = beepSound.play(0,0);				}				var tempString:String = textArray[0];				var tempArray:Array;				if(tempString.match("http://") || tempString.match("https://")){					foundHTTP = true;					resultView.text_txt.htmlText = "<a href='"+textArray[0]+"'>"+textArray[0]+"</a>";					if(autoURL == true){						navigateToURL(new URLRequest(textArray[0]), "_blank");					}				}else if(tempString.match("file://")){
					foundFile = true;
					var filePath:String = tempString.slice(7,tempString.length);
					trace("FILE OPEN "+filePath);
					resultView.text_txt.htmlText = "File Path: "+filePath+" \n\n\n\nTo open this file on scan, go into Settings, and enable \"Auto Open All Links\"";
					if(autoURL == true){
						var openFile:File = new File(filePath);
						openFile.openWithDefaultApplication();
					}

				}else{					resultView.text_txt.text = textArray[0];				}				cameraView.filters = [blurFilter];				redTimer.stop();				freezeImage.bitmapData.draw(video);				freezeImage.visible = true;				//removeEventListener(Event.ENTER_FRAME, processQR);				runTime.stop();				if(autoURL == true && (foundHTTP == true || foundFile == true)){					TweenMax.delayedCall(2, closeResults);				}else{					TweenMax.to(resultView, 0.5, {autoAlpha:1});					TweenMax.to(greyOut, 0.5, {autoAlpha:1});				}			}		}				private function openSettings(e:MouseEvent):void {			TweenMax.to(settingsView, 0.5, {autoAlpha:1});			TweenMax.to(greyOut, 0.5, {autoAlpha:1});		}				private function closeSettings(e: MouseEvent):void {						TweenMax.to(settingsView, 0.5, {alpha:0, visible:false});			TweenMax.to(greyOut, 0.5, {alpha:0, visible:false});		}				private function closeResults(e: MouseEvent = null):void {			textArray = ["", "", ""];			freezeImage.visible = false;			redTimer.start();			//addEventListener(Event.ENTER_FRAME, processQR);			runTime.start();			cameraView.filters = [];			TweenMax.to(resultView, 0.5, {alpha:0, visible:false});			TweenMax.to(greyOut, 0.5, {alpha:0, visible:false});			foundHTTP = false;
			foundFile = false;		}				private function onRedTimer(e:TimerEvent):void {			blue.alpha = 0;		}				private function onPrefChange( event:PreferenceChangeEvent ):void{			if ( event.action == PreferenceChangeEvent.ADD_EDIT_ACTION ){				//The new value				trace( event.newValue );							} else if ( event.action == PreferenceChangeEvent.DELETE_ACTION ){				//The old value				trace( event.oldValue );			}		}					private function saveSettings():void{			prefs.setValue( "selectedCamera", settingsView.cameras_list.selectedItem.data, false );			prefs.setValue( "autoURL", settingsView.autoURL.selected, false );			prefs.setValue( "beepSound", settingsView.beepSound.selected, false );			prefs.setValue( "flipVideo", settingsView.flipVideo.selected, false );			prefs.save();			//trace( "PREFS: "+ prefs );		}				private function checkSettings():void{					prefs.load();			settingsView.autoURL.selected = prefs.getValue( "autoURL" );			autoURL = prefs.getValue( "autoURL" );			settingsView.beepSound.selected = prefs.getValue( "beepSound" );			soundEnabled = prefs.getValue( "beepSound" );			settingsView.flipVideo.selected = prefs.getValue( "flipVideo" );			flippedVideo = prefs.getValue( "flipVideo" );			flipTheVideo();			setCamera(prefs.getValue("selectedCamera"));			settingsView.cameras_list.selectedIndex = prefs.getValue("selectedCamera");		}	}}