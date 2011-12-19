module: PersistentVector
synopsis: 
author: 
copyright: 


define constant EMPTY-NODE :: <node> = make(<node>);
define constant EMPTY-PVector :: <PVector> = make(<PVector>);


define class <node> (<object>)
  constant slot array :: <vector> = make(<vector>), init-keyword:  array:;
end class <node>;

define method print-object ( node ::<node> , stream :: <stream> ) => ()
  format-out("%=", node.array)
end method print-object;

define class <PVector>(<sequence>)
  constant slot element-count :: <integer> = 0, init-keyword: size:;
  // ( depth-level + 1 ) * 5 = shift 
  constant slot shift :: <integer> = 5, init-keyword: shift:;
  constant slot root-tail :: <vector> = make(<vector>), init-keyword: tail:;
  constant slot root-node :: <node> = EMPTY-NODE, init-keyword: root-node:;
  //constant slot tailoff :: <integer> = element-count - size(tail);
end class <PVector>;

define method tailoff ( vector :: <PVector> )
  element-count(vector) - size(vector.root-tail);
end method tailoff;

define method print-object ( vec :: <PVector>, stream :: <stream>) => ()
  format-out("PVector[Node[%=] tail[%=]", vec.root-node, vec.root-tail); 
end method print-object;

define function main(name, arguments)
  //let pvec = add( EMPTY-PVector, 1);
  //let pvec2 = add(pvec, 2);
  //format-out("pvec: %=   \n\n  pvec2: %=\n", pvec, pvec2);
  let vec = make(<vector>, size: 5, fill: 1);

  format-out("type of copy-seq (vec): %=\n", object-class ( copy-sequence(vec)));
  format-out("vec is type  %=\n", object-class(vec));
  format-out("shallow-copy(vec) is type %=\n", object-class( shallow-copy(vec)));
  format-out("vec[1] == shallow(vec)[1] => %=\n", vec[1] == shallow-copy(vec)[1]);
  format-out("type-for-copy(vec) is tpye %=\n", object-class( type-for-copy(vec)));
  format-out("1 = 1 %=\n", 1 = 1);
  format-out("1 == 2-1 %=\n", 1 == 2 - 1); 
  exit-application(0);
end function main;

define method add ( vec :: <PVector>, val ) => (result-vec :: <PVector>)
  let  tail-size = size(vec.root-tail);

  if ( tail-size < 32 )
    let new-tail = add( vec.root-tail, val );
    make(<PVector>, size: element-count(vec) + 1, shift: shift(vec), tail: new-tail, root-node: root-node(vec));
  else
    let tailnode = make(<node>, array: root-tail(vec)); 
    let new-shift = shift(vec);
    let new-root =  push-tail ( vec, shift(vec), root-node(vec), tailnode);
    make(<PVector>, size: element-count(vec) + 1, shift: new-shift, root-node: new-root, tail: tailnode );
  end if;

/*
  else
    let tailnode = make(<node>, array: vec.root-tail);
    define variable new-root :: <node>;
    define variable new-shift :: <integer> = shift(vec);
    if ( ash(element-count(vec), - 5) > lsh(1, shift(vec)) )
      new-root := make(<node>);
      new-root.array[0] := root-node(vec);
      new-root.array[1] := new-path(root-node(vec), shift(vec), new-tail);
      new-shift = new-shift + 5;
    else
      new-root := pushTail( shift(vec), root-node(vec), new-tail);
    end if
    make(<PVector>, size: element-count(vec)+1, shift: new-shift, root-node: new-root, tail:  );
  end if;
*/
end method add;

/*
private Node pushTail(int level, Node parent, Node tailnode){
  //if parent is leaf, insert node,
  // else does it map to an existing child? -> nodeToInsert = pushNode one more level
  // else alloc new path
  //return nodeToInsert placed in copy of parent
  int subidx = ((cnt - 1) >>> level) & 0x01f;
  Node ret = new Node(parent.edit, parent.array.clone());
  Node nodeToInsert;
  if(level == 5)
  {
     nodeToInsert = tailnode;
  }
  else
  {
     Node child = (Node) parent.array[subidx];
     nodeToInsert = (child != null)?
     pushTail(level-5,child, tailnode)
     :newPath(root.edit,level-5, tailnode);
  }
  ret.array[subidx] = nodeToInsert;
  return ret;
}
*/

define method push-tail ( vec :: <PVector>, level, parent :: <node>, tailnode :: <node>) => ( node :: <node> )
  let subindex :: <integer> = logand( ash( vec.element-count - 1, - level), 31);
  let ret = make(<node>, array: copy-sequence(parent.array)  );
  let node-to-insert = if (level == 5)
			 tailnode
		       else
			 let child = parent.array[subindex];
			 if (child)
			   push-tail( vec, level - 5, child, tailnode);
			 else
			   new-path (vec, level - 5, tailnode);
			 end if;
		       end if;
  ret.array[subindex] := node-to-insert;
end method push-tail;

/*
private static Node newPath(AtomicReference<Thread> edit,int level, Node node){
  if(level == 0)
     return node;
  Node ret = new Node(edit);
  ret.array[0] = newPath(edit, level - 5, node);
  return ret;
}
*/

define method new-path (vec :: <PVector>, level :: <integer>, node :: <node> ) => ( nod :: <node> )
  if ( level = 0 )
    node;
  else
    node;
    let ret :: <node> = make(<node>);
    ret.array[0] := new-path( vec, level - 5, node);
  end if;
end method new-path;

// Invoke our main() function.
main(application-name(), application-arguments());