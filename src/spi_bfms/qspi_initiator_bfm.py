
import pybfms
from spi_bfms.qspi_xfer_mode import QSpiXferMode

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/qspi_initiator_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/qspi_initiator_bfm.v"),
    }, has_init=True)
class QSpiInitiatorBfm():

    def __init__(self):
        self.busy = pybfms.lock()
        self.is_reset = False
        self.reset_ev = pybfms.event()
        self.recv_ev = pybfms.event()
        self.recv_data = 0
        pass
    
    async def send(self, data, mode : QSpiXferMode, recv):
        await self.busy.acquire()
        
        if not self.is_reset:
            await self.reset_ev.wait()
            self.reset_ev.clear()
            
        self._send(data, mode, recv)
        
        await self.recv_ev.wait()
        self.recv_ev.clear()
        
        self.busy.release()
        
        return self.recv_data
        
        
    @pybfms.export_task(pybfms.uint32_t)
    def _set_parameters(self, dat_width):
        self.dat_width = dat_width
        pass
    
    @pybfms.import_task(pybfms.uint64_t, pybfms.uint8_t, pybfms.uint8_t)
    def _send(self, data, mode, recv):
        pass
    
    @pybfms.export_task(pybfms.uint64_t)
    def _recv(self, data):
        self.recv_data = data
        self.recv_ev.set()
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()
        
        
