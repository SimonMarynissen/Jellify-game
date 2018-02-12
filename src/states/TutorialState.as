package states {
	
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import gui.Button;
	import gui.TutorialBorder;
	import gui.virtualMouse.Cursor;
	import gui.virtualMouse.MyVirtualMouse;
	
	public class TutorialState extends BackState {
		
		[Embed(source = "../../assets/img/listButton.png")] private static const LIST:Class;
		[Embed(source = "../../assets/img/tutorialButtonLeft.png")] private static const LEFT:Class;
		[Embed(source = "../../assets/img/tutorialButtonRight.png")] private static const RIGHT:Class;
		[Embed(source = "../../assets/tutorials/movement.png")] private static const MOVEMENT:Class;
		[Embed(source = "../../assets/tutorials/pushing.png")] private static const PUSHING:Class;
		[Embed(source = "../../assets/tutorials/walls.png")] private static const WALLS:Class;
		[Embed(source = "../../assets/tutorials/gravity.png")] private static const GRAVITY:Class;
		[Embed(source = "../../assets/tutorials/objective.png")] private static const OBJECTIVE:Class;
		[Embed(source = "../../assets/tutorials/greyBlocks.png")] private static const GREY_BLOCKS:Class;
		[Embed(source = "../../assets/tutorials/multipleShapes.png")] private static const MULTIPLE_SHAPES:Class;
		[Embed(source = "../../assets/tutorials/wallBlocks.png")] private static const WALL_BLOCKS:Class;
		[Embed(source = "../../assets/tutorials/immobileBlocks.png")] private static const IMMOBILE_BLOCKS:Class;
		[Embed(source = "../../assets/tutorials/lockedBlocks.png")] private static const LOCKED_BLOCKS:Class;
		[Embed(source = "../../assets/tutorials/hinges.png")] private static const HINGES:Class;
		[Embed(source = "../../assets/tutorials/colourChangers.png")] private static const COLOUR_CHANGERS:Class;
		[Embed(source = "../../assets/tutorials/bombs.png")] private static const BOMBS:Class;
		[Embed(source = "../../assets/tutorials/spikes.png")] private static const SPIKES:Class;
		[Embed(source = "../../assets/tutorials/freezers.png")] private static const FREEZERS:Class;
		[Embed(source = "../../assets/tutorials/defrosters.png")] private static const DEFROSTERS:Class;
		[Embed(source = "../../assets/tutorials/forceFields.png")] private static const FORCE_FIELDS:Class;
		[Embed(source = "../../assets/tutorials/forceFieldSplitting.png")] private static const FORCE_FIELD_SPLITTING:Class;
		[Embed(source = "../../assets/tutorials/moveCount.png")] private static const MOVE_COUNT:Class;
		[Embed(source = "../../assets/tutorials/chains.png")] private static const CHAINS:Class;
		
		private static const TILE_BITMAPDATA:Array = [];
		
		private static const
			LIST_BITMAPDATA:Array = [],
			LEFT_BITMAPDATA:Array = [],
			RIGHT_BITMAPDATA:Array = [];
		
		public static function initBitmapData():void {
			for (var i:int = 0; i < 4; i++) {
				(LEFT_BITMAPDATA[i] = new BitmapData(32, 64, true, 0)).copyPixels(
					new LEFT().bitmapData, new Rectangle(32 * i, 0, 32, 64),
					new Point(0, 0), null, null, true);
				(RIGHT_BITMAPDATA[i] = new BitmapData(32, 64, true, 0)).copyPixels(
					new RIGHT().bitmapData, new Rectangle(32 * i, 0, 32, 64),
					new Point(0, 0), null, null, true);
				if (i == 3)
					continue;
				(LIST_BITMAPDATA[i] = new BitmapData(48, 48, true, 0)).copyPixels(
					new LIST().bitmapData, new Rectangle(48 * i, 0, 48, 48),
					new Point(0, 0), null, null, true);
			}
			LIST_BITMAPDATA[3] = LIST_BITMAPDATA[1];
		}
		
		public static var
			tutorialList:Array/*Tutorial*/ = [
				new Tutorial("eNptzlEKwDAMAtDZ2qSyE/T+F13WIuxj+POQINGCErx0g60STFID7FpV/0cC64KT7ZBfphnV7vV3WAfdGEYYaUyjPnkA5NsC4g==",
					"Movement", [["t", "Click on a block and drag to move."], ["w", 0.3], ["m", 4, 2], ["d", 1, 0], ["m", 2, 1], ["d", 1, 0], ["m", 3, 2], ["d", 1, 0],["t", "You can only move left or right."], ["m", 3, 2], ["d", -1, 0], ["m", 3, 2], ["d", -1, 0], ["m", 5, 2], ["d", -1, 0]],
					new Rectangle(0, 0, 7, 4), new MOVEMENT().bitmapData),
				new Tutorial("eNptzlEKwDAMAtDZ2qSyE/T+F13WIuxj+POQINGCErx0g60STFID7FpV/0cC64KT7ZBfphnV7vV3WAfdGEYYaUyjPnkA5NsC4g==",
					"Pushing", [["t", "Moving blocks can push other blocks."], ["w", 0.3], ["m", 2,2], ["d", 1,0], ["m", 3,2], ["w", 0.3], ["d",1,0], ["m", 5,2], ["d",-1,0], ["m", 4,2], ["w", 0.3], ["d",-1,0], ["m", 3,2], ["w", 0.3], ["d",1,0]],
					new Rectangle(0, 0, 7, 4), new PUSHING().bitmapData),
				new Tutorial("eNptzMsNgDAMA1BSnI9hAiZg/w1JVVlwILk8WYl5G9Ow8TQMzEk43bDz6vh/58eAoxZCSKEECseL1E0ILoA0WDcnxmJ8GWJ1auoLwQUsAPUA3QUEOg==",
					"Walls", [["w", 0.3], ["m", 4, 3], ["w", 0.3], ["d", 1, 0], ["m", 5, 3], ["w", 0.3], ["d", 1, 0], ["m", 2, 3], ["d", 1, 0], ["m", 2, 3], ["d", 1, 0], ["m", 5, 3], ["d", -1, 0], ["m", 2, 3], ["d", -1, 0]],
					new Rectangle(0, 0, 7, 5), new WALLS().bitmapData),
				new Tutorial("eNptjDEOwCAQw5riK0QMzP3/R8uBupEsVqTYXba43MVNJgiHKH7nfK6rEI2RkK9nQ/xQIa1aOn1YIgGz",
					"Gravity", [["w", 0.3], ["m", 0,1], ["d", 1,0], ["m", 1,1], ["w", 0.3], ["d", 1,0], ["m", 2,4], ["d", 1,0], ["mc", 2,-2], ["mc", -2,2], ["mc", 2,-2], ["mc", 6,2], ["m", 2,0], ["d", 0,1], ["m", 4,1], ["d", 0,1], ["m", 4,2], ["w", 0.3], ["d", 0,1], ["mc", -2,2], ["mc", 2,-2], ["m", 0,3], ["d", 1,0], ["m", 1,3], ["w", 0.3], ["d", 1,0], ["mc", -2,2], ["mc", 2,6]],
					new Rectangle( -3, -3, 11, 11), new GRAVITY().bitmapData),
				new Tutorial("eNpty8ENgFAIA1CrBWwcwLj/ovIheJJeXoDqhgLcdIE7e0wGHnpy/Z/VWM8ugWBk0GSxzsGz4QMbMFHvnvyaNk2nvcpUAqE=",
					"Objective", [["t", "To win, all blocks of the same colour have to be merged."], ["w", 0.3], ["m", 2, 0], ["d", -1, 0], ["m", 0, 1], ["d", 1, 0], ["m", 1, 3], ["d", 1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 4, 5), new OBJECTIVE().bitmapData),
				new Tutorial("eNptzlEOgDAIA1Cr3aDxAMb7X1QG48/w89JQgh7IwEM3eHLkUAO89Eb8P6uxlr0wG9bwhgICEbDoJT2IomW6r83K1gf4ANDnArc=",
					"Grey blocks", [["t", "To win, you do not have to bring the grey blocks together."], ["w", 0.3], ["m", 4, 2], ["d", -1, 0], ["m", 0, 0], ["d", 1, 0], ["m", 1, 2], ["d", -1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 5, 4), new GREY_BLOCKS().bitmapData),
				new Tutorial("eNpFzlkKwDAIBNBoJ8tk6QX63ftfsUnDEAR5DIryNWZDYDM4AiJugNFw8ZkxDKur/E+m1o5joGx0oQlVoFAOspCEqOFErpOcjxQxi+Ok46R10jf74UCCf+3EBHY=0",
					"Multiple shapes", [["t", "When there are numbers to the side, you have to make that many shapes of that colour to win."], ["w", 0.3], ["m", 9,0], ["d", 1, 0], ["m", 10, 2], ["d",1, 0], ["m", 13, 1], ["d", -1, 0], ["w", 1], ["r"]],
					new Rectangle(8, 0, 9, 4), new MULTIPLE_SHAPES().bitmapData),
				new Tutorial("eNptzkEOgDAIBEDRBbp68AGe/f8XLTarMTGlYVIKLU8jDRM3wwwHEHDuBtDsE15xV3vKkRYevRe1f1YNrquBTUyxz3lPH9b7yRxf8YFVcISQKoXwdLWBEFJoAoUV7QJxBwTm",
					"Wall blocks", [["t", "Wall blocks are movable walls and will not merge like normal blocks."], ["w", 0.3], ["m", 0, 0], ["d", 1, 0], ["m", 1, 0], ["w", 0.3], ["d", 1, 0], ["m", 2, 1], ["d", 1, 0], ["m", 2,2], ["d", 1, 0], ["m", 2, 0], ["d", 1, 0], ["m", 3, 1], ["d", 1, 0], ["m", 3, 0], ["d", 1, 0], ["m", 4, 0], ["w", 0.3], ["d", 1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 6, 5), new WALL_BLOCKS().bitmapData),
				new Tutorial("eNpFykEOgDAMA0ECmxqrx/7/rySgCp/G0nqFMzg8g5NeQp8oDC7C7qM6aXWU6MPY0MZdeHP+HPQAZAcB6w==",
					"Immobile blocks", [["t", "Immobile blocks, the one with a hole in it, cannot move by themselves."], ["w", 0.3], ["m", 0, 2], ["d", 1, 0], ["w", 0.3], ["m", 1, 2], ["d", -1, 0], ["t", "They can be pushed by other blocks and are affected by gravity."], ["m", 3, 2], ["d", -1, 0], ["m", 2, 2], ["w", 0.3], ["d", 1, 0]],
					new Rectangle(0, 0, 5, 4), new IMMOBILE_BLOCKS().bitmapData),
				new Tutorial("eNptjlESADEEQ5dNaaYn6P0vuuj6a/w8JAa30AUPl0CRGgCH4OWO8b0yoWH0A9bgDbMBAXFZ8mpIu7Fq/pB1yMhcz/qh0NP7AfLNAvI=",
					"Locked blocks", [["t", "Locked blocks or blocks with screws cannot move. Blocks stuck on them cannot move either."], ["m", 4, 1], ["w", 0.3], ["d", -1, 0], ["m", 3, 1], ["w", 0.3], ["d", -1, 0], ["m", 2, 1], ["w", 0.3], ["d", -1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 5, 4), new LOCKED_BLOCKS().bitmapData),
				new Tutorial("eNptjksWgCAMA60On8gJXHr/Q2qr8HBh2cwLSVqdpmIsasYKVDIoGZsOl/+fZBhyc4qcOYgWqSXKNi6faYu/EvVif6E6KCBTP7EOK8nlpxh2N9ur+nUD2vB1yAPKgDqXthsgDwhY",
					"Hinges", [["t", "Hinges are on the side of walls or wall blocks."], ["m", 5,0], ["w", 0.3], ["d", -1,0], ["m", 4,1], ["w", 0.3], ["d", -1,0], ["m", 4,0], ["w", 0.3], ["t", "Shapes hinged onto walls cannot move."], ["d", -1,0], ["m", 3,1], ["w", 0.3], ["d", -1,0], ["m", 2,2], ["w", 0.3], ["d", -1,0], ["t", "Blocks hinged onto a wall block can be dragged and pushed."], ["m", 2,2], ["w", 0.3], ["d", 1,0], ["w", 1.5], ["r"]],
					new Rectangle(0, 0, 6, 4), new HINGES().bitmapData),
				new Tutorial("eNptjEESgDAIAxsNpdEX9P8PVdrKwVG47IQl6pCDRSe4kbTYKgN39Yj/VwIxZU+sgb4qNLItjho9j1x4xRApHQssoQbMNw/4vNmSWkrt1T2VwpbdfgM5Og+V",
					"Colour Changers", [["t", "Colour changers are on the side of walls or wall blocks. If a block stops next to a colour changer, it changes its colour."], ["m", 0,1], ["w", 0.3], ["d", 1,0], ["m", 1,3], ["w", 0.3], ["d", 1,0], ["m", 1,3], ["w", 0.3], ["d", 1,0], ["m", 2,4], ["t", "If a block happens to touch two different colour changers at the same time, it will remain its current colour."], ["w", 0.3], ["d", 1,0], ["m", 3,4], ["w", 0.3], ["d", -1,0], ["m", 2,4], ["w", 0.3], ["d", 1,0], ["m", 3,4], ["w", 0.3], ["d", -1,0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 5, 6), new COLOUR_CHANGERS().bitmapData),
				new Tutorial("eNptjFEKwDAIQ2sba0MPsI/d/5ybGQj9mCI8TSIvIw2N29ChcoDD4HTD4J0aND+tYE9/yNoY2hqeLH0zLEzsQ5NSjEx9MAuiYCVQeaTohV7oJ+b9BUhPCz4=",
					"Bombs", [["t", "Bombs are on the side of walls or wall blocks. A bomb destroys 1 block if the block stops next to the bomb."], ["m", 1, 1], ["w", 0.3], ["d", 1, 0], ["m", 4, 2], ["w", 0.3], ["d", -1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 5, 4), new BOMBS().bitmapData),
				new Tutorial("eNp1zlESgCAIBFCJFdrxCH13/ysGFjl9NP680V2Bp5CCxiHYoAA6jCro7ALlEW9/J4sRnI1JW/TJkdTgyN8aXWLAgy0ydgMFLRj2unnBCj/oBSv4wl7w3Cfr/l3hAjkaBIY=",
					"Spikes", [["t", "Spikes are on the side of walls or wall blocks. Spikes splits shapes into single blocks."], ["m", 4, 1], ["w", 0.3], ["d", -1, 0], ["m", 1, 1], ["w", 0.3], ["d", 1, 0], ["m", 3, 3], ["w", 0.3], ["d", -1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 5, 6), new SPIKES().bitmapData),
				new Tutorial("eNp1jlEOgDAIQ2WUsc4D+OH9z6kw3KeQkBdKG3gJKTh4ChoUgMGoEsMEyju0v6aXZ2RCC+tIz1pb6E9UnVgoC/oGL1MeOubGvrEv/OKtdvnbfAFVIwcS",
					"Freezers", [["t", "Freezers are on the side of walls or wall blocks. Frozen blocks will not merge with other blocks"], ["m", 2, 2], ["w", 0.3], ["d", -1, 0], ["m", 0, 0], ["w", 0.3], ["d", 1, 0], ["m", 1, 1], ["w", 0.3], ["d", 1, 0], ["m", 2, 1], ["w", 0.3], ["d", 1, 0], ["m", 3, 3], ["w", 0.3], ["d", -1, 0], ["m", 2, 3], ["w", 0.3], ["d", -1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 5, 5), new FREEZERS().bitmapData),
				new Tutorial("eNp1zUsOgDAIRdFiH5+XLsCB+1+ngg0DB5bJSS6kPIUUDC7BgQmFAZwCpQomr2x/Uze5A8eq5UHPM0iH+ATDnS/NaprNN+2l7+9jAw1tWMMbgXgAfGMHWA==",
					"Defrosters", [["t", "Defrosters are on the side of walls or wall blocks. Defrosters revert the effect of freezers."], ["m", 2, 2], ["w", 0.3], ["d", -1, 0], ["m", 2, 2], ["w", 0.3], ["d", 1, 0], ["m", 3, 2], ["w", 0.3], ["d", 1, 0], ["m", 3, 2], ["w", 0.3], ["d", -1, 0], ["m", 0, 2], ["w", 0.3], ["d", 1, 0], ["t", "If a shape has a freezer and defroster next to it, it will not change status."], ["m", 5, 2], ["w", 0.3], ["d", -1, 0], ["m", 1, 2], ["w", 0.3], ["d", -1, 0], ["m", 4, 2], ["w", 0.3], ["d", 1, 0]],
					new Rectangle(0, 0, 6, 4), new DEFROSTERS().bitmapData),
				new Tutorial("eNp1jbESgDAMQsWSppyDk5P//53K2WY0DHlHjqALErjpAHeSYVENDAXYdPv2J+XMjAlR0AuyYBjcAjvppwt7ueNzT/f5iUN8PGu9GrkKyg==",
					"Force fields", [["t", "Force fields obstruct blocks of the same colour."], ["m", 3, 2], ["w", 0.3], ["d", -1, 0], ["m", 3, 1], ["w", 0.3], ["d", -1, 0], ["m", 2, 1], ["w", 0.3], ["d", -1, 0], ["m", 1, 1], ["w", 0.3], ["d", -1, 0], ["m", 0, 2], ["w", 0.3], ["d", 1, 0], ["m", 2, 2], ["w", 0.3], ["d", 1, 0], ["m", 1, 2], ["w", 0.3], ["d", 1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 5, 4), new FORCE_FIELDS().bitmapData),
				new Tutorial("eNp9j9ENhDAMQy/gpDX3wQDMwP7jgUsJh5C4Rq2e4ih2uRpp+PBrGAC4KjganG4YuUh7K86aQKDobjq/pyv+R3n2ZVp6gtrBE0KghKZlLdqBccdILM0vsXXPfG9eASZMaTpljAuY0glVcCyucunrnt8rqdzkHfP8TWE=",
					"Force field splitting", [["t", "Force fields can also split shapes."], ["m", 3, 0], ["w", 0.3], ["d", -1, 0], ["m", 2, 2], ["w", 0.3], ["d", -1, 0],["t", "When a shape falls on a splitting force field, it has to slice the whole length."], ["m", 2, 1], ["w", 0.3], ["d", 1, 0], ["m", 3, 1], ["w", 0.3], ["d", 1, 0], ["w", 2], ["r"]],
					new Rectangle(0, 0, 5, 6), new FORCE_FIELD_SPLITTING().bitmapData),
				new Tutorial("eNp1jUEOgEAMAsUFd4knz/7/n6JNj2YuQxuCL9jg5hPcSSrQA5QFDt/5/eFZnVWilqNltqxIBpDLCyvoC3oAmYsCWw==",
					"Move Count", [["t", "When a block has a number, you can only actively move it that amount."], ["m", 1, 2], ["w", 0.3], ["d", -1, 0], ["m", 0, 2], ["w", 0.3], ["d", 1, 0], ["m", 1, 2], ["w", 0.3], ["d", 1, 0], ["t", "It can still be pushed or dragged by other blocks."], ["m", 3, 2], ["w", 0.3], ["d", 1, 0], ["m", 4, 2], ["w", 0.3], ["d", -1, 0], ["w", 1.5], ["r"]],
					new Rectangle(0, 0, 5, 4), new MOVE_COUNT().bitmapData),
				new Tutorial("eNptjMENgDAMAwk4TR3EAEzA/hsSKO4L5XOK7eNlpGHhbljhABqCbnAeBtaHCGxVqN/Gs6r/x3gEHX0AC8pr73yil/aNA21AE4SWjlSUilL2lP2DBAQuaIIumOW4ATe+BMA=",
					"Chains", [["t", "Chains are fixed connections between blocks. Their relative position will remain the same. Moving one block will move the other block."], ["m", 4, 1], ["w", 0.3], ["d", -1, 0], ["m", 3, 1], ["w", 0.3], ["d", -1, 0], ["m", 2, 3], ["w", 0.3], ["d", -1, 0], ["m", 1, 3], ["w", 0.3], ["d", -1, 0], ["m", 0, 3], ["w", 0.6], ["d", 1, 0], ["m", 1, 3], ["w", 0.3], ["d", 1, 0], ["t", "If one block is obstructed by a wall or the like, the other block cannot move either."], ["m", 2, 3], ["w", 0.3], ["d", 1, 0], ["m", 3, 5], ["w", 0.3], ["d", 1, 0], ["m", 4, 5], ["w", 0.3], ["d", 1, 0], ["w", 1], ["r"]],
					new Rectangle(0, 0, 6, 7), new CHAINS().bitmapData)
			];
		
		private var
			virtualMouse:MyVirtualMouse,
			useHand:Boolean,
			listButton:Button,
			previousButton:Button,
			nextButton:Button,
			tuto:Tutorial,
			game:GameState,
			index:int,
			tutoBorder:TutorialBorder,
			tutoText:TextField,
			tutoTitle:TextField,
			cursor:Cursor;
			
		public function TutorialState(index:int = -1) {
			if (index == -1) {
				// lastly seen tutorial
				index = 0;
			}
			this.index = index;
			tuto = tutorialList[index];
			cursor = new Cursor();
			addEventListener(Event.ADDED_TO_STAGE, startUp);
		}
		
		override public function startUp(e:Event):void {
			super.startUp(e);
			listButton = new Button(LIST_BITMAPDATA);
			listButton.x = 584;
			listButton.y = 8;
			listButton.activate();
			listButton.addEventListener(MouseEvent.CLICK, toList);
			addChild(listButton);
			
			previousButton = new Button(LEFT_BITMAPDATA);
			previousButton.x = 8;
			previousButton.y = 288;
			previousButton.activate();
			previousButton.addEventListener(MouseEvent.CLICK, previousTutorial);
			previousButton.activate();
			addChild(previousButton);
			
			nextButton = new Button(RIGHT_BITMAPDATA);
			nextButton.x = 600;
			nextButton.y = 288;
			nextButton.y = 288;
			nextButton.activate();
			nextButton.addEventListener(MouseEvent.CLICK, nextTutorial);
			addChild(nextButton);
			
			virtualMouse = new MyVirtualMouse(stage, 320, 320);
			tuto.addMouse(virtualMouse);
			game = tuto.getGame();
			addChild(game);
			tutoBorder = tuto.getBorder();
			addChild(tutoBorder);
			addChild(cursor);
			
			tutoTitle = new TextField();
			J.makeTextFieldReady(tutoTitle, 48, tuto.getTitle());
			tutoTitle.x = (640 - tutoTitle.width) / 2;
			tutoTitle.y = game.y - 64;
			addChild(tutoTitle);
			
			tutoText = new TextField();
			J.makeTextFieldReady(tutoText, 24 , "");
			tutoText.autoSize = TextFieldAutoSize.NONE;
			tutoText.wordWrap = true;
			tutoText.width = Math.max(18 + game.scrollRect.width, 320);
			tutoText.height = 300;
			tutoText.x = (640 - tutoText.width) / 2;
			tutoText.y = game.y + game.scrollRect.height + 16;
			addChild(tutoText);
			tuto.startRunning(this);
			addEventListener(Event.ENTER_FRAME, everyFrame);
		}
		
		override public function terminate():void {
			super.terminate();
			tuto.stopRunning();
			game.terminate();
			game = null;
			removeEventListener(Event.ENTER_FRAME, everyFrame);
			listButton.removeEventListener(MouseEvent.CLICK, toList);
		}
		
		override public function everyFrame(e:Event):void {
			if (virtualMouse == null)
				return;
			if (!switching) {
				cursor.visible = true;
				var diffY:int = 16 * (tuto.view.y - game.gridHeight + tuto.view.y + tuto.view.height);
				var diffX:int = 16 * (tuto.view.x - game.gridWidth + tuto.view.x + tuto.view.width);
				cursor.x = virtualMouse.location.x - diffX;
				cursor.y = virtualMouse.location.y - diffY;
				if (useHand != virtualMouse.useHandCursor) {
					useHand = virtualMouse.useHandCursor;
					if (useHand)
						cursor.toOver();
					else
						cursor.toNormal();
				}
			} else
				cursor.visible = false;
		}
		
		public function changeText(text:String):void {
			virtualMouse.busy = true;
			if (tutoText.text == text) {
				virtualMouse.busy = false;
				return;
			}
			if (tutoText.text != "") {
				Tweener.addTween(tutoText, {alpha:0, time:0.5, transition:"easeInQuad", onComplete:function():void {
					tutoText.text = text;
					Tweener.addTween(tutoText, {alpha:1, time:0.5, transition:"easeInQuad", onComplete:function():void {
						virtualMouse.busy = false;
					}});
				}});
			} else {
				tutoText.text = text;
				Tweener.addTween(tutoText, {alpha:1, time:1, transition:"easeInQuad", onComplete:function():void {
					virtualMouse.busy = false;
				}});
			}
		}
		
		private function toList(e:Event):void {
			Main.BLManager.theroot.switchState(new TutorialListState());
		}
		
		private var switching:Boolean = false;
		private function previousTutorial(e:Event):void {
			switching = true;
			cursor.visible = false;
			previousButton.deactivate();
			previousButton.removeEventListener(MouseEvent.CLICK, previousTutorial);
			nextButton.deactivate();
			nextButton.removeEventListener(MouseEvent.CLICK, nextTutorial);
			tuto.stopRunning();
			game.removeMouse();
			if (--index < 0)
				index = tutorialList.length - 1;
			tuto = tutorialList[index];
			tuto.addMouse(virtualMouse);
			var game2:GameState = tuto.getGame();
			var targetY:int = game2.y;
			var targetY2:int = game2.y + game2.scrollRect.height;
			Tweener.addTween(tutoTitle, {alpha:0, time:0.5, transition:"easeInQuad", onComplete:function():void {
				tutoTitle.text = tuto.getTitle();
				tutoTitle.x = (640 - tutoTitle.width) / 2;
				tutoTitle.y = targetY - 64;
				Tweener.addTween(tutoTitle, {alpha:1, time:0.5, transition:"easeInQuad"});
			}});
			Tweener.addTween(tutoText, {alpha:0, time:0.5, transition:"easeInQuad", onComplete:function():void {
				tutoText.text = "";
				tutoText.x = (640 - tutoText.width) / 2;
				tutoText.y = targetY2 + 16;
			}});
			game2.x -= 640;
			var diff:int = game.x - game2.x;
			addChild(game2);
			var tutoBorder2:TutorialBorder = tuto.getBorder();
			tutoBorder2.x -= 640;
			addChild(tutoBorder2);
			addChild(cursor);
			var thisState:TutorialState = this;
			Tweener.addTween(game, {x:game.x + 640, time:1, transition:"easeInQuad", onUpdate:function():void {
					game2.x = game.x - diff;
					tutoBorder.x = game.x - 9;
					tutoBorder2.x = game2.x - 9;
				}, onComplete:function():void {
					removeChild(game);
					game = game2;
					removeChild(tutoBorder);
					tutoBorder = tutoBorder2;
					virtualMouse.setToCenter();
					virtualMouse.moveToCenterAndStart(thisState);
					previousButton.addEventListener(MouseEvent.CLICK, previousTutorial);
					previousButton.activate();
					nextButton.addEventListener(MouseEvent.CLICK, nextTutorial);
					nextButton.activate();
					switching = false;
				}
			});
		}
		
		private function nextTutorial(e:Event):void {
			switching = true;
			cursor.visible = false;
			previousButton.deactivate();
			previousButton.removeEventListener(MouseEvent.CLICK, previousTutorial);
			nextButton.deactivate();
			nextButton.removeEventListener(MouseEvent.CLICK, nextTutorial);
			tuto.stopRunning();
			game.removeMouse();
			if (++index >= tutorialList.length)
				index = 0;
			tuto = tutorialList[index];
			tuto.addMouse(virtualMouse);
			var game2:GameState = tuto.getGame();
			var targetY:int = game2.y;
			var targetY2:int = game2.y + game2.scrollRect.height;
			Tweener.addTween(tutoTitle, {alpha:0, time:0.5, transition:"easeInQuad", onComplete:function():void {
				tutoTitle.text = tuto.getTitle();
				tutoTitle.x = (640 - tutoTitle.width) / 2;
				tutoTitle.y = targetY - 64;
				Tweener.addTween(tutoTitle, {alpha:1, time:0.5, transition:"easeInQuad"});
			}});
			Tweener.addTween(tutoText, {alpha:0, time:0.5, transition:"easeInQuad", onComplete:function():void {
				tutoText.text = "";
				tutoText.x = (640 - tutoText.width) / 2;
				tutoText.y = targetY2 + 16;
			}});
			game2.x += 640;
			var diff:int = game2.x - game.x;
			addChild(game2);
			var tutoBorder2:TutorialBorder = tuto.getBorder();
			tutoBorder2.x += 640;
			addChild(tutoBorder2);
			addChild(cursor);
			var thisState:TutorialState = this;
			Tweener.addTween(game, {x:(game.x - 640), time:1, transition:"easeInQuad", onUpdate:function():void {
					game2.x = game.x + diff;
					tutoBorder.x = game.x - 9;
					tutoBorder2.x = game2.x - 9;
				}, onComplete:function():void {
					removeChild(game);
					game = game2;
					removeChild(tutoBorder);
					tutoBorder = tutoBorder2;
					virtualMouse.setToCenter();
					virtualMouse.moveToCenterAndStart(thisState);
					previousButton.addEventListener(MouseEvent.CLICK, previousTutorial);
					previousButton.activate();
					nextButton.addEventListener(MouseEvent.CLICK, nextTutorial);
					nextButton.activate();
					switching = false;
				}
			});
		}
	}
}