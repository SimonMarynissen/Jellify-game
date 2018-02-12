package states {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gui.Button;

	public class BackState extends State {
		
		[Embed(source = "../../assets/img/backButton.png")] private static const BACK:Class;
		
		private static const BACK_BITMAPDATA:Array = [];
		
		private var backButton:Button;
		
		public static function initBitmapData():void {
			for (var i:int = 0; i < 3; i++) {
				(BACK_BITMAPDATA[i] = new BitmapData(48, 48, true, 0)).copyPixels(
					new BACK().bitmapData, new Rectangle(48 * i, 0, 48, 48),
					new Point(0, 0), null, null, true);
			}
			BACK_BITMAPDATA[3] = BACK_BITMAPDATA[1];
		}
		
		override public function startUp(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, startUp);
			addChild(new Bitmap(new GameState.BG().bitmapData));
			backButton = new Button(BACK_BITMAPDATA);
			backButton.x = 8;
			backButton.y = 584;
			backButton.activate();
			backButton.addEventListener(MouseEvent.CLICK, backToTitle);
			addChild(backButton);
		}
		
		override public function terminate():void {
			backButton.removeEventListener(MouseEvent.CLICK, backToTitle);
		}
		
		public function backToTitle(e:Event):void {
			Main.BLManager.theroot.switchState(new TitleState());
		}
	}
}