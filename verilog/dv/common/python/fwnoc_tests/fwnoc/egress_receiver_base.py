'''
Created on May 7, 2021

@author: mballance
'''

import pybfms

class EgressReceiverBase(object):
    
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