class Variable {
public:
  double value;
  bool known;
  Variable() : known(false){};
  Variable(double value) : value(value), known(true){};
};
