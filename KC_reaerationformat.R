##############################################################################################
#' @title Formats reaeration data for rate calculations

#' @author
#' Kaelin M. Cawley \email{kcawley@battelleecology.org} \cr
#' Amanda Gay DelVecchia \email{amanda.delvecchia@duke.edu} \cr

#' @description This function formats data from the NEON reaeration data product to calculate
#' loss rate, travel time, SF6 reaeration rate, O2 gas transfer velocity, and Schmidt number 600.
#' Either the basic or expanded package can be downloaded. The data files need to be loaded
#' into the R environment
#' 
#' AGD edited to expand the initial file for EDA analyses

#' @importFrom stageQCurve conv.calc.Q
#' @importFrom geoNEON getLocBySite
#' @importFrom utils read.csv

#' @param rea_backgroundFieldCondData This dataframe contains the data for the NEON rea_backgroundFieldCondData table [dataframe]
#' @param rea_backgroundFieldSaltData This dataframe contains the data for the NEON rea_backgroundFieldSaltData table [dataframe]
#' @param rea_fieldData This dataframe contains the data for the NEON rea_fieldData table [dataframe]
#' @param rea_plateauMeasurementFieldData This dataframe contains the data for the NEON rea_plateauMeasurementFieldData table [dataframe]
#' @param rea_plateauSampleFieldData This dataframe contains the data for the NEON rea_plateauSampleFieldData table [dataframe]
#' @param rea_externalLabDataSalt This dataframe contains the data for the NEON rea_externalLabDataSalt table [dataframe]
#' @param rea_externalLabDataGas This dataframe contains the data for the NEON rea_externalLabDataGas table [dataframe]
#' @param rea_widthFieldData This dataframe contains the data for the NEON rea_widthFieldData table [dataframe]
#' @param dsc_fieldData This dataframe contains the data for the NEON dsc_fieldData table, optional if there is a dsc_fieldDataADCP table [dataframe]
#' @param dsc_individualFieldData This dataframe contains the data for the NEON dsc_individualFieldData table, optional [dataframe]
#' @param dsc_fieldDataADCP This dataframe contains the data for the NEON dsc_fieldDataADCP table, optional[dataframe]

#' @return This function returns one data frame formatted for use with def.calc.reaeration.R

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords surface water, streams, rivers, reaeration, gas transfer velocity, schmidt number

#' @examples
#' #TBD

#' @seealso def.calc.tracerTime.R for calculating the stream travel time,
#' def.plot.reaQcurve.R for plotting reaeration rate versus stream flow

#' @export

# changelog and author contributions / copyrights
#   Kaelin M. Cawley (2017-10-30)
#     original creation
#   Kaelin M. Cawley (2018-05-03)
#     added the option of getting data from the API rather than a file download
#   Kaelin M. Cawley (2020-12-03)
#     updated to allow users to use data already loaded to R since there are so many options
#     of how to get it there now
#   Kaelin M. Cawley
#     Updated to fix a few user bugs (may have been mac specific) and include model injection types
#   Kaelin M. Cawley (2021-06-21)
#     Update to fix a bug with merging model injections
##############################################################################################
def.format.reaeration <- function(
  rea_backgroundFieldCondData,
  rea_backgroundFieldSaltData = NULL,
  rea_fieldData,
  rea_plateauMeasurementFieldData,
  rea_plateauSampleFieldData,
  rea_externalLabDataSalt,
  rea_externalLabDataGas,
  rea_widthFieldData,
  dsc_fieldData = NULL,
  dsc_individualFieldData = NULL,
  dsc_fieldDataADCP = NULL
) {
  
  if(is.null(dsc_fieldData) & is.null(dsc_fieldDataADCP)){
    resp <- readline("Discharge data not loaded or available. Reaeration rates cannot be determined. Do you want to continue to calculate travel time and SF6 loss rate only? y/n: ")
    if(resp %in% c("n","N")) {
      stop("Input data will not be used to make any calculations. Exiting.")
    }
    # if(!(resp %in% c("y","Y"))) {
    #   stop("Input data will not be used to make any calculations. Exiting.")
    # }
  }
  
  #Hopefully I can comment this out in the future when we get a siteID column, but for now, I'll make one
  dsc_fieldDataADCP$siteID <- dsc_fieldDataADCP$stationID
  
  # Pull the timezone for the site(s) for making sure the eventIDs match depending on the time of day, need to convert to local time.
  allSites <- unique(rea_fieldData$siteID)
  
  rea_fieldData$localDate <- NA
  dsc_fieldData$localDate <- NA
  dsc_fieldDataADCP$localDate <- NA
  rea_plateauMeasurementFieldData$localDate <- NA
  rea_backgroundFieldCondData$localDate <- NA
  for(currSite in allSites){
    currLocInfo <- geoNEON::getLocBySite(site = currSite)
    currTimeZone <- as.character(currLocInfo$siteTimezone)
    
    rea_fieldData$localDate[rea_fieldData$siteID == currSite] <- format(rea_fieldData$collectDate, tz = currTimeZone, format = "%Y%m%d")
    dsc_fieldData$localDate[dsc_fieldData$siteID == currSite] <- format(dsc_fieldData$collectDate, tz = currTimeZone, format = "%Y%m%d")
    dsc_fieldDataADCP$localDate[dsc_fieldDataADCP$siteID == currSite] <- format(dsc_fieldDataADCP$endDate, tz = currTimeZone, format = "%Y%m%d")
    rea_plateauMeasurementFieldData$localDate[rea_plateauMeasurementFieldData$siteID == currSite] <- format(rea_plateauMeasurementFieldData$collectDate, tz = currTimeZone, format = "%Y%m%d")
    rea_backgroundFieldCondData$localDate[rea_backgroundFieldCondData$siteID == currSite] <- format(rea_backgroundFieldCondData$startDate, tz = currTimeZone, format = "%Y%m%d")
  }
  
  # Add an eventID for later
  rea_fieldData$eventID <- paste(rea_fieldData$siteID, rea_fieldData$localDate, sep = ".")
  dsc_fieldData$eventID <- paste(dsc_fieldData$siteID, dsc_fieldData$localDate, sep = ".")
  rea_plateauMeasurementFieldData$eventID <- paste(rea_plateauMeasurementFieldData$siteID, rea_plateauMeasurementFieldData$localDate, sep = ".")
  rea_backgroundFieldCondData$eventID <- paste(rea_backgroundFieldCondData$siteID, rea_backgroundFieldCondData$localDate, sep = ".")
  dsc_fieldDataADCP$eventID <- paste(dsc_fieldDataADCP$siteID, dsc_fieldDataADCP$localDate, sep = ".")
  
  rea_fieldData$namedLocation <- NULL #So that merge goes smoothly
  rea_backgroundFieldCondData$collectDate <- rea_backgroundFieldCondData$startDate #Also to smooth merging
  
  # Populate the saltBelowDetectionQF if it isn't there and remove any values with flags of 1
  rea_externalLabDataSalt$saltBelowDetectionQF[is.na(rea_externalLabDataSalt$saltBelowDetectionQF)] <- 0
  rea_externalLabDataSalt$finalConcentration[rea_externalLabDataSalt$saltBelowDetectionQF == 1] <- NA
  ###CHANGE THIS LINE TO 1/2 THE DETECTION LIMIT OR WILL LOSE SAMPLES
  
  #Merge the rea_backgroundFieldSaltData, rea_backgroundFieldCondData, and rea_fieldData tables to handle the model injections
  if(!is.null(rea_backgroundFieldSaltData)){
    loggerSiteData <- merge(rea_backgroundFieldSaltData,
                            rea_fieldData,
                            by = c('siteID', 'collectDate'),
                            all = TRUE)
  }else{
    loggerSiteData <- merge(rea_backgroundFieldCondData,
                            rea_fieldData,
                            by = c('siteID', 'collectDate'),
                            all = TRUE)
  }
  
  #Add in station if it's missing for a model injectionType- so this is assuming station = namedLocation
  missingStations <- loggerSiteData$eventID[which(is.na(loggerSiteData$namedLocation))]
  if(length(missingStations) > 0){
    loggerSiteData <- merge(loggerSiteData,
                            rea_backgroundFieldCondData[rea_backgroundFieldCondData$eventID %in% missingStations,],
                            by = c("siteID","collectDate"),
                            all = TRUE)
    loggerSiteData$namedLocation <- loggerSiteData$namedLocation.x
    loggerSiteData$namedLocation[is.na(loggerSiteData$namedLocation.x)] <- loggerSiteData$namedLocation.y[is.na(loggerSiteData$namedLocation.x)]
    
    #Add back in a few variables that got messed up with the bonus merge step
    loggerSiteData$stationToInjectionDistance <- loggerSiteData$stationToInjectionDistance.x
    loggerSiteData$eventID <- loggerSiteData$eventID.x
  }
  
  #Add a classification for injectate, background, or plateau type to external lab data sheet
  rea_externalLabDataSalt$sampleType <- NA
  rea_externalLabDataSalt$sampleType[rea_externalLabDataSalt$saltSampleID %in% rea_fieldData$injectateSampleID] <- "injectate"
  rea_externalLabDataSalt$sampleType[rea_externalLabDataSalt$saltSampleID %in% rea_backgroundFieldSaltData$saltBackgroundSampleID] <- "background"
  rea_externalLabDataSalt$sampleType[rea_externalLabDataSalt$saltSampleID %in% rea_plateauSampleFieldData$saltTracerSampleID] <- "plateau"
  
#one line per station with individual background salt measurements and then mean plateau measurements 
  #(and individual parsed with | within lines)
  #would like just a full file to work with
  #either need to parse this or change Kaelin's code where she compresses?        
  
  
  #Create input file for reaeration calculations
  outputDFNames <- c(
    'siteID',
    'namedLocation', #Station at this point
    'collectDate',
    'stationToInjectionDistance',
    'injectionType',
    'slugTracerMass',
    'slugPourTime',
    'dripStartTime',
    'backgroundSaltConc',
    'plateauSaltConc',
    'meanPlatSaltConc',
    'plateauGasConc',
    'meanPlatGasConc',
    'wettedWidth',
    'waterTemp',
    'hoboSampleID',
    'fieldDischarge',
    'eventID'
  )
  outputDF <- data.frame(matrix(data=NA, ncol=length(outputDFNames), nrow=length(loggerSiteData$siteID)))
  names(outputDF) <- outputDFNames
  
  #Fill in the fields from the loggerSiteData table
  for(i in seq(along = names(outputDF))){
    if(names(outputDF)[i] %in% names(loggerSiteData)){
      outputDF[,i] <- loggerSiteData[,which(names(loggerSiteData) == names(outputDF)[i])]
    }
  }
  
  # #Remove data for model type injections since we can't get k values from those anyway
  # modelInjectionTypes <- c("model","model - slug","model - CRI")
  # outputDF <- outputDF[!outputDF$injectionType%in%modelInjectionTypes & !is.na(outputDF$injectionType),]
  
  #Recalculate wading survey discharge using the stageQCurve package and then add to the output dataframe
  dsc_fieldData_calc <- stageQCurve::conv.calc.Q(stageData = dsc_fieldData,
                                                 dischargeData = dsc_individualFieldData)
  
  #Populate Q from wading surveys
  for(i in unique(outputDF$eventID)){
    #print(i)
    currQ <- dsc_fieldData_calc$calcQ[dsc_fieldData_calc$eventID == i]
    try(outputDF$fieldDischarge[outputDF$eventID == i] <- currQ, silent = T)
  }
  
  #Populate Q from ADCP data, if applicable
  #why is Q not coming from the salt releases?
  
  for(i in unique(outputDF$eventID)){
    #print(i)
    currQ <- dsc_fieldDataADCP$totalDischarge[dsc_fieldDataADCP$eventID == i]
    try(outputDF$fieldDischarge[outputDF$eventID == i] <- currQ, silent = T)
  }
  
  #Loop through all the records to populate the other fields
  for(i in seq(along = outputDF$siteID)){
    siteID <- outputDF$siteID[i]
    startDate <- outputDF$collectDate[i]
    station <- outputDF$namedLocation[i]
    stationType <- substr(station, 6, nchar(station))
    
    #Fill in hoboSampleID from background logger table
    try(outputDF$hoboSampleID[i] <- rea_backgroundFieldCondData$hoboSampleID[
      rea_backgroundFieldCondData$namedLocation == station &
        rea_backgroundFieldCondData$startDate == startDate], silent = T)
    
    #Fill in background concentration data
    try(outputDF$backgroundSaltConc[i] <- rea_externalLabDataSalt$finalConcentration[
      rea_externalLabDataSalt$namedLocation == station &
        rea_externalLabDataSalt$startDate == startDate &
        rea_externalLabDataSalt$sampleType == "background"], silent = T)
    
    ##okay all this is the problem. don't want to concatenate.  will need to do a merge later. 
    #maybe go ahead with this script to just print the output table for Kaelin calculations with whatever minor edits
    #that I want to add, but after the print, do a merge between her output DF and the inputs so that there are repeats 
    #per row
    
    #Fill in plateau concentration data for constant rate injection
    # Need to join with the field data rather than use the sampleID since we're switching to barcodes only
    pSaltConc <- rea_externalLabDataSalt$finalConcentration[
      rea_externalLabDataSalt$namedLocation == station &
        rea_externalLabDataSalt$startDate == startDate &
        rea_externalLabDataSalt$sampleType == "plateau"]
    
    #Calculate a mean concentration for plateau salt
    outputDF$meanPlatSaltConc[i] <- mean(pSaltConc, na.rm = TRUE)
    
    #Concatenate all values for plotting and assessment
    outputDF$plateauSaltConc[i] <- paste(pSaltConc, collapse = "|")
    
    #Fill in plateau gas concentration
    pGasConc <- rea_externalLabDataGas$gasTracerConcentration[
      rea_externalLabDataGas$namedLocation == station &
        rea_externalLabDataGas$startDate == startDate]
    
    #Calculate a mean concentration for plateau salt
    outputDF$meanPlatGasConc[i] <- mean(pGasConc, na.rm = TRUE)
    
    #Concatenate all values for plotting and assessment
    outputDF$plateauGasConc[i] <- paste(pGasConc, collapse = "|")
    
    #Fill in mean wetted width
    wettedWidthVals <- rea_widthFieldData$wettedWidth[
      rea_widthFieldData$namedLocation == siteID &
        grepl(substr(startDate, 1, 10), rea_widthFieldData$collectDate)]
    
    #Remove outliers TBD
    #Calculate the mean wetted width
    outputDF$wettedWidth[i] <- ifelse(!is.nan(mean(wettedWidthVals, na.rm = T)),mean(wettedWidthVals, na.rm = T),NA)
    
    #Populate water temp
    suppressWarnings(try(outputDF$waterTemp[i] <- rea_plateauMeasurementFieldData$waterTemp[rea_plateauMeasurementFieldData$namedLocation == station &
                                                                                              rea_plateauMeasurementFieldData$eventID == outputDF$eventID[i]], silent = TRUE))
    
  }
  
  #Remove any rows where injectionType is missing
  outputDF <- outputDF[!is.na(outputDF$injectionType),]
  
  return(outputDF)
  
}
