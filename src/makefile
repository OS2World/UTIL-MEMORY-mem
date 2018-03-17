#
# Makefile for Mem - Assembler version 1.0
#
# Bob Eager   June 1998
#
# Product name
#
PRODUCT		= mem
#
# Target directory
#
TARGET		= f:\binp
#
#
# Compiler setup
#
AS		= alp
!IFDEF DEBUG
DBUG		= -DDEBUG
!ELSE
DBUG		=
!ENDIF
AFLAGS		= -Fl+ -Lc- -Li- -Lm+ -Lr- -Ls+ -Mb- -Sv:alp
#
# Names of object files
#
OBJ =		mem.obj
#
# Other files
#
DEF =		$(PRODUCT).def
LNK =		$(PRODUCT).lnk
#
# Final executable file
#
EXE =		$(PRODUCT).exe
#
#-----------------------------------------------------------------------------
#
#install:	$(EXE)
#		@copy $(EXE) $(TARGET) > nul
#
$(EXE):		$(OBJ) $(LNK) $(DEF)
!IFDEF	PROD
		ilink /nologo /exepack:2 @$(LNK)
		lxlite $(EXE)
!ELSE
		ilink /debug /nobrowse /nologo @$(LNK)
!ENDIF
#
# Object files
#
mem.obj:	mem.asm
		$(AS) $(AFLAGS) $*
#
# Linker response file. Rebuild if makefile changes
#
$(LNK):		makefile
		@if exist $(LNK) erase $(LNK)
		@echo /map:$(PRODUCT) >> $(LNK)
		@echo /out:$(PRODUCT) >> $(LNK)
		@echo $(OBJ) >> $(LNK)
		@echo $(DEF) >> $(LNK)
#
clean:		
		-erase $(OBJ) $(LNK) $(PRODUCT).map $(PRODUCT).lst
#
release:	$(EXE) readme.txt
		rm -f mem.zip
		zip -9 -j mem.zip readme.txt $(EXE)
#
# End of makefile for Mem
#
