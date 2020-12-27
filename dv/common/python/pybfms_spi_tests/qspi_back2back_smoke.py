'''
Created on Dec 27, 2020

@author: mballance
'''

import cocotb
import pybfms
from spi_bfms.qspi_xfer_mode import QSpiXferMode

def recv(targ, data):
    print("recv: " + hex(data))

@cocotb.test()
async def test(top):
    await pybfms.init()
    
    u_init = pybfms.find_bfm(".*u_init")
    u_targ = pybfms.find_bfm(".*u_targ")
    
    u_targ.recv_f = lambda data: recv(u_targ, data)

    print("--> send (SPI) 0x4")    
    await u_init.send(0x4, QSpiXferMode.SPI, False)
    print("<-- send (SPI) 0x4")    
    print("--> send (SPI) 0x8")    
    await u_init.send(0x8, QSpiXferMode.SPI, False)
    print("<-- send (SPI) 0x8")    
    print("--> send (QSPI) 0x4")    
    u_targ.set_xfer_mode(QSpiXferMode.QSPI)
    await u_init.send(0x4, QSpiXferMode.QSPI, False)
    print("<-- send (QSPI) 0x4")    
    print("--> send (QSPI) 0x8")    
    await u_init.send(0x8, QSpiXferMode.QSPI, False)
    print("<-- send (QSPI) 0x8")    
    
    pass

