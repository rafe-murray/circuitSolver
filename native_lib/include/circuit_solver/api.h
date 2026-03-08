#include <cstddef>
#include <stdexcept>
#define EXPORT extern "C"

// Blocking call for now
EXPORT
int solveGraphFromBuffer(void* inputBuffer, size_t inputLength,
                         void** outputBuffer, size_t* outputLength);

EXPORT
void destroyGraphBuffer(void* graphBuffer);

EXPORT
void destroyGraphJson(char* graphJson);

EXPORT
int solveGraphFromJson(char* inputJson, char** outputJson);

EXPORT
const char* getErrorMessage(int errorNumber);

#define CIRCUITSOLVER_ERROR_INVALID_INPUT 1
#define CIRCUITSOLVER_ERROR_NO_SOLUTION 2
#define CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION 3

// C++ bindings
#ifdef __cplusplus
#include <string>

class NoSolutionException : std::logic_error {
 public:
  explicit NoSolutionException(const std::string& message)
      : std::logic_error(message) {}
  const char* what() const noexcept override {
    return std::logic_error::what();
  }
};

class FailedSerializationException : std::runtime_error {
 public:
  explicit FailedSerializationException(const std::string& message)
      : std::runtime_error(message) {}
  const char* what() const noexcept override {
    return std::runtime_error::what();
  }
};

// Gets and returns a string version of a protocol buffer
std::string solveGraphFromString(std::string inputString);
std::string solveGraphFromJson(std::string inputJson);

#endif
