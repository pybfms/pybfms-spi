
import pybfms

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/spi_target_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/spi_target_bfm.v"),
    }, has_init=True)
class SpiTargetBfm():

    def __init__(self):
        self.busy = pybfms.lock()
        self.is_reset = False
        self.reset_ev = pybfms.event()
        self.recv_start_f = None
        self.recv_f = None
        pass

    def send(self, data):
        self._send(data)
        
    @pybfms.export_task()
    def _recv_start(self):
        if self.recv_start_f is not None:
            data = self.recv_start_f()
            self._send(data)

    @pybfms.export_task(pybfms.uint64_t)    
    def _recv(self, data):
        if self.recv_f is not None:
            self.recv_f(data)
        else:
            print("Note: received data " + hex(data))
            
    @pybfms.import_task(pybfms.uint64_t)
    def _send(self, data):
        pass
        
    @pybfms.export_task(pybfms.uint32_t)
    def _set_parameters(self, dat_width):
        self.dat_width = dat_width
        pass
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()
        
        
