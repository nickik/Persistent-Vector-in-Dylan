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
  format-out("PVector: %=Tail: %=\n\n", vec.root-node, vec.root-tail); 
end method print-object;

define function main(name, arguments)
  let pvec = EMPTY-PVector;

  for (element  from 1  to 32)
    pvec := add(pvec, element);
    //format-out("%=\n", pvec);
  end for;
  
  format-out("%=\n", pvec);
  add(pvec, 33);

  exit-application(0);
end function main;

/*
public PersistentVector cons(Object val){
  int i = cnt;
  if(cnt - tailoff() < 32)
  {
    Object[] newTail = new Object[tail.length + 1];
    System.arraycopy(tail, 0, newTail, 0, tail.length);
    newTail[tail.length] = val;
    return new PersistentVector(meta(), cnt + 1, shift, root, newTail);
   }
   Node newroot;
   Node tailnode = new Node(root.edit,tail);
   int newshift = shift;
   //overflow root?
   if((cnt >>> 5) > (1 << shift))
   {
     newroot = new Node(root.edit);
     newroot.array[0] = root;
     newroot.array[1] = newPath(root.edit,shift, tailnode);
     newshift += 5;
   }
   else
     newroot = pushTail(shift, root, tailnode);
   
   return new PersistentVector(meta(), cnt + 1, newshift, newroot, new Object[]{val});
}

*/

define method add ( vec :: <PVector>, val ) => (result-vec :: <PVector>)
  let  tail-size = size(vec.root-tail);
  //format-out("tail-size: %=\n", tail-size);
  //format-out("val: %=\n", val);
  
  if ( tail-size < 32 )
    let new-tail = add( vec.root-tail, val );
    make(<PVector>, size: element-count(vec) + 1, shift: shift(vec), tail: new-tail, root-node: root-node(vec));
  else
    format-out("\n\n\n test test test \n \n \n");
    let tailnode = make(<node>, array: vec.root-tail);
    format-out("\n\ntailnode: %=\n", tailnode);
    format-out("ash(element-count(vec), - 5): %=", ash(element-count(vec), - 5));
    format-out("lsh(1, shift(vec)): %=", lsh(1, shift(vec)));
    format-out("%=  > %=", ash(element-count(vec), - 5), lsh(1, shift(vec)));
    if ( ash(element-count(vec), - 5) > lsh(1, shift(vec)))
      let new-root = make(<node>);
      new-root.array[0] := root-node(vec);
      new-root.array[1] := new-path(vec, shift(vec), tailnode);      
      make(<PVector>, size: element-count(vec) + 1, 
	              shift: shift(vec) + 5, 
                      root-node: new-root, 
                      tail: tailnode);
    else
      let new-root :: <node> = push-tail(vec, shift(vec), root-node(vec), tailnode);
      make(<PVector>, size: element-count(vec) + 1,
                      shift: shift,
                      root-node: new-root,
	              tail: tailnode);
    end if;
  end if;
end method add;

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

define method new-path (vec :: <PVector>, level :: <integer>, node :: <node> ) => ( return-node :: <node> )
  if ( level = 0 )
    node;
  else
    let ret :: <node> = make(<node>);
    ret.array[0] := new-path(vec, level - 5, node);
  end if;
end method new-path;

// Invoke our main() function.
main(application-name(), application-arguments());