#include <stdio.h>
#include <svdpi.h>

using namespace std;

// drive a tr to bus
extern "C" void send_tr();

extern "C" void start_c(){
  
  printf("\n C: Hellow from C \n\n");
  
  send_tr();
  
};

