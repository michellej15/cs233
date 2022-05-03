/**
 * @file
 * Contains an implementation of the extractMessage function.
 */

#include <iostream> // might be useful for debugging
#include <assert.h>
#include "extractMessage.h"

using namespace std;

char *extractMessage(const char *message_in, int length) {
   // Length must be a multiple of 8
   assert((length % 8) == 0);

   // allocates an array for the output
   char *message_out = new char[length];
   for (int i=0; i<length; i++) {
   		message_out[i] = 0;    // Initialize all elements to zero.
	}

	// TODO: write your code here
  char *e_mess = new char[length];
  for (int i = 0; i < length; i++) {
    e_mess[i] = message_in[i];
  }
  for (int i = 0; i < length; i++) {
    for (int j = 7; j >= 0; j--) {
      char a = 1;
      char temp = e_mess[j + 8 * (i/8)] & a;
      temp = temp << j;
      e_mess[j + 8 * (i/8)] = e_mess[j + 8 * (i/8)] >> 1;
      message_out[i] = message_out[i] | temp;
    }
  }

	return message_out;
}
