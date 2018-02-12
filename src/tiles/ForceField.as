package tiles {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import tiles.Tile;

	public class ForceField extends Tile {
		
		[Embed(source = "../../assets/img/forceFields.png")] private static const FORCE_FIELD:Class;
		
		public static const
			BITMAPDATA:Array = [];
		
		private var
			colours:Array,
			image:Bitmap;
		
		public static function initBitmapData():void {
			var bit:BitmapData = new FORCE_FIELD().bitmapData;
			for (var i:int = 0; i <= 10; i++) {
				BITMAPDATA[i] = new Array();
				for (var j:int = 0; j < 4; j++) {
					var bitX:int = 8 * Math.floor(((j + 3) % 4) / 2) + 28 * int(j == 2);
					var bitY:int = 8 * Math.floor(((j + 1) % 4) / 2) + 28 * int(j == 3);
					var w:int = 4 * Math.floor(((j + 1) % 4) / 2) + 16 * Math.floor(((j + 3) % 4) / 2);
					var h:int = 16 * Math.floor(((j + 1) % 4) / 2) + 4 * Math.floor(((j + 3) % 4) / 2);
					(BITMAPDATA[i][j] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + bitX, bitY, w, h),
						new Point(bitX, bitY), null, null, true);
				}
				for (j = 0; j < 8; j++) {
					var k:int = Math.floor(j / 2);
					w = 4 * Math.floor(((k + 1) % 4) / 2) + 2 * Math.floor(((k + 3) % 4) / 2);
					h = 2 * Math.floor(((k + 1) % 4) / 2) + 4 * Math.floor(((k + 3) % 4) / 2);
					bitX = 6 * Math.floor(((k + 3) % 4) / 2) + 24 * int(k == 2) + 18 * int(j == 1 || j == 7) + 4 * int(j == 4 || j == 5);
					bitY = 6 * Math.floor(((k + 1) % 4) / 2) + 24 * int(k == 3) + 18 * int(j == 3 || j == 5) + 4 * int(j == 6 || j == 7);
					(BITMAPDATA[i][j + 4] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + bitX, bitY, w, h),
						new Point(bitX, bitY), null, null, true);
				}
				for (j = 0; j < 2; j++) {
					(BITMAPDATA[i][j + 12] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + 24 * j, 64, 8, 4),
						new Point(24 * j, 0), null, null, true);
					(BITMAPDATA[i][j + 14] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i, 32 + 24 * j, 4, 8),
						new Point(0, 24 * j), null, null, true);
					(BITMAPDATA[i][j + 16] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + 28, 32 + 24 * j, 4, 8),
						new Point(28, 24 * j), null, null, true);
					(BITMAPDATA[i][j + 18] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + 24 * j, 92, 8, 4),
						new Point(24 * j, 28), null, null, true);
					(BITMAPDATA[i][j + 20] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + 24 * j, 128, 8, 4),
						new Point(24 * j, 0), null, null, true);
					(BITMAPDATA[i][j + 22] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i, 96 + 24 * j, 4, 8),
						new Point(0, 24 * j), null, null, true);
					(BITMAPDATA[i][j + 24] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + 28, 96 + 24 * j, 4, 8),
						new Point(28, 24 * j), null, null, true);
					(BITMAPDATA[i][j + 26] = new BitmapData(32, 32, true, 0)).copyPixels(
						bit, new Rectangle(32 * i + 24 * j, 156, 8, 4),
						new Point(24 * j, 28), null, null, true);
				}
			}
		}
		
		public function ForceField(data:Array) {
			super(data[1], data[2]);
			colours = [data[3], data[4], data[5], data[6]];
		}
		
		public function getColour(xdir:int, ydir:int):int {
			return colours[J.getIndexFrom(xdir, ydir)];
		}
		
		public function changeImage(transitions:Array):void {
			if (image != null && contains(image))
				removeChild(image);
			var bit:BitmapData = new BitmapData(32, 32, true, 0);
			for (var i:int = 0; i < 4; i++) {
				if (colours[i] == J.NO_COLOUR)
					continue;
				bit.copyPixels(BITMAPDATA[colours[i]][i], new Rectangle(0, 0, 32, 32),
					new Point(0, 0), null, null, true);
				var index1:int = 4 + 8 * Math.floor(transitions[i] / 3) + 2 * i;
				var index2:int = 5 + 8 * (transitions[i] % 3) + 2 * i;
				bit.copyPixels(BITMAPDATA[colours[i]][index1], new Rectangle(0, 0, 32, 32),
					new Point(0, 0), null, null, true);
				bit.copyPixels(BITMAPDATA[colours[i]][index2], new Rectangle(0, 0, 32, 32),
					new Point(0, 0), null, null, true);
			}
			addChild(image = new Bitmap(bit));
		}
	}
}