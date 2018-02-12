package gui.virtualMouse {
	
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import states.GameState;
	import states.Tutorial;
	import states.TutorialState;
	
	[Event(name="update", type="flash.events.Event")]
	[Event(name="mouseLeave", type="flash.events.Event")]
	[Event(name="mouseMove", type="flash.events.MouseEvent")]
	[Event(name="mouseOut", type="flash.events.MouseEvent")]
	[Event(name="rollOut", type="flash.events.MouseEvent")]
	[Event(name="mouseOver", type="flash.events.MouseEvent")]
	[Event(name="rollOver", type="flash.events.MouseEvent")]
	[Event(name="mouseDown", type="flash.events.MouseEvent")]
	[Event(name="mouseUp", type="flash.events.MouseEvent")]
	[Event(name="click", type="flash.events.MouseEvent")]
	[Event(name="doubleClick", type="flash.events.MouseEvent")]
	
	public class MyVirtualMouse extends EventDispatcher {
		
		public static const
			NOT_BUSY:String = "NOT_BUSY",
			UPDATE:String = "UPDATE";
		
		public var
			tutorial:Tutorial,
			game:GameState;
		
		private var speed:int = 60;
		private var _busy:Boolean = false;
		
		
		
		private var altKey:Boolean = false;
		private var ctrlKey:Boolean = false;
		private var shiftKey:Boolean = false;
		private var delta:int = 0; // mouseWheel unsupported
		
		private var _stage:Stage;
		private var target:InteractiveObject;
		
		public var location:Point;
		public var useHandCursor:Boolean = false;
		
		private var isLocked:Boolean = false;
		private var isDoubleClickEvent:Boolean = false;
		private var _mouseIsDown:Boolean = false;
		
		private var disabledEvents:Object = new Object();
		private var ignoredInstances:Dictionary = new Dictionary(true);
		
		private var _lastEvent:Event;
		private var lastMouseDown:Boolean = false;
		private var lastLocation:Point;
		private var lastDownTarget:DisplayObject;
		private var lastWithinStage:Boolean = true;
			
		private var _useNativeEvents:Boolean = false;
		private var eventEvent:Class = VirtualMouseEvent;
		private var mouseEventEvent:Class = VirtualMouseMouseEvent;
		
		public function set busy(value:Boolean):void {
			_busy = value;
			if (!value && tutorial != null)
				tutorial.dispatchEvent(new Event(MyVirtualMouse.NOT_BUSY));
		}
		
		public function get stage():Stage {
			return _stage;
		}
		public function set stage(s:Stage):void {
			var hadStage:Boolean;
			if (_stage)
				hadStage = true;
			else
				hadStage = false;
			_stage = s;
			if (_stage) {
				target = _stage;
				if (!hadStage)
					update();
			}
		}
		
		/**
		 * The last event dispatched by the VirtualMouse
		 * instance.  This can be useful for preventing
		 * event recursion if performing VirtualMouse
		 * operations within MouseEvent handlers.
		 */
		public function get lastEvent():Event {
			return _lastEvent;
		}
		
		/**
		 * True if the virtual mouse is being
		 * pressed, false if not.  The mouse is
		 * down for the virtual mouse if press()
		 * was called.
		 * @see press()
		 * @see release()
		 */
		public function get mouseIsDown():Boolean {
			return _mouseIsDown;
		}
		
		/**
		 * The x location of the virtual mouse. If you are
		 * setting both the x and y properties of the
		 * virtual mouse at the same time, you would probably
		 * want to lock the VirtualMouse instance to prevent
		 * additional events from firing.
		 * @see lock
		 * @see unlock
		 * @see y
		 * @see setLocation()
		 * @see getLocation()
		 */
		public function get x():Number {
			return location.x;
		}
		public function set x(n:Number):void {
			location.x = n;
			if (!isLocked) update();
		}
		
		/**
		 * The y location of the virtual mouse.  If you are
		 * setting both the x and y properties of the
		 * virtual mouse at the same time, you would probably
		 * want to lock the VirtualMouse instance to prevent
		 * additional events from firing.
		 * @see lock
		 * @see unlock
		 * @see x
		 * @see setLocation()
		 * @see getLocation()
		 */
		public function get y():Number {
			return location.y;
		}
		public function set y(n:Number):void {
			location.y = n;
			if (!isLocked) update();
		}
		
		/**
		 * Determines if the events dispatched by the
		 * VirtualMouse instance are IVirualMouseEvent
		 * Events (wrapping Event and MouseEvent) or events
		 * of the native Event and MouseEvent type. When using
		 * non-native events, you can check to see if the
		 * events originated from VirtualMouse by seeing if
		 * the events are of the type IVirualMouseEvent.
		 * @see lastEvent
		 */
		public function get useNativeEvents():Boolean {
			return _useNativeEvents;
		}
		public function set useNativeEvents(b:Boolean):void {
			if (b == _useNativeEvents) return;
			_useNativeEvents = b;
			if (_useNativeEvents){
				eventEvent = VirtualMouseEvent;
				mouseEventEvent = VirtualMouseMouseEvent;
			}else{
				eventEvent = Event;
				mouseEventEvent = MouseEvent;
			}
		}
		
		public function MyVirtualMouse(stage:Stage=null, startX:Number=0, startY:Number=0) {
			this.stage = stage;
			location = new Point(startX, startY);
			lastLocation = location.clone();
			addEventListener(UPDATE, handleUpdate);
			update();
		}
		
		public function moveToPointAndClick(X:Number, Y:Number):void {
			busy = true;
			var x:int = tutorial.view.x * GameState.cellWidth + GameState.getGridXOffset();
            var y:int = tutorial.view.y * GameState.cellWidth + GameState.getGridYOffset();
			x += (X - tutorial.view.x) * GameState.cellWidth + 16;
			y += (Y - tutorial.view.y) * GameState.cellWidth + 16;
			var distance:Number = ((new Point(x, y)).subtract(getLocation())).length;
			var s:int = (speed/2) * (distance - 32) / 32;
			s = Math.max(0, s);
			s += speed;
			Tweener.addTween(this, {(location.x):x, time:(distance / s), transition:"linear"});
			Tweener.addTween(this, {(location.y):y, time:(distance / s), transition:"linear", onComplete:function():void {
				click();
				busy = false;
			}});
		}
		
		public function moveToCenterAndStart(tutoState:TutorialState):void {
			var centerX:Number = tutorial.view.x + (tutorial.view.width - 1) / 2.0;
			var centerY:Number = tutorial.view.y + (tutorial.view.height - 1) / 2.0;
			moveToPoint(centerX, centerY, true, tutoState);
		}
		
		public function setToCenter():void {
			var X:Number = tutorial.view.x + (tutorial.view.width - 1) / 2.0;
			var Y:Number = tutorial.view.y + (tutorial.view.height - 1) / 2.0;
			var x:int = tutorial.view.x * GameState.cellWidth + GameState.getGridXOffset();
            var y:int = tutorial.view.y * GameState.cellWidth + GameState.getGridYOffset();
			x += (X - tutorial.view.x) * GameState.cellWidth + 16;
			y += (Y - tutorial.view.y) * GameState.cellWidth + 16;
			lock();
			location.x = x;
			location.y = y;
			unlock();
		}
		
		public function clickAction():void {
			busy = true;
			click();
			busy = false;
		}
		
		public function moveToPoint(X:Number, Y:Number, start:Boolean = false, tutoState:TutorialState = null):void {
			busy = true;
			var x:int = tutorial.view.x * GameState.cellWidth + GameState.getGridXOffset();
            var y:int = tutorial.view.y * GameState.cellWidth + GameState.getGridYOffset();
			x += (X - tutorial.view.x) * GameState.cellWidth + 16;
			y += (Y - tutorial.view.y) * GameState.cellWidth + 16;
			var distance:Number = ((new Point(x, y)).subtract(getLocation())).length;
			var s:int = (speed/2) * (distance - 32) / 32;
			s = Math.max(0, s);
			s += speed;
			Tweener.addTween(this, {(location.x):x, time:(distance / s), transition:"linear"});
			Tweener.addTween(this, {(location.y):y, time:(distance / s), transition:"linear", onComplete:function():void {
				busy = false;
				if (start)
					tutorial.startRunning(tutoState);
			}});
		}
		
		public function downAndReleaseToPoint(X:Number, Y:Number):void {
			busy = true;
			this.press();
			this.press();
			var distance:Number = ((new Point(X, Y)).subtract(getLocation())).length;
			Tweener.addTween(this, {(location.x):X, time:(distance / speed), delay:0.2, transition:"linear"});
			Tweener.addTween(this, {(location.y):Y, time:(distance / speed), delay:0.2, transition:"linear", onComplete:function():void {
				this.release();
				busy = false;
			}});
		}
		
		public function movePointLikeBlock(xDir:int, yDir:int):void {
			downAndReleaseToPoint(location.x + 32 * xDir, location.y + 32 * yDir);
		}
		
		public function wait(t:Number):void {
			busy = true;
			Tweener.addTween(this, {time:t, onComplete:function():void {
				busy = false;
			}});
		}
		
		public function reset():void {
			busy = true;
			game.replayLevel(true);
			busy = false;
		}
		
		public function allowUndo():void {
			busy = true;
			game.allowUndo();
			busy = false;
		}
		
		public function getLocation():Point {
			return location.clone();
		}
		
		public function setLocation(a:Number, b:Number):void {
			location.x = a;
			location.y = b;
			if (!isLocked)
				update();
		}
		
		/**
		 * Locks the current VirtualMouse instance
		 * preventing updates from being made as 
		 * properties change within the instance.
		 * To release and allow an update, call unlock().
		 * @see lock()
		 * @see update()
		 */
		public function lock():void {
			isLocked = true;
		}
		
		/**
		 * Unlocks the current VirtualMouse instance
		 * allowing updates to be made for the
		 * dispatching of virtual mouse events. After
		 * unlocking the instance, it will update and
		 * additional calls to press(), release(), or
		 * changing the location of the virtual mouse
		 * will also invoke updates.
		 * @see lock()
		 * @see update()
		 */
		public function unlock():void {
			isLocked = false;
			update();
		}
		
		/**
		 * Allows you to disable an event by type
		 * preventing the virtual mouse from 
		 * dispatching that event during an update.
		 * @param type The type for the event to
		 * 		disable, e.g. MouseEvent.CLICK
		 * @see enableEvent()
		 */
		public function disableEvent(type:String):void {
			disabledEvents[type] = true;
		}
		
		/**
		 * Re-enables an event disabled with
		 * disableEvent.
		 * @param type The type for the event to
		 * 		enable, e.g. MouseEvent.CLICK
		 * @see disableEvent()
		 */
		public function enableEvent(type:String):void {
			if (type in disabledEvents) {
				delete disabledEvents[type];
			}
		}
		
		/**
		 * Ignores a display object preventing that
		 * object from recieving events from the
		 * virtual mouse.  This is useful for instances
		 * used for cursors which may always be under
		 * the virtual mouse's location.
		 * @param instance A reference to the
		 * 		DisplayObject instance to ignore.
		 * @see unignore()
		 */
		public function ignore(instance:DisplayObject):void {
			ignoredInstances[instance] = true;
		}
		
		/**
		 * Removes an instance from the ignore list
		 * defined by ignore().  When an ingored
		 * object is passed into unignore(), it will
		 * be able to receive events from the virtual
		 * mouse.
		 * @param instance A reference to the
		 * 		DisplayObject instance to unignore.
		 * @see ignore()
		 */
		public function unignore(instance:DisplayObject):void {
			if (instance in ignoredInstances){
				delete ignoredInstances[instance];
			}
		}
		
		public function press():void {
			if (_mouseIsDown)
				return;
			_mouseIsDown = true;
			if (!isLocked) {
				game.virtualMouseDown();
				update();
			}
		}
		
		public function release():void {
			if (!_mouseIsDown)
				return;
			_mouseIsDown = false;
			if (!isLocked) {
				game.virtualMouseUp();
				update();
			}
		}
		
		public function click():void {
			press();
			game.virtualMouseClick();
			release();
		}
		
		public function doubleClick():void {
			if (isLocked)
				release();
			else {
				click();
				press();
				isDoubleClickEvent = true;
				release();
				isDoubleClickEvent = false;
			}
		}
		
		private function update():void {
			dispatchEvent(new Event(UPDATE, false, false));
		}
		
		private function handleUpdate(event:Event):void {
			if (!game) return;
				
			// go through each objectsUnderPoint checking:
			// 		1) is not ignored
			//		2) is InteractiveObject
			//		3) mouseEnabled
			// 		4) all parents have mouseChildren
			// if not interactive object, defer interaction to next object in list
			// if is interactive and enabled, give interaction and ignore rest
			var objectsUnderPoint:Array = game.getObjectsUnderPoint(location);
			var currentTarget:InteractiveObject;
			var currentParent:DisplayObject;
			
			var i:int = objectsUnderPoint.length;
			while (i--) {
				currentParent = objectsUnderPoint[i];
				
				// go through parent hierarchy
				while (currentParent) {
					
					// don't use ignored instances as the target
					if (ignoredInstances[currentParent]) {
						currentTarget = null;
						break;
					}
					
					// invalid target if in a SimpleButton
					if (currentTarget && currentParent is SimpleButton) {
						currentTarget = null;
						
					// invalid target if a parent has a
					// false mouseChildren
					} else if (currentTarget && !DisplayObjectContainer(currentParent).mouseChildren && !(currentParent is GameState)) {
						currentTarget = null;
					}
					
					// define target if an InteractiveObject
					// and mouseEnabled is true
					if (!currentTarget && currentParent is InteractiveObject/* && InteractiveObject(currentParent).mouseEnabled*/) {
						currentTarget = InteractiveObject(currentParent);
					}
					
					// next parent in hierarchy
					currentParent = currentParent.parent;
				}
				
				// if a currentTarget was found
				// ignore all other objectsUnderPoint
				if (currentTarget){
					break;
				}
			}
			
			
			// if a currentTarget was not found
			// the currentTarget is the stage
			if (!currentTarget)
				currentTarget = game;
			
			// get local coordinate locations
			var targetLocal:Point = target.globalToLocal(location);
			var currentTargetLocal:Point = currentTarget.globalToLocal(location);
			
			// move event
			if (lastLocation.x != location.x || lastLocation.y != location.y) {
				
				var withinStage:Boolean = Boolean(location.x >= 0 && location.y >= 0 && location.x <= stage.stageWidth && location.y <= stage.stageHeight);
				
				// mouse leave if left stage
				if (!withinStage && lastWithinStage && !disabledEvents[Event.MOUSE_LEAVE]){
					_lastEvent = new eventEvent(Event.MOUSE_LEAVE, false, false);
					stage.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				
				// only mouse move if within stage
				if (withinStage && !disabledEvents[MouseEvent.MOUSE_MOVE]){
					_lastEvent = new mouseEventEvent(MouseEvent.MOUSE_MOVE, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				
				// remember if within stage
				lastWithinStage = withinStage;
			}
			
			// roll/mouse (out and over) events 
			if (currentTarget != target) {
				
				//addition of Simon Marynissen: add buttonmode to mouse
				var rollOut:Boolean = false;
				var rollOver:Boolean = false;
				
				// off of last target
				if (!disabledEvents[MouseEvent.MOUSE_OUT]){
					_lastEvent = new mouseEventEvent(MouseEvent.MOUSE_OUT, true, false, targetLocal.x, targetLocal.y, currentTarget, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
					target.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				if (!disabledEvents[MouseEvent.ROLL_OUT]){ // rolls do not propagate
					_lastEvent = new mouseEventEvent(MouseEvent.ROLL_OUT, false, false, targetLocal.x, targetLocal.y, currentTarget, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
					target.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
					rollOut = true;
				}
				
				// on to current target
				if (!disabledEvents[MouseEvent.MOUSE_OVER]){
					_lastEvent = new mouseEventEvent(MouseEvent.MOUSE_OVER, true, false, currentTargetLocal.x, currentTargetLocal.y, target, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				if (!disabledEvents[MouseEvent.ROLL_OVER]){ // rolls do not propagate
					_lastEvent = new mouseEventEvent(MouseEvent.ROLL_OVER, false, false, currentTargetLocal.x, currentTargetLocal.y, target, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
					rollOver = true; //addition of Simon Marynissen: add buttonmode to mouse
				}
				//addition of Simon Marynissen: add buttonmode to mouse
				if (rollOver || rollOut) {
					if (currentTarget is Sprite)
						useHandCursor = (currentTarget as Sprite).buttonMode;
				}
			}
			
			/*
			// click/up/down events
			if (lastMouseDown != _mouseIsDown) {
				if (_mouseIsDown) {
					
					if (!disabledEvents[MouseEvent.MOUSE_DOWN]){
						_lastEvent = new mouseEventEvent(MouseEvent.MOUSE_DOWN, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
						currentTarget.dispatchEvent(_lastEvent);
						if (currentTarget.parent != null) {
							if (currentTarget.parent.parent != null)
								currentTarget.parent.parent.dispatchEvent(_lastEvent);
						}
						dispatchEvent(_lastEvent);
					}
					// remember last down
					lastDownTarget = currentTarget;
					
				// mouse is up
				}else{
					if (!disabledEvents[MouseEvent.MOUSE_UP]){
						_lastEvent = new mouseEventEvent(MouseEvent.MOUSE_UP, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
						currentTarget.dispatchEvent(_lastEvent);
						dispatchEvent(_lastEvent);
					}
					
					if (!disabledEvents[MouseEvent.CLICK] && currentTarget == lastDownTarget) {
						_lastEvent = new mouseEventEvent(MouseEvent.CLICK, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
						currentTarget.dispatchEvent(_lastEvent);
						dispatchEvent(_lastEvent);
					}
					
					// clear last down
					lastDownTarget = null;
				}
			}*/
			
			// explicit call to doubleClick()
			if (isDoubleClickEvent && !disabledEvents[MouseEvent.DOUBLE_CLICK] && currentTarget.doubleClickEnabled) {
				_lastEvent = new mouseEventEvent(MouseEvent.DOUBLE_CLICK, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, ctrlKey, altKey, shiftKey, _mouseIsDown, delta);
				currentTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
			}
			
			// remember last values
			lastLocation = location.clone();
			lastMouseDown = _mouseIsDown;
			target = currentTarget;
		}
	}
}