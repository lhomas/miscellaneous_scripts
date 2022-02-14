BEGIN {
	mult_hits = 0;
	REF_is_ALT = 0;
	unmap = 0;
	key_error = 0;
}
/Multiple_hits/ {
	mult_hits++;
}
/REF==ALT/ {
	REF_is_ALT++;
}
/Unmap/ {
	unmap++;
}
/KeyError/ {
	key_error++;
}
END {
	print("Fail(Multiple_hits): ", mult_hits, "\n");
	print("Fail(REF==ALT): ", REF_is_ALT, "\n");
	print("Fail(Unmap): ", unmap, "\n");
	print("Fail(KeyError): ", key_error, "\n");
}
