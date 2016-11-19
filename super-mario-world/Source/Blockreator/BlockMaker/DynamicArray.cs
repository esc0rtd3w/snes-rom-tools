using System;
using System.Collections;
using System.Text;

namespace BlockMaker
{
	class DynamicArray<T>
	{
		System.Collections.ArrayList a  = new ArrayList();

		public void Append(T obj) { a.Add(obj); }
		public void Insert(int index, T obj) { a.Insert(index, obj); }
		public void RemoveAt(int index) { a.RemoveAt(index); }
		public void Remove(T obj) { a.Remove(obj); }
		public void Clear() { a.Clear(); }
		public int Count { get { return a.Count; } }
		public System.Collections.ArrayList GetArrayList() { return a; }
		public virtual T this[int index] 
		{
			get
			{
				return (T)a[index];
			}
			set
			{
				a[index] = value;
			}
		}
	}
}
