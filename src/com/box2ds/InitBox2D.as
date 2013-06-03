package com.box2ds
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Box2D世界及其他所有对象构造类
	 * @author Administrator
	 */	
	public class InitBox2D
	{
		private static var inst:InitBox2D;
		//重力向量
		private var gravity:b2Vec2;
		//是否休眠
		private var doSleep:Boolean;
		
		private var _world:b2World;
		private var debugSprite:Sprite
		
		public static function getInst():InitBox2D
		{
			if(!inst)
				inst = new InitBox2D();
			return inst;
		}
		public function InitBox2D()
		{
			gravity = new b2Vec2(0,0);
			doSleep = true;
		}
		public function creatWorld():void
		{
			_world = new b2World(gravity,doSleep);
			//false时初始刚体不受重力影响，除非受力
			_world.SetWarmStarting(true);
			createDebugDraw();
		}
		public function get world():b2World
		{
			return _world;
		}
		private function createDebugDraw():Sprite
		{
			//创建一个sprite，可以将测试几何物体放入其中
			debugSprite = new Sprite();
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(debugSprite);
			//设置边框厚度
			debugDraw.SetLineThickness(1.0);
			//边框透明度
			debugDraw.SetAlpha(1.0);
			//填充透明度
			debugDraw.SetFillAlpha(0.5);
			//设置显示对象
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
			//物理世界缩放
			debugDraw.SetDrawScale(Consts.P2M);
			_world.SetDebugDraw(debugDraw);
			
			return debugSprite;
		}
		public function getDebugDraw():Sprite
		{
			return debugSprite;
		}
		/**
		 * 构建一个刚体
		 * @param type 刚体类型
		 * @param init_point 初始位置
		 * @return 一个刚体
		 */		
		public function creatb2Body(type:uint,init_point:Point,init_shape:Array):b2Body
		{
			//1.需要创建的墙刚体
			var body:b2Body;
			//2.刚体定义
			var bodyDef:b2BodyDef = new b2BodyDef();
			//刚体类型和位置
			bodyDef.type = type;
			//注意刚体的注册中心都是在物体的中心位置
			bodyDef.position.Set(init_point.x/Consts.P2M, init_point.y/Consts.P2M);
			bodyDef.fixedRotation = false;
			bodyDef.allowSleep = false;
			//工厂模式创建刚体
			body = _world.CreateBody(bodyDef);
			
			//3.刚体修饰物定义
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			//密度
			fixtureDef.density = 1.0;
			//摩擦粗糙程度
			fixtureDef.friction = 0.3;
			//力度返回程度（弹性）
			fixtureDef.restitution = 1.0;
			
			//4.创建墙形状
			var shape:b2Shape;
			switch(init_shape[0])
			{
				case 0:
					shape = new b2PolygonShape();
					//此处参数为宽和高度的一半值
					(shape as b2PolygonShape).SetAsBox(init_shape[1]/2/Consts.P2M, init_shape[2]/2/Consts.P2M);
					break;
				case 1:
					shape = new b2PolygonShape();
					init_shape.shift();
					(shape as b2PolygonShape).SetAsArray(init_shape);
					break;
				case 2:
					shape = new b2CircleShape(init_shape[1]/2/Consts.P2M);
					break;
			}
			//将形状添加到刚体修饰物
			fixtureDef.shape = shape;
			
			body.CreateFixture(fixtureDef);
			
//			var mass:b2MassData = new b2MassData();
//			mass.mass = 100;
//			
//			body.SetMassData(mass);
			
			return body;
		}
		/**摧毁关节*/
		public function destroyJoint(joint:b2Joint):void
		{
			_world.DestroyJoint(joint);
		}
		/**创建鼠标关节*/
		public function createMouseJoint(body:b2Body,m_mouse_P:b2Vec2):b2MouseJoint
		{
			var joint:b2MouseJoint,jointdef:b2MouseJointDef;
			jointdef = new b2MouseJointDef();
			jointdef.bodyA = _world.GetGroundBody();//设置鼠标关节的一个节点为空刚体，GetGroundBody()可以理解为空刚体
			jointdef.bodyB = body;//设置鼠标关节的另一个刚体为鼠标点击的刚体
			jointdef.collideConnected = true;
			jointdef.target.Set(m_mouse_P.x,m_mouse_P.y);//更新鼠标关节拖动的点
			jointdef.maxForce = 300.0 * body.GetMass();//设置鼠标可以施加的最大的力
			joint = _world.CreateJoint(jointdef) as b2MouseJoint;
			return joint;
		}
		/**创建距离关节*/
		public function createDistanceJoint(bodyA:b2Body,bodyB:b2Body,localAnchorA:Point,localAnchorB:Point,length:Number):b2DistanceJoint
		{
			//需要创建的关节
			var joint:b2DistanceJoint,jointdef:b2DistanceJointDef;
			//关节定义
			jointdef = new b2DistanceJointDef();
			jointdef.collideConnected = false;
//			jointdef.bodyA = bodyA;
//			jointdef.bodyB = bodyB;
//			jointdef.localAnchorA = new b2Vec2(localAnchorA.x/Consts.PIXEL_TO_METER,localAnchorA.y/Consts.PIXEL_TO_METER);
//			jointdef.localAnchorB = new b2Vec2(localAnchorB.x/Consts.PIXEL_TO_METER,localAnchorB.y/Consts.PIXEL_TO_METER);
			jointdef.Initialize(bodyA,bodyB,new b2Vec2(localAnchorA.x/Consts.P2M,localAnchorA.y/Consts.P2M),
				new b2Vec2(localAnchorB.x/Consts.P2M,localAnchorB.y/Consts.P2M));
			jointdef.length = length/Consts.P2M;
			joint = _world.CreateJoint(jointdef) as b2DistanceJoint;
			return joint;
		}
		/**创建转动关节*/
		public function createRevoluteJoint(bodyA:b2Body,bodyB:b2Body,localAnchorA:Point,localAnchorB:Point):b2RevoluteJoint
		{
			//需要创建转动关节
			var joint:b2RevoluteJoint;
			//关节定义
			var jointdef:b2RevoluteJointDef = new b2RevoluteJointDef();
			//用bodyA、bodyB和anchor节点初始化马达关节
			jointdef.bodyA = bodyA;
			jointdef.bodyB = bodyB;
			jointdef.localAnchorA = new b2Vec2(localAnchorA.x/Consts.P2M,localAnchorA.y/Consts.P2M);
			jointdef.localAnchorB = new b2Vec2(localAnchorB.x/Consts.P2M,localAnchorB.y/Consts.P2M);
//			jointdef.Initialize(bodyA,bodyB,new b2Vec2(localAnchorA.x/Consts.PIXEL_TO_METER,localAnchorA.y/Consts.PIXEL_TO_METER));
			//设置连接的两个刚体之间不进行碰撞检测
			jointdef.collideConnected = false;
			//开启马达
//			jointdef.enableMotor = true;
			//设置马达的最大角速度，单位为 弧度/秒，如设置为Math.PI，即每秒钟转180度
//			jointdef.motorSpeed = Math.PI;
			//设置最大的扭力值
			jointdef.maxMotorTorque = 500;
			//创建马达关节
			joint = _world.CreateJoint(jointdef) as b2RevoluteJoint;
			return joint;
		}
	}
}