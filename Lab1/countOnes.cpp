/**
 * @file
 * Contains an implementation of the countOnes function.
 */


unsigned countOnes(unsigned input) {
	// TODO: write your code here
	unsigned left = input & 0x55555555;
	unsigned right = input & 0xAAAAAAAA;

	right >>= 1;
	input = left + right;

	left = input & 0x33333333;
	right = input & 0xCCCCCCCC;
	right >>= 2;
	input = left + right;

	left = input & 0x0F0F0F0F;
	right = input & 0xF0F0F0F0;
	right >>= 4;
	input = left + right;

	left = input & 0x00FF00FF;
	right = input & 0xFF00FF00;
	right >>= 8;
	input = left + right;

	left = input & 0x0000FFFF;
	right = input & 0xFFFF0000;
	right >>= 16;
	input = left + right;

	return input;
}
