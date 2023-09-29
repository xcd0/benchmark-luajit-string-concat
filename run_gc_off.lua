#! /usr/bin/env luajit

-- gcがOFFの状態で何度も実行するテスト

flag_print = false

function main()
	-- 実行中のLuaのバージョンを出力
	if flag_print then
		print("\nLua version \t: " .. _VERSION)
		if jit then
			print("LuaJIT version \t: " .. jit.version .. "\n") -- 実行中のLuaJITのバージョンを出力
		else
			print("LuaJIT version \t: LuaJIT is not being used.\n")
		end
	end

	-- epocの実行回数
	local epoc_num = 100
	-- 1回のepocでの文字列連結処理実行回数
	local itr = 1e4

	local ret = check( epoc_num, itr )

	-- 実行結果はtableにしている。それをいい感じに出力する。
	--print( dump_table( ret ) )

	-- csv形式で出力する。
	print( string.format( "%s,%s", "e_f", "e_d" ) )
	for i = 1, epoc_num do
		print( string.format( "%f,%f", ret["e_f"][i], ret["e_d"][i] ) )
	end
end

function check(epoc_num, itr)
	local test_name = "auto gc : OFF, manual gc : OFF"
	local ret = {}
	ret["e_f"] = {}
	ret["e_d"] = {}

	if flag_print then
		print("---- " .. test_name .. " ----")
	end
	local reset_gc = false -- 実行中にgcを実行するか
	for epoc = 1, epoc_num do
		e_f, e_d = check_auto_gc_off(itr, reset_gc)
		ret["e_f"][epoc] = e_f * 1000 -- ms相当にする
		ret["e_d"][epoc] = e_d * 1000 -- ms相当にする
		if flag_print then
			print_result(epoc, itr, e_f, e_d)
		end
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

function print_result(epoc, itr, e_f, e_d)
	local percent = ( 1 - (e_f / e_d)) * 100
	local ope = percent < 0 and "" or "+"
	local percent_str = string.format("%s%.2f%%", ope, percent )
	local str = ("\tepoc : " .. epoc)
		.. "\n" .. ("\t\tTime taken using 'string.format': " .. tostring(e_f) .. " s")
		.. "\n" .. ("\t\tTime taken using '..'           : " .. tostring(e_d) .. " s")
		.. "\n" .. string.format("\t\t\t>> itr: %-10s, diff ratio '1 - string.format / ..' : %s\n", tostring(itr), percent_str )
	print(str)
	--return percent_str
	return percent
end

function check_auto_gc_off(itr, reset_gc)
	if flag_print then
		print("\t-- check_auto_gc_off --")
	end
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

