import numpy as np

from helpers.lib import mygis
from helpers.lib.bunch import Bunch

def vcoord(filename):
    """compute the vertical coordinate in space and time for a given file"""
    na=np.newaxis
    a = mygis.read_nc(filename,"pressure").data
    z = a
    return z

