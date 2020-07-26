# MRP-Project
### Major Research Project 2020

The purpose of this project is to use an LDA topic model with LASSO regression to predict changes in trading volumes in the S&P500 index. The data used in this project is the larger version of the "All the News" dataset from Kaggle. This dataset contains news from various sources between January 2016 and April 2020.

### Datasets
The datasets for cross-validation and testing are contained in the "Datasets" folder in compressed zip files.
To run the code, extract the folder within the zip file and change the filepath in the code accordingly

### Code

#### Data Exploration
- <b>Data Exploration - NLP Clean.ipynb</b> contains the code used for the data exploration of the "All the News" dataset
- <b>Data Exploration - Financial.ipynb</b> contains the code used for the data exploration of the S&P500 daily trading volumes data. It was also used to generate the train/test sets for cross-validation and testing

#### Models
- <b>ARMA-GARCH forecast.R</b> was used to create the ARMA-GARCH model and generate the time series predictions. This code was also used to identify the peak days.
- <b>Topic Model - Final.ipynb</b> contains the code used to create the topic model and LASSO regression model
- <b>LASSO Regression - Results.ipynb</b> was used for the 5-fold cross-validation. It also contains the results/plots of the final model on 3 test datasets
