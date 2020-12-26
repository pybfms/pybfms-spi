
import pybfms

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/spi_initiator_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/spi_initiator_bfm.v"),
    }, has_init=True)
class SpiInitiatorBfm():

    def __init__(self):
        self.busy = pybfms.lock()
        self.is_reset = False
        self.reset_ev = pybfms.event()
        self.recv_ev = pybfms.event()
        self.dat_width = 0
        self.rdat = 0
        pass
    
    async def send(self, dat):
        await self.busy.acquire()
        
        self._send(dat)
        await self.recv_ev.wait()
        self.recv_ev.clear()
        
        self.busy.release()
        
        return self.rdat
        
    @pybfms.export_task(pybfms.uint32_t)
    def _set_parameters(self, dat_width):
        self.dat_width = dat_width
        pass
        
    @pybfms.export_task(pybfms.uint32_t)
    def _recv(self, rdat):
        self.rdat = rdat
        self.recv_ev.set()
        
    @pybfms.import_task(pybfms.uint32_t)
    def _send(self, dat):
        pass
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()
        
        
