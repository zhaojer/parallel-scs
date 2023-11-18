serial_lcs: serial_lcs.cpp
	g++ -O3 -o $@ $<

serial_scs: serial_scs.cpp
	g++ -O3 -o $@ $<

clean:
	rm -f serial_lcs
	rm -f serial_scs
