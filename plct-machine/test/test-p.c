#include<stdio.h>

__attribute__((noinline))
int mac_asm(long a,long b,long c) {
	asm __volatile__ (".word 0x40c5a57f\n");
	asm __volatile__ ("mv  %0,a0\n"
		: "=r"(a)
		: 
		:);
	printf("a=%lx\n",a);
	return a;
}

int main(){
	long a = 5,b=0x0000000100000006,c=0x0000000200000003;
	printf("add32:=0x%lx\n  add:=0x%lx\n",mac_asm(a, b, c), b + c);
	return 0;
}
