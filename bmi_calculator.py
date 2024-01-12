# BMI Calculator
# # BMI = (weight in pounds * 703)/(height in inches * height in inches)

# Function to calculate BMI
def bmi (weight, height_inches):
    bmi = round((weight * 703)/(height_inches*height_inches), 1)
    print('Your BMI is: ', bmi)
    if bmi > 0:
        if bmi < 18.5:
            print ("You are under-weight with minimal health risk")
        elif bmi >= 18.8 and bmi <= 24.9:
            print ("You have normal weight with minimal health risk")
        elif bmi >= 25 and bmi <= 29.9:
            print ("You are over-weight with increased health risk")
        elif bmi >= 30 and bmi <= 34.9:
            print ("You are obese with minimal high risk")
        elif bmi >= 35 and bmi <= 39.9:
            print ("You are severly-obese with very high health risk")
        elif 40 <= bmi:
            print ("You are morbidly-obese with extremely high health risk")
    else:
        print('Your bmi is out of range!!')

# Collect user input and display BMI with description
weight = int(input('Please enter your weight: '))
height_inches = int(input('Please enter your height: '))
bmi(weight, height_inches)