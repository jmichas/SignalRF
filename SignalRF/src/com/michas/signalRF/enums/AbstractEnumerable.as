package com.michas.signalRF.enums
{
	/**
	 * AbstractEnumerable.as
	 * @version Dated 6 July 2011
	 * ---------------
	 * Faux enumerations in Actionscript. Done through code reflection and static initializers.
	 *
	 * Adapted from:
	 * http://scottbilas.com/2008/06/01/faking-enums-in-as3/
	 * Scott Bilas - For his wonderful enumeration function.
	 * Hadrien - For the idea for type-checking the constants.
	 *
	 * @author Cardin Lee
	 * http://cardinal4.co.cc/
	 *
	 Copyright (C) 2011 by Cardin Lee
	 
	 Permission is hereby granted, free of charge, to any person obtaining a copy
	 of this software and associated documentation files (the "Software"), to deal
	 in the Software without restriction, including without limitation the rights
	 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 copies of the Software, and to permit persons to whom the Software is
	 furnished to do so, subject to the following conditions:
	 
	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	 THE SOFTWARE.
	 */
	
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Assists in the creation of faux enumeration datatypes.
	 * <ul><li>Auto indexing</li>
	 * <li>Provides index-to-string, and string-to-index translation</li>
	 * <li>Allows custom indexing</li>
	 * <li>Provides a Vector list of members for iteration</li><ul>
	 *
	 * @usage
	 * New enumerations must:
	 * <ol><li>Inherit AbstractEnumerable</li>
	 * <li>Call initEnum() in static initialiser</li>
	 * <li>Values are created as public, static, constants of its own type</li>
	 * <li>Prefix a variable with "_" to exclude it from being enumerated</li></ol>
	 *
	 * <listing version="3.0">
	 public class DaysInWeek extends AbstractEnumerable
	 {
	 public static const MONDAY:DaysInWeek = new DaysInWeek();
	 public static const TUESDAY:DaysInWeek = new DaysInWeek();
	 public static const WEDNESDAY:DaysInWeek = new DaysInWeek();
	 public static const THURSDAY:DaysInWeek = new DaysInWeek();
	 public static const FRIDAY:DaysInWeek = new DaysInWeek();
	 public static const SATURDAY:DaysInWeek = new DaysInWeek();
	 public static const SUNDAY:DaysInWeek = new DaysInWeek();
	 
	 // the following are not included in enumeration
	 public static const _MYBIRTHDAY:DaysInWeek = new DaysInWeek(); //because of "_" prefix
	 public static var bday_date:String = "1/1/1970"; //because it's not of type DaysInWeek
	 
	 // this segment in brackets must be exist to work
	 {
	 initEnum(DaysInWeek);
	 }
	 }
	 * </listing>
	 
	 * Usage-wise, you can refer to it using its value or its string value:
	 * <listing version="3.0">
	 trace(DaysInWeek.MONDAY.valueOf()); // 3
	 trace(DaysInWeek.MONDAY.toString()); // Monday
	 * </listing>
	 
	 * You can also retrieve the Enum constant using its value:
	 * <listing version="3.0">
	 var theDay:DaysInWeek = Enumerable.retrieveValue(1, DaysInWeek) as DaysInWeek;
	 trace(theDay.toString()); // Friday
	 * </listing>
	 *
	 * Notice how the index value of the Enumerable does not match the sequence at which it is
	 * written. That is typical of the Flash environment, as it does not instantiate sequentially.
	 * If you want to self-define your index, do this:
	 *
	 * <ol><li>Create a constructor that calls super()</li>
	 * <li>Supply index as a parameter to constructor</li>
	 * <li>Input false as an extra parameter to initEnum()</li></ol>
	 *
	 * Note:
	 * <ul><li>The index does not have to be sequential.</li>
	 * <li>You must NOT repeat indexes.</li></ul>
	 *
	 * <listing version="3.0">
	 public class DaysInWeek extends AbstractEnumerable
	 {
	 public static const MONDAY:DaysInWeek = new DaysInWeek(0);
	 public static const TUESDAY:DaysInWeek = new DaysInWeek(1);
	 public static const WEDNESDAY:DaysInWeek = new DaysInWeek(2);
	 public static const THURSDAY:DaysInWeek = new DaysInWeek(3);
	 public static const FRIDAY:DaysInWeek = new DaysInWeek(4);
	 public static const SATURDAY:DaysInWeek = new DaysInWeek(5);
	 public static const SUNDAY:DaysInWeek = new DaysInWeek(6);
	 
	 public static const HOLIDAYS:DaysInWeek = new DaysInWeek(999999);
	 
	 {
	 initEnum(DaysInWeek, false);
	 }
	 
	 public function DaysInWeek(index:uint)
	 {
	 super(index);
	 }
	 }
	 * </listing>
	 *
	 * If you want to be able to iterate through the values, take the Vector returned by initEnum
	 * and store it as a variable for access.
	 *
	 * <listing version="3.0">
	 * public static var _AllItems:Vector<Enumerable>;
	 *
	 * {
	 * 		_AllItems = initEnum(DaysInWeek);
	 * }
	 * </listing>
	 */
	public class AbstractEnumerable
	{
		private var constName:String;
		private var index:uint;
		
		public function AbstractEnumerable(index:uint = 0)	{	this.index = index;	}
		
		/**
		 * Initializes the specified class object into a faux enumeration datatype.
		 *
		 * @param inType 		The class object that you wish to initialize.
		 * @param autoIndex		Whether to auto index.
		 */
		protected static function initEnum(classObj:*, autoIndex:Boolean = true):Vector.<AbstractEnumerable>
		{
			var type:XML = describeType(classObj);
			var className:String = getQualifiedClassName(classObj);
			
			// sort ALPHABETICALLY into an array
			var tempList:Array = new Array();
			for each (var tempConst:XML in type.constant)
			{
				// Verify that we don't anyhow change any constant.
				if (tempConst.@type == className && tempConst.@name.substring(0,1) != "_")
				{
					tempList.push(tempConst.@name);
				}
			}
			tempList = tempList.sort();
			
			var listing:Vector.<AbstractEnumerable> = new Vector.<AbstractEnumerable>();
			var i:int = 0;
			for each (var constant:String in tempList)
			{
				classObj[constant].constName = constant;
				if (autoIndex)	classObj[constant].index = i;
				i++;
				
				listing.push(classObj[constant]);
			}
			
			listing.sort(sorting);
			return listing;
		}
		
		
		/**
		 * Retrieves a constant from an constant class based on its string value.
		 *
		 * @param	value	The string value of the constant.
		 * @param	classObj	The constant class to which the constant belongs to.
		 * @return	The constant itself.
		 * @see #retriveValue()
		 */
		public static function stringRetrieveValue(strValue:String, classObj:Class):AbstractEnumerable
		{
			strValue = StringUtils.trim(strValue);
			strValue = StringUtils.capitalize(strValue, true);
			
			var type:XML = describeType(classObj);
			var className:String = getQualifiedClassName(classObj);
			
			for each (var constant:XML in type.constant)
			{
				if (constant.@type == className)
				{
					if (classObj[constant.@name].toString() == strValue)
						return classObj[constant.@name];
				}
			}
			return null;
		}
		
		/**
		 * Retrieves a constant from an constant class based on its numerical value.
		 *
		 * @param	value	The numerical value of the constant.
		 * @param	classObj	The constant class to which the constant belongs to.
		 * @return	The constant itself.
		 * @see #stringRetrieveValue()
		 */
		public static function retrieveValue(value:uint, classObj:Class):AbstractEnumerable
		{
			var type:XML = describeType(classObj);
			var className:String = getQualifiedClassName(classObj);
			
			for each (var constant:XML in type.constant)
			{
				if (constant.@type == className)
				{
					if (classObj[constant.@name].index == value)
						return classObj[constant.@name];
				}
			}
			return null;
		}
		
		/**
		 * Name of the constant.
		 *
		 * @return The string representation of the specified constant.
		 * @see #valueOf()
		 */
		public final function toString():String
		{
			var tempName:String = constName.toLowerCase();
			var tempArray:Array = tempName.split("_");
			tempName = tempArray.join(" ");
			tempName = StringUtils.trim(tempName);
			tempName = StringUtils.capitalize(tempName, true);
			
			return tempName;
		}
		
		/**
		 * Value of the constant.
		 *
		 * @return The numerical representation of the specified constant.
		 * @see	#toString()
		 */
		public final function valueOf():uint	{	return index;	}
		
		private static function sorting(a:AbstractEnumerable, b:AbstractEnumerable):int
		{
			if (a.index > b.index)	return 1;
			else if (a.index < b.index)	return -1;
			return 0;
		}
	}
}

/**
 * 	String Utilities class by Ryan Matsikas, Feb 10 2006
 *
 *	Visit www.gskinner.com for documentation, updates and more free code.
 * 	You may distribute this code freely, as long as this comment block remains intact.
 */
internal class StringUtils {
	
	/**
	 *	Capitalizes the first word in a string or all words..
	 *
	 *	@param p_string The string.
	 *	@param p_all (optional) Boolean value indicating if we should
	 *	capitalize all words or only the first.
	 */
	internal static function capitalize(p_string:String, ...args):String {
		var str:String = trimLeft(p_string);
		if (args[0] === true) { return str.replace(/^.|\b./g, _upperCase);}
		else { return str.replace(/(^\w)/, _upperCase); }
	}
	
	/**
	 *	Removes whitespace from the front and the end of the specified
	 *	string.
	 *
	 *	@param p_string The String whose beginning and ending whitespace will
	 *	will be removed.
	 */
	internal static function trim(p_string:String):String {
		if (p_string == null) { return ''; }
		return p_string.replace(/^\s+|\s+$/g, '');
	}
	
	/**
	 *	Removes whitespace from the front (left-side) of the specified string.
	 *
	 *	@param p_string The String whose beginning whitespace will be removed.
	 */
	private static function trimLeft(p_string:String):String {
		if (p_string == null) { return ''; }
		return p_string.replace(/^\s+/, '');
	}
	
	private static function _upperCase(p_char:String, ...args):String {
		return p_char.toUpperCase();
	}
}