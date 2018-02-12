package tiles.wallAttachments {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import states.GameState;
	import tiles.Block;
	import tiles.Tile;

	public class Hinge extends WallAttachment {
		
		[Embed(source = "../../../assets/img/hinges.png")] private static const HINGE:Class;
		
		private static const
			bitmapData:Array = [[], []];
		
		public static function initBitmapdata():void {
			var bit:BitmapData = new HINGE().bitmapData;
			for (var i:int = 0; i < 4; i++) {
				(bitmapData[0][i] = new BitmapData(32, 32, true, 0)).copyPixels(bit,
					new Rectangle(32 * i, 0, 32, 32), new Point(0, 0), null, null, true);
				(bitmapData[1][i] = new BitmapData(32, 32, true, 0)).copyPixels(bit,
					new Rectangle(32 * i, 32, 32, 32), new Point(0, 0), null, null, true);
			}
		}
		
		public function Hinge(X:int, Y:int) {
			super(X, Y);	
		}
		
		override public function changeImage(movable:Boolean):void {
			super.changeImage(movable);
			var index:int = J.getIndexFrom(getX(), getY());
			bitmap = new Bitmap(bitmapData[int(movable)][index]);
			bitmap.x = 24 * (int(index == 2) - int(index == 1)) + int(index == 1 && movable) - int(index == 2 && movable);
			bitmap.y = 24 * (int(index == 3) - int(index == 0)) + int(index == 0 && movable) - int(index == 3 && movable);
			addChild(bitmap);
		}
		
		override public function changeBlock(block:Block, movable:Boolean, tile:Tile, gameState:GameState):Boolean {
			if (movable)
				block.mergeJellyShapes(tile as Block);
			else
				block.setLocked(true);
			return true;
		}
		
		override public function clone():WallAttachment {
			return new Hinge(getX(), getY());
		}
		
		public function getInfo():Array {
			return [1 ,X, Y];
		}
	}
}