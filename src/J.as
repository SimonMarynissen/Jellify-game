package {
	
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import tiles.wallAttachments.*;

	public class J {
		
		/*[Embed(source = "../assets/font/Bender_Inline.ttf", fontName = "bender_inline",
			mimeType = "application/x-font", advancedAntiAliasing = "true",
			embedAsCFF = "false")] private static const BENDER_INLINE:Class;
		[Embed(source = "../assets/font/Bender_Thin.ttf", fontName = "bender_thin",
			mimeType = "application/x-font", advancedAntiAliasing = "true",
			embedAsCFF = "false")] private static const BENDER_THIN:Class;*/
		[Embed(source = "../assets/font/Bender_Solid.ttf", fontName = "bender_solid",
			mimeType = "application/x-font", advancedAntiAliasing = "true",
			embedAsCFF = "false")] private static const BENDER_SOLID:Class;
		
		public static const NO_COLOUR:int = -1;
		public static const WALL_BLOCK_COLOUR:int = 11;
		
		public static function getXDir(index:int):int {
			if (index == 1)
				return -1;
			else if (index == 2)
				return  1;
			else
				return 0;
		}
		
		public static function getYDir(index:int):int {
			if (index == 0)
				return -1;
			else if (index == 3)
				return  1;
			else
				return 0;
		}
		
		public static function getIndexFrom(xDir:int, yDir:int):int {
			if (xDir == 0 && yDir == -1)
				return 0;
			if (xDir == -1 && yDir == 0)
				return 1;
			if (xDir == 1 && yDir == 0)
				return 2;
			if (xDir == 0 && yDir == 1)
				return 3;
			return 4;
		}
		
		public static function getStringFrom(xDir:int, yDir:int):String {
			if (xDir == 0 && yDir == -1)
				return "u";
			if (xDir == -1 && yDir == 0)
				return "l";
			if (xDir == 1 && yDir == 0)
				return "r";
			if (xDir == 0 && yDir == 1)
				return "d";
			return "n";
		}
		
		public static function getOppossiteIndices(index:int):Array {
			if (index == 0 || index == 3)
				return [1, 2];
			else if (index == 1 || index == 2)
				return [0, 3];
			else return [index, index];
		}
		
		public static function getOppositeDirections(index:int):Array {
			if (index == 0 || index == 3)
				return [[-1, 0], [1, 0]];
			else if (index == 1 || index == 2)
				return [[0, -1], [0, 1]]
			else return [[0, 0], [0, 0]];
		}
		
		public static function getWallAttachments(data:Array):Array {
			var attachments:Array = new Array();
			for (var i:int = 1; i < data.length; i++) {
				if (data[i][0] == 1)
					attachments.push(new ColourChanger(data[i][1], data[i][2], data[i][3]));
				else if (data[i][0] == 2)
					attachments.push(new Bomb(data[i][1], data[i][2]));
				else if (data[i][0] == 3)
					attachments.push(new Hinge(data[i][1], data[i][2]));
				else if (data[i][0] == 4)
					attachments.push(new Spike(data[i][1], data[i][2]));
				else if (data[i][0] == 5)
					attachments.push(new Freezer(data[i][1], data[i][2]));
				else if (data[i][0] == 6)
					attachments.push(new Defroster(data[i][1], data[i][2]));
			}
			return attachments;
		}
		
		public static function isAttachmentAfterJellify(attachment:WallAttachment):Boolean {
			return (attachment is Spike) || (attachment is ColourChanger) || (attachment is Freezer) || (attachment is Defroster);
		}
		
		public static function easeFast(t:Number, b:Number, c:Number, d:Number, p_params:Object = null):Number {
			var ts:Number=(t/=d)*t;
			var tc:Number=ts*t;
			return b+c*(12.745*tc*ts + -42.2325*ts*ts + 53.68*tc + -32.49*ts + 9.2975*t);
		}
		
		public static function makeTextFieldReady(tf:TextField, size:int, text:String, colour:int = 0XFFFFFF):void {
			var format:TextFormat = new TextFormat("bender_solid", size, colour);
			format.align = TextFormatAlign.CENTER;
			format.kerning = true;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.defaultTextFormat = format;
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.text = text;
			tf.selectable = false;
		}
		
		public static function makeLeftTextFieldReady(tf:TextField, size:int, text:String, colour:int = 0XFFFFFF):void {
			var format:TextFormat = new TextFormat("bender_solid", size, colour);
			format.align = TextFormatAlign.RIGHT;
			format.kerning = true;
			tf.autoSize = TextFieldAutoSize.RIGHT;
			tf.defaultTextFormat = format;
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.text = text;
			tf.selectable = false;
		}
		
		public static function makeRightTextFieldReady(tf:TextField, size:int, text:String, colour:int = 0XFFFFFF):void {
			var format:TextFormat = new TextFormat("bender_solid", size, colour);
			format.align = TextFormatAlign.LEFT;
			format.kerning = true;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.defaultTextFormat = format;
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.text = text;
			tf.selectable = false;
		}
		
		public static function newCentreTextField(y:int, size:int, text:String, colour:int = 0xFFFFFF):TextField {
			var tf:TextField = new TextField();
			J.makeTextFieldReady(tf, size, text, colour);
			tf.x = (640 - tf.width) / 2;
			tf.y = y;
			return tf;
		}
		
		public static function newRightTextField(split:int, y:int, size:int, text:String, colour:int = 0xFFFFFF):TextField {
			var tf:TextField = new TextField();
			J.makeRightTextFieldReady(tf, size, text, colour);
			tf.x = 320 + split;
			tf.y = y;
			return tf;
		}
		
		public static function newLeftTextField(split:int , y:int, size:int, text:String, colour:int = 0xFFFFFF):TextField {
			var tf:TextField = new TextField();
			J.makeLeftTextFieldReady(tf, size, text, colour);
			tf.x = 320 - tf.width - split;
			tf.y = y;
			return tf;
		}
		
		public static function newInSquareTextField(x:int, y:int, w:int, h:int, size:int, text:String, colour:int = 0xFFFFFF):TextField {
			var tf:TextField = new TextField();
			tf.wordWrap = true;
			J.makeTextFieldReady(tf, size, text, colour);
			tf.x = x
			tf.y = y;
			tf.width = w;
			tf.y += (h - tf.textHeight) / 2 - 2;
			return tf;
		}
	}
}