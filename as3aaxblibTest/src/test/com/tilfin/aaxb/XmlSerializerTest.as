package com.tilfin.aaxb
{
	import entity.List;
	import entity.ListItem;
	import entity.PlainText;
	
	import mx.controls.Text;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;

	public class XmlSerializerTest
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testPlainTextSerialize():void {
			var plainText:PlainText = new PlainText();
			plainText.text = "Plain Text.";
			
			var serializer:XmlSerializer = new XmlSerializer(PlainText);
			var xml:XML = serializer.serialize(plainText);
			assertEquals(String(xml.localName()), "plain");
			assertEquals(String(xml), plainText.text);
			
			var restoreObject:PlainText = serializer.deserialize(xml) as PlainText;
			assertNotNull(restoreObject);
			assertEquals(restoreObject.text, plainText.text);
		}
		
		[Test]
		public function testListAndItemSerialize():void {
			var list:List = new List();
			list.listItems = new Vector.<ListItem>();
			var item1:ListItem = new ListItem();
			item1.name = "item1";
			item1.value = 10;
			list.listItems.push(item1);
			var item2:ListItem = new ListItem();
			item2.name = "item2";
			item2.value = -20;
			list.listItems.push(item2);
			
			var serializer:XmlSerializer = new XmlSerializer(List, ListItem);
			var xml:XML = serializer.serialize(list);
			var items:XMLList = xml.items;
			var xitem1:XML = xml.items.item[0];
			var xitem2:XML = xml.items.item[1];
			assertEquals(String(xml.localName()), "list");
			assertEquals(String(xitem1.name), "item1");
			assertEquals(String(xitem1.value), "10");
			assertEquals(String(xitem2.name), "item2");
			assertEquals(String(xitem2.value), "-20");
			
			var restoreList:List = serializer.deserialize(xml) as List;
			assertNotNull(restoreList);
			assertNotNull(restoreList.listItems);
			assertEquals(restoreList.listItems[0].name, item1.name);
			assertEquals(restoreList.listItems[0].value, item1.value);
			assertEquals(restoreList.listItems[1].name, item2.name);
			assertEquals(restoreList.listItems[1].value, item2.value);
		}
	}
}