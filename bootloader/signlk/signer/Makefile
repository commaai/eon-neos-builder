CXX=g++
cur-dir   :=  $(shell pwd)
ELFIODIR=${cur-dir}/ELFIO/elfio/
SOURCES=${cur-dir}/signlk.cpp 
CPPFLAGS=-c -Wall -std=c++0x -I$(cur-dir)/ELFIO/
INCLUDES=$(ELFIODIR)elfio.hpp         $(ELFIODIR)elfio_header.hpp  \
         $(ELFIODIR)elfio_note.hpp    $(ELFIODIR)elfio_section.hpp \
         $(ELFIODIR)elfio_segment.hpp $(ELFIODIR)elfio_strings.hpp \
         $(ELFIODIR)elfio_symbols.hpp $(ELFIODIR)elfio_utils.hpp   \
         $(ELFIODIR)elf_types.hpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=${cur-dir}/signlk

all: $(SOURCES) $(EXECUTABLE) 

$(EXECUTABLE): $(OBJECTS)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
	$(CXX) $(CPPFLAGS) $< -o $@

test: $(EXECUTABLE)
	./$(EXECUTABLE) 

clean:
	rm $(OBJECTS) $(EXECUTABLE)
