package tiles.wallAttachments {
	
	import flash.display.Bitmap;
	import states.GameState;
	import tiles.Block;
	import tiles.Tile;

	public class WallAttachment extends Tile {
		
		protected var
			bitmap:Bitmap;
		
		public function WallAttachment(X:int, Y:int) {
			super(X, Y);
			this.x = 0;
			this.y = 0;
		}
		
		public function changeImage(movable:Boolean):void {
			if (bitmap != null && contains(bitmap))
				removeChild(bitmap);
		}
		
		public function changeBlock(block:Block, movable:Boolean, tile:Tile, gameState:GameState):Boolean { return false; }
		public function clone():WallAttachment { return this; }
	}
}