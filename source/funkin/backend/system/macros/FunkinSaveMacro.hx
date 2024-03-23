package funkin.backend.system.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * Macro that automatically generates flush and load functions.
 */
class FunkinSaveMacro {
	/**
	 * Generates flush and load functions.
	 * @param saveFieldName Name of the save field (`save`)
	 * @param saveFuncName Name of the save func (`flush`)
	 * @param loadFuncName Name of the load func (`load`)
	 * @return Array<Field>
	 */
	public static function build(saveFieldName:String = "save", saveFuncName:String = "flush", loadFuncName:String = "load"):Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();

		var fieldNames:Array<String> = [];
		for(field in fields) {
			if (!field.access.contains(AStatic)) continue;

			switch(field.kind) {
				case FVar(type, expr):
					if (field.name == saveFieldName) continue;
					var valid:Bool = true;
					if (field.meta != null)
						for(m in field.meta)
							if (m.name == ":doNotSave") {
								valid = false;
								break;
							}
					if (valid)
						fieldNames.push(field.name);
				default:
					continue;
			}
		}

		/**
		 * SAVE FUNCTION
		 */
		var saveFuncBlocks:Array<Expr> = [for(f in fieldNames)
			macro ${{
				pos: Context.currentPos(),
				expr: EConst(CIdent(saveFieldName))
			}}.data.$f = ${{
				pos: Context.currentPos(),
				expr: EConst(CIdent(f))
			}}
		];

		saveFuncBlocks.push(macro ${{
			pos: Context.currentPos(),
			expr: EConst(CIdent(saveFieldName))
		}}.flush());

		fields.push({
			pos: Context.currentPos(),
			name: saveFuncName,
			kind: FFun({
				args: [],
				expr: {
					pos: Context.currentPos(),
					expr: EBlock(saveFuncBlocks)
				}
			}),
			access: [APublic, AStatic]
		});

		/**
		 * LOAD FUNCTION
		 */
		fields.push({
			pos: Context.currentPos(),
			name: loadFuncName,
			kind: FFun({
				args: [],
				expr: {
					pos: Context.currentPos(),
					expr: EBlock([for(f in fieldNames)
						macro if (${{
							pos: Context.currentPos(),
							expr: EConst(CIdent(saveFieldName))
						}}.data.$f != null) ${{
							pos: Context.currentPos(),
							expr: EConst(CIdent(f))
						}} = ${{
							pos: Context.currentPos(),
							expr: EConst(CIdent(saveFieldName))
						}}.data.$f
					])
				}
			}),
			access: [APublic, AStatic]
		});

		return fields;
	}
}
#end