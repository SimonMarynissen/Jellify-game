package tiles.wallAttachments {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import states.GameState;
	import tiles.Block;
	import tiles.Tile;
	import tiles.blockContainers.Jelly;
	
	public class Spike extends WallAttachment {
		
		[Embed(source="../../../assets/img/spikes.png")] private static const SPIKE:Class;
		
		private static const
			bitmapData:Array =  [];
		
		public static function initBitmapData():void {
			for (var i:int = 0; i < 4; i++)
				(bitmapData[i] = new BitmapData(40, 40, true, 0)).copyPixels(new SPIKE().bitmapData,
					new Rectangle(40 * i, 0, 40, 40), new Point(), null, null, true);
		}
		
		public function Spike(X:int, Y:int) {
			super(X, Y);
		}
		
		override public function changeImage(movable:Boolean):void {
			super.changeImage(movable);
			bitmap = new Bitmap(bitmapData[J.getIndexFrom(getX(), getY())]);
			bitmap.x = -4;
			bitmap.y = -4;
			addChild(bitmap);
		}
		
		override public function changeBlock(block:Block, movable:Boolean, tile:Tile, gameState:GameState):Boolean {
			if (block.getColour() == J.WALL_BLOCK_COLOUR)
				return false;
			var jelly:Jelly = block.getJelly();
			var jellyBlocks:Array = jelly.shallowCopyBlocks();
			jelly.disband();
			gameState.hingeBlocks(jellyBlocks);
			return true;
		}
		
		override public function clone():WallAttachment {
			return new Spike(getX(), getY());
		}
	}
}