package funkin.macros;
#if macro

class FlxSpriteProxyMacro {
    public static function build() {
        return Context.getBuildFields();

        /*
        //TODO: FIX ALL OF THIS
        var parentFields:Array<ClassField> = [];
        var parentFieldsNames:Array<String> = [];
        var superClass = Context.getLocalClass().get().superClass.t.get();
        while(superClass != null) {
            for(e in superClass.fields.get()) {
                if (!parentFieldsNames.contains(e.name) && !e.kind.match(FMethod(MethInline))) {
                    parentFields.push(e);
                    parentFieldsNames.push(e.name);
                }
            }
            if (superClass.superClass != null)
                superClass = superClass.superClass.t.get();
            else
                superClass = null;
        }
        parentFieldsNames = [];
        trace(Context.getLocalType());  
        var fields:Array<Field> = Context.getBuildFields();
        
        // loop through all parent functions
        for(f in parentFields) {
            for(field in fields)
                if (field.name == f.name)
                    continue;
            switch(f.type) {
                case TLazy(lazyFunc):
                    switch(lazyFunc()) {
                        case TFun(args, ret):
                            
                            // its a function / getter / setter! overriding
                            var overFunc:Function = {
                                args: [for(a in args) {
                                    value: null,
                                    type: TypeTools.toComplexType(a.t),
                                    opt: a.opt,
                                    name: a.name
                                }]
                            };
                            var funcName = f.name;

                            var argNames:Array<haxe.macro.Expr> = [];
                            for(a in args)
                                argNames.push({
                                    pos: Context.makePosition({
                                        min: 1,
                                        max: 2,
                                        file: "DeezNuts.hx"
                                    }),
                                    expr: EConst(CIdent(a.name))
                                });
                            if (ret == null) {
                                overFunc.expr = macro {
                                    function test(p1) {
                                        trace(p1);
                                    }
                                    if (this.proxy != null) {
                                        this.proxy.$funcName($a{argNames});
                                        return;
                                    }
                                    super.$funcName($a{argNames});
                                };
                            } else {
                                overFunc.expr = macro {
                                    if (this.proxy != null) {
                                        return this.proxy.$funcName($a{argNames});
                                    }
                                    return super.$funcName($a{argNames});
                                };
                            }
                            var field:Field = {
                                pos: Context.makePosition({
                                    min: 0,
                                    max: 0,
                                    file: "DeezNuts.hx"
                                }),
                                name: f.name,
                                kind: FFun(overFunc),
                                access: [AOverride, APublic]
                            };
                            var p = new Printer();
                            trace(p.printField(field));
                            fields.push(field);
                        default:
                            // nothing
                    }
                default:
                    // nothing
            }
        }

        

        return fields;
        */
    }
}
#end