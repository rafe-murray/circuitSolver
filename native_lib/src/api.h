#include <cstddef>
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
