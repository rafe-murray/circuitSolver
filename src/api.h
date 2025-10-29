#include <cstddef>
#define EXPORT extern "C"

// Blocking call for now
EXPORT
int processGraph(void* inputBuffer, size_t inputLength, void** outputBuffer,
                 size_t* outputLength);

EXPORT
int destroyGraph(void* graph);

EXPORT
const char* getErrorMessage(int errorNumber);

#define CIRCUITSOLVER_ERROR_INVALID_INPUT 1
#define CIRCUITSOLVER_ERROR_NO_SOLUTION 2
#define CIRCUITSOLVER_ERROR_FAILED_SERIALIZATION 3
#define CIRCUITSOLVER_ERROR_BAD_ALLOC 4
