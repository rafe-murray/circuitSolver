#include "variable.h"
#include <cstdlib>
#include <functional>
#include <set>
#include <unordered_map>
#include <vector>

using namespace std;

typedef unordered_map<Variable *, unsigned> expressionMap;
typedef function<double(vector<double>, expressionMap)> expressionFunction;

class Expression {
public:
  Expression(set<Variable *> vars, expressionFunction fn);
  Expression operator+(Expression other);
  function<double(vector<double>)> toFunction();
  vector<Variable *> getUnknowns();

private:
  const set<Variable *> vars;
  const expressionFunction fn;
};
