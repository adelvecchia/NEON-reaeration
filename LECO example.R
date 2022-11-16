#LECO example because of good discharge for 2018 and 2019 and good coherence to USGS gauge for discharge

##############################################################################################
#' @title Example Script for use with neonUtilities 2.0+

#' @author
#' Kaelin M. Cawley \email{kcawley@battelleecology.org} \cr

#' @description This script downloads and formats reaeration and discharge data from the 
#' NEON data portal in order to calculate loss rate, travel time, SF6 reaeration rate, 
#' O2 gas transfer velocity, and Schmidt number 600.

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords surface water, streams, rivers, reaeration, gas transfer velocity, schmidt number

#' @examples
#' #where the data .zip file is in the working directory and has the default name,
#' #reaFormatted <- def.format.reaeration()

#' @seealso def.calc.tracerTime.R for calculating the stream travel time,
#' def.plot.reaQcurve.R for plotting reaeration rate versusu stream flow,
#' def.format.reaeration for formatting reaeration data

# changelog and author contributions / copyrights
#   Kaelin M. Cawley (2021-02-04)
#     original creation
##############################################################################################

#User Inputs
siteID <- "LECO" 
#siteID <- "" #ADCP site for testing that

#String constants
reaDPID <- "DP1.20190.001"
dscDPID <- "DP1.20048.001" #not sure why discharge is needed? this is the field based ADCP/flowmeter

# Download Reaeration Data
reaInputList <- neonUtilities::loadByProduct(dpID = reaDPID, site = siteID, check.size = FALSE)

rea_backgroundFieldCondDataIn <- reaInputList$rea_backgroundFieldCondData
rea_backgroundFieldSaltDataIn <- reaInputList$rea_backgroundFieldSaltData
rea_fieldDataIn <- reaInputList$rea_fieldData
rea_plateauMeasurementFieldDataIn <- reaInputList$rea_plateauMeasurementFieldData
rea_externalLabDataSaltIn <- reaInputList$rea_externalLabDataSalt
rea_externalLabDataGasIn <- reaInputList$rea_externalLabDataGas
rea_widthFieldDataIn <- reaInputList$rea_widthFieldData
rea_plateauSampleFieldData <- reaInputList$rea_plateauSampleFieldData #added this

# Download Discharge Data - ADCP discharge data
qInputList <- neonUtilities::loadByProduct(dpID = dscDPID, site = siteID, check.size = FALSE)

dsc_fieldDataIn <- qInputList$dsc_fieldData
dsc_individualFieldDataIn <- qInputList$dsc_individualFieldData

# rea_backgroundFieldCondData <- rea_backgroundFieldCondDataIn
# rea_backgroundFieldSaltData <- rea_backgroundFieldSaltDataIn
# rea_fieldData <- rea_fieldDataIn
# rea_plateauMeasurementFieldData <- rea_plateauMeasurementFieldDataIn
# rea_externalLabDataSalt <- rea_externalLabDataSaltIn
# rea_externalLabDataGas <- rea_externalLabDataGasIn
# rea_widthFieldData <- rea_widthFieldDataIn
# dsc_fieldData <- dsc_fieldDataIn
# dsc_individualFieldData <- dsc_individualFieldDataIn

#this function is in the KC reaeration format file
reaFormatted_LECO <- def.format.reaeration(rea_backgroundFieldCondData = rea_backgroundFieldCondDataIn,
                                      rea_backgroundFieldSaltData = rea_backgroundFieldSaltDataIn,
                                      rea_fieldData = rea_fieldDataIn,
                                      rea_plateauMeasurementFieldData = rea_plateauMeasurementFieldDataIn,
                                      rea_externalLabDataSalt = rea_externalLabDataSaltIn,
                                      rea_externalLabDataGas = rea_externalLabDataGasIn,
                                      rea_widthFieldData = rea_widthFieldDataIn,
                                      dsc_fieldData = dsc_fieldDataIn,
                                      dsc_individualFieldData = dsc_individualFieldDataIn,
                                      rea_plateauSampleFieldData = rea_plateauSampleFieldData)


inputFile = reaFormatted_LECO
loggerData = reaInputList$rea_conductivityFieldData
namedLocation = "namedLocation"
injectionTypeName = "injectionType"
eventID = "eventID"
stationToInjectionDistance = "stationToInjectionDistance"
plateauGasConc = "plateauGasConc"
corrPlatSaltConc = "corrPlatSaltConc"
hoboSampleID = "hoboSampleID"
discharge = "fieldDischarge"
waterTemp = "waterTemp"
wettedWidth = "wettedWidth"
plot = TRUE
savePlotPath = NULL
processingInfo = NULL

unique(inputFile$eventID)
setwd('C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/LECO_demo')
#save.image('LECOworking.RData')
#load('LECOworking.RData')

#mastercal reaeration file fcn
reaRatesCalcLECO <- def.calc.reaeration(inputFile = inputFile,
                                             loggerData = reaInputList$rea_conductivityFieldData,
                                             namedLocation = "namedLocation",
                                             injectionTypeName = "injectionType",
                                             eventID = "eventID",
                                             stationToInjectionDistance = "stationToInjectionDistance",
                                             plateauGasConc = "plateauGasConc",
                                             corrPlatSaltConc = "corrPlatSaltConc",
                                             hoboSampleID = "hoboSampleID",
                                             discharge = "fieldDischarge",
                                             waterTemp = "waterTemp",
                                             wettedWidth = "wettedWidth",
                                             plot = TRUE,
                                    savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/LECO_demo',#savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/COMO4',
                                             processingInfo = NULL,
                                    eventsindexstart = 1,
                                    eventsindexend = 42) #experiment indices

LECO_input1<-reaRatesCalcLECO[[2]]
LECO_output1<-reaRatesCalcLECO[[1]]
setwd('C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/LECO report1')
write.csv(LECO_input1, 'LECO_input1.csv')
write.csv(LECO_output1, 'LECO_output1.csv')

unique(inputFile$eventID)

reaRatesCalc_manualLECO <- manual.reaeration(inputFile = inputFile,
                                    loggerData = reaInputList$rea_conductivityFieldData,
                                    namedLocation = "namedLocation",
                                    injectionTypeName = "injectionType",
                                    eventID = "eventID",
                                    stationToInjectionDistance = "stationToInjectionDistance",
                                    plateauGasConc = "plateauGasConc",
                                    corrPlatSaltConc = "corrPlatSaltConc",
                                    hoboSampleID = "hoboSampleID",
                                    discharge = "fieldDischarge",
                                    waterTemp = "waterTemp",
                                    wettedWidth = "wettedWidth",
                                    plot = TRUE,
                                    savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/LECO demo manual',#savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/COMO4',
                                    processingInfo = NULL,
                                    eventsindexstart = 38,
                                    eventsindexend = 42)

#need to shorten the derivative averaging window for the slugs?

LECO_output1<-reaRatesCalc_manualLECO[[1]]
LECO_input1<-reaRatesCalc_manualLECO[[2]]
setwd('C://Users/adelv/Dropbox/NEON/CSVs_R/Reaeration/LECO report1')
write.csv(LECO_input1, 'LECO_input_add_peaks1.csv')
write.csv(LECO_output1, 'LECO_output_add_peaks1.csv')
#finally works...wiill just have to fix for peaks!  

reaRatesCalc_manualLECO <- manual.reaeration(inputFile = inputFile,
                                             loggerData = reaInputList$rea_conductivityFieldData,
                                             namedLocation = "namedLocation",
                                             injectionTypeName = "injectionType",
                                             eventID = "eventID",
                                             stationToInjectionDistance = "stationToInjectionDistance",
                                             plateauGasConc = "plateauGasConc",
                                             corrPlatSaltConc = "corrPlatSaltConc",
                                             hoboSampleID = "hoboSampleID",
                                             discharge = "fieldDischarge",
                                             waterTemp = "waterTemp",
                                             wettedWidth = "wettedWidth",
                                             plot = TRUE,
                                             savePlotPath = 'C://Users/adelv/Dropbox/NEON/CSVs_R/Reaeration/LECO report1',#savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/COMO4',
                                             processingInfo = NULL,
                                             eventsindexstart = 1,
                                             eventsindexend = 2)

#need to shorten the derivative averaging window for the slugs?

LECO_output2<-reaRatesCalc_manualLECO[[1]]
LECO_input2<-reaRatesCalc_manualLECO[[2]]
setwd('C://Users/adelv/Dropbox/NEON/CSVs_R/Reaeration/LECO report1')
write.csv(LECO_input2, 'LECO_input_add_peaks2.csv')
write.csv(LECO_output2, 'LECO_output_add_peaks2.csv')
#finally works...wiill just have to fix for peaks!  


reaRatesCalc_manualLECO <- manual.reaeration(inputFile = inputFile,
                                             loggerData = reaInputList$rea_conductivityFieldData,
                                             namedLocation = "namedLocation",
                                             injectionTypeName = "injectionType",
                                             eventID = "eventID",
                                             stationToInjectionDistance = "stationToInjectionDistance",
                                             plateauGasConc = "plateauGasConc",
                                             corrPlatSaltConc = "corrPlatSaltConc",
                                             hoboSampleID = "hoboSampleID",
                                             discharge = "fieldDischarge",
                                             waterTemp = "waterTemp",
                                             wettedWidth = "wettedWidth",
                                             plot = TRUE,
                                             savePlotPath = 'C://Users/adelv/Dropbox/NEON/CSVs_R/Reaeration/LECO report1',#savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/COMO4',
                                             processingInfo = NULL,
                                             eventsindexstart = 6,
                                             eventsindexend = 42)

#need to shorten the derivative averaging window for the slugs?

LECO_output2<-reaRatesCalc_manualLECO[[1]]
LECO_input2<-reaRatesCalc_manualLECO[[2]]
setwd('C://Users/adelv/Dropbox/NEON/CSVs_R/Reaeration/LECO report1')
write.csv(LECO_input2, 'LECO_input_add_peaks2.csv')
write.csv(LECO_output2, 'LECO_output_add_peaks2.csv')
#finally works...wiill just have to fix for peaks!  





#switching to higher tolerance script

reaRatesCalcLECO <- def.calc.reaeration(inputFile = inputFile,
                                        loggerData = reaInputList$rea_conductivityFieldData,
                                        namedLocation = "namedLocation",
                                        injectionTypeName = "injectionType",
                                        eventID = "eventID",
                                        stationToInjectionDistance = "stationToInjectionDistance",
                                        plateauGasConc = "plateauGasConc",
                                        corrPlatSaltConc = "corrPlatSaltConc",
                                        hoboSampleID = "hoboSampleID",
                                        discharge = "fieldDischarge",
                                        waterTemp = "waterTemp",
                                        wettedWidth = "wettedWidth",
                                        plot = TRUE,
                                        savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/LECO report1',#savePlotPath = 'C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/COMO4',
                                        processingInfo = NULL,
                                        eventsindexstart = 6,
                                        eventsindexend = 42) 

LECO_input3<-reaRatesCalcLECO[[2]]
LECO_output3<-reaRatesCalcLECO[[1]]
setwd('C://Users/agd37/Dropbox/NEON/CSVs_R/Reaeration/LECO report1')
write.csv(LECO_input3, 'LECO_input-hightol.csv')
write.csv(LECO_output3, 'LECO_output-hightol.csv')