package states {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class State extends Sprite {
		
		public function State() {
			addEventListener(Event.ADDED_TO_STAGE, startUp);
		}
		
		public function startUp(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, startUp);
			addEventListener(Event.ENTER_FRAME, everyFrame);
		}
		
		public function everyFrame(e:Event):void { }
		
		public function terminate():void {
			removeEventListener(Event.ENTER_FRAME, everyFrame);
		}
	}
}