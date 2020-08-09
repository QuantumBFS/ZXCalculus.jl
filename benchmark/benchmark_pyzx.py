import random, math, os, time
pyzx_path = "c:\\Users\\zhaochen\\Desktop\\pyzx-master"
import sys; sys.path.append(pyzx_path)
import pyzx as zx

def run_benchmark():
    dir = 'benchmark/circuits/'
    filenames = os.listdir(dir)
    bms = dict()
    for circ_name in filenames:
        circ_path = dir + circ_name
        c = zx.Circuit.load(circ_path).to_basic_gates()
        g = c.to_graph()
        t0 = time.time()
        g = zx.simplify.teleport_reduce(g)
        t1 = time.time()
        t = t1 - t0
        # tc = zx.tcount(g)
        print(circ_name + '\t time = ', t)
        bms[circ_name] = t
    return bms
        
bms = run_benchmark()
