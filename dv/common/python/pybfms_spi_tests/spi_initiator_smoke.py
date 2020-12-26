'''
Created on Dec 25, 2020

@author: mballance
'''

import cocotb
import pybfms



@cocotb.test()
async def test(top):
    
    await pybfms.init()
    
    u_bfm = pybfms.find_bfm(".*u_bfm")
    print("u_bfm=" + str(u_bfm))
    
    await cocotb.triggers.Timer(50, "ns")

    for i in range(4):
        rdat = await u_bfm.send(0xFF)
        if rdat != 0xFF:
            raise cocotb.result.TestFailure("Expect 0xFF ; rdat=" + hex(rdat))

    for i in range(100):    
        rdat = await u_bfm.send(i+1)
        if rdat != (i+1):
            raise cocotb.result.TestFailure("Expect " + hex(i+1) + " ; rdat=" + hex(rdat))

        
    