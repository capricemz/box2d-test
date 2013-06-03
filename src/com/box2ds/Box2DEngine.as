package com.box2ds
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	
	import com.box2ds.Consts;
	import com.box2ds.InitBox2D;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Box2D引擎类
	 * @author Administrator
	 */	
	public class Box2DEngine extends Sprite
	{
		private var theBox2D:InitBox2D;
		/**地板*/
		private var floor:b2Body;
		/**鼠标关节*/
		private var mouse_joint:b2MouseJoint;
		
		private var body1:b2Body;
		private var organ:b2Vec2;
		/**多点构建的正方形，init_point为左上角点*/
		private var body2:b2Body;
		
		private var body3:b2Body,body4:b2Body;
		/**
		 * distance_join：距离关节<br>
		 * distance_length：距离关节默认长度
		 */		
		private var distance_joint:b2DistanceJoint,distance_length:Number;
		
		public function Box2DEngine()
		{
			super();
			//添加舞台事件
			/*addEventListener(MouseEvent.CLICK,onClick,true);*/
			addEventListener(MouseEvent.MOUSE_DOWN,onDown,true);
			addEventListener(MouseEvent.MOUSE_UP,onUp,true);
			
			drawBackground();
			theBox2D = InitBox2D.getInst();
			theBox2D.creatWorld();
			addChild(theBox2D.getDebugDraw());
			
			floor = theBox2D.creatb2Body(b2Body.b2_staticBody,new Point(375,745),[0,750,5]);
			
			organ = new b2Vec2(375/Consts.P2M,375/Consts.P2M);
			body1 = theBox2D.creatb2Body(b2Body.b2_dynamicBody,new Point(375,150),[0,20,20]);
			body1.SetLinearVelocity(new b2Vec2(10,0));
			
//			body2 = theBox2D.creatb2Body(b2Body.b2_dynamicBody,new Point(220,200),
//				[1,new b2Vec2(20/Consts.PIXEL_TO_METER,0/Consts.PIXEL_TO_METER),
//				new b2Vec2(20/Consts.PIXEL_TO_METER,20/Consts.PIXEL_TO_METER),
//				new b2Vec2(40/Consts.PIXEL_TO_METER,20/Consts.PIXEL_TO_METER),
//				new b2Vec2(40/Consts.PIXEL_TO_METER,0/Consts.PIXEL_TO_METER)]);
			
			body3 = theBox2D.creatb2Body(b2Body.b2_staticBody,new Point(300,300),[0,60,10]);
			body4 = theBox2D.creatb2Body(b2Body.b2_dynamicBody,new Point(360,300),[0,60,10]);
			var revolute_joint:b2RevoluteJoint = theBox2D.createRevoluteJoint(body3,body4,new Point(30,0),new Point(-30,0));
			revolute_joint.EnableLimit(true);
			revolute_joint.SetLimits(Math.PI/4,Math.PI/2);
			
			distance_length = Math.cos(Math.PI/180)*60;
//			distance_joint = theBox2D.createDistanceJoint(body3,body4,new Point(300,305),new Point(360,305),distance_length);
		}
		protected function onClick(event:MouseEvent):void
		{
			var body:b2Body = theBox2D.creatb2Body(b2Body.b2_dynamicBody,new Point(mouseX,mouseY),[2,10]);
			body.SetLinearVelocity(new b2Vec2(0,10));
			
		}
		protected function onDown(event:MouseEvent):void
		{
			var mouse_b2v:b2Vec2 = new b2Vec2(event.stageX/Consts.P2M,event.stageY/Consts.P2M);
			var fun:Function = function (fixture:b2Fixture):void
			{
				if(fixture)
				{
					mouse_joint = theBox2D.createMouseJoint(fixture.GetBody(),mouse_b2v);
					addEventListener(MouseEvent.MOUSE_MOVE,onMove);
				}
			};
			theBox2D.world.QueryPoint(fun,mouse_b2v);
		}
		protected function onUp(event:MouseEvent):void
		{
			if(mouse_joint)
			{
				removeEventListener(MouseEvent.MOUSE_MOVE,onMove);
				theBox2D.destroyJoint(mouse_joint);
			}
		}
		protected function onMove(event:MouseEvent):void
		{
			if(mouse_joint) mouse_joint.SetTarget(new b2Vec2(event.stageX/Consts.P2M,event.stageY/Consts.P2M));
		}
		/**绘制显示的背景*/
		private function drawBackground():void
		{
			var bg:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.translate(100,100);
			bg.graphics.beginGradientFill(GradientType.RADIAL,[0xffffff,0xffaa00],[0.3,0.2],[0,255],matrix);
			bg.graphics.drawRect(0,0,750,750);
			bg.graphics.endFill();
			addChild(bg);
		}
		/**启动引擎*/
		public function startEngine():void
		{
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		protected function handleEnterFrame(event:Event):void
		{
			var timeStep:Number = 1/30;
			var velocityInterations:int = 20;
			var positionIterations:int = 20;
			
			theBox2D.world.Step(timeStep,velocityInterations,positionIterations);
			//在2.1版本清除力，以提高效率
			theBox2D.world.ClearForces();
			//绘制
			theBox2D.world.DrawDebugData();
			
			//圆周运动
			var b1pos:b2Vec2 = body1.GetPosition(),driect:b2Vec2,r:Number,v:Number,f:Number;
			driect = organ.Copy();
			driect.Subtract(b1pos.Copy());
			r = driect.Normalize();
			v = body1.GetLinearVelocity().Copy().Length();
			f = body1.GetMass()*v*v/(225/Consts.P2M);
			var force:b2Vec2 = driect.Copy();
			force.Multiply(f);
			var vl:b2Vec2,vr:b2Vec2;
			vl = vr = body1.GetWorldCenter().Copy();
			var tangent:b2Vec2 = driect.Copy();
			tangent.CrossFV(1);
			vl.Add(tangent);
			vr.Subtract(tangent);
			force.Multiply(0.5);
			body1.ApplyForce(force,vl);
			body1.ApplyForce(force,vr);
//			body1.SetAngularVelocity(10);
			
			//
//			body4.SetAngularVelocity(10);
			
//			if(distance_length <= 30*Math.sqrt(2) || distance_length >= 59) d = -d;
//			distance_length += d;
//			distance_join.SetLength(distance_length/Consts.PIXEL_TO_METER);
		}
		/**距离关节变长*/
		public function b2DistanceJointAddLength():void
		{
			var length:Number = distance_joint.GetLength();
			length = length + 1/Consts.P2M;
			distance_joint.SetLength(length);
		}
		/**距离关节变短*/
		public function b2DistanceJointSubLength():void
		{
			var length:Number = distance_joint.GetLength();
			length = length - 1/Consts.P2M;
			distance_joint.SetLength(length);
		}

	}
}