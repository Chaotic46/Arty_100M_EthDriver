Help:
	@echo "make Init  - Creates the entire project for the first time. \n\
             This includes creating the Vivado project as \n\
             well as the Petalinux project. It will also \n\
             build both. \n\
\n\
make Build - Only builds all the projects. Note that make \n\
             Init needs to be ran before running make \n\
             Build."

Init:
	cd vivado && \
	vivado -mode batch -source arty_eth_100mb.tcl && \
	cd arty_eth_100mb && \
	vivado -mode batch -source build_project.tcl

Build:
	@echo "Building"
