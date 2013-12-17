/* ***** BEGIN MIT LICENSE BLOCK *****
* 
* Copyright (c) 2009 DevelopmentArc LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*
* ***** END MIT LICENSE BLOCK ***** */
package com.michas.signalRF.tasks.queue
{
	/**
	 * The hash table is similar to a Dictionary in that a key object is used to map data. Unlike a Dictionary the HashTable behaves similar to an Array
	 * providing the ability check length and get itmes by position. 
	 * 
	 */
	public class HashTable
	{
		
		private var _itemTable:Array; // stores the items
		private var _keyTable:Array; // stores the keys
		
		
		/**
		 * Constructor for the HashTable. 
		 * 
		 */
		public function HashTable()
		{
			_itemTable = new Array();
			_keyTable = new Array();
		}
		
		/**
		 * Adds a key/item pair to the HashTable.  This enables the ability to lookup items by key or position. This also enables keys to be found by items or position. 
		 * @param key
		 * @param item
		 * 
		 */
		public function addItem(key:*, item:*):void
		{
			// see if we are already tracking the key
			var len:int = _keyTable.length;
			for(var i:uint = 0; i < len; i++)
			{
				if(_keyTable[i] == key)
				{
					_itemTable[i] = item;
					return;
				}
			}
			
			// we have not had this key yet, add it
			_keyTable.push(key);
			_itemTable.push(item);
		}
		
		/**
		 * Removes an item/key pair based on the key provided.
		 * 
		 * @param key Key to remove item on.
		 * 
		 */
		public function remove(key:*):void
		{
			// find key and remove key/item pair
			var len:int = _keyTable.length;
			for(var i:uint = 0; i < len; i++)
			{
				if(_keyTable[i] == key)
				{
					// remove from both tables
					_itemTable.splice(i, 1);
					_keyTable.splice(i, 1);
				}
			}
		}
		
		/**
		 * Returns the key at a specified position if the HashTable has that position available.
		 *  
		 * @param position Position to return key.
		 * @return Key at specified position.
		 * 
		 */
		public function getKeyAt(position:int):*
		{
			return _keyTable[position];
		}
		
		/**
		 * Returns the item for the specified key, if the key is not found then the method returns null.
		 *  
		 * @param key Key object to look up item.
		 * @return Item bound to key.
		 * 
		 */
		public function getItem(key:*):*
		{
			// find key return item
			var item:* = null;
			var len:int = _keyTable.length;
			for(var i:uint = 0; i < len; i++)
			{
				if(_keyTable[i] == key)
				{
					item = _itemTable[i];
				}
			}
			return item;
		}
		
		/**
		 * Returns all items stored in the HashTable.  The returned Array is a clone of the stored array to prevent key pair corruption.
		 *  
		 * @return Array of all the contained items.
		 * 
		 */
		public function getAllItems():Array
		{
			return _itemTable.slice();
		}
		
		/**
		 * Returns all keys stored in the HashTable. The returned Array is a clone of the stored array to prevent key pair corruption.
		 * 
		 * @return Array of all the contained keys.
		 * 
		 */
		public function getAllKeys():Array
		{
			return _keyTable.slice();
		}
		
		/**
		 * Removes all items and keys from the HashTable. 
		 * 
		 */
		public function removeAll():void
		{
			_itemTable = new Array();
			_keyTable = new Array();
		}
		
		/**
		 * Looks up the requested item and returns true if the item is contained, false if it is not.
		 *  
		 * @param item Item to lookup.
		 * @return True if found, false if not.
		 * 
		 */
		public function containsItem(item:*):Boolean
		{
			var len:int = _itemTable.length;
			for(var i:uint = 0; i < len; i++)
			{
				if(_itemTable[i] == item) return true;
			}
			return false;
		}
		
		/**
		 * Looks up the requested key and returns true if the key is contained, false if it is not.
		 *  
		 * @param key Key to lookup.
		 * @return True if found, false if not.
		 * 
		 */
		public function containsKey(key:*):Boolean
		{
			var len:int = _keyTable.length;
			for(var i:uint = 0; i < len; i++)
			{
				if(_keyTable[i] == key) return true;
			}
			return false;
		}
		
		/**
		 * Used to determine if there are currently item pairs in the table.
		 *  
		 * @return True if empty, false if not.
		 * 
		 */
		public function get isEmpty():Boolean
		{
			return (_itemTable.length > 0) ? false : true;
		}
		
		/**
		 * Returns the number of items currently inside the HashTable.
		 *  
		 * @return The number of items in the table.
		 * 
		 */
		public function get length():int
		{
			return _itemTable.length;
		}
		
	}
}