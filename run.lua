#! /usr/bin/env luajit

function main()
	-- 実行中のLuaのバージョンを出力
	print("\nLua version : " .. _VERSION)
	if jit then
		print("LuaJIT version : " .. jit.version .. "\n") -- 実行中のLuaJITのバージョンを出力
	else
		print("LuaJIT version : LuaJIT is not being used.\n")
	end

	-- 1回のepocでの文字列連結処理実行回数
	local itr = 1e5

	local ret = check( itr )

	-- 実行結果はtableにしている。それをいい感じに出力する。
	print( dump_table( ret ) )
end

function check(itr)
	local test_name = "auto gc : OFF, manual gc : OFF"
	print("---- " .. test_name .. " ----")
	local ret = {}
	local function add_return_table(ret, test_name, itr, e_f, e_d)
		if ret[test_name] == nil then
			ret[test_name] = print_result(itr, e_f, e_d)
		else
			ret[test_name] = ret[test_name] .. ", " .. print_result(itr, e_f, e_d)
		end
	end

	local reset_gc = false -- 実行中にgcを実行するか
	local num = 4
	for i = 1, num do
		e_f, e_d = check_auto_gc_off(itr, reset_gc)
		add_return_table(ret, test_name, itr, e_f, e_d)
	end

	test_name = "auto gc : OFF, manual gc : ON"
	print("---- " .. test_name .. " ----")
	reset_gc = true -- 実行中に手動でgcを実行するか
	for i = 1, num do
		e_f, e_d = check_auto_gc_off(itr, reset_gc)
		add_return_table(ret, test_name, itr, e_f, e_d)
	end

	test_name = "auto gc : ON, manual gc : OFF"
	print("---- " .. test_name .. " ----")
	reset_gc = false -- 実行中にgcを実行するか
	for i = 1, num do
		e_f, e_d = check_auto_gc_on(itr, reset_gc)
		add_return_table(ret, test_name, itr, e_f, e_d)
	end

	test_name = "auto gc : ON, manual gc : ON"
	print("---- " .. test_name .. " ----")
	reset_gc = true -- 実行中にgcを実行するか
	for i = 1, num do
		e_f, e_d = check_auto_gc_on(itr, reset_gc)
		add_return_table(ret, test_name, itr, e_f, e_d)
	end
	return ret
end

function dump_table(object, st, level)
	if st == nil then
		st = { }
	end
	if level == nil then
		level = 1
	end
	local function add_tab(level)
		local s = ''
		for i = 1, level do
			s = s .. "\t"
		end
		return s
	end
	local function dump_table_recursive(object, st, level)
		if type(object) ~= 'table' then
			return tostring(object)
		end
		if st[level] == nil then
			st[level] = ""
		end
		st[level] = st[level] .. '{\n'
		for k, v in pairs(object) do
			if type(k) ~= 'number' then
				k = '"' .. k .. '"'
			end
			st[level] = st[level] .. add_tab(level) .. string.format("%-16s\t = ", '[' .. k .. ']') .. dump_table_recursive(v, st, level + 1) .. ',\n'
		end
		return st[level] .. add_tab(level - 1) .. '}'
	end
	return dump_table_recursive(object, st, level)
end

 function print_result(itr, e_f, e_d)
	 print("\tTime taken using 'string.format': " .. tostring(e_f) .. " s")
	 print("\tTime taken using '..'           : " .. tostring(e_d) .. " s")
	 local percent = ( 1 - (e_f / e_d)) * 100
	 local ope = percent < 0 and "" or "+"
	 local percent_str = string.format("%s%.2f%%", ope, percent )
	 print(string.format("\t\t>> itr: %-10s, diff ratio '1 - string.format / ..' : %s\n", tostring(itr), percent_str ))
	 return percent_str
 end

 function check_auto_gc_on(itr, reset_gc)
	 print("\t-- check_auto_gc_on --")
	 collectgarbage("restart") -- 自動のGCを開始
	 collectgarbage("collect") -- 手動でGCを実行
	 local e_f = check_format(itr, reset_gc)
	 collectgarbage("collect") -- 手動でGCを実行
	 local e_d = check_dot(itr, reset_gc)
	 return e_f, e_d

 end


 function check_auto_gc_off(itr, reset_gc)
	 print("\t-- check_auto_gc_off --")
	 collectgarbage("stop")    -- 自動のGCを停止
	 collectgarbage("collect") -- 手動でGCを実行
	 local e_f = check_format(itr, reset_gc)
	 collectgarbage("collect") -- 手動でGCを実行
	 local e_d = check_dot(itr, reset_gc)
	 return e_f, e_d

 end

 function check_dot(itr, reset_gc)
	 local start_time = os.clock()
	 local str = ""
	 for i = 1, itr do
		 str = str .. "a"
		 -- 文字列が長くなりすぎると処理が止まるので適度にリセットする。
		 if i % 1e4 == 1e4-1 then
			 str = ""
			 if reset_gc then
				 collectgarbage("collect")
			 end
		 end
	 end
	 local end_time = os.clock()
	 return (end_time - start_time) / 1.0 -- 型を小数にする
 end

 function check_format(itr, reset_gc)
	 local start_time = os.clock()
	 local str = ""
	 for i = 1, itr do
		 str = string.format("%s%s", str, "a")
		 -- 文字列が長くなりすぎると処理が止まるので適度にリセットする。
		 if i % 1e4 == 1e4-1 then
			 str = ""
			 if reset_gc then
				 collectgarbage("collect")
			 end
		 end
	 end
	 local end_time = os.clock()
	 return (end_time - start_time) / 1.0 -- 型を小数にする
 end

 main()

