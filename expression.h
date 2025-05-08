#include "variable.h"
#include <cstdlib>
#include <functional>
#include <vector>
using namespace std;
class Expression {
public:
  vector<Variable> args;
  function<double(vector<Variable>)> fn;
};
