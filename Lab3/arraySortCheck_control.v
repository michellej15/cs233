
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, zero_length_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array, zero_length_array;
	input clock, reset;

	wire garbage, load, do_nothing, szero_length_array, sinversion_found, sorted_;

	wire garbage_next = (garbage & ~go) | reset;
	dffe d1(garbage, garbage_next, clock, 1'b1, 1'b0);
	wire do_nothing_next = (garbage & go & ~reset) | load & ~reset;
	dffe d2(do_nothing, do_nothing_next, clock, 1'b1, 1'b0);
	wire load_next = (do_nothing & ~inversion_found & ~end_of_array & ~zero_length_array & ~reset);
	dffe d3(load, load_next, clock, 1'b1, 1'b0);
	wire zero_length_array_next = (do_nothing & zero_length_array & ~reset);
	dffe d4(szero_length_array, zero_length_array_next, clock, 1'b1, 1'b0);
	wire inversion_found_next = inversion_found & ~reset & do_nothing;
	dffe d5(sinversion_found, inversion_found_next, clock, 1'b1, 1'b0);
	wire sorted_next = do_nothing & end_of_array & ~reset;
	dffe d6(sorted_, sorted_next, clock, 1'b1, 1'b0);

	assign done = sorted_ ? 1:
	sinversion_found ? 1:
	szero_length_array ? 1:
	0;

	assign sorted = sorted_;

	assign load_input = load ? 1:
	garbage ? 1:
	sorted_ ? 1:
	sinversion_found ? 1:
	szero_length_array ? 1:
	0;

	assign select_index = load ? 1:
	garbage ? 1:
	sorted_ ? 1:
	sinversion_found ? 1:
	szero_length_array ? 1:
	0;

	assign load_index = load ? 1:
	garbage ? 1:
	sorted_ ? 1:
	sinversion_found ? 1:
	szero_length_array ? 1:
	0;

endmodule
