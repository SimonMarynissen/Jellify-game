package gui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TutorialBorder extends Sprite {
		
		[Embed(source = "../../assets/img/tutorialBorders.png")] private static const BORDER:Class;
		
		private static var BORDER_BITMAPDATA:BitmapData;
		
		private var border:Bitmap;
		
		public static function initBitmapData():void {
			BORDER_BITMAPDATA = new BORDER().bitmapData;
		}
		
		public function TutorialBorder(w:int, h:int) {
			changeImage(w, h);
		}
		
		public function changeImage(w:int, h:int):void {
			if (border != null && contains(border))
				removeChild(border);
			if (border != null)
				border.bitmapData.dispose();
			border = null;
			var bit:BitmapData = new BitmapData(w, h, true, 0);
			border = new Bitmap(bit);
			this.x = (640 - w) / 2;
			this.y = (640 - h) / 2;
			addChild(border);
			border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(0, 0, 9, 9), new Point(0, 0), null, null, true);
			border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(9, 0, 9, 9), new Point(border.bitmapData.width - 9, 0), null, null, true);
			border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(18, 0, 9, 9), new Point(0, border.bitmapData.height - 9), null, null, true);
			border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(27, 0, 9, 9), new Point(border.bitmapData.width - 9, border.bitmapData.height - 9), null, null, true);
			var X:int = w - 18;
			var Y:int = h - 18;
			for (var i:int = 0; i < X; i++) {
				border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(36, 0, 1, 9), new Point(9 + i, 0), null, null, true);
				border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(37, 0, 1, 9), new Point(9 + i, h - 9), null, null, true);
			}
			var m:int = Y / 2;
			for (var j:int = 0; j < Y; j++) {
				if (j < m) {
					border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(38, 0, 9, 1), new Point(0, 9 + j), null, null, true);
					border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(38, 0, 9, 1), new Point(w - 9, 9 + j), null, null, true);
				} else if (j == m) {
					border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(38, 1, 9, 1), new Point(0, 9 + j), null, null, true);
					border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(38, 1, 9, 1), new Point(w - 9, 9 + j), null, null, true);
				} else {
					border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(38, 2, 9, 1), new Point(0, 9 + j), null, null, true);
					border.bitmapData.copyPixels(BORDER_BITMAPDATA, new Rectangle(38, 2, 9, 1), new Point(w - 9, 9 + j), null, null, true);
				}
			}
		}
	}
}