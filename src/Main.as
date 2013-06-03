package
{
	import com.box2ds.Box2DEngine;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	[SWF(width="750", height="750", frameRate="30")]
	public class Main extends Sprite
	{
		private var box2d_engine:Box2DEngine;

		private var sub:TextField;
		private var add:TextField;

		public function Main()
		{
			/*var theTaiChi:TaiChi = new TaiChi();
			addChild(theTaiChi);
			theTaiChi.x = 275;
			theTaiChi.y = 275;
			theTaiChi.start();*/
			
			addEventListener(MouseEvent.CLICK,onClick,true);
			
			box2d_engine = new Box2DEngine();
			addChild(box2d_engine);
			box2d_engine.startEngine();
			
			add = new TextField();
			addChild(add);
			add.text = "+";
			add.width = 15;
			add.height = 15;
			add.x = 10;
			add.y = 10;
			add.border = true;
			
			sub = new TextField();
			addChild(sub);
			sub.text = "-";
			sub.width = 15;
			sub.height = 15;
			sub.x = 35;
			sub.y = 10;
			sub.border = true;
		}
		
		protected function onClick(event:MouseEvent):void
		{
			switch (event.target)
			{
				case add:
					box2d_engine.b2DistanceJointAddLength();
					break;
				case sub:
					box2d_engine.b2DistanceJointSubLength();
					break;
			}
		}
	}
}