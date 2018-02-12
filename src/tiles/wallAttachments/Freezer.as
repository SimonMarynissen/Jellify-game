package tiles.wallAttachments {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import states.GameState;
	import tiles.Block;
	import tiles.Tile;
	import tiles.blockContainers.Jelly;

	public class Freezer extends WallAttachment {
		
		[Embed(source = "../../../assets/img/freezers.png")] private static const FREEZER:Class;
		
		private static const
			bitmapData:Array = [[], []];
			
		public static function initBitmapData():void {
			var bit:BitmapData = new FREEZER().bitmapData;
			for (var i:int = 0; i < 4; i++) {
				(bitmapData[0][i] = new BitmapData(36, 36, true, 0)).copyPixels(bit,
					new Rectangle(36 * i, 0, 36, 36), new Point(), null, null, true);
				(bitmapData[1][i] = new BitmapData(36, 36, true, 0)).copyPixels(bit,
					new Rectangle(36 * i, 36, 36, 36), new Point(), null, null, true);
			}
		}
		
		public static function freezeJelly(jelly:Jelly):void {
			var jellyBlocks:Array = jelly.getBlocks();
			for each (var jellyBlock:Block in jellyBlocks) {
				if (jellyBlock.getColour() != J.WALL_BLOCK_COLOUR)
					jellyBlock.setFrozen(true);
			}
		}
		
		public function Freezer(X:int, Y:int) {
			super(X, Y);
		}
		
		override public function changeImage(movable:Boolean):void {
			super.changeImage(movable);
			bitmap = new Bitmap(bitmapData[int(movable)][J.getIndexFrom(getX(), getY())]);
			bitmap.x = -2;
			bitmap.y = -2;
			addChild(bitmap);
		}
		
		override public function changeBlock(block:Block, movable:Boolean, tile:Tile, gameState:GameState):Boolean {
			if (block.getColour() == J.WALL_BLOCK_COLOUR)
				return false;
			block.getJelly().needsToFreeze();
			return false;
		}
		
		override public function clone():WallAttachment {
			return new Freezer(getX(), getY());
		}
	}
}