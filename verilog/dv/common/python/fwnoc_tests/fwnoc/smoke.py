'''
Created on Apr 25, 2021

@author: mballance
'''

import pybfms
import vsc
import cocotb
import rv_bfms
from fwnoc_bfms.fwnoc_channel_bfm import FwNocChannelBFM, FwNocPacket
from typing import Dict, Tuple
from gpio_bfms.GpioBfm import GpioBfm

class IngressSender(object):
    """
    """
    
    def __init__(self, 
                 src_x,
                 src_y,
                 max_x,
                 max_y,
                 count,
                 ingress,
                 receivers):
        self.src_x = src_x
        self.src_y = src_y
        self.max_x = max_x
        self.max_y = max_y
        self.count = count
        self.ingress = ingress
        self.receivers = receivers
        self.id = 0
    
    async def run(self):
        for i in range(self.count):
            pkt = FwNocPacket(self.src_x, self.src_y)

            pkt.src_chip_x = 0
            pkt.src_chip_y = 0
            pkt.src_tile_x = self.src_x
            pkt.src_tile_y = self.src_y
            pkt.id = i
            
            with pkt.randomize_with() as it:
                it.payload.size == 1
                it.dst_chip_x == 0
                it.dst_chip_y == 0
                it.dst_tile_x.inside(vsc.rangelist(vsc.rng(0,self.max_x)))
                it.dst_tile_y.inside(vsc.rangelist(vsc.rng(0,self.max_y)))
                
            print("" + str(i) + " " + pkt.src_s() + " (sz=" + str(len(pkt.payload)) + ") sending to " + pkt.dst_s())
            recv = self.receivers[(pkt.dst_tile_x,pkt.dst_tile_y)]
            recv.add_exp(pkt)
            await self.ingress.send(pkt)

class EgressReceiver(object):
    
    def __init__(self,
                 dst_x,
                 dst_y,
                 egress):
        self.x = dst_x
        self.y = dst_y
        self.egress = egress
        egress.add_recv_cb(self._recv)
        # Dict of lists holding expected packets
        self.exp = {}
        
        self.drain_ev = pybfms.event()
    
    def add_exp(self, pkt):
        if (pkt.src_tile_x,pkt.src_tile_y) not in self.exp:
            self.exp[(pkt.src_tile_x,pkt.src_tile_y)] = []
            
        self.exp[(pkt.src_tile_x,pkt.src_tile_y)].append(pkt)
        
    
    def _recv(self, pkt):
        
        print("" + str(pkt.id) + " (" + str(self.x) + "," + str(self.y) + ") receiving " + pkt.dst_s() + " from " + pkt.src_s())
        
        if (pkt.src_tile_x,pkt.src_tile_y) not in self.exp:
            queue = []
        else:
            queue = self.exp[(pkt.src_tile_x,pkt.src_tile_y)]
            

        if len(queue) == 0:            
            print("Error: (" + str(self.x) + "," + str(self.y) + ") not expecting a packet from (" +
                  str(pkt.src_tile_x) + "," + str(pkt.src_tile_y) + ")")
        else:
            print("TODO: check packet from " + pkt.src_s())
            queue.pop()
            
            if len(queue) == 0:
                print("Empty")
                self.drain_ev.set()
        
#        print("(" + str(self.x) + "," + str(self.y) + ") receive from " + str(pkt.src_tile_x) + "," + str(pkt.src_tile_y))

    def get_drain_ev(self):
        return self.drain_ev
        
        
    

@cocotb.test()
async def entry(dut):
    await pybfms.init()
    
    gpio : GpioBfm = pybfms.find_bfm(".*u_gpio_params")
    size_xy = gpio.get_gpio_in()
    size_x = (size_xy & 0xFF)
    size_y = ((size_xy >> 8) & 0xFF)
    print("Hello X=" + str(size_x) + " Y=" + str(size_y))

    i_bfms = {}
    e_bfms = {}

    max_x = size_x-1
    max_y = size_y-1
    for bfm in pybfms.find_bfms(".*", rv_bfms.ReadyValidDataInBFM):
        iname = bfm.bfm_info.inst_name
        x_si = iname.find('[')
        x_ei = iname.find(']', x_si)
        y_si = iname.find('[', x_ei)
        y_ei = iname.find(']', y_si)
        x_idx = int(iname[x_si+1:x_ei])
        y_idx = int(iname[y_si+1:y_ei])
        i_bfms[(x_idx,y_idx)] = bfm
        
    for bfm in pybfms.find_bfms(".*", rv_bfms.ReadyValidDataOutBFM):
        iname = bfm.bfm_info.inst_name
        x_si = iname.find('[')
        x_ei = iname.find(']', x_si)
        y_si = iname.find('[', x_ei)
        y_ei = iname.find(']', y_si)
        x_idx = int(iname[x_si+1:x_ei])
        y_idx = int(iname[y_si+1:y_ei])
        e_bfms[(x_idx,y_idx)] = bfm
        
    bfms : Dict[Tuple,FwNocChannelBFM] = {}    
    senders : Dict[Tuple,IngressSender] = {}
    receivers : Dict[Tuple,EgressReceiver] = {}
    
    for x in range(size_x):
        for y in range(size_y):
            bfms[(x,y)] = FwNocChannelBFM(
                e_bfms[(x,y)],
                i_bfms[(x,y)])
            
            senders[(x,y)] = IngressSender(
                x, 
                y, 
                max_x, 
                max_y, 
                0 if y == 0 else 8,
                bfms[(x,y)], 
                receivers)
            
            receivers[(x,y)] = EgressReceiver(
                x, 
                y, 
                bfms[(x,y)])

    # Now, kick off 
    sender_tasks = []            
    for x in range(size_x):
        for y in range(size_y):
            sender_tasks.append(pybfms.fork(senders[(x,y)].run()))
            
    await cocotb.triggers.Combine(*sender_tasks)
    
#     print("size_x=" + str(size_x) + " size_y=" + str(size_y))
#     await bfms[(0,0)].wait_reset()
#     
#     pkt = FwNocPacket(max_x, max_y)
# 
#     with pkt.randomize_with(debug=1) as it:
#         it.dst_chip_x == 0
#         it.dst_chip_y == 0
#         it.dst_tile_x.inside(vsc.rangelist(vsc.rng(0,max_x)))
#         it.dst_tile_y.inside(vsc.rangelist(vsc.rng(0,max_y)))
#         
#     await bfms[(0,0)].send(pkt)
#     print("dst_x=" + str(pkt.dst_tile_x) + " dst_y=" + str(pkt.dst_tile_y))
#     rpkt = await bfms[(pkt.dst_tile_x,pkt.dst_tile_y)].recv()
#     
#     print("Receive rpkt")
           
    await cocotb.triggers.Timer(1, 'ms')
    
        
        
    