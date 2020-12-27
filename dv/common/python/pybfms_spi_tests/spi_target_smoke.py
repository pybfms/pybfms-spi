'''
Created on Dec 25, 2020

@author: mballance
'''

import cocotb
import pybfms

class responder(object):
    def __init__(self, targ):
        self.targ = targ
        self.state = 0
        self.count = 0
        self.data = 0
        
    def recv(self, data):
        if self.state == 0:
            self.count = 0
            self.data = ((data+1) & 0xFF)
            print("recv: " + hex(data) + " state=" + str(self.state) + " send=" + hex(self.data))
            self.targ.send(self.data)
            self.state = 1
        else:
            self.data = ((self.data+1) & 0xFF)
            print("recv: " + hex(data) + " state=" + str(self.state) + " send=" + hex(self.data))
            self.targ.send(self.data)
            self.count += 1
            if self.count == 4:
                self.state = 0
            pass
    


@cocotb.test()
async def test(top):
    
    await pybfms.init()
    
    u_init = pybfms.find_bfm(".*u_init")
    u_targ = pybfms.find_bfm(".*u_targ")
   
    resp = responder(u_targ)
    u_targ.recv_f = resp.recv
    
    print("u_init=" + str(u_init) + " u_targ=" + str(u_targ))
    
    await cocotb.triggers.Timer(50, "ns")

    for i in range(4):
        rdat = await u_init.send(0xFF)
        print("rdat=" + hex(rdat))
        
        # Expect three more
        for j in range(4):
            rdat = await u_init.send(0x00)
            print("rdat=" + hex(rdat))
            
#        if rdat != 0xFF:
#            raise cocotb.result.TestFailure("Expect 0xFF ; rdat=" + hex(rdat))

#     for i in range(100):    
#         rdat = await u_bfm.send(i+1)
#         if rdat != (i+1):
#             raise cocotb.result.TestFailure("Expect " + hex(i+1) + " ; rdat=" + hex(rdat))

        
    