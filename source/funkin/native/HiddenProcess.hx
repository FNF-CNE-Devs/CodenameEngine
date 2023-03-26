package funkin.native;

typedef HiddenProcess = #if sys sys.io.Process #else Dynamic #end;