# This script extracts CPPS, jitter, shimmer, HNR, and F0 values of the files in the specified directory
# Sebastiano Failla
# The University of Western Ontario, April 2019
# sfailla@uwo.ca 


form Enter Information
	comment Sound file extension
	sentence Extension_(only_letters) wav
	
	comment Location of sound files of interest
	sentence Directory 
	
	comment Cepstrogram parameters
	positive PitchFloor_(Hz) 60
	positive MaximumFrequency_(Hz) 5000
	positive PreEmphasis_(Hz) 50
	
	comment CPPS parameters
	positive MinimumPitchSearch_(Hz) 60
	positive MaximumPitchSearch_(Hz) 330
	
	comment CPPS smoothing
	boolean SubtractTiltLineBeforeSmoothing
	positive TimeAveragingWindow_(s) 0.02
	positive QuefrencyAveragingWindow_(s) 0.0005 
	
	comment CPPS Tilt Line
	choice LineType: 2
	button Exponential decay
	button Straight
endform



# right$(a$,n) gives a string consisting of the last n characters of a$
# This line says "if the last letter of the variable directory 
# is not equal to / , then make the new variable directory as 
# the old string but now with / on the end of that string

if right$ (directory$,1) <> "/"
	directory$ = "'directory$'/"
endif



# Creates a Strings object called myList which contains the list of all files ending in your extension of interest
Create Strings as file list... myList 'directory$'*.'extension$'
numberOfFiles = Get number of strings

# Creates a .txt file in the same directory as the files of interest

deleteFile: "'directory$'CPPS_Jitter_Shimmer_HNR_F0_info.txt"
appendFileLine: "'directory$'CPPS_Jitter_Shimmer_HNR_F0_info.txt", "Participant,CPPS(dB),Jitter(%),Shimmer(dB),Harmonic-to-Noise Ratio(dB),F0(Hz)"


# This section loads and selects each file from the directory 
	for iFile to numberOfFiles
		select Strings myList
		fileName$ = Get string: iFile
		
		Read from file... 'directory$''fileName$'
		name$ = selected$ ("Sound")

		selectObject: "Sound 'name$'"
		To PowerCepstrogram: pitchFloor, 0.002, maximumFrequency, preEmphasis
		cPPS = Get CPPS: subtractTiltLineBeforeSmoothing, timeAveragingWindow, quefrencyAveragingWindow, minimumPitchSearch, maximumPitchSearch, 0.05, "Parabolic", 0.001, 0, lineType$, "Robust"

		selectObject: "Sound 'name$'"
		To Pitch: 0, 75, 600
		fFrequency = Get minimum: 0, 0, "Hertz", "Parabolic"
		selectObject: "Sound 'name$'"
		plusObject: "Pitch 'name$'"
		To PointProcess (cc)
		jITTER = Get jitter (local): 0, 0, 0.0001, 0.02, 1.3
		jITTER = jITTER * 100

		selectObject: "Sound 'name$'"
		plusObject: "PointProcess 'name$'_'name$'"
		sHIMMER = Get shimmer (local_dB): 0, 0, 0.0001, 0.02, 1.3, 1.6

		selectObject: "Sound 'name$'"
		To Harmonicity (cc): 0.01, 75, 0.1, 1
		hNR = Get mean: 0, 0
		
		
		#appendFileLine: "'directory$'CPPS_Jitter_Shimmer_HNR_F0_info.txt","'name$'",",",fixed$(cPPS,6),",",fixed$(jITTER,6),",",fixed$(sHIMMER,6),",",fixed$(hNR,6),",",fixed$(fFrequency,6) 
		# Build custom output filename based on WAV name
		outputFile$ = "'directory$''name$'.txt"
		deleteFile: outputFile$
		appendFileLine: outputFile$, "CPPS(dB),Jitter(%),Shimmer(dB),HNR(dB),F0(Hz)"
		appendFileLine: outputFile$, fixed$(cPPS,6), ",", fixed$(jITTER,6), ",", fixed$(sHIMMER,6), ",", fixed$(hNR,6), ",", fixed$(fFrequency,6)
              
		
	endfor
	
select all
Remove
	
exitScript("Done!")