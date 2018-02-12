package gui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class ShapePanel extends Sprite {
		
		[Embed(source = "../../assets/img/shapePanelTiles.png")] private static const SHAPE_TILES:Class;
		
		private static const SHAPE_TILE_BITMAPDATA:Array = [];
		
		public static function initBitmapData():void {
			var bit:BitmapData = new SHAPE_TILES().bitmapData;
			for (var i:int = 0; i < 10; i++)
				(SHAPE_TILE_BITMAPDATA[i] = new BitmapData(48, 48, false)).copyPixels(bit, new Rectangle(48 * i, 0, 48, 48), new Point());
			bit.dispose();
		}
		
		private var
			shapeTiles:Array = [],
			shapeNumbers:Array = [],
			shapeTexts:Array = [];
		
		public function ShapePanel(colourAmounts:Array, possibleColours:Array, up:Boolean, right:Boolean) {
			for (var i:int = 1; i <= 10; i++) {
				if (possibleColours[i] || (colourAmounts[i] != 0 && colourAmounts[i] != 10)) {
					shapeNumbers.push(colourAmounts[i]);
					shapeTiles.push(new Bitmap(SHAPE_TILE_BITMAPDATA[i-1]));
				}
			}
			if (!right) {
				for (i = 0; i < shapeTiles.length; i++) {
					shapeTiles[i].x = 584;
					shapeTiles[i].y = 64 * i + (640 - 64 * shapeTiles.length + 16) / 2;
				}
			} else {
				if (!up) {
					for (i = 0; i < shapeTiles.length; i++) {
						shapeTiles[i].x = 72 + 64 * Math.min(i+2-(shapeTiles.length - 10), 8);
						shapeTiles[i].y = 8 + 64 * Math.max(0, i+2 - (shapeTiles.length - 10) - 8);
					}
				} else {
					for (i = 0; i < shapeTiles.length; i++) {
						shapeTiles[i].x = 384 + 64 * Math.min(i, 3);
						shapeTiles[i].y = 8 + 64 * Math.max(i - 3, 0);
						if (i > 6)
							shapeTiles[i].y += 128;
					}
				}
			}
			
			for (i = 0; i < shapeTiles.length; i++) {
				addChild(shapeTiles[i]);
				var str:String = String(shapeNumbers[i]);
				if (shapeNumbers[i] == 10)
					str = "?";
				shapeTexts[i] = J.newInSquareTextField(shapeTiles[i].x, shapeTiles[i].y, 48, 48, 24, str, 0);
				addChild(shapeTexts[i]);
			}
		}
	}
}