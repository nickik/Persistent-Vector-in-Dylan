module: PersistentVector
synopsis: 
author: 
copyright: 


define constant EMPTY-NODE :: <node> = make(<node>);
define constant EMPTY-PVector :: <PVector> = make(<PVector>);

define class <node> (<object>)
  constant slot array :: <vector> = make(<vector>, size: 32), init-keyword:  array:;
end class <node>;

define method print-object ( node ::<node> , stream :: <stream> ) => ()
  format-out("%=\n", node.array);
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
  format-out("PVector:\n%=Tail: %=\n\n", vec.root-node, vec.root-tail); 
end method print-object;

define function main(name, arguments)
  let pvec = EMPTY-PVector;
  for (element  from 0  to 1000)
    pvec := add(pvec, element);
  end for; 
  format-out("%=\n", my-element(pvec, 1000, notfound: "maan!!"));
  format-out("size %=\n", size(pvec));
  format-out("emplty?: %=\n", empty?(pvec));
  format-out("key-sequence: %=\n", key-sequence(pvec));
  exit-application(0);
end function main;

define method add ( vec :: <PVector>, val ) => (result-vec :: <PVector>)
  let  tail-size = size(vec.root-tail);  
  if ( tail-size < 32 )
    let new-tail = add( vec.root-tail, val );
    make(<PVector>, size: element-count(vec) + 1, shift: shift(vec), tail: new-tail, root-node: root-node(vec));
  else
    let tailnode = make(<node>, array: vec.root-tail);
    if ( ash( element-count(vec), - 5) > lsh(1, shift(vec)))
      let new-root = make(<node>);
      new-root.array[0] := root-node(vec);
      new-root.array[1] := new-path(vec, shift(vec), tailnode);      
      make(<PVector>, size: element-count(vec) + 1, 
	              shift: shift(vec) + 5, 
                      root-node: new-root, 
                      tail: add(make(<vector>), val));
    else
      let new-root :: <node> = push-tail(vec, shift(vec), root-node(vec), tailnode);
      make(<PVector>, size: element-count(vec) + 1,
                      shift: shift(vec),
                      root-node: new-root,
	              tail: add( make(<vector>), val));
    end if;
  end if;
end method add;

define method size (vec :: <PVector>) => (i :: <integer>)
  element-count(vec);
end method size;

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
  ret;
end method push-tail;

define method new-path (vec :: <PVector>, level :: <integer>, node :: <node> ) => ( return-node :: <node> )
  if ( level = 0 )
    node;
  else
    let ret :: <node> = make(<node>);
    ret.array[0] := new-path(vec, level - 5, node);
  end if;
end method new-path;

define method my-element(vec :: <PVector>, key, #key notfound) => ( obj :: <object>)
  if ( key >= 0 &  key < element-count(vec))
    if ( key >= element-count(vec) - size(root-tail(vec)) )
      root-tail(vec)[ logand( key, 31 )]
    else
      let node-array :: <vector> = array(root-node(vec));
      for (level from shift(vec) above  0 by - 5)
	node-array := array(node-array[logand( ash(key, level), 31)]);
      end for;
      node-array[logand( key, 31)];
    end if;
  else
    notfound;
  end if;
end method my-element;





/*
if(i >= 0 && i < cnt)
{
	if(i >= tailoff())
	return tail;
	Node node = root;
	for(int level = shift; level > 0; level -= 5)
	   node = (Node) node.array[(i >>> level) & 0x01f];
	return node.array;
}
*/

/*if (i >= 0 && i < length) {
      if (i >= tailOff) {
        tail(i & 0x01f).asInstanceOf[T]
      } else {
        var arr = trie(i)
        arr(i & 0x01f).asInstanceOf[T]
      }
    } else throw new IndexOutOfBoundsException(i.toString)*/

// Invoke our main() function.
main(application-name(), application-arguments());