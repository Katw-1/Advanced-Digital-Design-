#! /usr/bin/python
from random import gauss

in_range = lambda x, median, bound: (median - bound) <= x <= (median + bound)

def get_random(bound):
	while not in_range(val := gauss(1, 0.05), 1, bound):
		pass
	return val

get_size_variations = lambda: [get_random(0.15) for _ in range(4)]
get_thickness_variations = lambda: [get_random(0.10) for _ in range(2)]

fmt = "x{j} n{i} n{j} inverter " \
	"tplv={tplv} tpwv={tpwv} tnlv={tnlv} tnwv={tnwv} " \
	"tpotv={toptv} tnotv={tnotv}\n"

# TODO: add SPICE header and subcircuit card start


for u in range(0, 8, 1):
	with open(f"ring_oscillator_{u}.cir", "w") as file:
		file.write(f"* ring oscillator {u}\n")
		file.write(f".subckt ring_oscillator_{u} in n12\n")
		# TODO: add NAND gate
		file.write("xNAND in n12 n0 nand2x1\n")
		# generate inverters
		for i, j in enumerate(range(1, 13)):
			# change to match your inverter parameters
			tplv, tpwv, tnlv, tnwv = get_size_variations()
			toptv, tnotv = get_thickness_variations()
			file.write(fmt.format(i=i, j=i+1, tplv=tplv, tpwv=tpwv,
				tnlv=tnlv, tnwv=tnwv, toptv=toptv, tnotv=tnotv))
		
		# TODO: add end of subcircuit card, add finishing newline

		
		file.write("\n.ends ring oscillator\n")

		print("ring_oscillator_{} created successfully!".format(u))

print("Task is complete.")
