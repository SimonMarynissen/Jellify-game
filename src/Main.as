package {
	
	import bl.MyGameManager;
	import caurina.transitions.Tweener;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import gui.*;
	import gui.virtualMouse.Cursor;
	import org.bonuslevel.Hack;
	import states.*;
	import tiles.*;
	import tiles.wallAttachments.*;
	
	[SWF(width = "640", height = "640", backgroundColor = "#ffffff")]
	
	public class Main extends Sprite {
		
		public static var
			BLManager:MyGameManager,
			soundPlayer:SoundPlayer = new SoundPlayer(),
			Global:Class,
			playerData:Array,
			bestPlayerData:Array,
			userData:Array;
			
		private var
			state:State,
			stateLayer:Sprite = new Sprite(),
			musicButton:MusicButton,
			optionPanel:OptionPanel;
		
		public function Main():void {
			BLManager = new MyGameManager(this);
			optionPanel = new OptionPanel(1, 1);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function switchState(newState:State):void {
			if (state != null) {
				state.terminate();
				stateLayer.removeChild(state);
			}
			if (newState != null) {
				state = newState;
				stateLayer.addChild(state);
			}
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			Tweener.autoOverwrite = true;
			stage.frameRate = 30;
			GameState.initBitmapData();
			TitleState.initBitmapData();
			BackState.initBitmapData();
			WinScreen.initBitmapData();
			Block.initBitmapData();
			Wall.initBitmapData();
			ColourChanger.initBitmapData();
			Bomb.initBitmapData();
			ForceField.initBitmapData();
			MusicButton.initBitmapData();
			Hinge.initBitmapdata();
			Spike.initBitmapData();
			Freezer.initBitmapData();
			Defroster.initBitmapData();
			TutorialState.initBitmapData();
			TutorialBorder.initBitmapData();
			ShapePanel.initBitmapData();
			AwardScreen.initBitmapData();
			Cursor.initBitmapData();
			BlockConnection.initBitmapData();
			addChild(stateLayer);
			musicButton = new MusicButton(8, 8);
			musicButton.addEventListener(MouseEvent.CLICK, changeMusic);
			switchState(new TitleState());
		}
		
		public function changeMusic(e:MouseEvent):void {
			if (!soundPlayer.hasMusic())
				return;
			musicButton.change();
			if (musicButton.isOn())
				soundPlayer.resumeMusic();
			else
				soundPlayer.stopMusic();
			if (Main.userData != null) {
				Main.userData[1] = musicButton.isOn();
				sendUserData();
			}
		}
		
		public function initSounds():void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				BLManager.showInfo("The sounds couldn't be loaded: " + e.text);
			});
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, soundsLoaded);
			loader.load(new URLRequest(BLManager.getExtraPath() + "JellifySounds.swf"));
		}
		
		private function soundsLoaded(e:Event):void {
			e.currentTarget.removeEventListener(Event.COMPLETE, soundsLoaded);
			var soundSWF:* = LoaderInfo(e.currentTarget).content;
			soundPlayer.addMusic((new soundSWF.MUSIC1()) as Sound);
			addChild(musicButton);
		}
		
		public function initGlobal():void {
			var obj:Object = this.parent;
			while (obj != null) {
				if (flash.utils.getQualifiedClassName(obj) == "blapi_fla::MainTimeline") {
					try {
						var abj:Object = obj.panel.goBtn.btnManager;
						var getGlobal:Function = function():Class {
							try {
								return flash.utils.getDefinitionByName("org.bonuslevel.Global") as Class;
							} catch (error:Error) {
								BLManager.showInfo("Error while retrieving Global from BL API: " + error.message);
							}
							return null;
						}
						var getLvlManager:Function = function():Class {
							try {
								return flash.utils.getDefinitionByName("org.bonuslevel.LvlManager") as Class;
							} catch (error:Error) {
								BLManager.showInfo("Error while retrieving LvlManager from BL API: " + error.message);
							}
							return null;
						}
						Global = getGlobal.apply(abj);
						Hack.LvlManager = getLvlManager.apply(abj);
					} catch (e:Error) {
						BLManager.showInfo("Error while fetching buttonManager for getting Global and LvlManager: " + e.message);
					}
					break;
				}
				obj = obj.parent;
			}
		}
		
		public static function changeToolTips():void {
			var index:int = 0;
			var lvlsData:Object = Hack.getLvlsData();
			var packLvls:Object = Hack.getPackLvls();
			var offSet:int = Hack.getOffset();
			while (true) {
				if (!Global.theroot.blmenu.tabs.playtab.starttab.lvlprog.hasOwnProperty(("o" + index)))
					break;
				var str:String = Global.theroot.blmenu.tabs.playtab.starttab.lvlprog[("o" + index)].btnManager.tt;
				var i:int = str.lastIndexOf("COMPLETED,");
				if (i == -1)
					continue;
				i = str.lastIndexOf("BEST SCORE IS ")
				if (i != -1)
					break;
				i = str.lastIndexOf("\n\n");
				if (i == -1) {
					BLManager.log("Error: unable to inject best score text", 0);
					continue;
				}
				var lvlid:int = packLvls[offSet + index].id;
				var lvlData:Object = lvlsData.getElementData(lvlid);
				var bestScore:Number = lvlData == null ? 0 : lvlData.bscore;// packLvls[offSet + index].sc;//
				var inText:String = (lvlData != null) ? "\nBEST SCORE IS " + bestScore : "\nNO BEST SCORE FOUND";
				str = str.slice(0, i).concat(inText).concat(str.slice(i));
				Global.theroot.blmenu.tabs.playtab.starttab.lvlprog[("o" + index)].btnManager.setTooltip(str);
				index++;
			}
		}
		
		public static function isYourLevel():Boolean {
			try {
				var player:String = Global.gamevars.uname;
				var levelMaker:String = Global.theroot.blbar.infogui.inf.text;
				levelMaker = levelMaker.slice(3, levelMaker.length);
				return (player != null && player != "" && player == levelMaker);
			} catch (e:Error) {
				BLManager.showInfo("Error while checking if you played your own level: " + e.message);	
			}
			return false;
		}
		
		public static function isAcceptedOrOfficial():Boolean {
			try {
				var mc:MovieClip = (Global.theroot.blbar.infogui.status as MovieClip);
				return (mc.acc.visible || mc.off.visible);
			} catch (e:Error) {
				BLManager.showInfo("Error while checking if it is an accepted or official level: " + e.message);	
			}
			return false;
		}
		
		public static function isGreyOrRed():Boolean {
			try {
				var mc:MovieClip = (Global.theroot.blbar.infogui.status as MovieClip);
				return (mc.eva.visible || mc.rej.visible);
			} catch (e:Error) {
				BLManager.showInfo("Error while checking if it is an to be evaluated or rejected level: " + e.message);	
			}
			return false;
		}
		
		public static function addLvlidToUserData(lvlid:int):void {
			var index:int = Main.userData[0].indexOf(lvlid);
			if (index == -1)
				Main.userData[0].push(lvlid);
		}
		
		public static function ownLevelsCompleted():int {
			return Main.userData == null ? 0 : Main.userData[0].length;
		}
		
		public static function getLvlid():int {
			return Global.lvlManager.curLvlInfo;
		}
		
		public static function sendUserData():void {
			var byte:ByteArray = new ByteArray();
			byte.position = 0;
			byte.writeObject(userData);
			byte.position = 0;
			BLManager.updateUserData(byte);
		}
	}
}	