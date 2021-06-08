'''
Created on May 30, 2021

@author: mballance
'''

class SpiMemoryModel(object):
    
    def __init__(self, 
                 bfm,
                 byte_sz):
        self.bfm = bfm
        self.byte_sz = byte_sz
        self.data = [0]*byte_sz
        
        self.bfm.recv_f = self._recv
        self.bfm.clocked_csn_high_f = self._clocked_csn_high
        self.powered_up = False
        self.xip_cmd = False
        self.bytecount = 0
        self.spi_cmd = 0
        self.spi_addr = 0
        
    def _recv(self, dat):
        self.bytecount += 1
        
        if self.bytecount == 1:
            self.spi_cmd = dat
            
            print("spi_cmd=%02x" % self.spi_cmd)
            
            if dat == 0xab:
                print("powered up")
                self.powered_up = True
                self.bytecount = 0
            elif dat == 0xb9:
                print("powered down")
                self.powered_up = False
                self.bytecount = 0
            elif dat == 0xff:
                print("xip off")
                self.xip_cmd = False
                self.bytecount = 0
            elif dat == 0x03:
                print("begin read")
                self.spi_addr = 0
                pass
            else:
                print("Error: unsupported command 0x%02x" % dat)
        else: # bytecount != 1
            if self.spi_cmd == 0x03:
                if self.bytecount == 2:
                    self.spi_addr |= (dat << 16)
                elif self.bytecount == 3:
                    self.spi_addr |= (dat << 8)
                elif self.bytecount == 4:
                    self.spi_addr |= (dat << 0)
                    
                    print("Start addr: 0x%08x" % self.spi_addr)
                    
                if self.bytecount >= 4:
                    print("Read address 0x%08x (%02x)" % (
                        self.spi_addr, self.data[self.spi_addr]))
                    self.bfm._send(self.data[self.spi_addr])
                    self.spi_addr = ((self.spi_addr+1) % len(self.data))
            else:
                raise Exception("Unsupported SPI command %02x" % self.spi_cmd)
                    
    def _clocked_csn_high(self):
        print("Reset command seq")
        self.bytecount = 0
                    
        
        