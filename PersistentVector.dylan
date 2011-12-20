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

   //if ( ash(element-count(vec), - 5) > lsh(1, shift(vec)))
    // (cnt >>> 5) > (1 << shift))
/*
  format-out("ash %=\n", ash(16, - 3));
  format-out("ash %=\n", ash(16, 3));
  format-out("lsh %=\n", lsh(16, 3));
  format-out("lsh %=\n", lsh(16, - 3));
  */


  for (element  from 1  to 1028)
    pvec := add(pvec, element);
    format-out("%=\n", pvec);
  end for;
  
  //format-out("%=\n", pvec.element-count);
  //format-out("TAILNODE copy test %=", make(<node>, array: pvec.root-tail  ));
  //with-open-file(stream = "/home/nick/dylan.txt", direction: #"output") write(stream, add(pvec, 33)); end;
  //format-out("%=\n", pvec);  
  //format-out("%=", add(pvec, 33));  
  exit-application(0);
end function main;

define method add ( vec :: <PVector>, val ) => (result-vec :: <PVector>)
  let  tail-size = size(vec.root-tail);
  
  if ( tail-size < 32 )
    let new-tail = add( vec.root-tail, val );
    make(<PVector>, size: element-count(vec) + 1, shift: shift(vec), tail: new-tail, root-node: root-node(vec));
  else
    let tailnode = make(<node>, array: vec.root-tail);
    //format-out("\nash(element-count(vec), - 5): %=\n", ash(element-count(vec), - 5));
    //format-out("\nlsh(1, shift(vec)): %=\n", lsh(1, shift(vec)));
    //format-out("\n%=  > %=\n", ash(element-count(vec), - 5), lsh(1, shift(vec)));
    //if ( ash(element-count(vec), - 5) > lsh(1, shift(vec)))
    // (cnt >>> 5) > (1 << shift))
    if (  ash( element-count(vec), - 5) > ash( shift(vec), - 2))
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

define method push-tail ( vec :: <PVector>, level, parent :: <node>, tailnode :: <node>) => ( node :: <node> )
  let subindex :: <integer> = logand( ash( vec.element-count - 1, - level), 31);
  let ret = make(<node>, array: copy-sequence(parent.array)  );
  let node-to-insert = if (level == 5)
			 tailnode
		       else
			 let child = parent.array[subindex];
			 if (child)
			   push-tail( vec, level - 5, child, tailnode);

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