#include <stdio.h>
#include <unistd.h>
#include <time.h>

int main() {
  while (1) {
    printf("Hello, world! %d\n", time(NULL));
    sleep(1);
  }
}
