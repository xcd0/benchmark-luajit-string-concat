all:
	@/bin/echo -e "luajit : `which luajit`\n"
	luajit run.lua | tee run.log

