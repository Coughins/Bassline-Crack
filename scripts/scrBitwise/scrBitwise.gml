/*
	If you don't know what these are for then
	you probably don't need to use them
*/

///@func int_create_mask(ind, len)
///@arg {real} ind
///@arg {real} len
function int_create_mask(ind, len) {
	return ~(~0 << len) << ind
}

///@func int_flip_bits(int, ind, num)
///@arg {real} int
///@arg {real} ind
///@arg {real} num
function int_flip_bits(int, ind, num) {
	return int ^ int_create_mask(ind, num)
}

///@func int_read_bit(int, ind)
///@arg {real} int
///@arg {real} ind
function int_read_bit(int, ind) {
	return int & (1 << ind)
}

///@func int_read_bits(int, ind, num)
///@arg {real} int
///@arg {real} ind
///@arg {real} num
function int_read_bits(int, ind, num) {
	return int >> ind & int_create_mask(0, num)	
}

///@func int_set_bit(int, ind, bool)
///@arg {real} int
///@arg {real} ind
///@arg {bool} bool
function int_set_bit(int, ind, val) {
	return (int & ~int_create_mask(ind, 1))	| bool(val) << ind
}

///@func int_set_bits(int, ind, num, val)
///@arg int
///@arg ind
///@arg num
///@arg val
function int_set_bits(int, ind, num, val) {
	return (int & ~int_create_mask(ind, num)) | val << ind
}

///@func int_truth_bit(int, ind)
///@arg {real} int
///@arg {real} ind
function int_truth_bit(int, ind) {
	return int | (1 << ind)
}