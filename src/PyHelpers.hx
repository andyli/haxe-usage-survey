import python.*;
import haxe.macro.*;
import haxe.macro.Expr;

class PyHelpers {
	@:noUsing
	macro static public function kw(exprs:Array<Expr>):Expr {
		var objd = {
			expr: EObjectDecl([for(e in exprs) switch (e) {
				case macro $i{k} => $v:
					{
						field: k,
						expr: v
					}
				case _:
					Context.error("Invalid expr. Should be in the form of `key => value`.", e.pos);
			}]),
			pos: Context.currentPos()
		};
		return macro ($objd:python.KwArgs<Dynamic>);
	}
}

#if !macro
class IterableAdaptor {
	static public function iterator<T>(it:NativeIterable<T>)
		return Lib.toHaxeIterable(it).iterator();
}

class IteratorAdaptor {
	static public function iterator<T>(it:NativeIterator<T>)
		return Lib.toHaxeIterator(it);
}
#end