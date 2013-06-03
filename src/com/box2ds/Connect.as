package com.box2ds
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Administrator
	 */	
	public class Connect
	{
		private static var singleton:Connect;
		/***/
		private var socket:Socket;

		public function Connect(caller:Function=null)
		{
			if(caller != hidden)
			{
				throw new Error("只能用getInstance()来获取实例");
			}
			if(Connect.singleton != null)
			{
				throw new Error("只能用getInstance()来获取实例");
			}
			socket = new Socket();
			socket.objectEncoding = ObjectEncoding.AMF3;
			socket.addEventListener(IOErrorEvent.IO_ERROR,onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
			socket.addEventListener(Event.CONNECT,onConnect);
			socket.addEventListener(ProgressEvent.SOCKET_DATA,onData);
			socket.addEventListener(Event.CLOSE,onClose);
		}
		
		public static function getInstance():Connect
		{
			if(singleton == null)
			{
				singleton = new Connect(hidden);
			}
			return singleton;
		}
		private static function hidden():void{}
		
		/**socket连接错误事件处理*/
		protected function onError(event:SecurityErrorEvent):void
		{
			
		}
		/**socket连接成功事件处理*/
		protected function onConnect(event:Event):void
		{
			trace("socket连接成功");
		}
		private var msg_length:int;
		/**socket读取数据事件处理*/
		protected function onData(event:ProgressEvent):void
		{
			var bytearray:ByteArray;
			if(msg_length == 0 && socket.bytesAvailable>=4)//当消息长度为0且socket的缓存区域的内容大于4个字节时
			{
				bytearray = new ByteArray();
				socket.readBytes(bytearray,0,4);//读取4个字节的信息
				msg_length = bytearray.readInt();//读取消息长度
			}
			if(msg_length>0 && socket.bytesAvailable>=msg_length+4)//当消息长度大于0且socket缓存区域的内容大于（消息长度+协议id长度），即消息完全收到时
			{
				bytearray.clear();
				socket.readBytes(bytearray,0,msg_length+4);
				var id:int = bytearray.readInt();
				
				msg_length = 0;
			}
		}
		/**socket关闭事件处理*/
		protected function onClose(event:Event):void
		{
			
		}
		public function connect(host:String,port:int):void
		{
			socket.connect(host,port);
		}
		/**发送信息*/
		public function send(info:Object):void
		{
			var str:String = /*TJON.encode(info)*/;
			var msg:ByteArray = new ByteArray();
			msg.writeUTF(str);
			try
			{
				socket.writeInt(msg.length);
				socket.writeBytes(msg,0,msg.length);
				socket.flush();
			}
			catch(e:IOError)
			{
				
			}
			
		}
		
	}
}