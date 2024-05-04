package funkin.backend.system.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Utils {
	macro public static function generateReflectionLike(totalArguments:Int, funcName:String, argsName:String) {
		#if macro
		totalArguments++;

		var funcCalls = [];
		for(i in 0...totalArguments) {
			var args = [
				for(d in 0...i) macro $i{argsName}[$v{d}]
			];

			funcCalls.push(macro $i{funcName}($a{args}));
		}

		var expr = {
			pos: Context.currentPos(),
			expr: ESwitch(
				macro ($i{argsName}.length),
				[
					for(i in 0...totalArguments) {
						values: [macro $v{i}],
						expr: funcCalls[i],
						guard: null,
					}
				],
				macro throw "Too many arguments"
			)
		}

		return expr;
		#end
	}

	public static macro function safeSet(variable:Null<Expr>, value:Null<Expr>):Null<Expr> {
		#if macro
		return macro if (${value} != null) ${variable} = ${value};
		#end
	}
	public static macro function safeSetWrapper(variable:Null<Expr>, value:Null<Expr>, wrapper:Null<Expr>):Null<Expr> {
		#if macro
		return macro if (${value} != null) ${variable} = ${wrapper}(${value});
		#end
	}

	public static macro function safeReflection(variable:Null<Expr>, value:Null<Expr>, field:Null<Expr>):Null<Expr> {
		#if macro
		return macro if (Reflect.hasField(${value}, ${field})) ${variable} = Reflect.field(${value}, ${field});
		#end
	}
}