package gui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;

	public class BGParticles extends Sprite {
		
		[Embed(source = "../../assets/img/bgparticles.png")] private static const BG_PARTICLE:Class;
		
		private var
			tiles:Array = [],
			xDir:int,
			yDir:int,
			tileWidth:int = 660,
			speed:int = 4;
			
		public function BGParticles() {
			var bits:BitmapData = new BG_PARTICLE().bitmapData;
			for (var X:int = 0; X < 2; X++) {
				for (var Y:int = 0; Y < 2; Y++) {
					var bit:Bitmap = new Bitmap(bits);
					bit.x = 320 - tileWidth * X;
					bit.y = 320 - tileWidth * Y;
					addChild(bit);
					tiles.push(bit);
				}
			}
		}
		
		public function start():void {
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function stop():void {
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, update);
		}
		
		public function changeDirection(xDir:int, yDir:int):void {
			this.xDir = xDir;
			this.yDir = yDir;
		}
		
		private function update(e:Event):void {
			for (var i:int = 0; i < tiles.length; i++) {
				tiles[i].x += xDir * speed;
				tiles[i].y += yDir * speed;
				if (xDir == 1) {
					if (tiles[i].x > 640)
						tiles[i].x -= 2 * tileWidth;
				} else if (xDir == -1) {
					if (tiles[i].x + tileWidth < 0)
						tiles[i].x += 2 * tileWidth;
				}
				
				if (yDir == 1) {
					if (tiles[i].y > 640)
						tiles[i].y -= 2 * tileWidth;
				} else if (yDir == -1) {
					if (tiles[i].y + tileWidth < 0)
						tiles[i].y += 2 * tileWidth;
				}
			}
		}
	}
}