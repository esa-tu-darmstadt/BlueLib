#include <stdlib.h>

// This function is imported in the Assertions package, so assertion fails can fail the CI.
void bad_exit(unsigned int code) {
    exit((int) code);
}
