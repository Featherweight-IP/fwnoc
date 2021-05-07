'''
Created on May 7, 2021

@author: mballance
'''

class IngressSenderBase(object):
    """
    """
    
    def __init__(self, 
                 src_x,
                 src_y,
                 max_x,
                 max_y,
                 ingress,
                 receivers):
        self.src_x = src_x
        self.src_y = src_y
        self.max_x = max_x
        self.max_y = max_y
        self.ingress = ingress
        self.receivers = receivers
        self.id = 0
        
    async def send(self, pkt):
        pkt.src_chip_x = 0
        pkt.src_chip_y = 0
        pkt.src_tile_x = self.src_x
        pkt.src_tile_y = self.src_y
        
        recv = self.receivers[(pkt.dst_tile_x,pkt.dst_tile_y)]
        recv.add_exp(pkt)
        await self.ingress.send(pkt)
