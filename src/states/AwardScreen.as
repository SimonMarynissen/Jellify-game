package states {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import gui.Button;

	public class AwardScreen extends Sprite {
		
		[Embed(source = "../../assets/awards/award icon.png")] private static const ICON:Class;
		[Embed(source = "../../assets/awards/award name.png")] private static const NAME:Class;
		[Embed(source = "../../assets/awards/award screen.png")] private static const SCREEN:Class;
		[Embed(source="../../assets/awards/getyourawardbutton.png")] private static const BUTTON:Class
		
		private static const
			BUTTON_BITMAPDATA:Array = [];
			
		private var
			panel:Bitmap,
			icon:Bitmap,
			nameImage:Bitmap,
			button:Button,
			score:int = 9001,
			ownLevelsCompleted:int,
			taskText:TextField,
			taskExplanationText:TextField,
			progressText:TextField,
			progressExplanationText:TextField,
			rewardText:TextField,
			rewardExplanationText:TextField;
		
		public static function initBitmapData():void {
			for (var i:int = 0; i < 4; i++) {
				(BUTTON_BITMAPDATA[i] = new BitmapData(567, 48, true, 0)).copyPixels(
					new BUTTON().bitmapData, new Rectangle(0, 48 * i, 567, 48),
					new Point(0, 0), null, null, true);
			}
		}
		
		public function AwardScreen(awardNumber:int, rest:Array) {
			panel = new Bitmap(new SCREEN().bitmapData);
			panel.x = 64;
			panel.y = 8;
			addChild(panel);
			icon = new Bitmap(new ICON().bitmapData);
			icon.x = 94;
			icon.y = 38;
			addChild(icon);
			nameImage = new Bitmap(new NAME().bitmapData);
			nameImage.x = 277;
			nameImage.y = 29;
			addChild(nameImage);
			button = new Button(BUTTON_BITMAPDATA);
			button.deactivate();
			button.x = 65;
			button.y = 584;
			ownLevelsCompleted = Main.ownLevelsCompleted();
			score = rest[2] - ownLevelsCompleted;
			if (score <= 0) {
				button.activate();
				button.addEventListener(MouseEvent.CLICK, onGetAward);
			}
			addChild(button);
			taskText = J.newRightTextField(-240, 185, 32, "Task:", 0xFFFFFF);
			addChild(taskText);
			taskExplanationText = J.newRightTextField(-224, 214, 40, "Create an approved level and score on it.", 0xFFFFFF);
			taskExplanationText.wordWrap = true;
			taskExplanationText.width = 505;
			addChild(taskExplanationText);
			progressText = J.newRightTextField(-240, 320, 32, "Progress:", 0xFFFFFF);
			addChild(progressText);
			progressExplanationText = J.newRightTextField(-224, 349, 40, "You scored on " + String(ownLevelsCompleted) + " level" + ((ownLevelsCompleted == 1) ? "" : "s") + " by yourself. " + String(Math.max(score, 0)) + " to go!", 0xFFFFFF);
			progressExplanationText.wordWrap = true;
			progressExplanationText.width = 505;
			addChild(progressExplanationText);
			rewardText = J.newRightTextField(-240, 457, 32, "Reward:", 0xFFFFFF);
			addChild(rewardText);
			rewardExplanationText = J.newRightTextField(-224, 486, 40, "25 Experience", 0xFFFFFF);
			rewardExplanationText.wordWrap = true;
			rewardExplanationText.width = 505;
			addChild(rewardExplanationText);
		}
		
		private function onGetAward(e:MouseEvent):void {
			if (Main.isYourLevel() && Main.isAcceptedOrOfficial())
				Main.addLvlidToUserData(Main.getLvlid());
			if (!Main.isGreyOrRed()) {
				if (score <= 0)
					Main.BLManager.lvlCompleted(true, score);
			}
			else
				Main.BLManager.showInfo("You cannot score on a to be evaluated or rejected level.");
		}
	}
}