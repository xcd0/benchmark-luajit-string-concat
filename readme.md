# luajitで文字列連結処理のベンチ

`..`による文字列連結と、string.format()による文字列連結のどちらが速いかを調べる目的で書いた。  
単純に文字を追加していく。  
正当性は不明。  

GCの影響があるのでGCの使い方を変えながら比較した。  
文字列が長くなると、文字列連結処理自体が大変時間がかかるので、ある程度長くなったらリセットしている。  
連結する文字列の長さで性能に違いがあるかもしれないが、そこまでは比較していない。  

## 結論

このベンチでの結論は、大きな性能差はない結果になった。  
よって、コーディング中に書きやすい方を使用すべき、という結論とする。  

強いて言えば、'..'のほうがGCに時間がかかっているように見える。  
GCをOFFにしたとき'..'のほうが若干速く、GCがONの時string.formatのほうが若干速いかもしれない。  

実行するたびに数%ぶれるので、このぶれが統計的に有意なのか計算するべきだと思われるが、  
現状面倒で、というか数%くらいの有意性ならコーディング中に書きやすい方を使用すべきだと思うので、  
そこまではやっていない。

```
{  
	["auto gc : ON, manual gc : OFF"]	 = +0.12%, +5.35%, +1.16%, -1.65%,  
	["auto gc : ON, manual gc : ON"]	 = +4.85%, +0.16%, +2.54%, +2.03%,  
	["auto gc : OFF, manual gc : ON"]	 = +1.66%, -1.18%, +1.98%, +8.20%,  
	["auto gc : OFF, manual gc : OFF"]	 = +2.94%, -12.69%, -2.37%, +0.20%,  
}
```

## 実行例

```sh
$ ./run.lua

Lua version : Lua 5.1
LuaJIT version : LuaJIT 2.1.0-beta3

---- auto gc : OFF, manual gc : OFF ----
	-- check_auto_gc_off --
	Time taken using 'string.format': 0.060961 s
	Time taken using '..'           : 0.062806 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +2.94%

	-- check_auto_gc_off --
	Time taken using 'string.format': 0.06562 s
	Time taken using '..'           : 0.058232 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : -12.69%

	-- check_auto_gc_off --
	Time taken using 'string.format': 0.05931 s
	Time taken using '..'           : 0.057937 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : -2.37%

	-- check_auto_gc_off --
	Time taken using 'string.format': 0.057028 s
	Time taken using '..'           : 0.05714 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +0.20%

---- auto gc : OFF, manual gc : ON ----
	-- check_auto_gc_off --
	Time taken using 'string.format': 0.056409 s
	Time taken using '..'           : 0.057359 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +1.66%

	-- check_auto_gc_off --
	Time taken using 'string.format': 0.058595 s
	Time taken using '..'           : 0.05791 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : -1.18%

	-- check_auto_gc_off --
	Time taken using 'string.format': 0.055925 s
	Time taken using '..'           : 0.057056 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +1.98%

	-- check_auto_gc_off --
	Time taken using 'string.format': 0.056067 s
	Time taken using '..'           : 0.061076 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +8.20%

---- auto gc : ON, manual gc : OFF ----
	-- check_auto_gc_on --
	Time taken using 'string.format': 0.056755 s
	Time taken using '..'           : 0.056823 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +0.12%

	-- check_auto_gc_on --
	Time taken using 'string.format': 0.056282 s
	Time taken using '..'           : 0.059466 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +5.35%

	-- check_auto_gc_on --
	Time taken using 'string.format': 0.056767 s
	Time taken using '..'           : 0.057433 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +1.16%

	-- check_auto_gc_on --
	Time taken using 'string.format': 0.055856 s
	Time taken using '..'           : 0.054951 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : -1.65%

---- auto gc : ON, manual gc : ON ----
	-- check_auto_gc_on --
	Time taken using 'string.format': 0.053236 s
	Time taken using '..'           : 0.055948 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +4.85%

	-- check_auto_gc_on --
	Time taken using 'string.format': 0.054517 s
	Time taken using '..'           : 0.054606 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +0.16%

	-- check_auto_gc_on --
	Time taken using 'string.format': 0.053759 s
	Time taken using '..'           : 0.055158 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +2.54%

	-- check_auto_gc_on --
	Time taken using 'string.format': 0.0552 s
	Time taken using '..'           : 0.056341 s
		>> itr: 100000    , diff ratio '1 - string.format / ..' : +2.03%

{
	["auto gc : ON, manual gc : OFF"]	 = +0.12%, +5.35%, +1.16%, -1.65%,
	["auto gc : ON, manual gc : ON"]	 = +4.85%, +0.16%, +2.54%, +2.03%,
	["auto gc : OFF, manual gc : ON"]	 = +1.66%, -1.18%, +1.98%, +8.20%,
	["auto gc : OFF, manual gc : OFF"]	 = +2.94%, -12.69%, -2.37%, +0.20%,
}
```
