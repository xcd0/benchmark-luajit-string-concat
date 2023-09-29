all:
	@/bin/echo -e "luajit : `which luajit`\n"
	stdbuf -oL luajit run.lua | tee run.log

run:
	# stdbufやteeが使えない環境向け
	luajit run.lua > run.log

gc-off:
	stdbuf -oL luajit run_gc_off.lua | tee run_gc_off.log
