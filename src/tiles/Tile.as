package tiles {
	
	import flash.display.Sprite;
	import states.GameState;

	public class Tile extends Sprite {
		
		protected var
			X:int,
			Y:int;
		
		public function Tile(X:int, Y:int) {
			this.X = X;
			this.Y = Y;
			this.x = GameState.getGridXOffset() + X * GameState.cellWidth;
			this.y = GameState.getGridYOffset() + Y * GameState.cellWidth;
		}
		
		public function getX():int { return this.X; }
		public function getY():int { return this.Y; }
	}
}