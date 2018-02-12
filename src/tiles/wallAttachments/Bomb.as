package tiles.wallAttachments {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import states.GameState;
	import tiles.Block;
	import tiles.Tile;

	public class Bomb extends WallAttachment {
		
		[Embed(source="../../../assets/img/bombs.png")] private static const BOMB:Class;
		
		private static const
			bitmapData:Array = [];
		
		private var
			readyToExplode:Boolean = false;
		
		public static function initBitmapData():void {
			var bits:BitmapData = new BOMB().bitmapData;
			for (var j:int = 0; j < 4; j++) {
				var w:int = 9 * Math.floor(((j + 1) % 4) / 2) + 20 * Math.floor(((j + 3) % 4) / 2);
				var h:int = 20 * Math.floor(((j + 1) % 4) / 2) + 9 * Math.floor(((j + 3) % 4) / 2);
				var bitX:int = 9 * Math.floor(((j + 3) % 4) / 2) + 29 * int(j == 2);
				var bitY:int = 9 * Math.floor(((j + 1) % 4) / 2) + 29 * int(j == 3);
				(bitmapData[j] = new BitmapData(38, 38, true, 0)).copyPixels(bits,
					new Rectangle(bitX, bitY, w, h), new Point(bitX, bitY), null, null, true);
			}
		}
		
		public static function explodeBlock(block:Block, gameState:GameState):void {
			var blocks:Array = block.getJelly().shallowCopyBlocks();
			block.getJelly().disband();
			gameState.jellify(true, blocks);
		}
		
		public function Bomb(X:int, Y:int) {
			super(X, Y);
		}
		
		override public function changeImage(movable:Boolean):void {
			super.changeImage(movable);
			bitmap = new Bitmap(bitmapData[J.getIndexFrom(getX(), getY())]);
			bitmap.x = -3;
			bitmap.y = -3;
			addChild(bitmap);
		}
		
		override public function changeBlock(block:Block, movable:Boolean, tile:Tile, gameState:GameState):Boolean {
			if (block.getColour() == J.WALL_BLOCK_COLOUR || readyToExplode == true)
				return false;
			block.setReadyToExplode();
			block.addExplosionDirection([getX(), getY()]);
			explodeBlock(block, gameState);
			readyToExplode = true;
			return true;
		}
		
		override public function clone():WallAttachment {
			return new Bomb(getX(), getY());
		}
		
		public function isReadyToExplode():Boolean { return this.readyToExplode; }
		
		public function getInfo():Array {
			return [0, X, Y, readyToExplode];
		}
		
		public function makeActive():void {
			readyToExplode = false;
			alpha = 1;
		}
		
		public function makeInactive():void {
			readyToExplode = true;
			alpha = 0;
		}
	}
}