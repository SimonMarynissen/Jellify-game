package states {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class CreditsState extends BackState {
		
		private var scrollScreen:Sprite;
		
		override public function startUp(e:Event):void {
			scrollScreen = new Sprite();
			super.startUp(e);
			var gameBy:TextField = J.newCentreTextField(16, 64, "A game by");
			
			var split:int = 48;
			var simonM:TextField = J.newLeftTextField(split, gameBy.y + 64, 48, "SimonM");
			var and:TextField = J.newCentreTextField(gameBy.y + 64, 48, "&");
			var treazer:TextField = J.newRightTextField(split, gameBy.y + 64, 48, "Treazer");
			
			split = 16;
			var inline:int = 16;
			var programming:TextField = J.newLeftTextField(split, simonM.y + 96, 24, "Programming");
			var simonM2:TextField = J.newRightTextField(split, simonM.y + 96, 24, "SimonM");
			var graphic:TextField = J.newLeftTextField(split, simonM2.y + simonM2.height + inline, 24, "Graphics");
			var treazer2:TextField = J.newRightTextField(split, simonM2.y + simonM2.height + inline, 24, "Treazer");
			var additionalGraphics:TextField = J.newLeftTextField(split, graphic.y + graphic.height + inline, 24, "Additional Graphics");
			var simonM3:TextField = J.newRightTextField(split, graphic.y + graphic.height + inline, 24, "SimonM");
			var music:TextField = J.newLeftTextField(split, simonM3.y + simonM3.height + inline, 24, "Music");
			var geckojsc:TextField = J.newRightTextField(split, simonM3.y + simonM3.height + inline, 24, "geckojsc");
			var	mainTesters:TextField = J.newLeftTextField(split, music.y + music.height + inline, 24, "Main Testers");
			var mainTesterNames:TextField = J.newRightTextField(split, music.y + music.height + inline, 24, "gameinsky, SuperDog");
			var	alphaTesters:TextField = J.newLeftTextField(split, mainTesterNames.y + mainTesterNames.height + inline, 24, "Alpha Testers");
			var alphaTesterNames:TextField = J.newRightTextField(split, mainTesterNames.y + mainTesterNames.height + inline, 24, "azz, chris3000, Dynamo,\nElizea, gundu, kiethy342,\nMatthijsM");
			var	betaTesters:TextField = J.newLeftTextField(split, alphaTesterNames.y + alphaTesterNames.height + inline, 24, "Beta Testers");
			var betaTesterNames:TextField = J.newRightTextField(split, alphaTesterNames.y + alphaTesterNames.height + inline, 24, "CamoDragoon, gamma73,\nlmr, nelson90, oldmanrob,\noldmtnguy, Toughman");
			scrollScreen.addChild(gameBy);
			scrollScreen.addChild(simonM);
			scrollScreen.addChild(and);
			scrollScreen.addChild(treazer);
			scrollScreen.addChild(programming);
			scrollScreen.addChild(simonM2);
			scrollScreen.addChild(graphic);
			scrollScreen.addChild(treazer2);
			scrollScreen.addChild(additionalGraphics);
			scrollScreen.addChild(simonM3);
			scrollScreen.addChild(music);
			scrollScreen.addChild(geckojsc);
			scrollScreen.addChild(mainTesters);
			scrollScreen.addChild(mainTesterNames);
			scrollScreen.addChild(alphaTesters);
			scrollScreen.addChild(alphaTesterNames);
			scrollScreen.addChild(betaTesters);
			scrollScreen.addChild(betaTesterNames);
			addChild(scrollScreen);
		}
	}
}