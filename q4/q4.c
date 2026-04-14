#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main(void) {
    char op[8];
    int num1, num2;

    void *current_handle = NULL;
    char current_op[8] = "";

    while (1) {
        int ret = scanf("%7s %d %d", op, &num1, &num2);

        if (ret == EOF) {
            break;
        }

        if (ret != 3) {
            fprintf(stderr, "Invalid input\n");
            break;
        }

        if (strcmp(op, current_op) != 0) {

            if (current_handle != NULL) {
                dlclose(current_handle);
                current_handle = NULL;
            }

            char libname[32];
            snprintf(libname, sizeof(libname), "./lib%s.so", op);

            current_handle = dlopen(libname, RTLD_LAZY | RTLD_LOCAL);
            if (current_handle == NULL) {
                fprintf(stderr, "Error loading %s: %s\n", libname, dlerror());
                return 1;
            }

            strncpy(current_op, op, sizeof(current_op) - 1);
            current_op[sizeof(current_op) - 1] = '\0';
        }

        dlerror();

        typedef int (*op_func_t)(int, int);
        op_func_t func = (op_func_t) dlsym(current_handle, op);

        const char *err = dlerror();
        if (err != NULL) {
            fprintf(stderr, "Error finding symbol '%s': %s\n", op, err);
            dlclose(current_handle);
            return 1;
        }

        int result = func(num1, num2);
        printf("%d\n", result);
    }

    if (current_handle != NULL) {
        dlclose(current_handle);
    }

    return 0;
}
