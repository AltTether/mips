#include<stdio.h>

void hanoi(int n, int a, int b, int c) {
  if (n == 1) move(n, a ,c);
  else {
    hanoi(n-1, a, c, b);
    move(n, a, c);
    hanoi(n-1, b, a, c);
  }
}

void move(int n, int a, int b) {
  printf("move %d from %d to %d\n", n, a, b);
}

int main() {
  int n = 3;
  int a = 1;
  int b = 2;
  int c = 3;
  hanoi(n, a, b, c);
  return 0;
}
