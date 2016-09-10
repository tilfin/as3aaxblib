/*
Copyright (c) 2011, Tilfin Limited
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the 
documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its 
contributors may be used to endorse or promote products derived from 
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


package com.tilfin.aaxb.marshallers {

	import com.tilfin.aaxb.annotations.XmlAttribute;
	import com.tilfin.aaxb.annotations.XmlElement;
	import com.tilfin.aaxb.annotations.XmlElementWrapper;
	import com.tilfin.aaxb.reflect.ClassStructure;
	import com.tilfin.aaxb.reflect.ClassStructureProvider;
	import com.tilfin.aaxb.reflect.TypeDescriptor;
	import com.tilfin.aaxb.reflect.TypeInfo;
	
	import flash.utils.getDefinitionByName;

	/**
	 * Class Structure Marshaller.
	 *
	 * @author tilfin
	 * @author Last Modified: $Author: tilfin $
	 * @version $Revision:  $ $Date:  $
	 */
	public class StructureMarshaller extends BaseMarshaller
	{
		public function StructureMarshaller(marshallerMap:Object, csp:ClassStructureProvider) {
			super(marshallerMap, csp);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function mashall(element:*, field:String=null):* {
			var struct:ClassStructure = csprovider.getStructure(element);
			var props:Object = struct.properties;
			var tagname:String = field ? field : struct.tagName;

			var rootNode:XML = <{tagname}></{tagname}>;
			for (var name:String in props) {
				if (isExceptFieldToXml(name)) continue;
				
				var typeInfo:TypeInfo = TypeInfo(props[name]);
				var marshaller:IMarshaller = marshallerMap[typeInfo.type] as IMarshaller;
				var xmlel:XmlElement = typeInfo.xmlElement;
				var propNode:* = marshaller.mashall(element[name], xmlel ? xmlel.name : name);
				if (propNode == null) continue;
				
				var xmlAttribute:XmlAttribute = typeInfo.xmlAttribute;
				if (xmlAttribute) {
					// Add element as Attribute.
					var aname:String = xmlAttribute.name == null ? propNode.localName() : xmlAttribute.name;
					rootNode.@[aname] = String(propNode);
					continue;
				}

				if (typeInfo.isXmlValue) {
					// Add element as Content Value.
					rootNode.appendChild(propNode.toString());
					continue;
				}
				
				var xmlelwrapper:XmlElementWrapper = typeInfo.xmlElementWrapper;
				if (xmlelwrapper) {
					// Add element wrapper.
					var wrapedNode:* = propNode;
					var wrapName:String = xmlelwrapper.name ? xmlelwrapper.name : name;
					propNode = <{wrapName}></{wrapName}>;
					propNode.appendChild(wrapedNode);
				}

				rootNode.appendChild(propNode);
			}
			
			return rootNode;
		}

		/**
		 * @inheritDoc
		 */
		public override function unmashall(nodeList:XMLList, elementType:String=null):* {
			if (nodeList == null || nodeList.length() == 0)
				return null;
			
			var node:XML = nodeList[0];
			var ns:String = String(node.namespace());
			var klass:Class;
			if (elementType) {
				klass = getDefinitionByName(elementType) as Class;
			} else {
				klass = classMap[String(node.localName())];
			}
			
			if (klass == null)
				return null;
			
			var target:Object = new klass();
			var struct:ClassStructure = csprovider.getStructure(target);
			
			for (var prop:String in struct.properties) {
				var typeInfo:TypeInfo = TypeInfo(struct.properties[prop]);
				var nodes:XMLList;
				
				if (typeInfo.isXmlValue) {
					// Get property as Content Value.
					nodes = XMLList(node);
					target[prop] = getValueFromXml(typeInfo, nodes);
					continue;
				}
				
				var xmlAttr:XmlAttribute = typeInfo.xmlAttribute;
				if (xmlAttr) {
					// Get property as Attribute.
					var aname:String = (xmlAttr.name == null) ? prop : xmlAttr.name;
					nodes = node.attribute(aname);
					target[prop] = getValueFromXml(typeInfo, nodes);
					continue;
				}
				
				var parent:XML;
				var xmlElWr:XmlElementWrapper = typeInfo.xmlElementWrapper;
				if (xmlElWr) {
					// Get property as child.
					parent = node.child(new QName(ns, xmlElWr.name))[0];
				} else {
					parent = node;
				}
				
				var xmlEl:XmlElement = typeInfo.xmlElement;
				if (xmlEl) {
					nodes = parent.child(new QName(ns, xmlEl.name));
				} else {
					nodes = parent.child(new QName(ns, prop));
				}
				
				target[prop] = getValueFromXml(typeInfo, nodes);
			}
			
			return target;
		}
		
		private function getValueFromXml(typeInfo:TypeInfo, node:XMLList):* {
			var marshaller:IMarshaller = marshallerMap[typeInfo.type];
			return marshaller.unmashall(node, typeInfo.elementType);
		}

		private static var exceptFields:Array = ["mx_internal_uid"];

		// 変換対象外のフィールドか判定する
		// アンダースコアで始まるもの、タイムスタンプなどは除外対象
		private static function isExceptFieldToXml(field:String):Boolean {
			if (field.substr(0, 1) == "_")
				return true;

			for each (var item:String in exceptFields) {
				if (item == field)
					return true;
			}

			return false;
		}
	}
}