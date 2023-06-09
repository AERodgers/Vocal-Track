###################################################################################
###                                                                             ###
### DLG_Voice.praat                                                             ###
### v 1.3.s                                                                     ###
### Voice analysis for Dublin Language Garden 2017                              ###
### ==============================================                              ###
###                                                                             ###
### - Reads in a wave file and text grid with a single interval tier.           ###
### - Splits original file into smaller Sound objects based on annotation tier. ###
### - Each interval to be analysed should be given a unique name.               ###
###                                                                             ###
### - Gets minimum, maximum, and mean f0 for each sound object.                 ###
### - Gets spectrum tier data and linear trend line from an LTAS analysis.      ###
### - Estimates VTL by averaging the most likely 3/4-wave-tube-like candidates  ###
###   from the formant contour and adjusting for end-correction.                ###
###   NOTE: the VTL approximation technique is very provisional.                ###
###                                                                             ###
### - Saves the results for each Sound object to a tab-separated text file to   ###
### - Creates an A4 sized Praat Picture which summarised the data.              ###
###                                                                             ###
### This is currently configured to run an input-lite version.                  ###
### Follow the instructions in the comments to restore the full version.        ###
###                                                                             ###
### Praat 6.0.31                                                                ###
###                                                                             ###
### Antoin Eoin Rodgers                                                         ###
### rodgeran@tcd.ie                                                             ###
### September 10 2017                                                            ###
###                                                                             ###
###################################################################################

### Some of the options have been removed from the form for the sake of convenience.
### To return to full version:
###    1. delete comment marked: #removed for short version
###    2. delete all lines between ### START and ### STOP comments

#####################
### Set Constants ###
#####################

########################
### Default settings ###

# flag to remove objects from object window.
removeObjects = 1

# amplitude settings (dBs SPL)
dBNormalisation = 70
dBThreshold = 30

# semiFinal = number of schwa-like candidates to include before removing extreme values.
semiFinal = 20

# Threshold of standard deviations considered extreme.
okayStdDevs = 3

# speed of sound (cm/s) in the vocal tract
c = 35000
# end correction co-efficient (NB not an offset value!)
endCorr = 0.92

### male standard values
minPitchM = 65
maxPitchM = 350
maxFormantFreqM = 5500
removeF5sM = 1

### female standard values
minPitchF = 100
maxPitchF = 450
maxFormantFreqF = 6600
removeF5sF = 0

### child standard values
minPitchC = 200
maxPitchC = 700
maxFormantFreqC = 8000
removeF5sC = 0

### Pitch analysis settings
  # NB: octave cost and voicing threshold set to higher than standard
  # to reduce likelihood of inclusion of pitch-doubling/halving and
  # mis-interpreting noise as periodic

oCost = 0.04
vThresh = 0.8


###################################
### GRAPHIC INTERFACE CONSTANTS ###

penColour$[1] = "Black"
penColour$[2] = "{1,0.1,0.1}"
penColour$[3] = "Green"
penColour$[4] = "Blue"
penColour$[5] = "Grey"
penColour$[6] = "Olive"
penColour$[7] = "Cyan"
penColour$[8] = "Silver"
penColour$[9] = "Teal"
penColour$[10] = "Navy"
penColour$[11] = "Lime"
penColour$[12] = "Maroon"
penColour$[13] = "Magenta"
penColour$[14] = "{0.267,0.447,0.769}"
penColour$[15] = "Purple"

### axis points for picture window
width = 18
height = 28
topMostHeight = 23
lowestHeight = 2.5
rightmost = 19
leftmost = 1
innerRight = 9.5
innerLeft = 12
innerTop = 11.5
innerBottom = 14

### Set min and max values for Display Axes
pitchMaxDisplay = 550
pitchMinDisplay = 50
vtlMaxDisplay = 19
vtlMinDisplay = 0
lTASdBMaxDisplay = 50
lTASdBMinDisplay = -10

### Average values for male and female voices
aveAdultMf0 = 116.65
aveAdultFf0 = 217

aveAdultMf0Min = 85
aveAdultFf0Min = 165

aveAdultMf0Max = 155
aveAdultFf0Max = 255

aveAdultMVTL = 16.9
aveAdultFVTL = 14.1

femaleText$ = "average" + newline$ + "normal" + newline$ +  "adult (F)"
maleText$ = femaleText$ - "F)" + "M)"

### cm to inch conversion
cm2i = 0.393701

### Text strings
infoTextTop$ = "The measurements and estimates below were calculated from audio of your speech" +
...newline$+"recorded at the Dublin Language Garden at the Hub, TCD on September 22nd, 2017."+
...newline$+"You can see how your voice and vocal tract look difference depending on how you speak."+
...newline$+"Compare your results with other people."+
...newline$ + "##Do remember there may be errors since the recordings were very short.#"

infoTextBottom$ = "Designed and written by Antoin Rodgers, Phonetics and Speech Laboratory, TCD. (rodgeran@tcd.ie)" +
...newline$ + "Written in Praat script (www.praat.org/)" +
...newline$ +
...newline$ + "*Goldstein, Ursula, 1980. %%An articulatory Model for the Vocal Tracts of Growing Children%," +
..." MIT. Ph.D. Thesis" +
...newline$ + "**Fitch, J., & Holbrook, A., 1970. Modal Fundamental Frequency of Young Adults. " +
..."%%Archives of Otolaryngology%, 92, pp.379–381"


##################
### USER INPUT ###
##################

form Input directory name with final slash
    comment -----------------------WAVEFORM INFORMATION-------------------------
    comment Do you want to load pre-existing files or record a new sound?
    choice sound_Options 1
        button load
        button record
    comment Enter directory with sound and text files:
    sentence dir
    comment Enter name of soundfile (without .wav extension)
    sentence baseName F1
    comment -------------------------VOICE SETTINGS-------------------------
    choice voice_settings 2
        button Child
        button Female
        button Male
        button Manual_Settings
    comment -------------------------MANUAL SETTINGS-------------------------
    positive minPitch 100
    positive maxPitch  450
    positive maxFormantFreq 6600
    boolean removeF5s 0
    comment -------------------------------------NOTES-------------------------------------
    comment Default pitch range is 100 - 450 Hz for females, 70 - 350 Hz for males, 200 - 700 Hz for children.
    comment Default formant frequency is 6600 Hz for females, 5500 Hz for males, 8000 Hz for children.
    comment Remove F5s is only recommended for adult male voices.
    comment The max formant value is very high, but most spurious values are removed.

#removed for short version    comment Enter Normalised average dB
#removed for short version    positive dBNormalisation 70
#removed for short version    comment Enter dB threshold for analysis frames
#removed for short version    positive dBThreshold 30
#removed for short version    comment
#removed for short version    comment Enter speed of sound in vocal tract (cm)
#removed for short version    positive c 35000
#removed for short version    comment Enter number of semi-final candidate VTL estimates
#removed for short version    positive semiFinal 20
#removed for short version    comment Enter maximum number of standard deviations for final candidates
#removed for short version    positive okayStdDevs 3
#removed for short version    comment Enter end correction ratio
#removed for short version    positive endCorr 0.92

endform

### set standard values appropriate if child, male, or female voices were selected.
if voice_settings = 1
    minPitch = minPitchC
    maxPitch = maxPitchC
    maxFormantFreq = maxFormantFreqC
    removeF5s = removeF5sC
else

    if voice_settings = 2
        minPitch = minPitchF
        maxPitch = maxPitchF
        maxFormantFreq = maxFormantFreqF
        removeF5s = removeF5sF
    else
        if voice_settings = 3
            minPitch = minPitchM
            maxPitch = maxPitchM
            maxFormantFreq = maxFormantFreqM
            removeF5s = removeF5sM
       endif
    endif
endif

thresholdPa = 10^(dBThreshold/20)*0.00002
if endCorr > 1
    endCorr = 1
endif

######################################
### GET SOUND FILES FOR PROCESSING ###
######################################

if sound_Options = 2
    pause Record & save your sound file using the specified directory and name along with an annotated textgrid.
    sound_Options = 1
endif

### get wave file
soundFile$ = "'dir$'\'baseName$'.wav"

#Read in target wave file
Read from file: soundFile$
soundID = selected()
fs = Get sampling frequency

### prevent maxFormantFreq from being higher than nyquist frequency
newMaxFormant = 5500
while maxFormantFreq > fs/2
    maxFormantFreq = newMaxFormant
    newMaxFormant = newMaxFormant = 100
endwhile

### read in text grid (asssumes textgrid exists)
textGridFile$ = left$ (soundFile$, rindex (soundFile$, "."))+ "TextGrid"
Read from file: textGridFile$
gridID = selected()

### CREATE NEW SOUND OBJECTS BASED ON TIER 1 INTERVAL AND ARRAY OF NON-BLANK INTERVAL NAMES
totalIntervals = Get number of intervals: 1
validIntervals = 0
for i from 1 to totalIntervals
    i$ = Get label of interval: 1, i
    if i$<>""
        validIntervals = validIntervals + 1
        list$[validIntervals] =  i$
    endif
endfor

### Read and split wavefile into interval segments
selectObject: gridID
plusObject: soundID
Extract non-empty intervals: 1, "no"

selectObject: gridID, soundID
if removeObjects = 1
    Remove
endif

#############################################
### Set up and Draw Graphics Output Frame ###
#############################################

###################################
### Set default graphic options ###
Erase all
Colour: "black"
Solid line
Font size: 10
Line width: 1
Helvetica

### Create page output template size and add logos
Axes: 0, width, 0, height
Select inner viewport: 0, width*cm2i, 0, height*cm2i

Insert picture from file: "DLG.jpg", 15, width, height-(3*865/888), height

Insert picture from file: "TCD.jpg", rightmost-(2*1713/591), rightmost, -0.5, 1.5

#################
### Add Text ####

### Info text at top
Font size: 10
Select inner viewport: 0, width*cm2i, 0, height*cm2i
Colour: "Black"
Helvetica
Text: 0, "Left", 27, "Top", infoTextTop$

###Title
Font size: 18
Select inner viewport: 0, width*cm2i, 0, height*cm2i
Text: 0, "Left", height, "Top", "##Have a look at your different voices!#"

### Info text at bottom
Font size: 8
Text: 0.5, "Left", 0.3, "Bottom", infoTextBottom$

#######################
### Draw VTL WINDOW ###

### Draw VTL window rectangle
Select inner viewport: 0, width*cm2i, 0, height*cm2i
Axes: 0, 18, 0, height
Draw rectangle: innerLeft, 18, lowestHeight, topMostHeight

### Mark Vertical Pitch axis title and values
Font size: 10
Select inner viewport: innerLeft*cm2i, width*cm2i, (height-topMostHeight)*cm2i, (height-lowestHeight)*cm2i
Axes: 0, validIntervals+2, vtlMinDisplay, vtlMaxDisplay
#       (validIntervals+2 because this will determine the number of columns)

Marks left every: 1, 1, "yes", "yes", "yes"
Marks bottom every: 1, 1, "no", "yes", "yes"
Text left: "yes", "Length (cm)"
Font size: 12
Text top: "yes", "Average Vocal Tract Length Estimates"

### draw average Male and Female VTL
Font size: 10
Select inner viewport: innerLeft*cm2i, width*cm2i, (height-topMostHeight)*cm2i, (height-lowestHeight)*cm2i
Axes: 0, validIntervals+2, vtlMinDisplay, vtlMaxDisplay

#### draw bar for average Male VTL
Paint rectangle: penColour$[14], validIntervals+1.7, validIntervals+1.3, 0, aveAdultMVTL

#### draw bar for average female VTL
Paint rectangle: penColour$[15], validIntervals+0.7, validIntervals+0.3, 0, aveAdultFVTL
### Add category information and data values
Colour: "Black"
Font size: 8
Text: validIntervals+1.5, "Centre", 0.2, "Top", maleText$ + "*"
Text: validIntervals+0.5, "Centre", 0.2, "Top", femaleText$ + "*"
Font size: 10
Text: validIntervals+1.5, "Centre", aveAdultMVTL, "Bottom", string$(aveAdultMVTL)
Text: validIntervals+0.5, "Centre", aveAdultFVTL, "Bottom", string$(aveAdultFVTL)


#########################
### DRAW PITCH WINDOW ###

### Draw Pitch window Rectangle
Select inner viewport: 0, width*cm2i, 0, height*cm2i
Axes: 0, width, 0, height
Draw rectangle: leftmost, innerRight, lowestHeight, innerTop

### Mark Vertical Pitch axis title and values
Font size: 10
Select inner viewport: leftmost*cm2i, innerRight*cm2i, (height-innerTop)*cm2i, (height-lowestHeight)*cm2i
Axes: 0, validIntervals+2, pitchMinDisplay, pitchMaxDisplay
#       (validIntervals+2 because this will determine the number of columns)

Marks left every: 1, 50, "yes", "yes", "yes"
Marks bottom every: 1, 1, "no", "yes", "yes"
Text left: "yes", "fundamental frequency (Hz)"

Font size: 12
Text top: "yes", "Pitch Ranges and Averages"

#### draw average male and female f0
Line width: 2
Font size: 10

#### draw x for mean: male
Colour: penColour$[14]
Draw line: validIntervals+1.45, aveAdultMf0+4, validIntervals+1.55, aveAdultMf0-4
Draw line: validIntervals+1.45, aveAdultMf0-4, validIntervals+1.55, aveAdultMf0+4

#### draw lines to show range, max, and min - male
Draw line: validIntervals+1.5, aveAdultMf0Min, validIntervals+1.5, aveAdultMf0Max
Draw line: validIntervals+1.38, aveAdultMf0Min, validIntervals+1.62, aveAdultMf0Min
Draw line: validIntervals+1.38, aveAdultMf0Max, validIntervals+1.62, aveAdultMf0Max

#### Add category axis and label values -male
Colour: "Black"
Text: validIntervals+1.5, "Centre",  pitchMinDisplay, "Top", maleText$ + "**"
Font size: 10
Text: validIntervals+1.55, "Left", aveAdultMf0, "Half", string$(round(aveAdultMf0))
Text: validIntervals+1.5, "Centre", aveAdultMf0Min, "Top", string$(round(aveAdultMf0Min))
Text: validIntervals+1.5, "Centre", aveAdultMf0Max, "Bottom", string$(round(aveAdultMf0Max))

### draw x for mean: female
Colour: penColour$[15]
Draw line: validIntervals+0.45, aveAdultFf0+4, validIntervals+0.55, aveAdultFf0-4
Draw line: validIntervals+0.45, aveAdultFf0-4, validIntervals+0.55, aveAdultFf0+4

### draw lines to show range, max, and min - female
Draw line: validIntervals+0.5, aveAdultFf0Min, validIntervals+0.5, aveAdultFf0Max
Draw line: validIntervals+0.38, aveAdultFf0Min, validIntervals+0.62, aveAdultFf0Min
Draw line: validIntervals+0.38, aveAdultFf0Max, validIntervals+0.62, aveAdultFf0Max

### Add category axis and label values - female
Colour: "Black"
Text: validIntervals+0.5, "Centre", pitchMinDisplay, "Top", femaleText$ + "**"
Font size: 10
Text: validIntervals+0.55, "Left", aveAdultFf0, "Half", string$(round(aveAdultFf0))
Text: validIntervals+0.5, "Centre", aveAdultFf0Min, "Top", string$(round(aveAdultFf0Min))
Text: validIntervals+0.5, "Centre", aveAdultFf0Max, "Bottom", string$(round(aveAdultFf0Max))
Line width: 1

###################
### LTAS WINDOW ###

### Draw LTAS window Rectangle
Select inner viewport: 0, width*cm2i, 0, height*cm2i
Axes: 0, width, 0, height
Draw rectangle: leftmost, innerRight, innerBottom, topMostHeight

### Mark Vertical Pitch axis title and values
Font size: 10
Select inner viewport: leftmost*cm2i, innerRight*cm2i, (height-topMostHeight)*cm2i, (height-innerBottom)*cm2i
Axes: 0, 5, lTASdBMinDisplay, lTASdBMaxDisplay
Marks left every: 1, 10, "yes", "yes", "yes"
Marks bottom every: 1, 1, "yes", "yes", "yes"
Text left: "yes", "Intensity (dB/Hz)"
Text bottom: "yes", "Frequency (kHz)"
Font size: 12
Text top: "yes", "Voice Quality: Long-term Average Spectrum Trends"
Font size: 10

### Draw LTAS Legend
currentY = lTASdBMaxDisplay-(lTASdBMaxDisplay-lTASdBMinDisplay)*0.07
increment = (lTASdBMaxDisplay-lTASdBMinDisplay)*0.047

### draw background for legend
Paint rectangle: "white", 3.5, 4.9,
              ...lTASdBMaxDisplay-78/(lTASdBMaxDisplay-lTASdBMinDisplay),
              ...currentY-increment*(validIntervals)
Colour: "black"
Draw rectangle: 3.5, 4.9,
              ...lTASdBMaxDisplay-78/(lTASdBMaxDisplay-lTASdBMinDisplay),
              ...currentY-increment*(validIntervals)

### get legend key
legend$ = ""
for key to validIntervals
    legend$ = legend$  + newline$ + list$[key]
endfor
Text: 4.5, "Right", lTASdBMaxDisplay, "Top", legend$

### draw key lines
Line width: 2
for drawLine to validIntervals
    Colour: penColour$[drawLine]
    Draw line: 4.6, currentY, 4.8, currentY
    currentY = currentY - increment
endfor
Line width: 1

Select inner viewport: 0, width*cm2i, 0, height*cm2i

####################
### THE ANALYSIS ###
####################
for analyseThese to validIntervals
    if analyseThese <= 15
        currentPen$ = penColour$[analyseThese]
    endif

    ### Select sound, normalise dB, run pass band filter and identify beginning and end of file
    currentSound$ = "Sound " + list$[analyseThese]
    selectObject: currentSound$
    Scale intensity: 70
    startsAt = Get start time
    endsAt = Get end time
    if endsAt > startsAt + 10
        endsAt = startsAt + 9.99
    endif
    Filter (pass Hann band): 50, 22050, 50
    selectObject: currentSound$
    Remove
    currentSound$ = currentSound$ + "_band"
    
    
    ###################
    ##VTL Estimation ##

    ### GET FORMANT CONTOUR
    ### get table of formant contour for whole sound file
    selectObject: currentSound$
    Edit
    editor: currentSound$
        Advanced pitch settings: 0, 0, "no", 15, 0.03, 0.65, 0.04, 0.35, 0.14
        Formant settings: maxFormantFreq, 5, 0.025, 30, 1
        Zoom: startsAt, endsAt
        Extract visible formant contour
        Close
    endeditor
    deleteMe = selected()
    formantContour$ = Down to Table: "no", "yes", 6, "yes", 6, "yes", 3, "no"
    tableOne = selected ()


    ### RUN VTL ESTIMATION CALCULATIONS
    ### Remove unreliable frames
    Extract rows where column (number): "intensity", "greater than or equal to", thresholdPa
    tableTwo = selected ()
    Extract rows where column (text): "F4(Hz)", "is not equal to", "--undefined--"
    tableThree = selected ()

    if removeF5s = 1
        Extract rows where column (text): "F5(Hz)", "is not equal to", "--undefined--"
    endif

    Rename: "ValidFormantFrames"
    validFormantFrame = selected()

    selectObject: tableOne, tableTwo, deleteMe
    if removeF5s = 1
        plusObject: tableThree
    endif
    if removeObjects = 1
        Remove
    endif

    selectObject: validFormantFrame
    rows = Get number of rows

    ### append VTL-estimate, F1-estimate, average VTL estimate, and F1-estimate-Std-dev columns to table
    for i to 4
        Append column: "VTL_F" + string$(i)
        Append column: "F1_via_F" + string$(i)
    endfor
    Append column: "Ave_VTL"
    Append column: "StdDev_F1_ests"

    ### Calculate VTL estimates per formant and F1 values per formant as if for 3/4 wave tube
    for j to rows
        totalVTL = 0
        totalF1_ests = 0

        for i to 4
            columnName$ = Get column label: i+3
            currentFormant = Get value: j, columnName$

            currentF1_Hz[i] = round(currentFormant/(2*i-1))
            currentF_VTL = round(100*(2*i-1)*c/(4*currentFormant))/100

            Set numeric value: j, "VTL_F" + string$(i), currentF_VTL
            Set numeric value: j, "F1_via_F" + string$(i), currentF1_Hz[i]

            totalVTL = totalVTL + currentF_VTL
            totalF1_ests = totalF1_ests + currentF1_Hz[i]
        endfor

        Set numeric value: j, "Ave_VTL", round(100*totalVTL/4)/100

        meanF1ests = totalF1_ests/4
        sum = 0
        for i to 4
            sum = sum + (currentF1_Hz[i]-meanF1ests)^2
        endfor
        rootOfSum = sqrt(sum)
        Set numeric value: j, "StdDev_F1_ests", round(100*rootOfSum / 4)/100
    endfor

    ### Sort rows by F1 estimate standard deviations
    Sort rows: "StdDev_F1_ests"

    ### Remove all but smallest "semiFinal" candidate standard deviations
    rows = Get number of rows
    while rows > semiFinal
        Remove row: semiFinal+1
        rows = Get number of rows
    endwhile

    ### get means and standard deviation of semi-final VTL estimates
    mean_VTL_ests = Get mean: "Ave_VTL"
    ave_VTL_StDevs = Get standard deviation: "Ave_VTL"

    ### remove values which are more than x standard deviations away from the mean
    Extract rows where column (number): "Ave_VTL", "less than", okayStdDevs + mean_VTL_ests
    tableWithoutHighExtremes = selected()
    selectObject: validFormantFrame
    if removeObjects = 1
        Remove
    endif

    ### remove values which are less than x standard deviations away from the mean
    selectObject: tableWithoutHighExtremes
    Extract rows where column (number): "Ave_VTL", "greater than", okayStdDevs - mean_VTL_ests
    Rename: "FinalList"
    finalTable = selected()
    selectObject: tableWithoutHighExtremes
    if removeObjects = 1
        Remove
    endif

    selectObject: finalTable

    result = Get mean: "Ave_VTL"
    result = round(10*result*endCorr)/10

    ### DRAW CURRENT VTL INFO
    ### select correct viewport and axes
    Font size: 10
    Select inner viewport: innerLeft*cm2i, width*cm2i,
                       ... (height-topMostHeight)*cm2i, (height-lowestHeight)*cm2i
    Axes: 0, validIntervals+2, vtlMinDisplay, vtlMaxDisplay

    ### draw bar for current VTL
    Paint rectangle: currentPen$, analyseThese-0.7, analyseThese-0.3, 0, result

    ### Add category information and data values
    Colour: "Black"
    Text: analyseThese-0.5, "Centre", 0, "Top", list$[analyseThese]
    Text: analyseThese-0.5, "Centre", result, "Bottom", string$(result)

    #######################
    ## pitch information ##

    ### GET PITCH DATA FOR CURRENT SOUND
    selectObject: currentSound$
    To Pitch (ac): 0, minPitch, 15, 1, 0.03, vThresh, oCost, 0.35, 0.14, maxPitch

    pitchData = selected()
    minf0 = Get minimum: 0, 0, "Hertz", "Parabolic"
    maxf0 = Get maximum: 0, 0, "Hertz", "Parabolic"
    meanf0 = Get mean: 0, 0, "Hertz"

    ### DRAW CURRENT PITCH INFO
    ### select correct viewport and axes
    Font size: 10
    Select inner viewport: leftmost*cm2i, innerRight*cm2i,
                       ... (height-innerTop)*cm2i, (height-lowestHeight)*cm2i
    Axes: 0, validIntervals+2, pitchMinDisplay, pitchMaxDisplay

    ### draw data for current pitch values
    Colour: currentPen$
    Line width: 2
    # draw lines to show range, max, and min
    Draw line: analyseThese-0.5, minf0, analyseThese-0.5, maxf0
    Draw line: analyseThese-0.62, minf0, analyseThese-0.38, minf0
    Draw line: analyseThese-0.62, maxf0, analyseThese-0.38, maxf0

    ### draw x for mean
    Draw line: analyseThese-0.55, meanf0+4, analyseThese-0.45, meanf0-4
    Draw line: analyseThese-0.55, meanf0-4, analyseThese-0.45, meanf0+4

    ### Add category axis and label values
    Colour: "Black"
    Text: analyseThese-0.5, "Centre", pitchMinDisplay, "Top", list$[analyseThese]
    Text: analyseThese-0.45, "Left", meanf0, "Half", string$(round(meanf0))
    Text: analyseThese-0.5, "Centre", maxf0, "Bottom", string$(round(maxf0))
    Text: analyseThese-0.5, "Centre", minf0, "Top", string$(round(minf0))
    Line width: 1

    selectObject: pitchData
    if removeObjects = 1
        Remove
    endif

    ######################
    ## LTAS information ##

    ### GET LTAS DATA FOR CURRENT SOUND
      # note: LTAS band width set high (500 Hz) to show trends more clearly.
    selectObject: currentSound$
    To Ltas (pitch-corrected): minf0, maxf0, 5000, 500, 0.0001, 0.02, 1.3
    ltasCurrent = selected()

    Compute trend line: 200, 5000
    ltasTrend = selected()

    ### DRAW CURRENT LTAS INFO
    Font size: 10
    Select inner viewport: leftmost*cm2i, innerRight*cm2i,
                        ...(height-topMostHeight)*cm2i, (height-innerBottom)*cm2i
    Axes: 0, 5, lTASdBMinDisplay, lTASdBMaxDisplay
    Colour: currentPen$
    # Draw LTAS
    Line width: 2
    selectObject: ltasCurrent
    Draw: 0, 0, lTASdBMinDisplay, lTASdBMaxDisplay, "no", "Curve"

    # Draw Trend
    Line width: 3
    Dotted line
    selectObject: ltasTrend
    Draw: 0, 0, lTASdBMinDisplay, lTASdBMaxDisplay, "no", "Curve"
    Line width: 1
    Solid line

    ### Get Spectrum Tier for current LTAS for Excel Output
      # NB This is now largely redundant as Excel no longer used
    #ltas = selected()
    #To SpectrumTier (peaks)
    #ltasinfo$ = List... 0 1 1

    selectObject: ltasCurrent
    plusObject: ltasTrend
    Remove

    ### Remove remains
    selectObject: finalTable
    plusObject: currentSound$
    Remove

#    NB Next 2 sections largely redundant as Excel no longer used
#    to generate visuals
#    #############################################################
#    ### Save current set of results to file for current sound ###
#
#    saveFileFull$ = dir$+"\"+baseName$+"_"+list$[analyseThese]+".txt"
#    writeFileLine: saveFileFull$, currentSound$, newline$
#    appendFileLine: saveFileFull$, "VTL", tab$,  round(10*result*endCorr)/10
#    appendFileLine: saveFileFull$, "mean_f0", tab$, round(meanf0)
#    appendFileLine: saveFileFull$, "minimum_f0", tab$, round(minf0)
#    appendFileLine: saveFileFull$, "maximum_f0", tab$, round(maxf0)
#    appendFileLine: saveFileFull$, newline$, ltasinfo$, newline$
#
#    ####################################################
#    ### Output current set of results to Info window ###
#
#    #appendInfoLine: currentSound$
#    #appendInfoLine: "  ", " VTL:  ", tab$,  round(10*result)/10
#    #appendInfoLine: "  ", " mean_f0:", tab$, round(meanf0)
#    #appendInfoLine: "  ", " min_f0:", tab$, round(minf0)
#    #appendInfoLine: "  ", " max_f0:", tab$, round(maxf0), newline$

endfor

#################################
### Save graphics as PNG file ###
#################################
Select inner viewport: 0, width*cm2i, 0, height*cm2i
Font size: 10
Axes: 0, width, 0, height

image$ = dir$ + "\" + baseName$ + ".png"
Save as 600-dpi PNG file: image$