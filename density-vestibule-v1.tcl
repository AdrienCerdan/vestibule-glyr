# Compute the number of chloride in the vestibule of Glyr
# Adrien Cerdan, Univerty of strasbourg, France


# Usage:
#vmd -dispdev text prot_ions.psf -e density-vestibule-v1.tcl -args ${prodlist[*]}
# or
#vmd -dispdev text prot_ions.psf -e density-vestibule-v1.tcl -args prod01.dcd



#exec rm comz.dat
#exec rm portal-trans.dat
exec rm tmp

source bigdcd-skip.tcl



#applied at each frame
proc COMZ {frame} {
	#puts "hello"
	#global molID molList atomID1 atomID2 framerate
	global molID molList ringIN1 ringOUT1 ringOUT1BOT ringIN2 ringOUT2 ringOUT2BOT ringIN3 ringOUT3 ringOUT3BOT ringIN4 ringOUT4 ringOUT4BOT ringIN5 ringOUT5 ringOUT5BOT framerate flagOUT flagIN OUT IN flag radius listCLA Dflag Din Dout Dflagout Dflagin bulk vestibule centerRING transition
	#puts "bye"

	set posCENTER [measure center $centerRING]

#loop over all selected molecules
        set numCLA 0
	foreach mol $listCLA {
	#selections
		set CLA [atomselect 0 "index $mol"]

	
  	#set posCLA [lindex [$CLA get {x y z}] 0]
		set posCLA [measure center $CLA]
	
	

		# distance bulk vs vestibule
		set distanceCENTER [veclength [vecsub $posCENTER $posCLA]]

		
		# [OPTI] we could continue all ion either compartement and track only the ones in the middle.
		if { [expr {$distanceCENTER < 25}] } {
				set numCLA [expr {$numCLA + 1 }]
		}

	}
	exec echo "$frame $numCLA" >> cla-vestibule.dat
	return
}

# General Parameters
set framerate 1

set selectCLA [atomselect 0 "name CLA"]
# can be used for specific ion only:
#set selectCLA [atomselect 0 "name CLA and resid 248"]

set listCLA [$selectCLA list]

# to initiate all the dicts
foreach mol $listCLA {
	dict set Dflag $mol 0
	dict set Dflagin $mol 0
	dict set Dflagout $mol 0
	dict set Din $mol 0
	dict set Dout $mol 0
	dict set bulk $mol 0
	dict set vestibule $mol 0
	dict set transition $mol 0
	
}
puts "number of tracked ions: [dict size $Dflag]"


# set ring atoms
set centerRING [atomselect 0 "protein and (chain A B C D E and resid 120)"]

set flagOUT 0
set flagIN 0

set IN 0
set OUT 0

set flag 0

# Most important parameter to change:
set radius 6




# Do the job

# only every $framerate frames
eval bigdcd COMZ $framerate $argv 

bigdcd_wait

exit
