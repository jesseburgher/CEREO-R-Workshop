###
#Get Bike Data from the Workshop Googledrive and save it in our data folder

download.file(
  url= "https://drive.google.com/file/d/1kfmFupf81DtW9cMU1VhoUfkjBtfoyvKW/view?usp=sharing",
  destfile="data/daily_bike_data.csv"
)

#May seem silly you make full script for little step 
#but then this is reproducible especially if you host data online.