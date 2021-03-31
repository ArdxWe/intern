// This is a test file for RISC-V ZFINX extension
// you can compile with args "-S -march=rv64imafdzfinx -mabi=lp64d" to verify if the ZFINX extion works
// you can aslo compile without "zfinx" with args "-S -march=rv64imafd -mabi=lp64d" to compare ZFINX effort with FP regs
// compile without -S to generator binary test file on spike or qemu

#include<stdio.h>
#include<math.h>

int main(){

  float a = 1.0;
  float b = 2.0;
  float c;

// fadd.s
  c = a + b;
  printf("%f is 3.0\n",c);
// fsub.s
  c = a - b;
  printf("%f is -1.0\n",c);
// fmul.s
  c = a * b;
  printf("%f is 2.0\n",c);
// fdiv.s
  c = a / b;
  printf("%f is 0.5\n",c);
// fneg.s  
  c = -a;
  printf("%f is -1.0\n",c);
// fabs.s
  c = fabs(c);
  printf("%f is 1.0\n",c);
//fsqrt.s
  c = sqrt(a);
  printf("%f is 1.0\n",c);
// fmax.s
  c = fmax(a,b);
  printf("%f is 2.0\n",c);
// fmin.s
  c = fmax(a,b);
  printf("%f\n",c);
// compare instructions
if(a==b && a>b && a>=b && a<b && a<=b) c = 5.0;
// cast instructions
unsigned u = (unsigned)c;
printf("%u\n is 5",u);
unsigned long lu = (unsigned long)c;
printf("%lu is 5\n",lu);
int d = (int)c;
printf("%d is 5\n",d);
long l = (long)c;
printf("%ld is 5\n",l);
double e = (double)c;
printf("%f is 5.0\n",e);
c = (float)u;
printf("%f is 5.0\n",c);
c = (float)lu;
printf("%f is 5.0\n",c);
c = (float)d;
printf("%f is 5.0\n",c);
c = (float)l;
printf("%f is 5.0\n",c);
c = (double)e;
printf("%f is 5.0\n",c);

return 0;
}
