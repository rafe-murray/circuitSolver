EXE = circuitGraph
OBJS = expression.o circuitGraph.o

CXX = clang++
CXXFLAGS = -std=c++14 -c -g -Wall -Wextra -pedantic
LD = clang++
LDFLAGS = -std=c++14 -lpthread -lm -lnlopt

$(EXE) : $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) -o $(EXE)

expression.o : math/expression.cpp math/*.h
	$(CXX) $(CXXFLAGS) $< -o $@

circuitGraph.o : circuitGraph.cpp circuitGraph.h branch.h resistor.h voltageSource.h graph.h
	$(CXX) $(CXXFLAGS) $< -o $@

clean :
	-rm -f *.o $(EXE)
