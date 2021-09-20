## bash script to run all components of forecasts
# Change the working directory to this folder (r_code)


# Comment out this line if your data is up-to-date
# This file could be updated to only download NEW data
# Currently it downloads all data until TODAY
Rscript update_JHU_data.R


cd /Applications/MATLAB_R2021a.app/bin
##  ./matlab -nojvm -nosplash -nodisplay 

./matlab -nosplash -nodisplay -r "cd /Users/hannah.biegel/Dropbox/Research-Materials-Hannah/covid_related/HRB_COVID_code; mainEpiCovDA; quit"
