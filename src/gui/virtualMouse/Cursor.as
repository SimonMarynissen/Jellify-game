package gui.virtualMouse {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Cursor extends Bitmap {
		
		[Embed(source = "../../../assets/img/cursor.png")] private static const CURSOR:Class;
		
		private static var
			normal:BitmapData,
			over:BitmapData,
			down:BitmapData,
			isOver:Boolean;
		
		public static function initBitmapData():void {
			var bit:BitmapData = new CURSOR().bitmapData;
			(normal = new BitmapData(24, 24, true, 0)).copyPixels(bit, new Rectangle(0, 0, 24, 24),
				new Point(0, 0), null, null, true);
			(over = new BitmapData(24, 24, true, 0)).copyPixels(bit, new Rectangle(24, 0, 24, 24),
				new Point(0, 0), null, null, true);
			(down = new BitmapData(24, 24, true, 0)).copyPixels(bit, new Rectangle(48, 0, 24, 24),
				new Point(0, 0), null, null, true);
			bit.dispose();
			bit = null;
		}
		
		public function Cursor() {
			super(normal);
		}
		
		public function toNormal():void {
			this.bitmapData = normal;
		}
		
		public function toOver():void {
			this.bitmapData = over;
			isOver = true;
		}
		
		public function toDown():void {
			this.bitmapData = down;
		}
		
		public function toUp():void {
			isOver ? toOver() : toNormal();
		}
		
		public function setOver(o:Boolean):void {
			isOver = o;
		}
	}
}