package gui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class MusicButton extends SimpleButton {
		
		[Embed(source = "../../assets/img/musicButton.png")] private static const MUSIC:Class;
		
		private static const
			bitmapData:Array = [];
		
		private var
			upStateSprite:Sprite = new Sprite(),
			upBitmap:Bitmap,
			overStateSprite:Sprite = new Sprite(),
			overBitmap:Bitmap,
			downStateSprite:Sprite = new Sprite(),
			downBitmap:Bitmap,
			on:Boolean;
		
		public static function initBitmapData():void {
			var bit:BitmapData = new MUSIC().bitmapData;
			for (var i:int = 0; i < 2; i++) {
				bitmapData[i] = new Array();
				for (var j:int = 0; j < 3; j++)
					(bitmapData[i][j] = new BitmapData(48, 48, false)).copyPixels(
						bit, new Rectangle(48 * j, 48 * i, 48, 48), new Point(0, 0));
			}
		}
		
		public function MusicButton(x:int, y:int) {
			super(upStateSprite, overStateSprite, downStateSprite, overStateSprite);
			this.x = x;
			this.y = y;
			upStateSprite.addChild(upBitmap = new Bitmap(bitmapData[int(!on)][0]));
			overStateSprite.addChild(overBitmap = new Bitmap(bitmapData[int(!on)][1]));
			downStateSprite.addChild(downBitmap = new Bitmap(bitmapData[int(!on)][2]));
			useHandCursor = true;
		}
		
		public function change():void {
			on = !on;
			upStateSprite.removeChild(upBitmap);
			upStateSprite.addChild(upBitmap = new Bitmap(bitmapData[int(!on)][0]));
			overStateSprite.removeChild(overBitmap);
			overStateSprite.addChild(overBitmap = new Bitmap(bitmapData[int(!on)][1]));
			downStateSprite.removeChild(downBitmap);
			downStateSprite.addChild(downBitmap = new Bitmap(bitmapData[int(!on)][2]));
		}
		
		public function isOn():Boolean { return this.on; }
	}
}