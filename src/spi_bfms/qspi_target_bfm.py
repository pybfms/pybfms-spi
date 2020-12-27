
import pybfms
from spi_bfms.qspi_xfer_mode import QSpiXferMode

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/qspi_target_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/qspi_target_bfm.v"),
    }, has_init=True)
class QSpiTargetBfm():

    def __init__(self):
        self.busy = pybfms.lock()
        self.is_reset = False
        self.reset_ev = pybfms.event()
        self.dat_width = 0
        self.recv_f = None
        pass

    def send(self, data, mode : QSpiXferMode):
        self._send(data, mode)

    @pybfms.export_task(pybfms.uint64_t)
    def _recv(self, data):
        if self.recv_f is not None:
            self.recv_f(data)
            
    @pybfms.import_task(pybfms.uint64_t, pybfms.uint32_t)
    def _send(self, data, mode):
        pass
    
    @pybfms.import_task(pybfms.uint32_t)
    def set_xfer_mode(self, mode : QSpiXferMode):
        pass
        
    @pybfms.export_task(pybfms.uint32_t)
    def _set_parameters(self, dat_width):
        self.dat_width = dat_width
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()
        
        
