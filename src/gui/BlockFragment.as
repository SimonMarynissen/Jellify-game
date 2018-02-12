package gui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class BlockFragment extends Bitmap {
		
		public var
			speedX:Number,
			speedY:Number,
			time:int = 0;
		
		public function BlockFragment(X:int, Y:int, bits:BitmapData) {
			super(bits);
			this.x = X;
			this.y = Y;
		}
		
		public function update():void {
			x += speedX;
			y += speedY;
			time++;
			alpha -= 1/15;
		}
	}
}