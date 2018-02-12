package gui {
	
	import flash.display.Sprite;
	import states.GameState;
	import tiles.Block;
	
	public class Animator {
		
		private var
			display:Sprite,
			gameState:GameState,
			emitters:Array = [];
		
		public function Animator(display:Sprite, gameState:GameState) {
			super();
			this.display = display;
			this.gameState = gameState;
		}
		
		public function addBlockExplosion(block:Block):void {
			var fragments:Array = block.getFragments();
			for (var i:int = 0; i < fragments.length; i++) {
				display.addChild(fragments[i]);
				fragments[i].speedX = (Math.round(Math.random() * 2) + 1) * (Math.random() < 0.5 ? 1 : -1);
				fragments[i].speedY = (Math.round(Math.random() * 2) + 1) * (Math.random() < 0.5 ? 1 : -1);
			}
			gameState.addFragments(fragments);
		}
		
		public function addBlockPainting(x:int, y:int, paints:Array):void {
			
		}
		
		public function startAnimating():void {
			
		}
	}
}