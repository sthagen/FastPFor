#
.SUFFIXES:
#
.SUFFIXES: .cpp .o .c .h
# replace the YOURCXX variable with a path to a C++11 compatible compiler.
YOURCXX ?= g++-4.7
CXX := $(YOURCXX)

# todo: allow custom architectures , e.g., -march=nocona -march=corei7
CXXFLAGSEXTRA = -mssse3 # necessary for varintg8iu 
CXXFLAGS = $(CXXFLAGSEXTRA) -ggdb -std=c++0x -Weffc++ -pedantic -O3 -Wold-style-cast -Wall -Wextra -Wcast-align -Wunsafe-loop-optimizations -Wcast-qual


HEADERS = ./headers/common.h ./headers/memutil.h ./headers/pfor.h ./headers/pfor2008.h ./headers/bitpackingunaligned.h ./headers/bitpackingaligned.h ./headers/blockpacking.h ./headers/deltaio.h ./headers/codecfactory.h ./headers/packingvectors.h ./headers/compositecodec.h ./headers/cpubenchmark.h  ./headers/maropuparser.h ./headers/bitpacking.h  ./headers/util.h ./headers/simple9.h ./headers/simple8b.h ./headers/simple16.h ./headers/optpfor.h ./headers/newpfor.h ./headers/vsencoding.h ./headers/mersenne.h  ./headers/ztimer.h ./headers/codecs.h ./headers/synthetic.h ./headers/fastpfor.h ./headers/variablebyte.h ./headers/stringutil.h ./headers/entropy.h ./headers/VarIntG8IU.h 

all: unit codecs iotests gapencoder gapdecoder csv2maropu

test: unit
	./unit

#search to find which is the important parameter.  Turns out that there are 2.  Note that 400 insns was not enough
#GCCPARAMS=  --param max-completely-peel-times=32  --param max-completely-peeled-insns=800 # --param max-peeled-insns=1000  # --param max-unrolled-insns=1000 # --param max-average-unrolled-insns=500 --param max-unroll-times=32 --param max-peel-times=32

GCCPARAMS=  --param max-completely-peel-times=64  --param max-completely-peeled-insns=5000 --param max-peeled-insns=6000  --param max-unrolled-insns=6000 --param max-average-unrolled-insns=4000  --param max-unroll-times=64 --param max-peel-times=64

./headers/common.h.gch: 
	$(CXX) $(CXXFLAGS) -x c++-header  -c ./headers/common.h -Iheaders

COMMONBINARIES=bitpacking.o bitpackingaligned.o bitpackingunaligned.o

bitpacking.o: ./headers/bitpacking.h ./src/bitpacking.cpp
	$(CXX) $(CXXFLAGS) -c ./src/bitpacking.cpp -Iheaders

bitpackingunaligned.o: ./headers/bitpacking.h ./src/bitpackingunaligned.cpp
	$(CXX) $(CXXFLAGS) -c ./src/bitpackingunaligned.cpp -Iheaders

bitpackingaligned.o: ./headers/bitpacking.h ./src/bitpackingaligned.cpp
	$(CXX) $(CXXFLAGS) -c ./src/bitpackingaligned.cpp -Iheaders

gapstats: $(HEADERS) src/gapstats.cpp
	$(CXX) $(CXXFLAGS) -o gapstats src/gapstats.cpp -Iheaders

partitionbylength: $(HEADERS) src/partitionbylength.cpp
	$(CXX) $(CXXFLAGS) -o partitionbylength src/partitionbylength.cpp -Iheaders


codecs:  $(HEADERS) src/codecs.cpp ./headers/common.h.gch makefile $(COMMONBINARIES)
	$(CXX) $(CXXFLAGS) $(GCCPARAMS) -Winvalid-pch  -o codecs src/codecs.cpp $(COMMONBINARIES) -Iheaders

iotests:  $(HEADERS) src/iotests.cpp ./headers/common.h.gch $(COMMONBINARIES)
	$(CXX) $(CXXFLAGS) $(GCCPARAMS) -Winvalid-pch  -o iotests src/iotests.cpp $(COMMONBINARIES)  -Iheaders

cppcheck: 
	cppcheck --std=c++11 --enable=all $(HEADERS) src/codecs.cpp src/iotests.cpp

csv2maropu:  $(HEADERS) src/csv2maropu.cpp ./headers/externalvector.h ./headers/csv.h
	$(CXX)  $(CXXFLAGS) -o csv2maropu src/csv2maropu.cpp  -Iheaders

gapdecoder: $(HEADERS) src/gapdecoder.cpp makefile ./headers/common.h.gch $(COMMONBINARIES)
	$(CXX) $(CXXFLAGS) $(GCCPARAMS)  -Winvalid-pch -o gapdecoder src/gapdecoder.cpp $(COMMONBINARIES) -Iheaders


gapencoder: $(HEADERS)  src/gapencoder.cpp ./headers/common.h.gch makefile $(COMMONBINARIES)
	$(CXX) $(CXXFLAGS) -Winvalid-pch  -o gapencoder  src/gapencoder.cpp $(COMMONBINARIES) -Iheaders 

unit: $(HEADERS) src/unit.cpp makefile ./headers/common.h.gch $(COMMONBINARIES)
	$(CXX) $(CXXFLAGS) $(GCCPARAMS) -Winvalid-pch  -o unit src/unit.cpp $(COMMONBINARIES) -Iheaders

clean:
	rm -f *.o ./headers/*.gch codecs iotests unit gapdecoder gapencoder csv2maropu unrolledvsrolledbitpacking
