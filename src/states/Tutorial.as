package states {
	
	import com.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import gui.TutorialBorder;
	import gui.virtualMouse.MyVirtualMouse;
	
	public class Tutorial extends EventDispatcher {
		
		public var
			view:Rectangle;
		
		private var
			data:ByteArray,
			title:String,
			actionList:Array,
			area:Rectangle, // works in tiles
			thumbnail:Bitmap,
			mouse:MyVirtualMouse;
		
		public function Tutorial(dataStr:String, title:String, actionList:Array, area:Rectangle, thumb:BitmapData) {
			data = Base64.decodeToByteArray(dataStr);
			data.uncompress();
			this.title = title;
			this.actionList = actionList;
			this.area = area;
			this.view = new Rectangle(area.x, area.y, area.width, area.height);
			this.thumbnail = new Bitmap(thumb);
		}
		
		public function getGame():GameState {
			var game:GameState = new GameState(data, 0, mouse);
			var X:int = view.x * GameState.cellWidth + GameState.getGridXOffset();
			var Y:int = view.y * GameState.cellWidth + GameState.getGridYOffset();
			var W:int = view.width * GameState.cellWidth;
			var H:int = view.height * GameState.cellWidth;
			game.scrollRect = new Rectangle(X, Y, W, H);
			game.mouseEnabled = false;
			game.mouseChildren = false;
			game.disableUndo();
			game.x = (640 - W) / 2;
			game.y = (640 - H) / 2;
			return game; 
		}
		
		public function getBorder():TutorialBorder {
			return new TutorialBorder(GameState.cellWidth * view.width + 18, GameState.cellWidth * view.height + 18);
		}
		
		public function getThumbnail():Bitmap {
			return thumbnail;
		}
		
		public function getTitle():String {
			return title;
		}
		
		public function addMouse(mouse:MyVirtualMouse):void {
			this.mouse = mouse;
			if (mouse != null)
				mouse.tutorial = this;
		}
		
		private function removeMouse():void {
			if (mouse != null) {
				mouse.tutorial = null;
				mouse.game = null;
			}
			mouse = null;
			
		}
		
		private var tutoState:TutorialState;
		public function startRunning(tutoState:TutorialState):void {
			this.tutoState = tutoState;
			addEventListener(MyVirtualMouse.NOT_BUSY, loop);
			loop(null);
		}
		
		
		public function stopRunning():void {
			reset();
			if (hasEventListener(MyVirtualMouse.NOT_BUSY))
				removeEventListener(MyVirtualMouse.NOT_BUSY, loop);
		}
		
		private function reset():void {
			index = 0;
			removeMouse();
			tutoState = null;
		}
		
		private var index:int = 0;
		private function loop(e:Event):void {
			if (mouse == null)
				return;
			var oi:int = index;
			if (++index >= actionList.length)
				index = 0;
			switch (actionList[oi][0]) {
				case "d" : 
					mouse.movePointLikeBlock(actionList[oi][1], actionList[oi][2]);
					break;
				case "m" :
					mouse.moveToPoint(actionList[oi][1], actionList[oi][2]);
					break;
				case "w" :
					mouse.wait(actionList[oi][1]);
					break;
				case "c" :
					mouse.clickAction();
					break;
				case "mc" :
					mouse.moveToPointAndClick(actionList[oi][1], actionList[oi][2]);
					break;
				case "r" :
					mouse.reset();
					break;
				case "u" :
					mouse.allowUndo();
					break;
				case "t" :
					tutoState.changeText(actionList[oi][1]);
					break;
				case "v" :
					view = new Rectangle(actionList[oi][1], actionList[oi][2], actionList[oi][3], actionList[oi][4]);
					break;
			}
		}
	}
}