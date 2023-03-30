package funkin.macros;

class SoftcodedClassMacro {
	#if macro
	public static function init() {
		trace("cock and balls");
		// Compiler.addGlobalMetadata('funkin.game', '@:build(funkin.macros.SoftcodedClassMacro.build())');
	}

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass();

		var funcs:Array<Field> = [];
		if (cl != null) {
			var c = cl.get();
			if (c.isAbstract) return fields;

			for(m in c.meta.get()) {
				switch(m.name) {
					case ":final", ":noSoftcodedExtend":
						return fields;
					default:
						// cool
				}
			}

			for(f in fields) {
				var valid = true;
				if (f.access != null) for(e in f.access) {
					switch (e) {
						case AStatic | ADynamic | AInline | AMacro | AFinal | AExtern | AAbstract:
							valid = false;
							break;
						default:
							// nothing
					}
				}

				if (!valid) continue;

				switch(f.kind) {
					case FFun(fun):
						var funcExpr = macro {
							${{
								pos: Context.currentPos(),
								expr: ECall({
									pos: Context.currentPos(),
									expr: EField({
										pos: Context.currentPos(),
										expr: EConst(CIdent("super"))
									}, f.name)
								}, fun.args != null ? [for(a in fun.args) {
									pos: Context.currentPos(),
									expr: EConst(CIdent(a.name))
								}] : [])
							}};
						};
						
						var accessors = [];
						if (f.access != null) for(f in f.access) accessors.push(f);
						accessors.remove(AOverride);
						
						if (f.name != "new") {
							var func:Function = {
								expr: funcExpr,
								args: fun.args
							};
							funcs.push({
								pos: Context.currentPos(),
								name: '__super__${f.name}',
								kind: FFun(func),
								access: accessors
							});
						}

						accessors.push(AOverride);

						var overrideFuncExpr = macro {
							var fieldName = ${{
								pos: Context.currentPos(),
								expr: EConst(CString(f.name, DoubleQuotes))
							}};
							if (__scriptClass != null && __scriptClass.hasField(fieldName) && Reflect.isFunction(__scriptClass.get(fieldName))) {
								__scriptClass.call(fieldName, ${{
									pos: Context.currentPos(),
									expr: EArrayDecl([for(a in fun.args) {
										pos: Context.currentPos(),
										expr: EConst(CIdent(a.name))
									}])
								}});
							} else ${funcExpr}
						};

						var overrideFunc:Function = {
							expr: overrideFuncExpr,
							args: fun.args
						};
						funcs.push({
							pos: Context.currentPos(),
							name: '${f.name}',
							kind: FFun(overrideFunc),
							access: accessors
						});



						var printer = new Printer();
						trace(printer.printField(funcs[funcs.length - 1]));
					default:

				}
			}
		}
		return fields;
	}
	#end
}