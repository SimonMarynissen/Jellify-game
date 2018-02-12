package gui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	public class Button extends SimpleButton {
		
		private var
			normalState:Sprite = new Sprite(),
			normalBitmap:Bitmap,
			normal:BitmapData,
			inactive:BitmapData;
		
		public function Button(data:Array) {
			super(normalState, new Bitmap(data[2]), new Bitmap(data[3]), new Bitmap(data[2]));
			this.normal = data[0];
			this.inactive = data[1];
			useHandCursor = true;
			normalState.buttonMode = true;
		}
		
		public function deactivate():void {
			enabled = false;
			normalState.buttonMode = false;
			if (normalBitmap != null)
				normalState.removeChild(normalBitmap);
			normalState.addChild(normalBitmap = new Bitmap(inactive));
		}
		
		public function activate():void {
			enabled = true;
			normalState.buttonMode = true;
			if (normalBitmap != null)
				normalState.removeChild(normalBitmap);
			normalState.addChild(normalBitmap = new Bitmap(normal));
		}
	}
}