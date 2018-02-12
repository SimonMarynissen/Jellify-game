package states {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import gui.TutorialBorder;
	
	public class TutorialListState extends BackState {
		
		private var
			tiles:Array/*Sprite*/ = [],
			texts:Array/*TextField*/ = [];
		
		override public function startUp(e:Event):void {
			super.startUp(e);
			for (var i:int = 0; i < TutorialState.tutorialList.length; i++) {
				var text:TextField = new TextField();
				text.wordWrap = true;
				text.width = 120;
				J.makeTextFieldReady(text, 16, TutorialState.tutorialList[i].getTitle());
				text.x = 35 + (i % 5) * 122 + (84 - text.width)/2;
				text.y = 65 + Math.floor(i / 5) * 130 - 10 * (text.numLines - 1);
				addChild(text);
				texts[i] = text;
				var spr:Sprite = new Sprite();
				spr.x = 44 + (i % 5) * 122;
				spr.y = 100 + Math.floor(i / 5) * 130;
				spr.addChild(TutorialState.tutorialList[i].getThumbnail());
				var border:TutorialBorder = new TutorialBorder(82, 82);
				border.x = -9;
				border.y = -9;
				spr.addChild(border);
				spr.buttonMode = true;
				spr.addEventListener(MouseEvent.CLICK, clickOnTile);
				addChild(spr);
				tiles[i] = spr;
			}
		}
		
		override public function backToTitle(e:Event):void {
			Main.BLManager.theroot.switchState(new TutorialState());
		}
		
		override public function terminate():void {
			super.terminate();
			for (var i:int = 0; i < tiles.length; i++)
				tiles[i].removeEventListener(MouseEvent.CLICK, clickOnTile);
		}
		
		private function clickOnTile(e:Event):void {
			var index:int = tiles.indexOf(e.currentTarget);
			if (index != -1)
				Main.BLManager.theroot.switchState(new TutorialState(index));
		}
	}
}