'''
Created on May 7, 2021

@author: mballance
'''
from gpio_bfms import GpioBfm
import pybfms
import rv_bfms
from fwnoc_tests.fwnoc.ingress_sender_base import IngressSenderBase
from fwnoc_tests.fwnoc.egress_receiver_base import EgressReceiverBase
from typing import Dict, Tuple
from fwnoc_bfms.fwnoc_channel_bfm import FwNocChannelBFM


class FwnocTestBase(object):
    
    def __init__(self):
        pass
    
    async def init(self):
        await pybfms.init()
    
        gpio : GpioBfm = pybfms.find_bfm(".*u_gpio_params")
        size_xy = gpio.get_gpio_in()
        self.size_x = (size_xy & 0xFF)
        self.size_y = ((size_xy >> 8) & 0xFF)
        print("Hello X=" + str(self.size_x) + " Y=" + str(self.size_y))

        self.i_bfms = {}
        self.e_bfms = {}

        max_x = self.size_x-1
        max_y = self.size_y-1
        for bfm in pybfms.find_bfms(".*", rv_bfms.ReadyValidDataInBFM):
            iname = bfm.bfm_info.inst_name
            x_si = iname.find('[')
            x_ei = iname.find(']', x_si)
            y_si = iname.find('[', x_ei)
            y_ei = iname.find(']', y_si)
            x_idx = int(iname[x_si+1:x_ei])
            y_idx = int(iname[y_si+1:y_ei])
            self.i_bfms[(x_idx,y_idx)] = bfm
        
        for bfm in pybfms.find_bfms(".*", rv_bfms.ReadyValidDataOutBFM):
            iname = bfm.bfm_info.inst_name
            x_si = iname.find('[')
            x_ei = iname.find(']', x_si)
            y_si = iname.find('[', x_ei)
            y_ei = iname.find(']', y_si)
            x_idx = int(iname[x_si+1:x_ei])
            y_idx = int(iname[y_si+1:y_ei])
            self.e_bfms[(x_idx,y_idx)] = bfm
        
        self.bfms : Dict[Tuple,FwNocChannelBFM] = {}    
        self.senders : Dict[Tuple,IngressSenderBase] = {}
        self.receivers : Dict[Tuple,EgressReceiverBase] = {}
        
        for x in range(self.size_x):
            for y in range(self.size_y):
                print("i_bfms[%d,%d] = %s" % (x,y,self.i_bfms[(x,y)].bfm_info.inst_name))
                print("e_bfms[%d,%d] = %s" % (x,y,self.e_bfms[(x,y)].bfm_info.inst_name))
    
        for x in range(self.size_x):
            for y in range(self.size_y):
                self.bfms[(x,y)] = FwNocChannelBFM(
                    self.e_bfms[(x,y)],
                    self.i_bfms[(x,y)])
            
                self.senders[(x,y)] = self.create_ingress_sender(
                    x, 
                    y, 
                    max_x, 
                    max_y, 
                    self.bfms[(x,y)], 
                    self.receivers)
            
                self.receivers[(x,y)] = self.create_egress_recv(
                    x,
                    y,
                    self.bfms[(x,y)])        
                
        await self.bfms[(0,0)].wait_reset()
                
    def create_egress_recv(self, x, y, bfm):
        return EgressReceiverBase(x, y, bfm)
    
    def create_ingress_sender(self, x, y, max_x, max_y, bfm, receivers):
        return IngressSenderBase(x, y, max_x, max_y, bfm, receivers)
    
    async def run(self):
        pass
    
