package entity
{
	import com.tilfin.aaxb.annotations.XmlElement;
	import com.tilfin.aaxb.annotations.XmlElementWrapper;

	public class List
	{
		[XmlElementWrapper(name="items")]
		[XmlElement(name="item")]
		public var listItems:Vector.<ListItem>;
	}
}