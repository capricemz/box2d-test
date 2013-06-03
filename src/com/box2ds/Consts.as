package com.box2ds
{
	/**
	 * Box2D常量定义类
	 * @author Administrator
	 */	
	public class Consts
	{
		public static const P2M:int = 30;
		
		public static const categotybits_1:uint = 1<<0;
		public static const categotybits_2:uint = 1<<1;
		//……
		
		public static const maskbits_1:uint = categotybits_1 + categotybits_2;
		public static const maskbits_2:uint = categotybits_1;
	}
}