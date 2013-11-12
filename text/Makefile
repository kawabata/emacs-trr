SOURCES = C_programs Cpp_programs Elisp_programs Iccad_90 Java_programs \
	Ocaml_programs Python_programs The_Constitution_Of_JAPAN 

TARGETS = $(addsuffix .formed,$(SOURCES))

CONV = ../trr_format.sh

all: $(TARGETS)

.SECONDEXPANSION:

$TARGETS:	
	$(CONV) $@


