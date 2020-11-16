# Explore bike data to see if there is relationship between weather and ridership.

library(tidyverse)

df <- read_csv("data/daily_bike_data.csv")

df

ggplot(df) +
  geom_line(aes(x = as.Date(dteday), y = cnt))

##You can specificy data set in each individual layer so you can pull layers from multiple data sets.

ggplot(data = df, aes( x= temp, y= cnt))+
  geom_point() +
  geom_smooth()

#What is weather sit variable? Looks like  a categorical variable, we went to source
#nots and found the weather categories.
summary(df$weathersit)
unique(df$weathersit)

#Then use dplyr to transform this variable

df2 <- df %>%
    dplyr::mutate(
      weather_fac = factor(weathersit,
                           levels=c(1,2,3,4),
                           labels=c("Clear", "Cloudy", "Rainy", "Heavy Rain"))
    )

#Then we can use dplyr to select the specific columns we're interested in
#Select function selects columsn filter selects rows.
df2 %>% 
 dplyr::select(dteday, weathersit, weather_fac)

df2 %>%
  dplyr::filter(weather_fac == "Rainy") %>%
  ggplot(aes(x= temp, y= cnt))+
  geom_point()+
  geom_smooth()

## Notes ##
#for dplyr::select you can use the negative and drop variables

df3 <- df2 %>%
  dplyr::select(-weathersit)

#can also use select to make character lists
keep_vars <- c("dteday", "weather_fac", "temp", "cnt")

df4 <- df2 %>% 
  select( all_of(keep_vars))

#other ways of filters
df2 %>% dplyr::filter(weather_fac %in% c("Rainy", "Cloudy"))
df2 %>% dplyr::filter(!(weather_fac  %in% c("Rainy", "Cloudy")))

#Also summarize, dplyr::summarize function, lets you create a new variable based on the output
df2 %>%
  dplyr::group_by(season, weather_fac) %>%
  dplyr::summarize(
    cnt_mean = mean(cnt)
  )

 ### Transforming data format from long to wide or vice-versa, 
#Transform our tidy data frame to a wide form, separate temp variable columsn for each month

df_wide <- df2 %>%
  dplyr::select(mnth, temp, season)%>%
  dplyr::group_by(mnth, season)%>%
  dplyr::summarize(temp_mean=mean(temp))%>%
  dplyr::select(-season)%>%
  tidyr::pivot_wider(names_prefix= "temp_", names_from= mnth, values_from= temp)

##Still issues with pivoting because we have two records in same months, so add in year
months <-c( "January", "February",  "March", "April" ,"May"      
            ,"June", "July", "August", "September", "October"   
            ,"November", "December")
df_wide <- df2 %>%
  dplyr::mutate(mnth=factor(mnth,levels=months,labels=months))%>%
  dplyr::rename(year=yr)%>%
  dplyr::select(year, mnth, temp)%>%
  dplyr::group_by(year, mnth)%>%
  dplyr::summarize(temp_mean=mean(temp))%>%
  tidyr::pivot_wider(names_prefix= "temp_", names_from= mnth, values_from= temp_mean)

##Pivoting Longer

df_long <- df2 %>%
  tidyr::pivot_longer(cols=c(temp, atemp, hum, windspeed),
                      values_to="value", names_to = "variable")

##and then you can use pivot_wider to go back

df_wide2 <- df_long %>%
  tidyr::pivot_wider(names_prefix="v_", names_from= variable, values_from=value)

## Another example with smaller subset of data

df%>%
  group_by(weekday) %>%
  summarize (mean_temp =mean(temp))%>%
  pivot_wider(names_from = weekday, 
              values_from=mean_temp)


## Plotting with long form data and or facet wraps

ggplot(data=df2, aes(temp,cnt))+
  geom_point(shape=21, color="orangered")+
  geom_smooth(method="lm", formula= y~poly(x,2), color="steelblue", se= FALSE)+
  facet_wrap(~weather_fac, scales="free_y")+
  labs(x="Temperature", y= "Ridership Count")+
  ggtitle("Relationship Between Temp and Ridership")+
  theme_linedraw()


