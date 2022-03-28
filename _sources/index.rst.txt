SARA-dictionary
=========================

``SARA-dictionary`` contains a MATLAB implementation of the "segment-wise 2D discrete wavelet transform" described in :cite:p:`Prusa2012`,
with a serial and a distributed implementation of the SARA wavelet dictionary
:cite:p:`Carrillo2012`. A serial implementation is also proposed.

The original codes published by the author of :cite:p:`Prusa2012`, available `online <https://www.utko.fekt.vut.cz/~rajmic/segwt/index_en.html>`_, have been significantly refactored to implement the SARA wavelet dictionary described in
:cite:p:`Carrillo2012`.

The ``SARA-dictionary`` library is a core dependency of the
`Faceted-Hyper-SARA <https://github.com/basp-group/Faceted-Hyper-SARA>`_ wideband imaging library for radio-interferometry.


.. warning::

   This project is under active development.


.. toctree::
   :maxdepth: 2
   :caption: Installation & references

   setup
   contributors
   biblio

.. toctree::
   :maxdepth: 2
   :caption: API

   src
   lib

.. .. autosummary::
..    :toctree: _autosummary
..    :template: custom-module-template.rst
..    :recursive:

..    lib
..    src


Indices and tables
==================

* :ref:`genindex`
* :ref:`mat-modindex`
* :ref:`search`
