package states {

	import caurina.transitions.Tweener;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gui.Button;
	
	public class WinScreen extends Sprite {
		
		[Embed(source = "../../assets/img/winScreen/moves.png")] private static const MOVES:Class;
		[Embed(source = "../../assets/img/winScreen/move.png")] private static const MOVE:Class;
		[Embed(source = "../../assets/img/winScreen/numbers.png")] private static const NUMBERS:Class;
		[Embed(source = "../../assets/img/winScreen/victory buttons.png")] private static const BUTTONS:Class;
		[Embed(source = "../../assets/img/winScreen/victory text.png")] private static const VICTORY:Class;
		[Embed(source = "../../assets/img/winScreen/winScreenDripping.png")] private static const DRIPPING:Class;
		[Embed(source = "../../assets/img/winScreen/moves_silver.png")] private static const MOVES_SILVER:Class;
		[Embed(source = "../../assets/img/winScreen/move_silver.png")] private static const MOVE_SILVER:Class;
		[Embed(source = "../../assets/img/winScreen/numbers_silver.png")] private static const NUMBERS_SILVER:Class;
		[Embed(source = "../../assets/img/winScreen/victory buttons gold.png")] private static const BUTTONS_GOLD:Class;
		[Embed(source = "../../assets/img/winScreen/victory text silver.png")] private static const VICTORY_SILVER:Class;
		[Embed(source = "../../assets/img/winScreen/dripping_gold.png")] private static const DRIPPING_GOLD:Class;
		
		private static const
			NEXT_BITMAPDATA:Array = [[], []],
			REPLAY_BITMAPDATA:Array = [[], []],
			NUMBERS_BITMAPDATA:Array = [[], []],
			NUMBER_WIDTH:Array = [22, 14, 22, 23, 22, 22, 23, 22, 22, 21],
			NUMBER_X:Array = [0, 22, 36, 58, 81, 103, 125, 148, 170, 192],
			KERNING:Array = [	[3, 5, 4, 4, 5, 4, 4, 5, 5, 5],
								[3, 5, 4, 4, 5, 4, 4, 4, 5, 5],
								[3, 4, 4, 5, 6, 5, 5, 5, 4, 5],
								[4, 5, 6, 5, 6, 5, 6, 6, 6, 7],
								[4, 6, 7, 5, 6, 6, 5, 8, 6, 8],
								[4, 5, 5, 4, 5, 4, 5, 6, 5, 6],
								[3, 5, 6, 4, 5, 5, 4, 7, 5, 7],
								[5, 4, 6, 7, 7, 6, 6, 6, 5, 6],
								[4, 5, 6, 4, 5, 5, 5, 7, 6, 7],
								[3, 4, 4, 4, 4, 4, 4, 5, 4, 4]];
			
		private var
			gameState:GameState,
			dripSquare:Bitmap,
			drip:Bitmap,
			replayButton:Button,
			nextButton:Button,
			movesText:Sprite,
			winText:Bitmap;
			
		public static function initBitmapData():void {
			for (var i:int = 0; i < 3; i++) {
				(NEXT_BITMAPDATA[0][i] = new BitmapData(64, 64, true, 0)).copyPixels(
					new BUTTONS().bitmapData, new Rectangle(64 * i, 64, 64, 64),
					new Point(0, 0), null, null, true);
				(NEXT_BITMAPDATA[1][i] = new BitmapData(64, 64, true, 0)).copyPixels(
					new BUTTONS_GOLD().bitmapData, new Rectangle(64 * i, 64, 64, 64),
					new Point(0, 0), null, null, true);
				(REPLAY_BITMAPDATA[0][i] = new BitmapData(64, 64, true, 0)).copyPixels(
					new BUTTONS().bitmapData, new Rectangle(64 * i, 0, 64, 64),
					new Point(0, 0), null, null, true);
				(REPLAY_BITMAPDATA[1][i] = new BitmapData(64, 64, true, 0)).copyPixels(
					new BUTTONS_GOLD().bitmapData, new Rectangle(64 * i, 0, 64, 64),
					new Point(0, 0), null, null, true);
			}
			for (i = 0; i < 10; i++) {
				(NUMBERS_BITMAPDATA[0][i] = new BitmapData(NUMBER_WIDTH[i], 31, true, 0)).copyPixels(
					new NUMBERS().bitmapData, new Rectangle(NUMBER_X[i], 0, NUMBER_WIDTH[i], 31),
					new Point(0, 0), null, null, true);
					(NUMBERS_BITMAPDATA[1][i] = new BitmapData(NUMBER_WIDTH[i], 31, true, 0)).copyPixels(
					new NUMBERS_SILVER().bitmapData, new Rectangle(NUMBER_X[i], 0, NUMBER_WIDTH[i], 31),
					new Point(0, 0), null, null, true);
			}
			NEXT_BITMAPDATA[0][3] = NEXT_BITMAPDATA[0][1];
			NEXT_BITMAPDATA[1][3] = NEXT_BITMAPDATA[1][1];
			REPLAY_BITMAPDATA[0][3] = REPLAY_BITMAPDATA[0][1];
			REPLAY_BITMAPDATA[1][3] = REPLAY_BITMAPDATA[1][1];
		}
		
		public function WinScreen(moves:int, gameState:GameState, official:Boolean) {
			this.gameState = gameState;
			y = -488;
			if (!official) {
				dripSquare = new Bitmap(new BitmapData(640, 320, true, 0xffb3fffc));
				addChild(dripSquare);
			}
			if (official) {
				drip = new Bitmap(new DRIPPING_GOLD().bitmapData);
				drip.y = -135;
			} else {
				drip = new Bitmap(new DRIPPING().bitmapData);
				drip.y = 320;
			}
			addChild(drip);
			if (official)
				winText = new Bitmap(new VICTORY_SILVER().bitmapData);
			else
				winText = new Bitmap(new VICTORY().bitmapData);
			winText.y = 48;
			winText.x = (640 - winText.width) / 2;
			addChild(winText);
			replayButton= new Button(REPLAY_BITMAPDATA[official ? 1 : 0]);
			replayButton.x = 160;
			replayButton.y = 256;
			replayButton.activate();
			addChild(replayButton);
			nextButton = new Button(NEXT_BITMAPDATA[official ? 1 : 0]);
			nextButton.x = 416;
			nextButton.y = 256;
			nextButton.activate();
			addChild(nextButton);
			movesText = new Sprite();
			movesText.y = 280;
			var digits:Array = String(moves).split("");
			var w:int = 0;
			for (var i:int = 0; i < digits.length; i++)
				digits[i] = parseInt(digits[i], 10);
			for (i = 0; i < digits.length; i++) {
				var bits:Bitmap = official ? new Bitmap(NUMBERS_BITMAPDATA[1][digits[i]]) : new Bitmap(NUMBERS_BITMAPDATA[0][digits[i]]);
				var kerning:int = 0;
				if (i != 0)
					kerning = KERNING[digits[i - 1]][digits[i]];
				bits.x = w - kerning;
				movesText.addChild(bits);
				w = w - kerning + NUMBER_WIDTH[digits[i]];
			}
			var mover:Bitmap;
			if (moves == 1)
				official ? mover = new Bitmap(new MOVE_SILVER().bitmapData) : mover = new Bitmap(new MOVE().bitmapData);
			else 
				official ? mover = new Bitmap(new MOVES_SILVER().bitmapData) : mover = new Bitmap(new MOVES().bitmapData);
			mover.x = w + 10;
			movesText.addChild(mover);
			w = w + 10 + mover.width;
			movesText.x = (640 - w) / 2;
			movesText.y = 208;
			if (official)
				movesText.y += 12;
			addChild(movesText);
		}
		
		public function start():void {
			Tweener.addTween(this, { y:y + 488, time:1, transition:"easeOutExpo", onComplete:activate });
		}
		
		public function stop():void {
			removeListeners();
			Tweener.addTween(this, { y:y - 488, time:1, transition:"easeOutExpo", onComplete:function():void {
				gameState.removeChild(this);
			}});
		}
		
		public function replayLevel(e:MouseEvent):void {
			stop();
			gameState.replayLevel();
		}
		
		public function nextLevel(e:MouseEvent):void {
			stop();
			gameState.saveScoreAndNext();
		}
		
		private function activate(e:Event = null):void {
			replayButton.addEventListener(MouseEvent.CLICK, replayLevel);
			nextButton.addEventListener(MouseEvent.CLICK, nextLevel);
		}
		
		private function removeListeners():void {
			replayButton.removeEventListener(MouseEvent.CLICK, replayLevel);
			nextButton.removeEventListener(MouseEvent.CLICK, nextLevel);
		}
	}
}