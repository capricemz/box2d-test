package com.TaiChi
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * 太极动态图形类
	 * @author Administrator
	 */	
	public class TaiChi extends Sprite
	{
		private var base:Bitmap,black_in:BitmapData,write_out:BitmapData,write_in:BitmapData,black_out:BitmapData;
		private var mat:Matrix,point:Point,rect:Rectangle;
		private var timer:Timer;
		
		public function TaiChi()
		{
			super();
			timer = new Timer(30);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			mat = new Matrix();
			point = new Point();
			rect = new Rectangle();
			var bmpd:BitmapData = new BitmapData(200,200,true,0xFF888888);
			base = new Bitmap(bmpd,"auto",true);
			addChild(base);
			var shape_black_in:Shape = createCircle(0x000000,5);
			black_in = createBmpdCircle(shape_black_in);
			var shape_write_out:Shape = createCircle(0xFFFFFF,50);
			write_out = createBmpdCircle(shape_write_out);
			var shape_write_in:Shape = createCircle(0xFFFFFF,5);
			write_in = createBmpdCircle(shape_write_in);
			var shape_black_out:Shape = createCircle(0x000000,50);
			black_out = createBmpdCircle(shape_black_out);
		}
		private function createCircle(color:Number,redius:Number):Shape
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(color);
			shape.graphics.drawCircle(0,0,redius);
			shape.graphics.endFill();
			return shape;
		}
		private function createBmpdCircle(shape:Shape):BitmapData
		{
			var bmpd:BitmapData = new BitmapData(shape.width,shape.height,true,0);
			bmpd.draw(shape,new Matrix(1,0,0,1,shape.width/2,shape.height/2));
			return bmpd;
		}
		public function start():void
		{
			timer.start();
		}
		
		protected function onTimer(event:Event):void
		{
			var bmpd:BitmapData = base.bitmapData;
//			bmpd.fillRect(new Rectangle(0,0,bmpd.width,bmpd.height),0xFF888888);
			/*var t:Number = timer.currentCount*Math.PI/180;
			mat.tx = 50+Math.cos(t)*50;mat.ty = 50+Math.sin(t)*50;
			bmpd.draw(black_out,mat);
			mat.tx = 95+Math.cos(t)*50;mat.ty = 95+Math.sin(t)*50;
			bmpd.draw(write_in,mat);
			t = (timer.currentCount+180)*Math.PI/180;
			mat.tx = 50+Math.cos(t)*50;mat.ty = 50+Math.sin(t)*50;
			bmpd.draw(write_out,mat);
			mat.tx = 95+Math.cos(t)*50;mat.ty = 95+Math.sin(t)*50;
			bmpd.draw(black_in,mat);*/
			
			var t:Number = timer.currentCount*Math.PI/180*3;
			point.x = 50+Math.cos(t)*50;point.y = 50+Math.sin(t)*50;rect.width = black_out.width;rect.height = black_out.height;
			bmpd.copyPixels(black_out,rect,point,null,null,true);
			point.x = 95+Math.cos(t)*50;point.y = 95+Math.sin(t)*50;rect.width = write_in.width;rect.height = write_in.height;
			bmpd.copyPixels(write_in,rect,point,null,null,true);
			t = (timer.currentCount+180)*Math.PI/180*3;
			point.x = 50+Math.cos(t)*50;point.y = 50+Math.sin(t)*50;rect.width = write_out.width;rect.height = write_out.height;
			bmpd.copyPixels(write_out,rect,point,null,null,true);
			point.x = 95+Math.cos(t)*50;point.y = 95+Math.sin(t)*50;rect.width = black_in.width;rect.height = black_in.height;
			bmpd.copyPixels(black_in,rect,point,null,null,true);
			
//			if(timer.currentCount == 1)
//			{
//				timer.stop();
//				trace("stop");
//			}
		}
	}
}