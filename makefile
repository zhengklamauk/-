obj=winmine_wg.obj winmine_wg.res
cfile=winmine_wg.obj winmine_wg.res winmine_wg.exe

winmine_wg.exe:$(obj)
	link /subsystem:windows $(obj)

winmine_wg.obj:winmine_wg.asm
	ml /c /coff winmine_wg.asm

winmine_wg.res:winmine_wg.rc
	rc winmine_wg.rc

clean:
	-del $(cfile)