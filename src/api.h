#include <cstddef>
#define EXPORT extern "C"

// Blocking call for now
EXPORT
bool processGraph(void* inputBuffer, size_t inputLength, void** outputBuffer,
                  size_t* outputLength);

EXPORT
void freeGraph(void* graph);
