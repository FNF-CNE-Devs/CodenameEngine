package funkin.macros;

using StringTools;
class SoftcodedClassMacro {
	#if macro
	public static function init() {
		trace("cock and balls");
		Compiler.addGlobalMetadata('funkin', '@:build(funkin.macros.SoftcodedClassMacro.build())');
		Compiler.addGlobalMetadata('flixel', '@:build(funkin.macros.SoftcodedClassMacro.build())');
	}

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass();

		if (cl != null) {
			var scriptClassType = TPath({
				pack: ['funkin', 'scripting'],
				name: 'Script',
				sub: 'ScriptClass'
			});

			var funcs:Array<Field> = [];
			funcs.push({
				pos: Context.currentPos(),
				name: '__scriptClass',
				kind: FVar(scriptClassType, macro null)
			});
			var c = cl.get();
			trace(c.name);
			if (c.name.endsWith('__Softcoded')) return fields;
			if (c.params.length > 0) return fields; // NOT SUPPORTED
			if (c.isAbstract) return fields;

			for(m in c.meta.get()) {
				switch(m.name) {
					case ":final", ":noSoftcodedExtend":
						return fields;
					default:
						// cool
				}
			}

			var shadowClass = macro class {

			};

			shadowClass.name = '${c.name}__Softcoded';
			shadowClass.fields = funcs;
			shadowClass.pack = c.pack; // todo
			shadowClass.kind = TDClass({
				pack: c.pack,
				name: c.name
			}, [], false, false, false);

			for(f in [for(f in fields) f]) {
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

						var isVoid = fun.ret.match(TPath({name: "Void"}));

						if (!isVoid)
							funcExpr = macro return ${funcExpr};
						
						var accessors = [];
						if (f.access != null) for(f in f.access) accessors.push(f);
						accessors.remove(AOverride);
						
						if (f.name == "new") {
							var constructorExpr = macro {
								${{
									expr: ECall({
										pos: Context.currentPos(),
										expr: EConst(CIdent("super"))
									}, fun.args != null ? [for(a in fun.args) {
										pos: Context.currentPos(),
										expr: EConst(CIdent(a.name))
									}] : []),
									pos: Context.currentPos()
								}}

								__scriptClass = scrObj;

								__scriptClass.call("new", ${{
									pos: Context.currentPos(),
									expr: EArrayDecl([for(a in fun.args) {
										pos: Context.currentPos(),
										expr: EConst(CIdent(a.name))
									}])
								}}, this);

							}
							var func:Function = {
								expr: constructorExpr,
								args: [for(a in fun.args) a]
							};
							func.args.insert(0, {
								name: "scrObj",
								type: scriptClassType
							});
							funcs.push({
								pos: Context.currentPos(),
								name: 'new',
								kind: FFun(func),
								access: [for(a in accessors) a]
							});


							var printer = new Printer();

							continue;
						} else {
							var func:Function = {
								expr: funcExpr,
								args: fun.args
							};
							funcs.push({
								pos: Context.currentPos(),
								name: '__super__${f.name}',
								kind: FFun(func),
								access: [for(a in accessors) a]
							});
						}

						accessors.push(AOverride);

						var overrideFuncExpr = isVoid ? macro {
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
								}}, this);
							} else ${funcExpr}
						} : macro {
							var fieldName = ${{
								pos: Context.currentPos(),
								expr: EConst(CString(f.name, DoubleQuotes))
							}};
							if (__scriptClass != null && __scriptClass.hasField(fieldName) && Reflect.isFunction(__scriptClass.get(fieldName))) {
								return __scriptClass.call(fieldName, ${{
									pos: Context.currentPos(),
									expr: EArrayDecl([for(a in fun.args) {
										pos: Context.currentPos(),
										expr: EConst(CIdent(a.name))
									}])
								}}, this);
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

					default:

				}
			}

			var imports = [for(i in Context.getLocalImports()) i];
			imports.push({
				path: [for(p in c.module.split(".")) {
					pos: Context.currentPos(),
					name: p
				}],
				mode: IAll
			});
			imports.push({
				path: [for(p in c.module.split(".")) {
					pos: Context.currentPos(),
					name: p
				}],
				mode: INormal
			});

			Context.defineModule(c.module + "__Softcoded", [shadowClass], imports);
		}
		return fields;
	}
	#end
}