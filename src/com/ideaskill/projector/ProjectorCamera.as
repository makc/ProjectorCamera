package com.ideaskill.projector {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.setTimeout;
	
	/**
	 * Projector-webcam proxy tool.
	 * @author makc
	 */
	public class ProjectorCamera extends Sprite {
		
		/**
		 * Constructor.
		 * @param	shortcut Keyboard shortcut to listen to (null for Ctrl+Space).
		 */
		public function ProjectorCamera (shortcut:Object = null) {
			this.homo = new Homography;
			this.shortcut = shortcut ? shortcut : { keyCode : 32, ctrlKey : true };
			addEventListener (Event.ADDED_TO_STAGE, onStage);
			makeArrows ();
		}
		
		/**
		 * Requests access to webcam feed.
		 */
		public function requestCamera (width:int = 640, height:int = 480, fps:Number = 15, name:String = null, favorArea:Boolean = true):void {
			if (video) {
				video.attachCamera (null);
				frame1.dispose ();
				frame2.dispose ();
				// does anyone know how to release camera?
			}
			camera = Camera.getCamera (name);
			camera.setMode (width, height, fps, favorArea);
			video = new Video (width, height);
			video.attachCamera (camera);
			frame1 = new BitmapData (width, height, false, 0);
			frame2 = new BitmapData (width, height, false, 0);
		}
		
		/**
		 * Draws projector perspective to provided BitmapData instance.
		 * @param	bitmapData
		 */
		public function drawTo (bitmapData:BitmapData):void {
			if (video) {
				frame2.draw (video);
				homo.setTransform (frame2,
					new Point (arrows [4].x, arrows [4].y),
					new Point (arrows [5].x, arrows [5].y),
					new Point (arrows [6].x, arrows [6].y),
					new Point (arrows [7].x, arrows [7].y),
					bitmapData.width, bitmapData.height
				);
				bitmapData.draw (homo);
			} 
		}
		
		private var camera:Camera;
		private var frame1:BitmapData;
		private var frame2:BitmapData;
		private var video:Video;
		private var homo:Homography;
		private var shortcut:Object;
		private var arrows:Vector.<Sprite>;
		
		private function onStage (event:Event):void {
			removeEventListener (Event.ADDED_TO_STAGE, onStage);
			stage.addEventListener (Event.RESIZE, onResize);
			stage.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);
			visible = false;
		}
		
		private function showUp ():void {
			// bring ourselves to top
			parent.swapChildrenAt (parent.getChildIndex (this), parent.numChildren - 1);
			
			// draw fresh test pattern
			onResize ();
			
			// hide draggable arrows
			for (var i:int = 0; i < 8; i++) {
				arrows [i].visible = (i < 4);
			}
			
			// wait for camera to see this
			setTimeout (calibrate, 1234);
		}
		
		private function calibrate ():void {
			// if still visible
			if (visible) {
				// show last camera frame
				frame1.draw (video);
				graphics.beginBitmapFill (frame1);
				graphics.drawRect (0, 0, frame1.width, frame1.height);
				graphics.endFill ();
				
				// unhide draggable arrows
				for (var i:int = 0; i < 8; i++) {
					arrows [i].visible = (i > 3);
				}
			}
		}
				
		private function startDragArrow (e:MouseEvent):void {
			Sprite (e.target).startDrag ();
		}
		
		private function stopDragArrow (e:MouseEvent):void {
			Sprite (e.target).stopDrag ();
		}
		
		private function onKeyDown (event:KeyboardEvent):void {
			var match:Boolean = true;
			for (var property:String in shortcut) {
				if (shortcut [property] != event [property]) {
					match = false; break;
				}
			}
			
			if (match) {
				if (visible = !visible) {
					showUp ();
				}
			}
		}
		
		private function onResize (event:Event = null):void {
			// assuming stageWidth x stageHeight as drawing area
			arrows [1].x = stage.stageWidth;
			arrows [2].x = stage.stageWidth;
			arrows [2].y = stage.stageHeight;
			arrows [3].y = stage.stageHeight;
			
			graphics.clear ();
			graphics.beginFill (0);
			graphics.drawRect (0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill ();
		}
		
		private function makeArrows (): void {
			arrows = new Vector.<Sprite>;
			var i:int;
			var sx:Vector.<Number> = new <Number> [ 100, -100, -100, 100 ];
			var sy:Vector.<Number> = new <Number> [ 100, 100, -100, -100 ];
			for (i = 0; i < 8; i++) {
				var f:Function = drawWhiteArrow;
				var s:Sprite = arrows [i] = new Sprite;
				if (i > 3) {
					f = drawGreenArrow;
					s.addEventListener (MouseEvent.MOUSE_DOWN, startDragArrow);
					s.addEventListener (MouseEvent.MOUSE_UP, stopDragArrow);
					s.buttonMode = true;
					s.useHandCursor = true;
					// assuming this is within stage rect on addedToStage
					s.x = 300 - sx [i % 4] * 1.5;
					s.y = 300 - sy [i % 4] * 1.5;
				} else {
					s.mouseEnabled = false;
				}
				f (arrows [i]["graphics"], sx [i % 4], sy [i % 4]);
				addChild (arrows [i]);
			}
		}
		
		private function drawWhiteArrow (g:Graphics, sx:Number, sy:Number):void {
			g.clear (); g.beginFill (0xffffff); g.moveTo (0, 0);
			g.lineTo (sx, 0); g.lineTo (sx * 0.75, sy * 0.25); g.lineTo (sx, sy * 0.5);
			g.lineTo (sx * 0.5, sy); g.lineTo (sx * 0.25, sy * 0.75); g.lineTo (0, sy);
			g.endFill ();
		}
		
		private function drawGreenArrow (g:Graphics, sx:Number, sy:Number):void {
			g.clear (); g.beginFill (0xff00); g.moveTo (0, 0);
			g.lineTo (sx * 0.875, sy * 0.375); g.lineTo (sx * 0.625, sy * 0.5); g.lineTo (sx, sy * 0.875);
			g.lineTo (sx * 0.875, sy); g.lineTo (sx * 0.5, sy * 0.625); g.lineTo (sx * 0.375, sy * 0.875);
			g.endFill ();			
		}
	}
}

/**
 * @author zeh, original idea
 * @author makc, inverted transform
 * @see http://zehfernando.com/2010/the-best-drawplane-distortimage-method-ever/
 * @see http://makc3d.wordpress.com/2010/10/21/inverse-homography-drawtriangles/
 */
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Point;
class Homography extends Shape {
	private var v6:Vector.<int> = Vector.<int> ([0, 1, 2, 0, 2, 3]);
	private var v8:Vector.<Number> = new Vector.<Number> (8, true);
	private var v12:Vector.<Number> = new Vector.<Number> (12, true);

	public function setTransform (src:BitmapData,
		p0:Point, p1:Point, p2:Point, p3:Point,
		destWidth:int = 100, destHeight:int = 100):void {

		// Find diagonals intersection point
		var pc:Point = new Point;

		var a1:Number = p2.y - p0.y;
		var b1:Number = p0.x - p2.x;
		var a2:Number = p3.y - p1.y;
		var b2:Number = p1.x - p3.x;

		var denom:Number = a1 * b2 - a2 * b1;
		if (denom == 0) {
			// something is better than nothing
			pc.x = 0.25 * (p0.x + p1.x + p2.x + p3.x);
			pc.y = 0.25 * (p0.y + p1.y + p2.y + p3.y);
		} else {
			var c1:Number = p2.x * p0.y - p0.x * p2.y;
			var c2:Number = p3.x * p1.y - p1.x * p3.y;
			pc.x = (b1 * c2 - b2 * c1) / denom;
			pc.y = (a2 * c1 - a1 * c2) / denom;
		}

		// Lengths of first diagonal
		var ll1:Number = Point.distance(p0, pc);
		var ll2:Number = Point.distance(pc, p2);

		// Lengths of second diagonal
		var lr1:Number = Point.distance(p1, pc);
		var lr2:Number = Point.distance(pc, p3);

		// Ratio between diagonals
		var f:Number = (ll1 + ll2) / (lr1 + lr2);

		var sw:Number = src.width, sh:Number = src.height;
		var dw:Number = destWidth, dh:Number = destHeight;

		v8 [2] = dw; v8 [4] = dw; v8 [5] = dh; v8 [7] = dh;

		v12 [0] = p0.x / sw; v12 [ 1] = p0.y / sh; v12 [ 2] = ll2 / f;
		v12 [3] = p1.x / sw; v12 [ 4] = p1.y / sh; v12 [ 5] = lr2;
		v12 [6] = p2.x / sw; v12 [ 7] = p2.y / sh; v12 [ 8] = ll1 / f;
		v12 [9] = p3.x / sw; v12 [10] = p3.y / sh; v12 [11] = lr1;

		graphics.clear ();
		graphics.beginBitmapFill (src, null, false, true);
		graphics.drawTriangles (v8, v6, v12);
	}
}