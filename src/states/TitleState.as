package states {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gui.Button;
	//import flash.utils.ByteArray;

	public class TitleState extends State {
		
		[Embed(source = "../../assets/img/creditsButton.png")] private static const CREDITS:Class;
		[Embed(source = "../../assets/img/tutorialButton.png")] private static const TUTORIAL:Class;
		[Embed(source = "../../assets/img/settingsButton.png")] private static const SETTINGS:Class;
		[Embed(source = "../../assets/img/startbutton.png")] private static const START:Class;
		[Embed(source = "../../assets/img/logo.png")] private static const LOGO:Class;
		
		private static const
			CREDITS_BITMAPDATA:Array = [],
			TUTORIAL_BITMAPDATA:Array = [],
			SETTINGS_BITMAPDATA:Array = [],
			START_BITMAPDATA:Array = [];
			
		private var
			creditsButton:Button,
			tutorialButton:Button,
			settingsButton:Button,
			startButton:Button,
			logo:Bitmap;
		
		public static function initBitmapData():void {
			for (var i:int = 0; i < 3; i++) {
				(CREDITS_BITMAPDATA[i] = new BitmapData(144, 48, false, 0)).copyPixels(
					new CREDITS().bitmapData, new Rectangle(0, 48 * i, 144, 48),
					new Point(0, 0), null, null, true);
				(TUTORIAL_BITMAPDATA[i] = new BitmapData(48, 48, true, 0)).copyPixels(
					new TUTORIAL().bitmapData, new Rectangle(48 * i, 0, 48, 48),
					new Point(0, 0), null, null, true);
				(SETTINGS_BITMAPDATA[i] = new BitmapData(48, 48, true, 0)).copyPixels(
					new SETTINGS().bitmapData, new Rectangle(48 * i, 0, 48, 48),
					new Point(0, 0), null, null, true);
				(START_BITMAPDATA[i] = new BitmapData(269, 75, true, 0)).copyPixels(
					new START().bitmapData, new Rectangle(0, 75 * i, 269, 75),
					new Point(0, 0), null, null, true);
			}
			CREDITS_BITMAPDATA[3] = CREDITS_BITMAPDATA[1];
			TUTORIAL_BITMAPDATA[3] = TUTORIAL_BITMAPDATA[1];
			SETTINGS_BITMAPDATA[3] = SETTINGS_BITMAPDATA[1];
			START_BITMAPDATA[3] = START_BITMAPDATA[1];
		}
		
		override public function startUp(e:Event):void {
			addChild(new Bitmap(new GameState.BG().bitmapData));
			creditsButton = new Button(CREDITS_BITMAPDATA);
			creditsButton.x = 488;
			creditsButton.y = 584;
			creditsButton.activate();
			creditsButton.addEventListener(MouseEvent.CLICK, goToCredits);
			addChild(creditsButton);
			tutorialButton = new Button(TUTORIAL_BITMAPDATA);
			tutorialButton.x = 584;
			tutorialButton.y = 8;
			tutorialButton.activate();
			tutorialButton.addEventListener(MouseEvent.CLICK, goToTutorial);
			addChild(tutorialButton);
			settingsButton = new Button(SETTINGS_BITMAPDATA);
			settingsButton.x = 56;
			settingsButton.y = 8;
			settingsButton.activate();
			settingsButton.addEventListener(MouseEvent.CLICK, goToSettings);
			addChild(settingsButton);
			startButton = new Button(START_BITMAPDATA);
			startButton.x = (640 - 269) / 2;
			startButton.y = 440;
			startButton.activate();
			startButton.addEventListener(MouseEvent.CLICK, start);
			addChild(startButton);
			logo = new Bitmap(new LOGO().bitmapData);
			logo.x = (640 - logo.width) / 2;
			logo.y = (640 - logo.height) / 2;
			addChild(logo);
			//Main.BLManager.blPlayLvl(new ByteArray(), 0);
		}
		
		override public function terminate():void {
			super.terminate();
			creditsButton.removeEventListener(MouseEvent.CLICK, goToCredits);
			tutorialButton.removeEventListener(MouseEvent.CLICK, goToTutorial);
			settingsButton.removeEventListener(MouseEvent.CLICK, goToSettings);
		}
		
		private function goToCredits(e:Event):void {
			Main.BLManager.theroot.switchState(new CreditsState());
		}
		
		private function goToTutorial(e:Event):void {
			Main.BLManager.theroot.switchState(new TutorialState());
		}
		
		private function goToSettings(e:Event):void {
			Main.BLManager.theroot.switchState(new SettingsState());
		}
		
		private function start(e:Event):void {
			Main.BLManager.showMenu(-1);
		}
	}
}