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
  printf("fadd %f is 3.000000\n",c);
// fsub.s
  c = a - b;
  printf("fsub %f is -1.000000\n",c);
// fmul.s
  c = a * b;
  printf("fmul %f is 2.000000\n",c);
// fdiv.s
  c = a / b;
  printf("fdiv %f is 0.500000\n",c);
// fneg.s  
  c = -a;
  printf("fneg %f is -1.000000\n",c);
// fabs.s
  c = fabs(c);
  printf("fabs %f is 1.000000\n",c);
//fsqrt.s
  c = sqrt(a);
  printf("fsqrt %f is 1.000000\n",c);
// fmax.s
  c = fmax(a,b);
  printf("fmax %f is 2.000000\n",c);
// fmin.s
  c = fmin(a,b);
  printf("fmin %f is 1.000000\n",c);
// compare instructions
  printf("feq %d is 0\n", a==b);
  printf("flt %d is 1\n", a<b);
  printf("fle %d is 1\n", a<=b);
  printf("fgt %d is 0\n", a>b);
  printf("fge %d is 0\n", a>=b);
// cast instructions
unsigned u = (unsigned)c;
printf("fcvt.wu.s %u is 1\n",u);
unsigned long lu = (unsigned long)c;
printf("fcvt.w.s %lu is 1\n",lu);
int d = (int)c;
printf("fcvt.lu.s %d is 1\n",d);
long l = (long)c;
printf("fcvt.l.s %ld is 1\n",l);
double e = (double)c;
printf("fcvt.d.s %lf is 1.000000\n",e);
c = (float)u;
printf("fcvt.s.wu %f is 1.000000\n",c);
c = (float)lu;
printf("fcvt.s.w %f is 1.000000\n",c);
c = (float)d;
printf("fcvt.s.lu %f is 1.000000\n",c);
c = (float)l;
printf("fcvt.s.l %f is 1.000000\n",c);
c = (float)e;
printf("fcvt.s.d %f is 1.000000\n",c);

return 0;
}
