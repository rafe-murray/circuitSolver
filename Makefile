EXE = solver
OBJS = solver.o

CXX = clang++
CXXFLAGS = -std=c++14 -c -g -0g -Wall -Wextra -pedantic
LD = clang++
LDFLAGS = -std=c++14 -lpthread -lm -lnlopt

$(EXE) : $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) -o $(EXE)

solver.o : solver.cpp solver.h
	$(CXX) $(CXXFLAGS) solver.cpp -o $@ 

clean :
	-rm -f *.o $(EXE)
