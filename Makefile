name = kittenofchaos

default: assemble

assemble:
	as -arch arm64 -g -o $(name).o $(name).s
	ld -o $(name) $(name).o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -arch arm64 

clean:
	rm -f $(name) $(name).o