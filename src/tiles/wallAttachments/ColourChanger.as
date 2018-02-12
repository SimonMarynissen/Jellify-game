package tiles.wallAttachments {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import states.GameState;
	import tiles.Block;
	import tiles.Tile;

	public class ColourChanger extends WallAttachment {
		
		[Embed(source = "../../../assets/img/colourChangers.png")] private static const COLOUR_CHANGERS:Class;
		
		private static const
			bitmapData:Array = [];
		
		private var
			colour:uint;
		
		public static function initBitmapData():void {
			var bits:BitmapData = new COLOUR_CHANGERS().bitmapData;
			for (var i:int = 0; i <= 10; i++) {
				bitmapData[i] = [[], []]; // normal wall, movable walls
				for (var j:int = 0; j < 4; j++) {
					var w:int = 6 * Math.floor(((j + 1) % 4) / 2) + 20 * Math.floor(((j + 3) % 4) / 2);
					var h:int = 20 * Math.floor(((j + 1) % 4) / 2) + 6 * Math.floor(((j + 3) % 4) / 2);
					var bitX:int = 6 * Math.floor(((j + 3) % 4) / 2) + 26 * int(j == 2);
					var bitY:int = 6 * Math.floor(((j + 1) % 4) / 2) + 26 * int(j == 3);
					for (var k:int = 0; k < 2; k++) {
						(bitmapData[i][k][j] = new BitmapData(32, 32, true, 0)).copyPixels(bits,
								new Rectangle(32 * i + bitX, 32 * k + bitY, w, h), new Point(bitX, bitY), null, null, true);
					}
				}
			}
		}
		
		public static function colourBlock(block:Block, colour:uint, gameState:GameState):void {
			if (block.getColour() == J.WALL_BLOCK_COLOUR)
				return;
			if (block.getColour() == colour)
				return;
			block.setColour(colour);
			var blocks:Array = block.getJelly().shallowCopyBlocks();
			block.getJelly().disband();
			gameState.jellify(false, blocks);
		}
		
		public function ColourChanger(X:int, Y:int, colour:uint) {
			super(X, Y);
			this.colour = colour;
		}
		
		override public function changeImage(movable:Boolean):void {
			super.changeImage(movable);
			bitmap = new Bitmap(bitmapData[colour][int(movable)][J.getIndexFrom(getX(), getY())]);
			addChild(bitmap);
		}
		
		override public function changeBlock(block:Block, movable:Boolean, tile:Tile, gameState:GameState):Boolean {
			if (block.getColour() == J.WALL_BLOCK_COLOUR)
				return false;
			block.addPaint(colour);
			return false;
		}
		
		override public function clone():WallAttachment {
			return new ColourChanger(getX(), getY(), colour);
		}
	}
}