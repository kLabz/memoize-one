package;

import haxe.Json;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

class MemoizeOne {
	public static macro function memoize(fExpr:Expr):Expr {
		switch (Context.typeof(fExpr)) {
			case TFun(_, t) if (isVoid(t)):
				// TODO: error

			case TFun(args, ret):
				// TODO: create custom (optimized) serializer
				return macro MemoizeOne.memoizeOne(${fExpr});

			default:
				// TODO: error
		}

		return macro {};
	}

	public static function memoizeOne<T:haxe.Constraints.Function, TSerialized, TRet>(
		f:T,
		?serializer:Dynamic->TSerialized
	):T {
		if (serializer == null) serializer = cast Json.stringify.bind(_, null, null);

		var previousValue:Null<TRet> = null;
		var previousArgs:Null<TSerialized> = null;

		return Reflect.makeVarArgs(function(args:Array<Dynamic>):TRet {
			var strArgs = serializer(args);

			if (previousValue == null || strArgs != previousArgs) {
				previousArgs = strArgs;
				previousValue = Reflect.callMethod(null, f, args);
			}

			return previousValue;
		});
	}

	#if macro
	static function isVoid(t:Type):Bool {
		return switch (t) {
			case TAbstract(_.get() => {module: "StdTypes", name: "Void"}, []):
				true;

			default:
				false;
		}
	}
	#end
}
