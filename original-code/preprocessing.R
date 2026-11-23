
coupon<-read.csv("/Users/fredrickosei/Documents/spring 2024/STAT 502/project/STAT 502/coupon.csv")
#coupon$age<-as.numeric(coupon$age)

#####NA
coupon[coupon==""]<-NA

################### function to replace  empty cells with random imputation
replace_missing_with_random <- function(x) {
  missing_indices <- which(is.na(x))
  non_missing_values <- x[which(!is.na(x))]
  x[missing_indices] <- sample(non_missing_values, length(missing_indices), replace = TRUE)
  return(x)
}


# Loop through each column of the data frame and apply the function
for (i in 1:26) {
  coupon[[i]] <- replace_missing_with_random(coupon[[i]])
}


#### Age
# Replace "50plus" with 70 and "below21" with 18
coupon$age <- ifelse(coupon$age == "50plus", 70, ifelse(coupon$age == "below21", 18, as.numeric(coupon$age)))

############# income
#$100000 or More, Less than $12500
coupon$income <- ifelse(coupon$income == "$100000 or More", "$100000 - $500000", 
                        ifelse(coupon$income == "Less than $12500", "$500 - $12500", as.character(coupon$income)))

# Function to extract numbers from the income string
library(stringr)
extract_numbers <- function(income_str) {
  numbers <- as.numeric(unlist(str_extract_all(income_str, "\\d+")))
  return(numbers)
}

# Replace the income values with the mean of the two numbers
coupon$income <- sapply(coupon$income, function(x) {
  numbers <- extract_numbers(x)
  mean(numbers)
})


########### Extract Y
Y<-coupon[,26]
Y<-factor(Y,levels = c(0,1),labels = c("no","yes"))
coupon<-coupon[,-26]

#### extract numeric variables
num.data<-coupon[,c(4,9,11,14,21,22,23,24,25)]
coupon<-coupon[,-c(4,9,11,14,21,22,23,24,25)]


#### convert all num.data columns to numeric
num.data1 <- as.data.frame(lapply(num.data, as.numeric))

### do onehot encoding of the categorical variables. 
encoded_data <- model.matrix(~ . - 1, coupon)
encoded_data<-as.data.frame(encoded_data)



######## final data
coupon.dat<-cbind(encoded_data,num.data1,Y)
#####removing constant column
coupon.dat<-coupon.dat[,-80]

write.csv(coupon.dat,"preprocesseddata.csv")
str(coupon.dat) #check structure



###### train and Test set
set.seed(42)
train_indices <- sample(nrow(coupon.dat), 0.7 * nrow(coupon.dat))
train_set <- coupon.dat[train_indices, ]
test_set <- coupon.dat[-train_indices, ]



