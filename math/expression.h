#include "variable.h"
#include <autodiff/reverse/var.hpp>
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
  Expression();
  Expression(set<Variable *> vars, expressionFunction fn);
  Expression operator+(const Expression &other);
  Expression operator-(const Expression &other);
  const Expression &operator+=(const Expression &other);
  Expression square();
  vector<Variable *> getUnknowns();

private:
  set<Variable *> vars;
  expressionFunction fn;
  function<double(vector<double>)> toFunction();
};
