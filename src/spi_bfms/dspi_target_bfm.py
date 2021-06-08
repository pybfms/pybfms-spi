'''
Created on May 30, 2021

@author: mballance
'''

import pybfms

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/dspi_target_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/dspi_target_bfm.v"),
    }, has_init=True)
class DSpiTargetBfm(object):
    
    def __init__(self):
        pass
    
    @pybfms.import_task(pybfms.uint8_t)
    def _send(self, dat):
        pass
    
    @pybfms.export_task()
    def _recv_start(self):
        pass
    
    @pybfms.export_task(pybfms.uint8_t)
    def _recv(self, dat):
        pass
    
    
    