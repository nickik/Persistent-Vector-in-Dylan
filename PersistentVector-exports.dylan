module: dylan-user

define library PersistentVector
  use common-dylan;
  use io;
end library;

define module PersistentVector
  use common-dylan, exclude: { format-to-string };
  use format-out;
  use print;
end module;