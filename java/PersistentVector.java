/**
 *   Copyright (c) Rich Hickey. All rights reserved.
 *   The use and distribution terms for this software are covered by the
 *   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
 *   which can be found in the file epl-v10.html at the root of this distribution.
 *   By using this software in any fashion, you are agreeing to be bound by
 * 	 the terms of this license.
 *   You must not remove this notice, or any other, from this software.
 **/

/* rich Jul 5, 2007 */

import java.util.Arrays;

public class PersistentVector{

static class Node {
	final Object[] array;

	Node(Object[] array){
		this.array = array;
	}

	Node(){
		this.array = new Object[32];
	}

	public String toString()
	{
		StringBuffer str = new StringBuffer( Arrays.toString( array ));
		return str.toString();
	}
}

public static void main(String args[])
{
    PersistentVector pvec = EMPTY;
	for(int i = 1; i != 10000 + 1; i++)
	{
		pvec = pvec.cons(i); 
		//System.out.println( pvec.toString() );
	}
	//System.out.println( pvec.toString() );
}

public String toString()
{
	StringBuffer str = new StringBuffer("");
	str.append("PVector:\n");
	str.append(root.toString());
	str.append("\nTail: ");
	str.append( Arrays.toString( tail ) );
	str.append("\n");
	return str.toString();
}

final static Node EMPTY_NODE = new Node();

final int cnt;
final int shift;
final Node root;
final Object[] tail;

public final static PersistentVector EMPTY = new PersistentVector(0, 5, EMPTY_NODE, new Object[]{});

PersistentVector(int cnt, int shift, Node root, Object[] tail){
	this.cnt = cnt;
	this.shift = shift;
	this.root = root;
	this.tail = tail;
}

final int tailoff(){
	if(cnt < 32)
		return 0;
	return ((cnt - 1) >>> 5) << 5;
}

public Object[] arrayFor(int i){
	if(i >= 0 && i < cnt)
		{
		if(i >= tailoff())
			return tail;
		Node node = root;
		for(int level = shift; level > 0; level -= 5)
			System.out.println("level: "+ level);
			System.out.println("stuff: "+ (i >>> level) & 0x01f);
			System.out.println(Arrays.toString( node.array ));
			node = (Node) node.array[(i >>> level) & 0x01f];
		return node.array;
		}
	throw new IndexOutOfBoundsException();
}

public Object nth(int i){
	Object[] node = arrayFor(i);
	return node[i & 0x01f];
}

public int count(){
	return cnt;
}

public PersistentVector cons(Object val){
	//room in tail?
//	if(tail.length < 32)
	if(cnt - tailoff() < 32)
		{
		Object[] newTail = new Object[tail.length + 1];
		System.arraycopy(tail, 0, newTail, 0, tail.length);
		newTail[tail.length] = val;
		return new PersistentVector(cnt + 1, shift, root, newTail);
		}
	//full tail, push into tree
	Node newroot;
	Node tailnode = new Node(tail);
	int newshift = shift;
	//overflow root?
	if((cnt >>> 5) > (1 << shift))
		{
		newroot = new Node();
		newroot.array[0] = root;
		newroot.array[1] = newPath(shift, tailnode);
		newshift += 5;
		}
	else
		newroot = pushTail(shift, root, tailnode);
	return new PersistentVector(cnt + 1, newshift, newroot, new Object[]{val});
}

private Node pushTail(int level, Node parent, Node tailnode){
	//if parent is leaf, insert node,
	// else does it map to an existing child? -> nodeToInsert = pushNode one more level
	// else alloc new path
	//return  nodeToInsert placed in copy of parent
	int subidx = ((cnt - 1) >>> level) & 0x01f;
	Node ret = new Node(parent.array.clone());
	Node nodeToInsert;
	if(level == 5)
		{
		nodeToInsert = tailnode;
		}
	else
		{
		Node child = (Node) parent.array[subidx];
		//System.out.println("child: " + child.toString());
		if (child != null)
		{
		    nodeToInsert = pushTail(level-5,child, tailnode);
		} else {
			nodeToInsert = newPath(level-5, tailnode);
		}
		}
	ret.array[subidx] = nodeToInsert;
	return ret;
}

private static Node newPath(int level, Node node){
	if(level == 0)
		return node;
	Node ret = new Node();
	ret.array[0] = newPath(level - 5, node);
	return ret;
}
}
