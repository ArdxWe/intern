#include<stdio.h>

__attribute__((noinline))
long mac_asm(long a,long b,long c) {
	asm __volatile__ (".word 0x40c5a57f\n");
	asm __volatile__ ("mv  %0,a0\n"
		: "=r"(a)
		: 
		:);
	return a;
}

int main(){
	long a = 5,b = 0x0000000100000006,c = 0x0000000200000003;
	long d = b + c;
	long e = mac_asm(a, b, c);
	printf("add32 result: 0x%lx\n", e);
	printf("add   result: 0x%lx\n", d);
	if (d == e) {
		printf("result OK !!!\n");
	}
	else {
		printf("test failed!!!\n");
	}
	return 0;
}

